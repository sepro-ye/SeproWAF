package proxy

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	db "SeproWAF/database"
	"SeproWAF/models"
	"SeproWAF/services"

	"github.com/beego/beego/v2/core/logs"
	"github.com/beego/beego/v2/server/web"
	"github.com/corazawaf/coraza/v3"
)

var (
	ruleGenerator     *services.RuleGenerator
	ruleVersions      map[int]int64
	ruleMutex         sync.RWMutex
	wafLogService     *services.WAFLogService
	ruleDbMutex       sync.Mutex
	ruleCheckInterval               = 15 * time.Minute // Check less frequently
	ruleDbTryLock     chan struct{} = make(chan struct{}, 1)
	lastRuleCheck                   = make(map[int]time.Time)
	ruleCheckMutex    sync.RWMutex
)

func init() {
	ruleGenerator = services.NewRuleGenerator()
	ruleVersions = make(map[int]int64)

	// Initialize the WAF log service
	// Get config values from app.conf if available
	bufferSize, _ := web.AppConfig.Int("WAFLogBufferSize")
	if bufferSize <= 0 {
		bufferSize = 100
	}

	logDetails, _ := web.AppConfig.Bool("WAFLogDetails")
	retention, _ := web.AppConfig.Int("WAFLogRetention")
	if retention <= 0 {
		retention = 30
	}

	wafLogService = services.NewWAFLogService(bufferSize, logDetails, retention)

	// Initialize the try lock channel
	ruleDbTryLock <- struct{}{}

	// Add a background cleanup for the cache
	go func() {
		ticker := time.NewTicker(10 * time.Minute)
		defer ticker.Stop()

		for range ticker.C {
			now := time.Now()
			wafDecisionCacheMutex.Lock()

			// Clean expired entries
			for key, value := range wafDecisionCache {
				if now.Sub(value.timestamp) > wafCacheTTL {
					delete(wafDecisionCache, key)
				}
			}

			wafDecisionCacheMutex.Unlock()
		}
	}()
}

// WAFManager manages Coraza WAF instances for each site
type WAFManager struct {
	wafInstances map[int]coraza.WAF
	mutex        sync.RWMutex
	shutdownCh   chan struct{}
}

// NewWAFManager creates a new WAF manager
func NewWAFManager() (*WAFManager, error) {
	manager := &WAFManager{
		wafInstances: make(map[int]coraza.WAF),
		mutex:        sync.RWMutex{},
		shutdownCh:   make(chan struct{}),
	}

	// Start the rule update checker in a goroutine
	go manager.StartRuleUpdateChecker(manager.shutdownCh)

	return manager, nil
}

// GenerateCustomRulesFile generates a file containing all custom rules for a site
func (wm *WAFManager) GenerateCustomRulesFile(siteID int) (string, error) {
	// Use a mutex to prevent concurrent rule generation for the same site
	ruleDbMutex.Lock()
	defer ruleDbMutex.Unlock()

	// Get rules directory
	rulesDir, err := web.AppConfig.String("WAFRulesDir")
	if err != nil || rulesDir == "" {
		rulesDir = "rules"
	}

	// Create site-specific directory if it doesn't exist
	siteDir := filepath.Join(rulesDir, fmt.Sprintf("site_%d", siteID))
	if err := os.MkdirAll(siteDir, 0755); err != nil {
		return "", fmt.Errorf("failed to create rules directory: %v", err)
	}

	// Use connection from pool
	o := db.GetPool().GetOrm()

	// Get active rules for this site with a timeout context
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var rules []*models.WAFRule
	_, err = o.QueryTable(new(models.WAFRule)).
		Filter("status", models.RuleStatusActive).
		Filter("site_id__in", []int{0, siteID}).
		OrderBy("priority").
		AllWithCtx(ctx, &rules)

	if err != nil {
		return "", fmt.Errorf("failed to get active rules: %v", err)
	}

	// Generate rules file content
	content := fmt.Sprintf("# Custom WAF rules for site %d\n", siteID)
	content += "# Generated at " + time.Now().Format(time.RFC3339) + "\n\n"

	for _, rule := range rules {
		content += rule.RuleText + "\n\n"
	}

	// Write rules to file
	rulesFile := filepath.Join(siteDir, "custom_rules.conf")
	if err := os.WriteFile(rulesFile, []byte(content), 0644); err != nil {
		return "", fmt.Errorf("failed to write rules file: %v", err)
	}

	// Update rule version
	ruleMutex.Lock()
	ruleVersions[siteID] = time.Now().UnixNano()
	ruleMutex.Unlock()

	return rulesFile, nil
}

