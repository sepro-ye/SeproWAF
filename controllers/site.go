package controllers

import (
	"SeproWAF/models"
	"SeproWAF/proxy"
	"encoding/json"
	"net/http"
	"strconv"
	"strings"

	"github.com/beego/beego/v2/client/orm"
	"github.com/beego/beego/v2/core/logs"
	"github.com/beego/beego/v2/server/web"
)

// SiteController handles site management operations
type SiteController struct {
	web.Controller
}

// SiteRequest represents the request body for creating/updating sites
type SiteRequest struct {
	Name      string `json:"name"`
	Domain    string `json:"domain"`
	TargetURL string `json:"target_url"`
	Status    string `json:"status,omitempty"`
}

// ListSites returns all sites owned by the current user
func (c *SiteController) ListSites() {
	// Get user ID from context (set by middleware)
	userID := c.Ctx.Input.GetData("userID").(int)
	userRole := c.Ctx.Input.GetData("userRole").(models.Role)

	var sites []*models.Site
	o := orm.NewOrm()

	// If admin, return all sites, otherwise only user's sites
	if userRole == models.RoleAdmin {
		_, err := o.QueryTable(new(models.Site).TableName()).All(&sites)
		if err != nil {
			c.Ctx.Output.SetStatus(http.StatusInternalServerError)
			c.Data["json"] = map[string]string{"error": "Failed to fetch sites: " + err.Error()}
			c.ServeJSON()
			return
		}
	} else {
		_, err := o.QueryTable(new(models.Site).TableName()).Filter("user_id", userID).All(&sites)
		if err != nil {
			c.Ctx.Output.SetStatus(http.StatusInternalServerError)
			c.Data["json"] = map[string]string{"error": "Failed to fetch sites: " + err.Error()}
			c.ServeJSON()
			return
		}
	}

	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = sites
	c.ServeJSON()
}

// GetSite returns details of a specific site
func (c *SiteController) GetSite() {
	// Get user ID and role from context (set by middleware)
	userID := c.Ctx.Input.GetData("userID").(int)
	userRole := c.Ctx.Input.GetData("userRole").(models.Role)

	// Get site ID from URL parameter
	siteID, err := strconv.Atoi(c.Ctx.Input.Param(":id"))
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid site ID"}
		c.ServeJSON()
		return
	}

	// Get the site
	site, err := models.GetSiteByID(siteID)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusNotFound)
		c.Data["json"] = map[string]string{"error": "Site not found"}
		c.ServeJSON()
		return
	}

	// Check if user has permission to view the site
	if !site.CanUserManageSite(userID, userRole) {
		c.Ctx.Output.SetStatus(http.StatusForbidden)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = site
	c.ServeJSON()
}

// CreateSite creates a new protected site
func (c *SiteController) CreateSite() {
	// Get user ID from context (set by middleware)
	userID := c.Ctx.Input.GetData("userID").(int)

	// Parse request body
	var req SiteRequest
	if err := json.Unmarshal(c.Ctx.Input.RequestBody, &req); err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid request format"}
		c.ServeJSON()
		return
	}

	// Validate required fields
	if req.Name == "" || req.Domain == "" || req.TargetURL == "" {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Name, domain, and target URL are required"}
		c.ServeJSON()
		return
	}

	// Normalize domain (remove protocol if present)
	domain := req.Domain
	domain = strings.TrimPrefix(domain, "http://")
	domain = strings.TrimPrefix(domain, "https://")
	domain = strings.Split(domain, "/")[0] // Remove path if present

	// Check if domain already exists
	o := orm.NewOrm()
	exists := o.QueryTable(new(models.Site).TableName()).Filter("domain", domain).Exist()
	if exists {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Domain already exists"}
		c.ServeJSON()
		return
	}

	// Normalize target URL (ensure it has protocol)
	targetURL := req.TargetURL
	if !strings.HasPrefix(targetURL, "http://") && !strings.HasPrefix(targetURL, "https://") {
		targetURL = "http://" + targetURL
	}

	// Create the site
	site := &models.Site{
		Name:      req.Name,
		Domain:    domain,
		TargetURL: targetURL,
		Status:    models.SiteStatusPending, // Default status is pending
		UserID:    userID,
	}

	_, err := o.Insert(site)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusInternalServerError)
		c.Data["json"] = map[string]string{"error": "Failed to create site: " + err.Error()}
		c.ServeJSON()
		return
	}

	c.Ctx.Output.SetStatus(http.StatusCreated)
	c.Data["json"] = site
	c.ServeJSON()
}

