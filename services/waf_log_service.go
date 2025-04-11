package services

import (
	"SeproWAF/models"
	"encoding/json"
	"net"
	"net/http"
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

	// Extract matched rules
	var matchedRules string
	var severity string
	var category string
	var ruleMatches []map[string]interface{}

	// Process rule matches from the interruption if available
	if interruption := tx.Interruption(); interruption != nil {
		// Extract rule information from the interruption
		severity = getSeverityFromScore(interruption.RuleID)
		category = getCategoryFromRule(interruption.RuleID)

		// Create a rule match entry for the rule that caused the interruption
		match := map[string]interface{}{
			"id":       interruption.RuleID,
			"severity": severity,
			"category": category,
			"message":  interruption.Action, // This might need adjustment based on Coraza's API
		}

		ruleMatches = append(ruleMatches, match)

		// Serialize matches to JSON for the main log record
		if matchedJSON, err := json.Marshal(ruleMatches); err == nil {
			matchedRules = string(matchedJSON)
		} else {
			logs.Error("Failed to marshal rule matches: %v", err)
			matchedRules = "{}"
		}
	} else {
		matchedRules = "[]"
	}

	// Create the log object
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

	// Create detail objects if enabled
	var details []*models.WAFLogDetail
	if s.logDetails {
		// Add request headers
		if headerBytes, err := json.Marshal(req.Header); err == nil {
			details = append(details, &models.WAFLogDetail{
				DetailType: "request_headers",
				Content:    string(headerBytes),
			})
		}

		// Add rule matches if available
		if len(ruleMatches) > 0 {
			if matchesBytes, err := json.Marshal(ruleMatches); err == nil {
				details = append(details, &models.WAFLogDetail{
					DetailType: "rule_matches",
					Content:    string(matchesBytes),
				})
			}
		}
	}

	return log, details
}

// Placeholder functions - implement based on your rules
func getSeverityFromScore(ruleID int) string {
	// Implement logic to map rule ID to severity
	return "medium"
}

func getCategoryFromRule(ruleID int) string {
	// Implement logic to map rule ID to category
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