// LoadRulesWithCustomRules loads all rules including custom rules for a site
func (wm *WAFManager) LoadRulesWithCustomRules(siteID int) (coraza.WAF, error) {
	// Try to get rules directory from config
	rulesDir, err := web.AppConfig.String("WAFRulesDir")
	if err != nil || rulesDir == "" {
		rulesDir = "rules"
	}

	// Generate custom rules file
	customRulesFile, err := wm.GenerateCustomRulesFile(siteID)
	if err != nil {
		logs.Warning("Failed to generate custom rules: %v", err)
		// Continue without custom rules
	}

	// Create WAF configuration
	cfg := coraza.NewWAFConfig().
		WithDirectivesFromFile(filepath.Join(rulesDir, "coraza.conf"))

	// Add custom rules if available
	if customRulesFile != "" {
		cfg = cfg.WithDirectivesFromFile(customRulesFile)
	}

	// Add CRS rules
	cfg = cfg.WithDirectivesFromFile(filepath.Join(rulesDir, "coreruleset", "crs-setup.conf.example")).
		WithDirectivesFromFile(filepath.Join(rulesDir, "coreruleset", "rules", "*.conf"))

	// Create WAF instance
	waf, err := coraza.NewWAF(cfg)
	if err != nil {
		return nil, fmt.Errorf("failed to create WAF instance: %v", err)
	}

	return waf, nil
}

// RulesNeedReload checks if rules for a site need to be reloaded
func (wm *WAFManager) RulesNeedReload(siteID int) bool {
	// Check cache first to avoid excessive DB calls
	ruleCheckMutex.RLock()
	lastCheck, exists := lastRuleCheck[siteID]
	ruleCheckMutex.RUnlock()

	// Only check database once per minute at most
	if exists && time.Since(lastCheck) < time.Minute {
		return false
	}

	ruleMutex.RLock()
	currentVersion, exists := ruleVersions[siteID]
	ruleMutex.RUnlock()

	if !exists {
		return true
	}

	// Update last check time
	ruleCheckMutex.Lock()
	lastRuleCheck[siteID] = time.Now()
	ruleCheckMutex.Unlock()

	// Run this in a background goroutine to not block requests
	go func() {
		// Only lock for database access
		ruleDbMutex.Lock()
		defer ruleDbMutex.Unlock()

		o := db.GetPool().GetOrm()
		count, err := o.QueryTable(new(models.WAFRule)).
			Filter("site_id__in", []int{0, siteID}).
			Filter("updated_at__gt", time.Unix(0, currentVersion)).
			Count()

		if err != nil {
			logs.Warning("Failed to check for rule updates: %v", err)
			return
		}

		if count > 0 {
			// Queue reload in background
			go wm.ReloadWAF(siteID)
		}
	}()

	return false // Never block the request path
}

// ReloadWAF reloads the WAF instance for a site
func (wm *WAFManager) ReloadWAF(siteID int) error {
	wm.mutex.Lock()
	defer wm.mutex.Unlock()

	// Load a new WAF instance with updated rules
	waf, err := wm.LoadRulesWithCustomRules(siteID)
	if err != nil {
		return fmt.Errorf("failed to reload WAF rules: %v", err)
	}

	// Update the WAF instance in the map
	wm.wafInstances[siteID] = waf

	// Update rule version timestamp
	ruleMutex.Lock()
	ruleVersions[siteID] = time.Now().UnixNano()
	ruleMutex.Unlock()

	return nil
}

// GetWAF gets or creates a WAF instance for a site
func (wm *WAFManager) GetWAF(siteID int) (coraza.WAF, error) {
	wm.mutex.RLock()
	waf, exists := wm.wafInstances[siteID]
	wm.mutex.RUnlock()

	// Check if we need to reload the rules
	needsReload := !exists || wm.RulesNeedReload(siteID)

	if needsReload {
		// Create a new WAF instance with custom rules
		newWaf, err := wm.LoadRulesWithCustomRules(siteID)
		if err != nil {
			return nil, fmt.Errorf("failed to create WAF instance: %v", err)
		}

		// Store the new WAF instance
		wm.mutex.Lock()
		wm.wafInstances[siteID] = newWaf
		wm.mutex.Unlock()

		return newWaf, nil
	}

	return waf, nil
}