// UpdateSite updates an existing protected site
func (c *SiteController) UpdateSite() {
	// Get user ID and role from context (set by middleware)
	userID := c.Ctx.Input.GetData("userID").(int)
	userRole := c.Ctx.Input.GetData("userRole").(models.Role)

	// Get site ID from URL parameter
	siteID, err := strconv.Atoi(c.Ctx.Input.Param(":id"))
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid site ID"}
		c.ServeJSON()
		return
	}

	// Get the site
	site, err := models.GetSiteByID(siteID)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusNotFound)
		c.Data["json"] = map[string]string{"error": "Site not found"}
		c.ServeJSON()
		return
	}

	// Check if user has permission to update the site
	if !site.CanUserManageSite(userID, userRole) {
		c.Ctx.Output.SetStatus(http.StatusForbidden)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	// Parse request body
	var req SiteRequest
	if err := json.Unmarshal(c.Ctx.Input.RequestBody, &req); err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid request format"}
		c.ServeJSON()
		return
	}

	// Update fields if provided
	if req.Name != "" {
		site.Name = req.Name
	}

	if req.Domain != "" {
		// Normalize domain
		domain := req.Domain
		domain = strings.TrimPrefix(domain, "http://")
		domain = strings.TrimPrefix(domain, "https://")
		domain = strings.Split(domain, "/")[0]

		// Check if domain already exists (and it's not this site)
		o := orm.NewOrm()
		exists := o.QueryTable(new(models.Site).TableName()).
			Filter("domain", domain).
			Exclude("id", site.ID).
			Exist()

		if exists {
			c.Ctx.Output.SetStatus(http.StatusBadRequest)
			c.Data["json"] = map[string]string{"error": "Domain already exists"}
			c.ServeJSON()
			return
		}

		site.Domain = domain
	}

	if req.TargetURL != "" {
		// Normalize target URL
		targetURL := req.TargetURL
		if !strings.HasPrefix(targetURL, "http://") && !strings.HasPrefix(targetURL, "https://") {
			targetURL = "http://" + targetURL
		}
		site.TargetURL = targetURL
	}

	// Only admins can change status
	if req.Status != "" && userRole == models.RoleAdmin {
		site.Status = models.SiteStatus(req.Status)
	}

	// Save changes
	o := orm.NewOrm()
	_, err = o.Update(site)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusInternalServerError)
		c.Data["json"] = map[string]string{"error": "Failed to update site: " + err.Error()}
		c.ServeJSON()
		return
	}

	// If site is active, refresh it in the proxy
	if site.Status == models.SiteStatusActive {
		err = proxy.RefreshSite(site)
		if err != nil {
			logs.Error("Failed to update site in proxy: %v", err)
			// Still return success to the client, but log the error
		}
	}

	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = site
	c.ServeJSON()
}

