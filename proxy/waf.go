package proxy

import (
	"bytes"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"SeproWAF/models"
	"SeproWAF/services"

	"github.com/beego/beego/v2/client/orm"
	"github.com/beego/beego/v2/core/logs"
	"github.com/beego/beego/v2/server/web"
	"github.com/corazawaf/coraza/v3"
)

var (
	ruleGenerator *services.RuleGenerator
	ruleVersions  map[int]int64
	ruleMutex     sync.RWMutex
)

func init() {
	ruleGenerator = services.NewRuleGenerator()
	ruleVersions = make(map[int]int64)
}

// WAFManager manages Coraza WAF instances for each site
type WAFManager struct {
	wafInstances map[int]coraza.WAF
	mutex        sync.RWMutex
}

// NewWAFManager creates a new WAF manager
func NewWAFManager() (*WAFManager, error) {
	manager := &WAFManager{
		wafInstances: make(map[int]coraza.WAF),
		mutex:        sync.RWMutex{},
	}

	return manager, nil
}

// GenerateCustomRulesFile generates a file containing all custom rules for a site
func (wm *WAFManager) GenerateCustomRulesFile(siteID int) (string, error) {
	// Get rules directory
	rulesDir, err := web.AppConfig.String("WAFRulesDir")
	if err != nil || rulesDir == "" {
		rulesDir = "rules"
	}

	// Create site-specific directory if it doesn't exist
	siteDir := filepath.Join(rulesDir, fmt.Sprintf("site_%d", siteID))
	if err := os.MkdirAll(siteDir, 0755); err != nil {
		return "", fmt.Errorf("failed to create site directory: %v", err)
	}

	// Get active rules for this site
	rules, err := models.GetActiveWAFRules(siteID)
	if err != nil {
		return "", fmt.Errorf("failed to get active rules: %v", err)
	}

	// Generate rules file content
	content := fmt.Sprintf("# Custom WAF rules for site %d\n", siteID)
	content += "# Generated at " + time.Now().Format(time.RFC3339) + "\n\n"

	for _, rule := range rules {
		ruleText, err := ruleGenerator.GenerateRule(rule)
		if err != nil {
			logs.Warning("Failed to generate rule %d: %v", rule.ID, err)
			continue
		}

		content += fmt.Sprintf("# Rule ID: %d - %s\n", rule.ID, rule.Name)
		content += ruleText + "\n\n"
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
	ruleMutex.RLock()
	currentVersion, exists := ruleVersions[siteID]
	ruleMutex.RUnlock()

	if !exists {
		return true
	}

	// Check if any rules have been updated since the last version
	o := orm.NewOrm()
	count, err := o.QueryTable(new(models.WAFRule)).
		Filter("site_id", siteID).
		Filter("updated_at__gt", time.Unix(0, currentVersion)).
		Count()

	if err != nil {
		logs.Warning("Failed to check for rule updates: %v", err)
		return true
	}

	return count > 0
}

// ReloadWAF reloads the WAF instance for a site
func (wm *WAFManager) ReloadWAF(siteID int) error {
	wm.mutex.Lock()
	defer wm.mutex.Unlock()

	// Remove the current WAF instance
	delete(wm.wafInstances, siteID)

	logs.Info("WAF instance for site %d removed, will be reloaded on next request", siteID)
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

		logs.Info("Created new WAF instance with custom rules for site ID %d", siteID)
		return newWaf, nil
	}

	return waf, nil
}

// WAFHandler creates an HTTP handler with WAF protection
func (wm *WAFManager) WAFHandler(next http.Handler, siteID int, siteDomain string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Debug logging for every incoming request
		logs.Debug("WAF processing request: %s %s from %s", r.Method, r.URL.String(), r.RemoteAddr)

		// Get WAF instance for this site
		waf, err := wm.GetWAF(siteID)
		if err != nil {
			logs.Error("Failed to get WAF instance for site %d: %v", siteID, err)
			logs.Debug("WAF BYPASSED: Request processing continues without WAF")
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
		logs.Debug("WAF processing request headers")
		tx.ProcessRequestHeaders()

		// Check early interruption after header processing
		if intervention := tx.Interruption(); intervention != nil {
			logs.Warning("WAF blocked request to %s during header processing: %s (status: %d)",
				siteDomain, intervention.Action, intervention.Status)

			// Use error template instead of basic HTTP error
			serveWAFErrorPage(w, "Request Blocked", intervention.Status,
				"The WAF has blocked this request due to a security violation")
			return
		}

		// Process request body if available
		if r.Body != nil && r.ContentLength > 0 {
			logs.Debug("WAF processing request body (%d bytes)", r.ContentLength)
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

					// Use error template instead of basic HTTP error
					serveWAFErrorPage(w, "Request Blocked", http.StatusForbidden,
						"The WAF has blocked this request due to a security violation in the body content")
					return
				}
			}
		}

		// Process request body phase
		tx.ProcessRequestBody()

		// Check if the request should be blocked after body processing
		if intervention := tx.Interruption(); intervention != nil {
			logs.Warning("WAF blocked request to %s after body processing: %s (status: %d)",
				siteDomain, intervention.Action, intervention.Status)

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
		logs.Debug("WAF processing response headers")
		for key, values := range rww.Header() {
			for _, value := range values {
				tx.AddResponseHeader(key, value)
			}
		}
		tx.ProcessResponseHeaders(rww.statusCode, rww.proto)

		// Process response body
		if len(rww.body) > 0 {
			logs.Debug("WAF processing response body (%d bytes)", len(rww.body))
			interrupt, _, err := tx.WriteResponseBody(rww.body)
			if err != nil {
				logs.Error("WAF response body processing error: %v", err)
			} else if interrupt != nil {
				logs.Warning("WAF blocked response from %s during body processing", siteDomain)
				http.Error(w, "Forbidden", http.StatusForbidden)
				return
			}

			// Process response body phase
			tx.ProcessResponseBody()
		}

		// Check if the response should be blocked
		if intervention := tx.Interruption(); intervention != nil {
			logs.Warning("WAF blocked response from %s: %s", siteDomain, intervention.Action)
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

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