// Cache to store previous WAF inspection results
type wafruleCache struct {
	decision  string
	timestamp time.Time
}

var (
	// Simple in-memory cache for identical requests
	wafDecisionCache      = make(map[string]wafruleCache)
	wafDecisionCacheMutex sync.RWMutex
	wafCacheTTL           = 5 * time.Minute
)

// WAFHandler creates an HTTP handler with WAF protection
func (wm *WAFManager) WAFHandler(next http.Handler, siteID int, siteDomain string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Generate a more complete cache key including query parameters
		cacheKey := fmt.Sprintf("%s:%s:%s%s:%s",
			siteDomain,
			r.Method,
			r.URL.Path,
			r.URL.RawQuery, // Include query parameters
			r.RemoteAddr)

		// Check cache for recent identical requests
		wafDecisionCacheMutex.RLock()
		cachedDecision, found := wafDecisionCache[cacheKey]
		wafDecisionCacheMutex.RUnlock()

		if found && time.Since(cachedDecision.timestamp) < wafCacheTTL {
			// We've seen this exact request recently
			if cachedDecision.decision == "blocked" {
				serveWAFErrorPage(w, "Request Blocked", http.StatusForbidden,
					"The WAF has blocked this request due to a security violation")
				return
			}
			// If allowed, continue to next handler
			next.ServeHTTP(w, r)
			return
		}

		// For testing purposes, process all requests through the WAF
		// When in production, you can consider re-enabling sampling
		shouldSample := true // Process all requests

		if !shouldSample {
			// Skip WAF for sampled requests when under heavy load
			next.ServeHTTP(w, r)
			return
		}

		startTime := time.Now()

		// Get WAF instance for this site
		waf, err := wm.GetWAF(siteID)
		if err != nil {
			logs.Error("Failed to get WAF instance for site %d: %v", siteID, err)
			next.ServeHTTP(w, r)
			return
		}

		// Create a transaction
		tx := waf.NewTransaction()
		defer func() {
			// Process logging and close transaction
			tx.ProcessLogging()
			tx.Close()
		}()

		// Process request headers and URL
		tx.ProcessURI(r.URL.String(), r.Method, r.Proto)
		tx.AddRequestHeader("Host", r.Host) // Add host as a header

		// Add remote address header for logging
		if remoteAddr, _, err := net.SplitHostPort(r.RemoteAddr); err == nil {
			tx.AddRequestHeader("X-Real-IP", remoteAddr)
		} else {
			tx.AddRequestHeader("X-Real-IP", r.RemoteAddr)
		}

		// Process request headers
		for name, values := range r.Header {
			for _, value := range values {
				tx.AddRequestHeader(name, value)
			}
		}
		tx.ProcessRequestHeaders()

		// Check early interruption after header processing
		if intervention := tx.Interruption(); intervention != nil {
			logs.Warning("WAF blocked request to %s during header processing: %s (status: %d)",
				siteDomain, intervention.Action, intervention.Status)

			// Log WAF blocking event
			wafLogService.LogWAFEvent(
				tx,
				r,
				"blocked",
				intervention.Status,
				intervention.Status,
				0,
				time.Since(startTime),
				siteID,
				siteDomain,
			)

			// Use error template instead of basic HTTP error
			serveWAFErrorPage(w, "Request Blocked", intervention.Status,
				"The WAF has blocked this request due to a security violation")
			return
		}

		// Process request body if available
		if r.Body != nil && r.ContentLength > 0 {
			bodyBytes, err := io.ReadAll(r.Body)
			if err != nil {
				logs.Error("Failed to read request body for WAF processing: %v", err)
			} else {
				// Create a new ReadCloser for the request body
				r.Body = io.NopCloser(bytes.NewReader(bodyBytes))

				// Process request body by writing it directly to transaction
				interrupt, _, err := tx.WriteRequestBody(bodyBytes)
				if err != nil {
					logs.Error("WAF request body processing error: %v", err)
				} else if interrupt != nil {
					logs.Warning("WAF blocked request to %s during body processing", siteDomain)

					// Log WAF blocking event
					wafLogService.LogWAFEvent(
						tx,
						r,
						"blocked",
						http.StatusForbidden,
						http.StatusForbidden,
						0,
						time.Since(startTime),
						siteID,
						siteDomain,
					)

					// Use error template instead of basic HTTP error
					serveWAFErrorPage(w, "Request Blocked", http.StatusForbidden,
						"The WAF has blocked this request due to a security violation in the body content")
					return
				}
			}
		}

		// Process request body phase
		tx.ProcessRequestBody()

		// Check interruption more verbosely
		if intervention := tx.Interruption(); intervention != nil {
			logs.Warning("WAF blocked request to %s after body processing: %s (status: %d, rule: %d, msg: %s)",
				siteDomain,
				intervention.Action,
				intervention.Status,
				intervention.RuleID,
				intervention.Data)

			// Log WAF blocking event
			wafLogService.LogWAFEvent(
				tx,
				r,
				"blocked",
				intervention.Status,
				intervention.Status,
				0,
				time.Since(startTime),
				siteID,
				siteDomain,
			)

			// Use error template instead of basic HTTP error
			serveWAFErrorPage(w, "Request Blocked", intervention.Status,
				"The WAF has blocked this request due to a security violation")
			return
		}

		// Create a response writer wrapper to capture the response
		rww := newResponseWriterWrapper(w)

		// Call the next handler
		next.ServeHTTP(rww, r)

		// Process response headers
		for key, values := range rww.Header() {
			for _, value := range values {
				tx.AddResponseHeader(key, value)
			}
		}
		tx.ProcessResponseHeaders(rww.statusCode, rww.proto)

		// Process response body
		if len(rww.body) > 0 {
			interrupt, _, err := tx.WriteResponseBody(rww.body)
			if err != nil {
				logs.Error("WAF response body processing error: %v", err)
			} else if interrupt != nil {
				logs.Warning("WAF blocked response from %s during body processing", siteDomain)

				// Log WAF blocking event (response)
				wafLogService.LogWAFEvent(
					tx,
					r,
					"blocked",
					http.StatusForbidden,
					http.StatusForbidden,
					int64(len(rww.body)),
					time.Since(startTime),
					siteID,
					siteDomain,
				)

				http.Error(w, "Forbidden", http.StatusForbidden)
				return
			}

			// Process response body phase
			tx.ProcessResponseBody()
		}

		// Check if the response should be blocked
		if intervention := tx.Interruption(); intervention != nil {
			logs.Warning("WAF blocked response from %s: %s", siteDomain, intervention.Action)

			// Log WAF blocking event (response)
			wafLogService.LogWAFEvent(
				tx,
				r,
				"blocked",
				http.StatusForbidden,
				http.StatusForbidden,
				int64(len(rww.body)),
				time.Since(startTime),
				siteID,
				siteDomain,
			)

			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		// After processing, update cache with decision
		decision := "allowed"
		if intervention := tx.Interruption(); intervention != nil {
			decision = "blocked"
			// Existing blocked request handling
		}

		// Update cache
		wafDecisionCacheMutex.Lock()
		wafDecisionCache[cacheKey] = wafruleCache{
			decision:  decision,
			timestamp: time.Now(),
		}
		wafDecisionCacheMutex.Unlock()

		// Log allowed request
		wafLogService.LogWAFEvent(
			tx,
			r,
			"allowed",
			rww.statusCode,
			0,
			int64(len(rww.body)),
			time.Since(startTime),
			siteID,
			siteDomain,
		)

		// Write the response body if not blocked
		w.Write(rww.body)
	})
}