// DeleteSite removes a protected site
func (c *SiteController) DeleteSite() {
	// Get user ID and role from context (set by middleware)
	userID := c.Ctx.Input.GetData("userID").(int)
	userRole := c.Ctx.Input.GetData("userRole").(models.Role)

	// Get site ID from URL parameter
	siteID, err := strconv.Atoi(c.Ctx.Input.Param(":id"))
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid site ID"}
		c.ServeJSON()
		return
	}

	// Get the site
	site, err := models.GetSiteByID(siteID)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusNotFound)
		c.Data["json"] = map[string]string{"error": "Site not found"}
		c.ServeJSON()
		return
	}

	// Check if user has permission to delete the site
	if !site.CanUserManageSite(userID, userRole) {
		c.Ctx.Output.SetStatus(http.StatusForbidden)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	// Get the domain before deleting
	domain := site.Domain

	// Delete the site
	o := orm.NewOrm()
	_, err = o.Delete(site)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusInternalServerError)
		c.Data["json"] = map[string]string{"error": "Failed to delete site: " + err.Error()}
		c.ServeJSON()
		return
	}

	// Remove from proxy
	proxy.RemoveSiteFromProxy(domain)

	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = map[string]string{"message": "Site deleted successfully"}
	c.ServeJSON()
}

// ToggleSiteStatus enables or disables a site
func (c *SiteController) ToggleSiteStatus() {
	// Get user ID and role from context (set by middleware)
	userID := c.Ctx.Input.GetData("userID").(int)
	userRole := c.Ctx.Input.GetData("userRole").(models.Role)

	// Get site ID from URL parameter
	siteID, err := strconv.Atoi(c.Ctx.Input.Param(":id"))
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid site ID"}
		c.ServeJSON()
		return
	}

	// Get the site
	site, err := models.GetSiteByID(siteID)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusNotFound)
		c.Data["json"] = map[string]string{"error": "Site not found"}
		c.ServeJSON()
		return
	}

	// Check if user has permission to modify the site
	if !site.CanUserManageSite(userID, userRole) {
		c.Ctx.Output.SetStatus(http.StatusForbidden)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	// Toggle the status
	var newStatus models.SiteStatus
	var message string

	if site.Status == models.SiteStatusActive {
		site.Status = models.SiteStatusInactive
		newStatus = models.SiteStatusInactive
		message = "Site deactivated successfully"

		// Remove the site from the proxy
		proxy.RemoveSiteFromProxy(site.Domain)
	} else {
		site.Status = models.SiteStatusActive
		newStatus = models.SiteStatusActive
		message = "Site activated successfully"
	}

	// Save changes
	o := orm.NewOrm()
	_, err = o.Update(site, "Status")
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusInternalServerError)
		c.Data["json"] = map[string]string{"error": "Failed to update site status: " + err.Error()}
		c.ServeJSON()
		return
	}

	// If site was activated, add it to the proxy
	if newStatus == models.SiteStatusActive {
		err = proxy.RefreshSite(site)
		if err != nil {
			logs.Error("Failed to add site to proxy: %v", err)
			// Still return success to the client, but log the error
		}
	}

	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = map[string]interface{}{
		"message": message,
		"status":  site.Status,
	}
	c.ServeJSON()
}

// GetSiteStats returns statistics for a specific site
func (c *SiteController) GetSiteStats() {
	// Get user ID and role from context (set by middleware)
	userID := c.Ctx.Input.GetData("userID").(int)
	userRole := c.Ctx.Input.GetData("userRole").(models.Role)

	// Get site ID from URL parameter
	siteID, err := strconv.Atoi(c.Ctx.Input.Param(":id"))
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid site ID"}
		c.ServeJSON()
		return
	}

	// Get the site
	site, err := models.GetSiteByID(siteID)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusNotFound)
		c.Data["json"] = map[string]string{"error": "Site not found"}
		c.ServeJSON()
		return
	}

	// Check if user has permission to view the site
	if !site.CanUserManageSite(userID, userRole) {
		c.Ctx.Output.SetStatus(http.StatusForbidden)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	// Prepare stats response
	// In a real implementation, you'd fetch more detailed stats from logs
	stats := map[string]interface{}{
		"total_requests":   site.RequestCount,
		"blocked_requests": site.BlockedCount,
		"block_rate":       float64(0),
	}

	if site.RequestCount > 0 {
		stats["block_rate"] = float64(site.BlockedCount) / float64(site.RequestCount) * 100
	}

	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = stats
	c.ServeJSON()
}
