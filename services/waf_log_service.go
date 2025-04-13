package services

import (
	"SeproWAF/models"
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/beego/beego/v2/client/orm"
	"github.com/beego/beego/v2/core/logs"
	"github.com/beego/beego/v2/server/web"
	txtype "github.com/corazawaf/coraza/v3/types"
)

// WAFLogService handles logging for WAF events
type WAFLogService struct {
	logChan     chan *WAFLogEntry
	wg          sync.WaitGroup
	shutdown    chan struct{}
	flushTicker *time.Ticker
	buffer      []*WAFLogEntry
	bufferMutex sync.Mutex
	bufferSize  int
	logDetails  bool // Whether to log detailed information like headers and bodies
	retention   int  // Log retention in days
}

// WAFLogEntry represents a log entry to be processed
type WAFLogEntry struct {
	Transaction    txtype.Transaction
	Request        *http.Request
	Response       *http.ResponseWriter
	SiteID         int
	Domain         string
	Action         string
	ProcessingTime int64
	StatusCode     int
	BlockStatus    int
	ResponseSize   int64
	Timestamp      time.Time
}

// NewWAFLogService creates a new WAF logging service
func NewWAFLogService(bufferSize int, logDetails bool, retention int) *WAFLogService {
	if bufferSize <= 0 {
		bufferSize = 100 // Default buffer size
	}

	if retention <= 0 {
		retention = 30 // Default 30 days retention
	}

	service := &WAFLogService{
		logChan:     make(chan *WAFLogEntry, 1000),
		shutdown:    make(chan struct{}),
		flushTicker: time.NewTicker(10 * time.Second),
		buffer:      make([]*WAFLogEntry, 0, bufferSize),
		bufferSize:  bufferSize,
		logDetails:  logDetails,
		retention:   retention,
	}

	// Start background workers
	service.wg.Add(1)
	go service.processLogs()

	service.wg.Add(1)
	go service.runRetentionPolicy()

	return service
}

// LogWAFEvent logs a WAF event asynchronously
func (s *WAFLogService) LogWAFEvent(tx txtype.Transaction, r *http.Request,
	w *http.ResponseWriter, siteID int, domain string, action string,
	processingTime int64, statusCode, blockStatus int, responseSize int64) {

	entry := &WAFLogEntry{
		Transaction:    tx,
		Request:        r,
		Response:       w,
		SiteID:         siteID,
		Domain:         domain,
		Action:         action,
		ProcessingTime: processingTime,
		StatusCode:     statusCode,
		BlockStatus:    blockStatus,
		ResponseSize:   responseSize,
		Timestamp:      time.Now(),
	}

	// Try to send to channel, but don't block if channel is full
	select {
	case s.logChan <- entry:
		// Sent successfully
	default:
		logs.Warning("WAF log channel is full, dropping log entry")
	}
}

// processLogs handles log entries from the channel
func (s *WAFLogService) processLogs() {
	defer s.wg.Done()

	for {
		select {
		case entry := <-s.logChan:
			s.bufferMutex.Lock()
			s.buffer = append(s.buffer, entry)

			// If buffer is full, flush it
			if len(s.buffer) >= s.bufferSize {
				go s.flushLogs(s.buffer)
				s.buffer = make([]*WAFLogEntry, 0, s.bufferSize)
			}
			s.bufferMutex.Unlock()

		case <-s.flushTicker.C:
			s.bufferMutex.Lock()
			if len(s.buffer) > 0 {
				go s.flushLogs(s.buffer)
				s.buffer = make([]*WAFLogEntry, 0, s.bufferSize)
			}
			s.bufferMutex.Unlock()

		case <-s.shutdown:
			// Flush any remaining logs before shutting down
			s.bufferMutex.Lock()
			if len(s.buffer) > 0 {
				s.flushLogs(s.buffer)
			}
			s.bufferMutex.Unlock()
			s.flushTicker.Stop()
			return
		}
	}
}

// flushLogs writes logs to the database
func (s *WAFLogService) flushLogs(entries []*WAFLogEntry) {
	if len(entries) == 0 {
		return
	}

	o := orm.NewOrm()
	tx, err := o.Begin()
	if err != nil {
		logs.Error("Failed to begin transaction for log flush: %v", err)
		return
	}

	for _, entry := range entries {
		log, details := s.createLogObjects(entry)

		// Insert the main log
		_, err := o.Insert(log)
		if err != nil {
			logs.Error("Failed to insert WAF log: %v", err)
			tx.Rollback()
			return
		}

		// Insert details if enabled
		if s.logDetails && len(details) > 0 {
			for _, detail := range details {
				detail.WAFLogID = log.ID
				_, err := o.Insert(detail)
				if err != nil {
					logs.Error("Failed to insert WAF log detail: %v", err)
					// Continue despite errors in details
				}
			}
		}
	}

	err = tx.Commit()
	if err != nil {
		logs.Error("Failed to commit transaction for log flush: %v", err)
		tx.Rollback()
		return
	}

	logs.Info("Successfully flushed %d WAF logs", len(entries))
}

