package controllers

import (
	"SeproWAF/models"
	"SeproWAF/services"
	"strconv"
	"time"

	"github.com/beego/beego/v2/client/orm"
	"github.com/beego/beego/v2/server/web"
)

// WAFLogsController handles WAF logs API
type WAFLogsController struct {
	web.Controller
}

// GetLogs returns WAF logs with filtering and pagination
func (c *WAFLogsController) GetLogs() {
	// Get query parameters for filtering
	siteID, _ := c.GetInt("site_id", 0)
	clientIP := c.GetString("client_ip", "")
	domain := c.GetString("domain", "")
	action := c.GetString("action", "")
	method := c.GetString("method", "")
	uri := c.GetString("uri", "")
	severity := c.GetString("severity", "")
	category := c.GetString("category", "")

	// Get date range
	startDate := c.GetString("start_date", "")
	endDate := c.GetString("end_date", "")

	// Parse dates if provided
	var startTime, endTime time.Time
	var err error
	if startDate != "" {
		startTime, err = time.Parse("2006-01-02", startDate)
		if err != nil {
			c.Data["json"] = map[string]interface{}{
				"success": false,
				"message": "Invalid start date format. Use YYYY-MM-DD",
			}
			c.ServeJSON()
			return
		}
	}

	if endDate != "" {
		endTime, err = time.Parse("2006-01-02", endDate)
		if err != nil {
			c.Data["json"] = map[string]interface{}{
				"success": false,
				"message": "Invalid end date format. Use YYYY-MM-DD",
			}
			c.ServeJSON()
			return
		}
		// Set end time to end of day
		endTime = endTime.Add(24*time.Hour - time.Second)
	}

	// Get pagination parameters
	page, _ := c.GetInt("page", 1)
	pageSize, _ := c.GetInt("page_size", 20)

	// Build filters
	filters := make(map[string]interface{})
	if siteID > 0 {
		filters["site_id"] = siteID
	}
	if clientIP != "" {
		filters["client_ip"] = clientIP
	}
	if domain != "" {
		filters["domain__icontains"] = domain
	}
	if action != "" {
		filters["action"] = action
	}
	if method != "" {
		filters["method"] = method
	}
	if uri != "" {
		filters["uri__icontains"] = uri
	}
	if severity != "" {
		filters["severity"] = severity
	}
	if category != "" {
		filters["category"] = category
	}

	// Add date range filters
	if !startTime.IsZero() {
		filters["created_at__gte"] = startTime
	}
	if !endTime.IsZero() {
		filters["created_at__lte"] = endTime
	}

	// Query logs
	logs, total, err := services.GetWAFLogService().QueryLogs(filters, page, pageSize)
	if err != nil {
		c.Data["json"] = map[string]interface{}{
			"success": false,
			"message": "Failed to query logs: " + err.Error(),
		}
		c.ServeJSON()
		return
	}

	// Calculate pagination info
	totalPages := (total + int64(pageSize) - 1) / int64(pageSize)

	c.Data["json"] = map[string]interface{}{
		"success": true,
		"data":    logs,
		"pagination": map[string]interface{}{
			"page":        page,
			"page_size":   pageSize,
			"total":       total,
			"total_pages": totalPages,
		},
	}
	c.ServeJSON()
}

// GetLogDetails returns details for a specific log entry
func (c *WAFLogsController) GetLogDetails() {
	idStr := c.Ctx.Input.Param(":id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.Data["json"] = map[string]interface{}{
			"success": false,
			"message": "Invalid log ID",
		}
		c.ServeJSON()
		return
	}

	// Get the log entry
	log := &models.WAFLog{ID: id}
	o := orm.NewOrm()
	err = o.Read(log)
	if err != nil {
		c.Data["json"] = map[string]interface{}{
			"success": false,
			"message": "Log not found",
		}
		c.ServeJSON()
		return
	}

	// Get details if they exist
	var details []*models.WAFLogDetail
	_, err = o.QueryTable(new(models.WAFLogDetail)).Filter("WAFLogID", id).All(&details)
	if err != nil {
		c.Data["json"] = map[string]interface{}{
			"success": false,
			"message": "Failed to retrieve log details: " + err.Error(),
		}
		c.ServeJSON()
		return
	}

	c.Data["json"] = map[string]interface{}{
		"success": true,
		"log":     log,
		"details": details,
	}
	c.ServeJSON()
}