// serveWAFErrorPage renders a custom WAF block page
func serveWAFErrorPage(w http.ResponseWriter, title string, statusCode int, message string) {
	// Set status code and content type
	w.WriteHeader(statusCode)
	w.Header().Set("Content-Type", "text/html; charset=utf-8")

	// Path to the WAF block page
	blockPagePath := "proxy/waf_block.html"

	// Read the HTML file
	content, err := os.ReadFile(blockPagePath)
	if err != nil {
		// If we can't read the file, fall back to a simple error message
		logs.Error("Failed to read WAF block page: %v", err)
		http.Error(w, "Security alert: This request has been blocked ("+message+")", statusCode)
		return
	}

	// Simple replacement of placeholders in the HTML
	htmlContent := string(content)
	htmlContent = strings.Replace(htmlContent, "{{.ErrorCode}}", fmt.Sprintf("%d", statusCode), -1)
	htmlContent = strings.Replace(htmlContent, "{{.ErrorMessage}}", message, -1)

	// Write the response
	w.Write([]byte(htmlContent))
}

// responseWriterWrapper wraps an http.ResponseWriter to capture the response
type responseWriterWrapper struct {
	http.ResponseWriter
	statusCode int
	proto      string
	body       []byte
}

// newResponseWriterWrapper creates a new response writer wrapper
func newResponseWriterWrapper(w http.ResponseWriter) *responseWriterWrapper {
	return &responseWriterWrapper{
		ResponseWriter: w,
		statusCode:     http.StatusOK,
		proto:          "HTTP/1.1",
	}
}