// createLogObjects creates log and detail objects from entry
func (s *WAFLogService) createLogObjects(entry *WAFLogEntry) (*models.WAFLog, []*models.WAFLogDetail) {
	tx := entry.Transaction
	req := entry.Request

	// Extract client IP
	clientIP := req.RemoteAddr
	if ip, _, err := net.SplitHostPort(clientIP); err == nil {
		clientIP = ip
	}

	var matchedRules string
	var ruleMatches []map[string]interface{}
	var severity, category string

	// Track interruption rule ID to avoid duplicates
	var interruptionRuleID int = 0
	var interruptionFound bool = false

	// Process interruption first if available
	interruption := tx.Interruption()
	if interruption != nil {
		interruptionRuleID = interruption.RuleID

		// We'll set default values for severity and category
		severity = "unknown"
		category = "unknown"

		// We'll update these when we process matched rules if we find the rule
		interruptionMatch := map[string]interface{}{
			"id":             interruptionRuleID,
			"message":        interruption.Data,
			"severity":       severity,
			"category":       category,
			"phase":          "unknown",
			"matched_data":   "",
			"variable_name":  "",
			"operator":       interruption.Action,
			"operator_value": "",
			"file":           "",
			"line":           0,
			"match_details":  []map[string]interface{}{},
			"isInterruption": true,
		}
		ruleMatches = append(ruleMatches, interruptionMatch)
	}

	// Process all matched rules
	for _, rule := range tx.MatchedRules() {
		r := rule.Rule()

		// Extract category from tags
		ruleCategory := extractCategoryFromTags(r.Tags())
		ruleSeverity := r.Severity().String()

		// Extract variable matches and rule details for better display
		var matchDetails []map[string]interface{}
		var matchedData, variableName string

		// Extract matched data from the rule if available
		for _, matchData := range rule.MatchedDatas() {
			matchDetails = append(matchDetails, map[string]interface{}{
				"variable": matchData.Variable(),
				"key":      matchData.Key(),
				"value":    matchData.Value(),
				"message":  matchData.Message(),
				"data":     matchData.Data(),
			})

			// Use the first match for summary display
			if matchedData == "" {
				matchedData = matchData.Value()
				variableName = matchData.Variable().Name()
				if matchData.Key() != "" {
					variableName += ":" + matchData.Key()
				}
			}
		}

		// If this is the interruption rule, update our main log severity and category
		if interruption != nil && r.ID() == interruptionRuleID {
			interruptionFound = true
			severity = ruleSeverity
			category = ruleCategory

			// Update the interruption match we added earlier with complete data
			for i, match := range ruleMatches {
				if id, ok := match["id"].(int); ok && id == interruptionRuleID {
					// Use properly expanded rule message
					ruleMatches[i]["message"] = rule.Message()
					ruleMatches[i]["full_rule"] = r.Raw()
					ruleMatches[i]["severity"] = ruleSeverity
					ruleMatches[i]["category"] = ruleCategory
					ruleMatches[i]["phase"] = r.Phase()
					ruleMatches[i]["operator"] = r.Operator()
					ruleMatches[i]["file"] = r.File()
					ruleMatches[i]["line"] = r.Line()
					ruleMatches[i]["revision"] = r.Revision()
					ruleMatches[i]["version"] = r.Version()
					ruleMatches[i]["tags"] = r.Tags()
					ruleMatches[i]["maturity"] = r.Maturity()
					ruleMatches[i]["accuracy"] = r.Accuracy()
					ruleMatches[i]["secmark"] = r.SecMark()
					ruleMatches[i]["data"] = rule.Data()
					ruleMatches[i]["is_disruptive"] = rule.Disruptive()
					// Include matched data info
					ruleMatches[i]["matched_data"] = matchedData
					ruleMatches[i]["variable_name"] = variableName
					ruleMatches[i]["match_details"] = matchDetails
					break
				}
			}
		}

		// Add this rule to matches if it's not the interruption rule we already added
		if interruption == nil || r.ID() != interruptionRuleID || !interruptionFound {
			// Create the full rule display for UI rendering
			fullRuleText := r.Raw()
			// If we have the rule ID, try to format it like ModSecurity rule
			if r.ID() > 0 && fullRuleText == "" {
				fullRuleText = fmt.Sprintf("SecRule %s \"%s\" \"id:%d, phase:%s, %s, severity:%s\"",
					variableName,
					matchedData,
					r.ID(),
					fmt.Sprintf("%v", r.Phase()),
					r.Operator(),
					r.Severity())
			}

			match := map[string]interface{}{
				"id":             r.ID(),
				"message":        rule.Message(), // Use MatchedRule.Message() which is macro-expanded
				"full_rule":      fullRuleText,   // Full rule text for display
				"severity":       ruleSeverity,
				"category":       ruleCategory,
				"phase":          r.Phase(),
				"operator":       r.Operator(),
				"matched_data":   matchedData,
				"variable_name":  variableName,
				"file":           r.File(),
				"line":           r.Line(),
				"revision":       r.Revision(),
				"version":        r.Version(),
				"tags":           r.Tags(),
				"maturity":       r.Maturity(),
				"accuracy":       r.Accuracy(),
				"secmark":        r.SecMark(),
				"match_details":  matchDetails,
				"data":           rule.Data(), // Get expanded log data
				"is_disruptive":  rule.Disruptive(),
				"isInterruption": false,
			}
			ruleMatches = append(ruleMatches, match)
		}
	}

	// If no matched rule was found for the interruption, keep the default values
	if interruption != nil && !interruptionFound {
		logs.Warning("Interruption rule (ID: %d) not found in matched rules", interruptionRuleID)
	}

	if len(ruleMatches) > 0 {
		if jsonData, err := json.Marshal(ruleMatches); err == nil {
			matchedRules = string(jsonData)
		} else {
			logs.Error("Failed to marshal matched rules: %v", err)
			matchedRules = "[]"
		}
	} else {
		matchedRules = "[]"
	}

	log := &models.WAFLog{
		TransactionID:   tx.ID(),
		SiteID:          entry.SiteID,
		Domain:          entry.Domain,
		ClientIP:        clientIP,
		Method:          req.Method,
		URI:             req.URL.Path,
		QueryString:     req.URL.RawQuery,
		Protocol:        req.Proto,
		UserAgent:       req.Header.Get("User-Agent"),
		Referer:         req.Header.Get("Referer"),
		JA4Fingerprint:  req.Header.Get("X-JA4"),
		Action:          entry.Action,
		StatusCode:      entry.StatusCode,
		BlockStatusCode: entry.BlockStatus,
		ResponseSize:    entry.ResponseSize,
		MatchedRules:    matchedRules,
		Severity:        severity,
		Category:        category,
		ProcessingTime:  int(entry.ProcessingTime),
		CreatedAt:       entry.Timestamp,
	}

	var details []*models.WAFLogDetail
	if s.logDetails {
		if headers, err := json.Marshal(req.Header); err == nil {
			details = append(details, &models.WAFLogDetail{
				DetailType: "request_headers",
				Content:    string(headers),
			})
		}

		if len(ruleMatches) > 0 {
			if matchBytes, err := json.Marshal(ruleMatches); err == nil {
				details = append(details, &models.WAFLogDetail{
					DetailType: "rule_matches",
					Content:    string(matchBytes),
				})
			}
		}
	}

	return log, details
}

