package services

import (
	db "SeproWAF/database"
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
	logChan      chan *WAFLogEntry
	wg           sync.WaitGroup
	shutdown     chan struct{}
	flushTicker  *time.Ticker
	buffer       []*WAFLogEntry
	bufferMutex  sync.Mutex
	bufferSize   int
	logDetails   bool // Whether to log detailed information like headers and bodies
	retention    int  // Log retention in days
	logBatch     []*WAFLogEntry
	batchMutex   sync.Mutex
	batchTicker  *time.Ticker
	batchSize    int
	shuttingDown bool
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

// Update the function signature to include better defaults
func NewWAFLogService(retentionDays int, logDetails bool, bufferSize int) *WAFLogService {
	if bufferSize < 500 {
		bufferSize = 500 // Larger default batch size
	}

	service := &WAFLogService{
		logChan:     make(chan *WAFLogEntry, 5000), // Larger channel buffer
		shutdown:    make(chan struct{}),
		flushTicker: time.NewTicker(30 * time.Second), // Flush less frequently
		buffer:      make([]*WAFLogEntry, 0, bufferSize),
		bufferSize:  bufferSize,
		logDetails:  logDetails,
		retention:   retentionDays,
		logBatch:    make([]*WAFLogEntry, 0, bufferSize),
		batchMutex:  sync.Mutex{},
		batchTicker: time.NewTicker(15 * time.Second), // Process batches less frequently
		batchSize:   bufferSize,
	}

	// Start background workers
	service.wg.Add(1)
	go service.processLogs()

	service.wg.Add(1)
	go service.runRetentionPolicy(retentionDays)

	// Start the batch processing goroutine
	go service.processBatches()

	return service
}

// LogWAFEvent logs a WAF event asynchronously
func (s *WAFLogService) LogWAFEvent(tx txtype.Transaction, req *http.Request, action string, statusCode int, blockStatus int, responseSize int64, processingTime time.Duration, siteID int, domain string) {
	entry := &WAFLogEntry{
		Transaction:    tx,
		Request:        req,
		Action:         action,
		StatusCode:     statusCode,
		BlockStatus:    blockStatus,
		ResponseSize:   responseSize,
		ProcessingTime: int64(processingTime),
		SiteID:         siteID,
		Domain:         domain,
		Timestamp:      time.Now(),
	}

	s.batchMutex.Lock()
	s.logBatch = append(s.logBatch, entry)

	// If we've reached batch size, signal immediate processing
	if len(s.logBatch) >= s.batchSize {
		// Process in a separate goroutine to avoid blocking
		go s.flushBatch()
	}
	s.batchMutex.Unlock()
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
				detail.WAFLogID = int64(log.ID)
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

}

// flushBatch processes and writes batched logs to the database
func (s *WAFLogService) flushBatch() {
	s.batchMutex.Lock()
	if len(s.logBatch) == 0 {
		s.batchMutex.Unlock()
		return
	}

	// Use a much larger batch size for bulk inserts
	currentBatch := s.logBatch
	s.logBatch = make([]*WAFLogEntry, 0, s.batchSize)
	s.batchMutex.Unlock()

	// Process in a worker goroutine
	go s.processBatchInWorker(currentBatch)
}

// New method for worker-based batch processing
func (s *WAFLogService) processBatchInWorker(entries []*WAFLogEntry) {
	if len(entries) == 0 {
		return
	}

	// Get connection from pool
	pool := db.GetPool()
	if pool == nil {
		logs.Error("Database pool is nil!")
		return
	}
	o := pool.GetOrm()
	if o == nil {
		logs.Error("ORM object is nil!")
		return
	}

	// Use bulk insert instead of individual inserts
	tx, err := o.Begin()
	if err != nil {
		logs.Error("Failed to begin transaction for WAF log batch: %v", err)
		return
	}

	// Create collections for logs and details
	wafLogs := make([]*models.WAFLog, 0, len(entries))
	var bulkDetails []*models.WAFLogDetail

	// Create all log objects first
	for _, entry := range entries {
		log, details := s.createLogObjects(entry)

		// Truncate fields that might cause issues
		if len(log.Referer) > 255 {
			log.Referer = log.Referer[:252] + "..."
		}

		// Validate processing time is in range
		if log.ProcessingTime > 2147483647 {
			log.ProcessingTime = 2147483647
		} else if log.ProcessingTime < 0 {
			log.ProcessingTime = 0
		}

		// Add to the logs collection
		wafLogs = append(wafLogs, log)

		// Save details if needed and enabled
		if s.logDetails && len(details) > 0 && len(entries) < 1000 {
			bulkDetails = append(bulkDetails, details...)
		}
	}

	// Insert all logs at once using ORM
	if len(wafLogs) > 0 {
		// Use ORM's InsertMulti for bulk insertion
		_, err := tx.InsertMulti(len(wafLogs), wafLogs)
		if err != nil {
			logs.Error("Failed to bulk insert WAF logs: %v", err)
			tx.Rollback()
			return
		}

		// Now we need to query the inserted logs to get their IDs
		var txIDs []string
		txToLogMap := make(map[string]int64)

		// Collect transaction IDs for querying
		for _, log := range wafLogs {
			txIDs = append(txIDs, log.TransactionID)
		}

		// Query to get the actual database IDs by transaction IDs
		var queryLogs []*models.WAFLog

		// Handle transaction IDs - use Raw SQL for IN condition since Beego's ORM doesn't support it directly
		if len(txIDs) > 0 {
			// Create a transaction ID placeholder list (?,?,?) for the SQL
			placeholders := ""
			params := []interface{}{}

			for i, txID := range txIDs {
				if i > 0 {
					placeholders += ","
				}
				placeholders += "?"
				params = append(params, txID)
			}

			// Use model's TableName method to get correct table name
			tableName := new(models.WAFLog).TableName()

			// Modify the SQL query to remove the time filter
			sql := fmt.Sprintf("SELECT * FROM %s WHERE transaction_id IN (%s)",
				tableName, placeholders)

			// Change this line to use the transaction for querying:
			_, err = tx.Raw(sql, params...).QueryRows(&queryLogs)

			if err != nil {
				logs.Error("Failed to query inserted logs: %v", err)
				// Continue anyway, but details might not link correctly
			} else {
				// Create mapping from transaction ID to database ID
				for _, log := range queryLogs {
					txToLogMap[log.TransactionID] = int64(log.ID)
				}
			}
		} else {
			logs.Warning("No transaction IDs to query")
		}

		// Process details if needed
		if len(bulkDetails) > 0 {
			validDetails := make([]*models.WAFLogDetail, 0, len(bulkDetails))

			// Set the correct WAF log IDs for each detail
			for _, detail := range bulkDetails {
				if logID, exists := txToLogMap[detail.TransactionID]; exists {
					detail.WAFLogID = logID
					validDetails = append(validDetails, detail)
				} else {
					logs.Warning("Could not find parent log for detail with transaction ID: %s", detail.TransactionID)
				}
			}

			// Insert details if we have any valid ones
			if len(validDetails) > 0 {
				_, err = tx.InsertMulti(len(validDetails), validDetails)
				if err != nil {
					logs.Warning("Failed to insert WAF log details: %v", err)
					// Continue despite errors in details
				} else {
				}
			}
		}
	}

	// Commit the transaction
	err = tx.Commit()
	if err != nil {
		logs.Error("Failed to commit transaction for WAF log batch: %v", err)
		tx.Rollback()
	}
}

// Helper function to create SQL value placeholders like ($1,$2,$3),($4,$5,$6)
func createValuePlaceholders(numRows, numCols int) string {
	var result strings.Builder

	for i := 0; i < numRows; i++ {
		if i > 0 {
			result.WriteString(", ")
		}
		result.WriteString("(")

		for j := 0; j < numCols; j++ {
			if j > 0 {
				result.WriteString(", ")
			}
			result.WriteString(fmt.Sprintf("$%d", i*numCols+j+1))
		}

		result.WriteString(")")
	}

	return result.String()
}

// processBatches handles batch processing periodically
func (s *WAFLogService) processBatches() {
	for range s.batchTicker.C {
		if s.shuttingDown {
			return
		}

		s.flushBatch()
	}
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
				DetailType:    "request_headers",
				Content:       string(headers),
				TransactionID: log.TransactionID,
			})
		}

		if len(ruleMatches) > 0 {
			if matchBytes, err := json.Marshal(ruleMatches); err == nil {
				details = append(details, &models.WAFLogDetail{
					DetailType:    "rule_matches",
					Content:       string(matchBytes),
					TransactionID: log.TransactionID,
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
func (s *WAFLogService) runRetentionPolicy(retentionDays int) {
	defer s.wg.Done()

	ticker := time.NewTicker(24 * time.Hour) // Run once per day
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			s.cleanupOldLogs(retentionDays)
		case <-s.shutdown:
			return
		}
	}
}

// cleanupOldLogs removes logs older than retention days
func (s *WAFLogService) cleanupOldLogs(retentionDays int) {
	cutoffDate := time.Now().AddDate(0, 0, -retentionDays)

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
	}
}

// Shutdown gracefully shuts down the logging service
func (s *WAFLogService) Shutdown() {
	s.shuttingDown = true
	s.batchTicker.Stop()

	// Flush any remaining logs
	s.flushBatch()

	close(s.shutdown)
	s.wg.Wait()
}

// QueryLogs retrieves logs with filters
func (s *WAFLogService) QueryLogs(filters map[string]interface{}, page, pageSize int) ([]*models.WAFLog, int64, error) {
	o := orm.NewOrm()
	qs := o.QueryTable(new(models.WAFLog))

	// Apply filters
	for key, value := range filters {
		if value != nil {
			// Special handling for date ranges
			if key == "start_date" {
				// Convert to time.Time if it's a string
				if startDate, ok := value.(string); ok {
					t, err := time.Parse("2006-01-02", startDate)
					if err == nil {
						// Use greater than or equal for start date
						qs = qs.Filter("created_at__gte", t)
					} else {
						logs.Error("Invalid start_date format: %v", err)
					}
				} else if t, ok := value.(time.Time); ok {
					qs = qs.Filter("created_at__gte", t)
				}
			} else if key == "end_date" {
				// Convert to time.Time if it's a string
				if endDate, ok := value.(string); ok {
					t, err := time.Parse("2006-01-02", endDate)
					if err == nil {
						// Add one day to include the entire end date (until 23:59:59)
						t = t.AddDate(0, 0, 1)
						// Use less than for end date
						qs = qs.Filter("created_at__lt", t)
					} else {
						logs.Error("Invalid end_date format: %v", err)
					}
				} else if t, ok := value.(time.Time); ok {
					// Add one day to include the entire end date
					t = t.AddDate(0, 0, 1)
					qs = qs.Filter("created_at__lt", t)
				}
			} else {
				// Regular equality filter for other fields
				qs = qs.Filter(key, value)
			}
		}
	}

	// Rest of the function remains the same
	count, err := qs.Count()
	if err != nil {
		return nil, 0, err
	}

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
		logDetails := true
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

		// Pass bufferSize as third parameter
		wafLogServiceInstance = NewWAFLogService(retention, logDetails, bufferSize)
	})
	return wafLogServiceInstance
}