// WriteHeader captures the status code
func (rww *responseWriterWrapper) WriteHeader(statusCode int) {
	rww.statusCode = statusCode
	rww.ResponseWriter.WriteHeader(statusCode)
}

// Write captures the response body
func (rww *responseWriterWrapper) Write(b []byte) (int, error) {
	rww.body = append(rww.body, b...)
	return len(b), nil
}

// CheckForRuleUpdates checks for rule updates less frequently and reuses connections
func (wm *WAFManager) CheckForRuleUpdates() {
	// Try to acquire the mutex with a timeout, but use a non-blocking approach first
	if !wm.tryLockRuleDb() {
		// Try with timeout
		lockChan := make(chan struct{}, 1)
		go func() {
			if wm.tryLockRuleDb() {
				lockChan <- struct{}{}
			}
		}()

		select {
		case <-lockChan:
			// Successfully acquired the lock
			defer wm.unlockRuleDb()
		case <-time.After(5 * time.Second):
			logs.Warning("Timed out waiting for rule update lock")
			return
		}
	} else {
		// We got the lock on first try
		defer wm.unlockRuleDb()
	}

	// Use connection pool
	o := db.GetPool().GetOrm()

	// Get active sites with a timeout context
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var sites []*models.Site
	_, err := o.QueryTable(new(models.Site)).
		Filter("status", models.SiteStatusActive).
		Filter("waf_enabled", true).
		AllWithCtx(ctx, &sites)

	if err != nil {
		// Check if this is a table not found error
		if strings.Contains(err.Error(), "doesn't exist") {
			logs.Warning("Site table not found, disabling rule updates")
			return
		}
		logs.Warning("Failed to check for rule updates: %v", err)
		return
	}

	// Check each site for rule updates
	for _, site := range sites {
		if wm.RulesNeedReload(site.ID) {
			if err := wm.ReloadWAF(site.ID); err != nil {
				logs.Warning("Failed to reload WAF for site %d: %v", site.ID, err)
			}
		}
	}
}

// StartRuleUpdateChecker starts a periodic rule update checker
func (wm *WAFManager) StartRuleUpdateChecker(shutdownCh chan struct{}) {
	ticker := time.NewTicker(ruleCheckInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			wm.CheckForRuleUpdates()
		case <-shutdownCh:
			return
		}
	}
}

// tryLockRuleDb attempts to acquire the ruleDbMutex lock
func (wm *WAFManager) tryLockRuleDb() bool {
	select {
	case <-ruleDbTryLock:
		ruleDbMutex.Lock()
		return true
	default:
		return false
	}
}

// unlockRuleDb releases the ruleDbMutex lock
func (wm *WAFManager) unlockRuleDb() {
	ruleDbMutex.Unlock()
	ruleDbTryLock <- struct{}{}
}

var (
	wafManagerInstance *WAFManager
	wafManagerOnce     sync.Once
	wafManagerErr      error
)

// GetWAFManager returns the singleton WAF manager instance
func GetWAFManager() (*WAFManager, error) {
	wafManagerOnce.Do(func() {
		wafManagerInstance, wafManagerErr = NewWAFManager()
	})
	return wafManagerInstance, wafManagerErr
}