// extractCategoryFromTags tries to determine a category from rule tags
func extractCategoryFromTags(tags []string) string {
	// Common WAF rule categories to look for in tags
	exactCategories := map[string]bool{
		"sql":                true,
		"sqli":               true,
		"xss":                true,
		"rce":                true,
		"lfi":                true,
		"rfi":                true,
		"command_injection":  true,
		"injection":          true,
		"session_fixation":   true,
		"csrf":               true,
		"protocol":           true,
		"protocol_violation": true,
		"method":             true,
		"request_limit":      true,
		"content":            true,
		"evading":            true,
		"file_upload":        true,
		"policy":             true,
		"scanner":            true,
		"bot":                true,
		"reputation":         true,
		"error":              true,
		"application":        true,
		"access_control":     true,
		"data_leakage":       true,
	}

	// Category keywords to look for as substrings
	categoryKeywords := []struct {
		keyword  string
		category string
	}{
		{"sql", "sql"},
		{"sqli", "sql"},
		{"sql_injection", "sql"},
		{"xss", "xss"},
		{"cross-site", "xss"},
		{"command", "command_injection"},
		{"rce", "rce"},
		{"remote", "rce"},
		{"execution", "rce"},
		{"inclusion", "lfi"},
		{"lfi", "lfi"},
		{"rfi", "rfi"},
		{"traversal", "lfi"},
		{"directory", "lfi"},
		{"path", "lfi"},
		{"injection", "injection"},
		{"csrf", "csrf"},
		{"session", "session_fixation"},
		{"fixation", "session_fixation"},
		{"protocol", "protocol"},
		{"violation", "protocol_violation"},
		{"method", "method"},
		{"request", "request_limit"},
		{"limit", "request_limit"},
		{"content", "content"},
		{"evading", "evading"},
		{"evasion", "evading"},
		{"bypass", "evading"},
		{"upload", "file_upload"},
		{"file", "file_upload"},
		{"policy", "policy"},
		{"scanner", "scanner"},
		{"bot", "bot"},
		{"reputation", "reputation"},
		{"error", "error"},
		{"app", "application"},
		{"access", "access_control"},
		{"leakage", "data_leakage"},
		{"leak", "data_leakage"},
		{"disclosure", "data_leakage"},
	}

	// First, try exact matches (faster)
	for _, tag := range tags {
		if exactCategories[tag] {
			return tag
		}
	}

	// Then, try substring matching
	for _, tag := range tags {
		tagLower := strings.ToLower(tag)
		for _, kw := range categoryKeywords {
			if strings.Contains(tagLower, kw.keyword) {
				return kw.category
			}
		}
	}

	// Return a default if no known category is found
	return "unknown"
}

