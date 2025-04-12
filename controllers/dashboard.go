// filepath: /home/alnuzaili/projects/Sepro/SeproWAF/controllers/dashboard.go
package controllers

import (
	"SeproWAF/models"
	"fmt"
	"strconv"
	"time"

	"github.com/beego/beego/v2/client/orm"
	"github.com/beego/beego/v2/server/web"
)

// DashboardController handles dashboard API endpoints
type DashboardController struct {
	web.Controller
}

// GetStats returns dashboard statistics
func (c *DashboardController) GetStats() {
	o := orm.NewOrm()

	// Get site count
	var sitesCount int64
	sitesCount, _ = o.QueryTable(new(models.Site)).Count()

	// Get 24h stats
	oneDayAgo := time.Now().Add(-24 * time.Hour)

	// Requests count in last 24h
	var requestsCount int64
	requestsCount, _ = o.QueryTable(new(models.WAFLog)).Filter("created_at__gte", oneDayAgo).Count()

	// Attacks count in last 24h
	var attacksCount int64
	attacksCount, _ = o.QueryTable(new(models.WAFLog)).Filter("created_at__gte", oneDayAgo).Filter("action", "blocked").Count()

	c.Data["json"] = map[string]interface{}{
		"success":        true,
		"sites_count":    sitesCount,
		"requests_count": requestsCount,
		"attacks_count":  attacksCount,
	}
	c.ServeJSON()
}

// GetTraffic returns traffic data for the chart (last 24 hours)
func (c *DashboardController) GetTraffic() {
	o := orm.NewOrm()

	// Create 24 hour buckets
	now := time.Now()
	labels := make([]string, 24)
	legitimate := make([]int64, 24)
	blocked := make([]int64, 24)

	// Generate time labels and initialize data arrays
	for i := 0; i < 24; i++ {
		hourDiff := 23 - i
		labels[i] = fmt.Sprintf("%dh ago", hourDiff)
	}

	// Get hourly counts for the last 24 hours
	for i := 0; i < 24; i++ {
		hourStart := now.Add(-time.Duration(i+1) * time.Hour)
		hourEnd := now.Add(-time.Duration(i) * time.Hour)

		// Count legitimate traffic (non-blocked requests)
		legitimate[23-i], _ = o.QueryTable(new(models.WAFLog)).
			Filter("created_at__gte", hourStart).
			Filter("created_at__lt", hourEnd).
			Filter("action__in", "allowed", "log").
			Count()

		// Count blocked attacks
		blocked[23-i], _ = o.QueryTable(new(models.WAFLog)).
			Filter("created_at__gte", hourStart).
			Filter("created_at__lt", hourEnd).
			Filter("action", "blocked").
			Count()
	}

	c.Data["json"] = map[string]interface{}{
		"success": true,
		"traffic": map[string]interface{}{
			"labels":     labels,
			"legitimate": legitimate,
			"blocked":    blocked,
		},
	}
	c.ServeJSON()
}

// GetAttackTypes returns data for attack type distribution chart
func (c *DashboardController) GetAttackTypes() {
	o := orm.NewOrm()

	// Get attack types for the last 30 days
	thirtyDaysAgo := time.Now().Add(-30 * 24 * time.Hour)

	// Use a raw SQL query instead which gives us more control
	sql := `SELECT category, COUNT(*) as count 
            FROM waf_log 
            WHERE created_at >= ? AND action = 'block'
            GROUP BY category 
            ORDER BY count DESC 
            LIMIT 5`

	var results []orm.Params
	_, err := o.Raw(sql, thirtyDaysAgo).Values(&results)

	if err != nil {
		c.Data["json"] = map[string]interface{}{
			"success": false,
			"message": "Failed to get attack types data: " + err.Error(),
		}
		c.ServeJSON()
		return
	}

	// Extract labels and values from query results
	labels := make([]string, 0)
	values := make([]int64, 0)

	otherCount := int64(0)

	// Process the top categories and group the rest as "Other"
	for i, result := range results {
		category := result["category"]
		countStr, ok := result["count"].(string)
		if !ok {
			// Try to get as int64 or other type
			countVal, ok := result["count"].(int64)
			if ok {
				if i < 4 && category != nil { // Show top 4 categories
					categoryName := fmt.Sprintf("%v", category)
					if categoryName == "" {
						categoryName = "Unknown"
					}
					labels = append(labels, categoryName)
					values = append(values, countVal)
				} else {
					otherCount += countVal
				}
			}
			continue
		}

		// Convert string count to int64
		countVal, _ := strconv.ParseInt(countStr, 10, 64)

		if i < 4 && category != nil { // Show top 4 categories
			categoryName := fmt.Sprintf("%v", category)
			if categoryName == "" {
				categoryName = "Unknown"
			}
			labels = append(labels, categoryName)
			values = append(values, countVal)
		} else {
			// Group the rest as "Other"
			otherCount += countVal
		}
	}

	// Add "Other" category if there are additional attacks
	if otherCount > 0 {
		labels = append(labels, "Other")
		values = append(values, otherCount)
	}

	// If no data was found, provide some default categories
	if len(labels) == 0 {
		labels = []string{"SQL Injection", "XSS", "CSRF", "Path Traversal", "Other"}
		values = []int64{0, 0, 0, 0, 0}
	}

	c.Data["json"] = map[string]interface{}{
		"success": true,
		"attack_types": map[string]interface{}{
			"labels": labels,
			"values": values,
		},
	}
	c.ServeJSON()
}