// GetSiteLogs returns WAF logs for a specific site with filtering and pagination
func (c *WAFLogsController) GetSiteLogs() {
	// Get site ID from URL parameter
	siteIDStr := c.Ctx.Input.Param(":id")
	siteID, err := strconv.Atoi(siteIDStr)
	if err != nil {
		c.Data["json"] = map[string]interface{}{
			"success": false,
			"message": "Invalid site ID",
		}
		c.ServeJSON()
		return
	}

	// Get query parameters for filtering
	clientIP := c.GetString("client_ip", "")
	domain := c.GetString("domain", "")
	action := c.GetString("action", "")
	method := c.GetString("method", "")
	uri := c.GetString("uri", "")
	severity := c.GetString("severity", "")
	category := c.GetString("category", "")

	// Get date range
	startDate := c.GetString("start_date", "")
	endDate := c.GetString("end_date", "")

	// Parse dates if provided
	var startTime, endTime time.Time
	if startDate != "" {
		startTime, err = time.Parse("2006-01-02", startDate)
		if err != nil {
			c.Data["json"] = map[string]interface{}{
				"success": false,
				"message": "Invalid start date format. Use YYYY-MM-DD",
			}
			c.ServeJSON()
			return
		}
	}

	if endDate != "" {
		endTime, err = time.Parse("2006-01-02", endDate)
		if err != nil {
			c.Data["json"] = map[string]interface{}{
				"success": false,
				"message": "Invalid end date format. Use YYYY-MM-DD",
			}
			c.ServeJSON()
			return
		}
		// Set end time to end of day
		endTime = endTime.Add(24*time.Hour - time.Second)
	}

	// Get pagination parameters
	page, _ := c.GetInt("page", 1)
	pageSize, _ := c.GetInt("page_size", 20)

	// Build filters
	filters := make(map[string]interface{})

	// Always filter by the provided site ID - use "SiteID" (capitalized) instead of "site_id"
	filters["SiteID"] = siteID

	if clientIP != "" {
		filters["client_ip"] = clientIP
	}
	if domain != "" {
		filters["domain__icontains"] = domain
	}
	if action != "" {
		filters["action"] = action
	}
	if method != "" {
		filters["method"] = method
	}
	if uri != "" {
		filters["uri__icontains"] = uri
	}
	if severity != "" {
		filters["severity"] = severity
	}
	if category != "" {
		filters["category"] = category
	}

	// Add date range filters
	if !startTime.IsZero() {
		filters["created_at__gte"] = startTime
	}
	if !endTime.IsZero() {
		filters["created_at__lte"] = endTime
	}

	// Query logs
	logs, total, err := services.GetWAFLogService().QueryLogs(filters, page, pageSize)
	if err != nil {
		c.Data["json"] = map[string]interface{}{
			"success": false,
			"message": "Failed to query logs: " + err.Error(),
		}
		c.ServeJSON()
		return
	}

	// Calculate pagination info
	totalPages := (total + int64(pageSize) - 1) / int64(pageSize)

	// Get attack and request counts for the site in the last 24 hours
	o := orm.NewOrm()
	oneDayAgo := time.Now().Add(-24 * time.Hour)

	// Requests count in last 24h for this site - use "SiteID" (capitalized)
	var requestsCount int64
	requestsCount, _ = o.QueryTable(new(models.WAFLog)).
		Filter("SiteID", siteID).
		Filter("created_at__gte", oneDayAgo).
		Count()

	// Attacks count in last 24h for this site - use "SiteID" (capitalized)
	var attacksCount int64
	attacksCount, _ = o.QueryTable(new(models.WAFLog)).
		Filter("SiteID", siteID).
		Filter("created_at__gte", oneDayAgo).
		Filter("action", "blocked").
		Count()

	c.Data["json"] = map[string]interface{}{
		"success": true,
		"data":    logs,
		"pagination": map[string]interface{}{
			"page":        page,
			"page_size":   pageSize,
			"total":       total,
			"total_pages": totalPages,
		},
		"site_id": siteID,
		"stats": map[string]interface{}{
			"requests_24h": requestsCount,
			"attacks_24h":  attacksCount,
		},
	}
	c.ServeJSON()
}