// runRetentionPolicy removes old logs periodically
func (s *WAFLogService) runRetentionPolicy() {
	defer s.wg.Done()

	ticker := time.NewTicker(24 * time.Hour) // Run once per day
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			s.cleanupOldLogs()
		case <-s.shutdown:
			return
		}
	}
}

// cleanupOldLogs removes logs older than retention days
func (s *WAFLogService) cleanupOldLogs() {
	cutoffDate := time.Now().AddDate(0, 0, -s.retention)

	o := orm.NewOrm()

	// Delete details for old logs first
	_, err := o.Raw("DELETE FROM waf_log_detail WHERE waf_log_id IN (SELECT id FROM waf_log WHERE created_at < ?)", cutoffDate).Exec()
	if err != nil {
		logs.Error("Failed to delete old WAF log details: %v", err)
	}

	// Then delete the logs themselves
	res, err := o.Raw("DELETE FROM waf_log WHERE created_at < ?", cutoffDate).Exec()
	if err != nil {
		logs.Error("Failed to delete old WAF logs: %v", err)
		return
	}

	if rowsAffected, err := res.RowsAffected(); err == nil && rowsAffected > 0 {
		logs.Info("Deleted %d WAF logs older than %d days", rowsAffected, s.retention)
	}
}

// Shutdown gracefully shuts down the logging service
func (s *WAFLogService) Shutdown() {
	close(s.shutdown)
	s.wg.Wait()
	logs.Info("WAF logging service shut down")
}

// QueryLogs retrieves logs with filters
func (s *WAFLogService) QueryLogs(filters map[string]interface{}, page, pageSize int) ([]*models.WAFLog, int64, error) {
	o := orm.NewOrm()
	qs := o.QueryTable(new(models.WAFLog))

	// Apply filters
	for key, value := range filters {
		if value != nil {
			qs = qs.Filter(key, value)
		}
	}

	// Get total count
	count, err := qs.Count()
	if err != nil {
		return nil, 0, err
	}

	// Get records with pagination
	var logs []*models.WAFLog
	_, err = qs.OrderBy("-created_at").Limit(pageSize, (page-1)*pageSize).All(&logs)
	if err != nil {
		return nil, 0, err
	}

	return logs, count, nil
}

var (
	wafLogServiceInstance *WAFLogService
	wafLogServiceOnce     sync.Once
)

// GetWAFLogService returns the singleton WAF log service instance
func GetWAFLogService() *WAFLogService {
	wafLogServiceOnce.Do(func() {
		// Use configuration values or defaults
		bufferSize := 100
		logDetails := true // Change this to true to always enable detailed logging
		retention := 30

		// Try to read from config if available
		if appConfig, err := web.AppConfig.Int("WAFLogBufferSize"); err == nil && appConfig > 0 {
			bufferSize = appConfig
		}
		if logDetailsConfig, err := web.AppConfig.Bool("WAFLogDetails"); err == nil {
			logDetails = logDetailsConfig
		}
		if retentionConfig, err := web.AppConfig.Int("WAFLogRetention"); err == nil && retentionConfig > 0 {
			retention = retentionConfig
		}

		wafLogServiceInstance = NewWAFLogService(bufferSize, logDetails, retention)
	})
	return wafLogServiceInstance
}
