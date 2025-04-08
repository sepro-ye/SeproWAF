package proxy

import (
	"bytes"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"sync"

	"github.com/beego/beego/v2/core/logs"
	"github.com/beego/beego/v2/server/web"
	"github.com/corazawaf/coraza/v3"
)

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

// loadRules loads the Coraza rules and creates a WAF instance
func (wm *WAFManager) loadRules() (coraza.WAF, error) {
	// Try to get rules directory from config
	rulesDir, err := web.AppConfig.String("WAFRulesDir")
	if err != nil || rulesDir == "" {
		// Default to a 'rules' directory in the application root
		rulesDir = "rules"
	}

	// Make sure rules directory exists
	if _, err := os.Stat(rulesDir); os.IsNotExist(err) {
		logs.Warning("WAF rules directory %s does not exist, creating it", rulesDir)
		if err := os.MkdirAll(rulesDir, 0755); err != nil {
			return nil, fmt.Errorf("failed to create rules directory: %v", err)
		}
	}

	// Create default configuration file if it doesn't exist
	configFile := filepath.Join(rulesDir, "coraza.conf")
	if _, err := os.Stat(configFile); os.IsNotExist(err) {
		logs.Info("Creating default Coraza configuration file at %s", configFile)
		err = os.WriteFile(configFile, []byte(`# Default Coraza WAF configuration
SecRuleEngine On
SecRequestBodyAccess On
SecResponseBodyAccess On
SecRequestBodyLimit 10485760
SecRequestBodyNoFilesLimit 131072
SecResponseBodyLimit 10485760
SecResponseBodyMimeType text/plain text/html text/xml application/json
SecDefaultAction "phase:1,log,auditlog,deny,status:403"
SecCollectionTimeout 600

# Basic rules
SecRule REQUEST_URI "@contains /admin" "id:1000,phase:1,deny,log,msg:'Admin access attempt'"
SecRule REQUEST_HEADERS:User-Agent "@contains sqlmap" "id:1001,phase:1,deny,log,msg:'SQL injection tool detected'"
SecRule ARGS "@rx (<script>|SELECT.+FROM|INSERT.+INTO)" "id:1002,phase:2,deny,log,msg:'Potential XSS or SQL injection'"

# Uncomment below to include CRS rules if available
# Include @pm crs-setup.conf
# Include @pm coreruleset/*.conf
`), 0644)
		if err != nil {
			logs.Warning("Failed to create default Coraza config: %v", err)
		}
	}

	cfg := coraza.NewWAFConfig().WithDirectivesFromFile(rulesDir + "coraza.conf").WithDirectivesFromFile(rulesDir + "coreruleset/crs-setup.conf.example").WithDirectivesFromFile(rulesDir + "coreruleset/rules/*.conf")

	waf, err := coraza.NewWAF(cfg)
	if err != nil {
		return nil, fmt.Errorf("failed to create WAF instance: %v", err)
	}

	return waf, nil
}

// GetWAF gets or creates a WAF instance for a site
func (wm *WAFManager) GetWAF(siteID int) (coraza.WAF, error) {
	wm.mutex.RLock()
	waf, exists := wm.wafInstances[siteID]
	wm.mutex.RUnlock()

	if exists {
		return waf, nil
	}

	// Create a new WAF instance
	waf, err := wm.loadRules()
	if err != nil {
		return nil, fmt.Errorf("failed to create WAF instance: %v", err)
	}

	// Store the WAF instance
	wm.mutex.Lock()
	wm.wafInstances[siteID] = waf
	wm.mutex.Unlock()

	logs.Info("Created new WAF instance for site ID %d", siteID)
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
			http.Error(w, "Forbidden", intervention.Status)
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
					http.Error(w, "Forbidden", http.StatusForbidden)
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
			http.Error(w, "Forbidden", intervention.Status)
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
