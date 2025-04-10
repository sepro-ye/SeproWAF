package controllers

import (
	"encoding/json"
	"fmt"
	"os"
	"strconv"
	"time"

	"SeproWAF/models"
	"SeproWAF/proxy"
	"SeproWAF/services"

	"github.com/beego/beego/v2/core/logs"
	"github.com/beego/beego/v2/server/web"
	"github.com/corazawaf/coraza/v3"
)

// WAFRuleController handles the custom WAF rules
type WAFRuleController struct {
	web.Controller
	ruleGenerator *services.RuleGenerator
	wafManager    *proxy.WAFManager // Add WAFManager field
}

// Prepare runs before each method
func (c *WAFRuleController) Prepare() {
	// Initialize rule generator if needed
	if c.ruleGenerator == nil {
		c.ruleGenerator = services.NewRuleGenerator()
	}

	// Initialize WAF manager
	if c.wafManager == nil {
		wafManager, err := proxy.GetWAFManager()
		if err != nil {
			logs.Error("Failed to get WAF manager: %v", err)
			// Continue without WAF manager, errors will be handled in individual methods
		} else {
			c.wafManager = wafManager
		}
	}

	// Check if user is authenticated
	// This is assumed to be handled by middleware that sets these values
	// If not, add authentication check code here
}

// RequireSignedIn ensures that a user is signed in before proceeding
func (c *WAFRuleController) RequireSignedIn() bool {
	userID := c.Ctx.Input.GetData("userID")
	if userID == nil {
		c.Ctx.Output.SetStatus(401)
		c.Data["json"] = map[string]string{"error": "Authentication required"}
		c.ServeJSON()
		return true
	}
	return false
}

// GetRules retrieves all WAF rules for a site
func (c *WAFRuleController) GetRules() {
	// Get user ID and role from context (set by middleware)
	userID := c.Ctx.Input.GetData("userID").(int)
	userRole := c.Ctx.Input.GetData("userRole").(models.Role)

	// Get site ID from URL parameter
	siteIDStr := c.Ctx.Input.Param(":siteId")
	siteID, err := strconv.Atoi(siteIDStr)
	if err != nil {
		c.Ctx.Output.SetStatus(400)
		c.Data["json"] = map[string]string{"error": "Invalid site ID"}
		c.ServeJSON()
		return
	}

	// Get the site
	site, err := models.GetSiteByID(siteID)
	if err != nil {
		c.Ctx.Output.SetStatus(404)
		c.Data["json"] = map[string]string{"error": "Site not found"}
		c.ServeJSON()
		return
	}

	// Check if user has permission to view the site
	if !site.CanUserManageSite(userID, userRole) {
		c.Ctx.Output.SetStatus(403)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	// Get rules for the site
	rules, err := models.GetWAFRules(siteID)
	if err != nil {
		c.Ctx.Output.SetStatus(500)
		c.Data["json"] = map[string]string{"error": "Failed to get rules: " + err.Error()}
		c.ServeJSON()
		return
	}

	c.Data["json"] = rules
	c.ServeJSON()
}

// GetRule retrieves a specific WAF rule
func (c *WAFRuleController) GetRule() {
	// Get user ID and role from context (set by middleware)
	userID := c.Ctx.Input.GetData("userID").(int)
	userRole := c.Ctx.Input.GetData("userRole").(models.Role)

	// Get rule ID from URL parameter
	ruleIDStr := c.Ctx.Input.Param(":id")
	ruleID, err := strconv.Atoi(ruleIDStr)
	if err != nil {
		c.Ctx.Output.SetStatus(400)
		c.Data["json"] = map[string]string{"error": "Invalid rule ID"}
		c.ServeJSON()
		return
	}

	// Get the rule
	rule, err := models.GetWAFRuleByID(ruleID)
	if err != nil {
		c.Ctx.Output.SetStatus(404)
		c.Data["json"] = map[string]string{"error": "Rule not found"}
		c.ServeJSON()
		return
	}

	// Get the site
	site, err := models.GetSiteByID(rule.SiteID)
	if err != nil {
		c.Ctx.Output.SetStatus(404)
		c.Data["json"] = map[string]string{"error": "Site not found"}
		c.ServeJSON()
		return
	}

	// Check if user has permission to view the site
	if !site.CanUserManageSite(userID, userRole) {
		c.Ctx.Output.SetStatus(403)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	c.Data["json"] = rule
	c.ServeJSON()
}

// CreateRule creates a new WAF rule
func (c *WAFRuleController) CreateRule() {
	// Get user ID and role from context (set by middleware)
	userID := c.Ctx.Input.GetData("userID").(int)
	userRole := c.Ctx.Input.GetData("userRole").(models.Role)

	fmt.Println(c.Ctx.Input.RequestBody)
	// Parse request body
	var rule models.WAFRule
	if err := json.Unmarshal(c.Ctx.Input.RequestBody, &rule); err != nil {
		c.Ctx.Output.SetStatus(400)
		c.Data["json"] = map[string]string{"error": "Invalid request body: " + err.Error()}
		c.ServeJSON()
		return
	}

	// Get the site
	fmt.Println(rule)
	fmt.Println(rule.SiteID)
	site, err := models.GetSiteByID(rule.SiteID)
	fmt.Println(site)
	if err != nil {
		c.Ctx.Output.SetStatus(404)
		c.Data["json"] = map[string]string{"error": "Site not found"}
		c.ServeJSON()
		return
	}

	// Check if user has permission to manage the site
	if !site.CanUserManageSite(userID, userRole) {
		c.Ctx.Output.SetStatus(403)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	// Validate rule parameters
	if err := c.ruleGenerator.ValidateRuleParameters(&rule); err != nil {
		c.Ctx.Output.SetStatus(400)
		c.Data["json"] = map[string]string{"error": "Invalid rule parameters: " + err.Error()}
		c.ServeJSON()
		return
	}

	// Generate rule text for non-custom rules
	if rule.Type != models.CustomRule {
		ruleText, err := c.ruleGenerator.GenerateRule(&rule)
		if err != nil {
			c.Ctx.Output.SetStatus(400)
			c.Data["json"] = map[string]string{"error": "Failed to generate rule text: " + err.Error()}
			c.ServeJSON()
			return
		}

		// Store the generated rule text
		rule.RuleText = ruleText
	}

	// Set metadata
	rule.CreatedBy = userID
	rule.CreatedAt = time.Now()
	rule.UpdatedAt = time.Now()

	// For custom rules, validate the rule text
	if rule.Type == models.CustomRule && rule.RuleText == "" {
		c.Ctx.Output.SetStatus(400)
		c.Data["json"] = map[string]string{"error": "Custom rule requires rule text"}
		c.ServeJSON()
		return
	}

	// Insert the rule
	if err := models.InsertWAFRule(&rule); err != nil {
		c.Ctx.Output.SetStatus(500)
		c.Data["json"] = map[string]string{"error": "Failed to create rule: " + err.Error()}
		c.ServeJSON()
		return
	}

	// Reload WAF for the site
	if c.wafManager == nil {
		logs.Warning("WAF manager not available, rule created but WAF not reloaded")
	} else {
		if err := c.wafManager.ReloadWAF(rule.SiteID); err != nil {
			logs.Error("Failed to reload WAF for site %d: %v", rule.SiteID, err)
			// Continue - don't fail the entire operation if just the reload fails
		} else {
			logs.Info("WAF rules reloaded for site %d", rule.SiteID)
		}
	}

	c.Ctx.Output.SetStatus(201)
	c.Data["json"] = rule
	c.ServeJSON()
}

// UpdateRule updates an existing WAF rule
func (c *WAFRuleController) UpdateRule() {
	// Get user ID and role from context (set by middleware)
	userID := c.Ctx.Input.GetData("userID").(int)
	userRole := c.Ctx.Input.GetData("userRole").(models.Role)

	// Get rule ID from URL parameter
	ruleIDStr := c.Ctx.Input.Param(":id")
	ruleID, err := strconv.Atoi(ruleIDStr)
	if err != nil {
		c.Ctx.Output.SetStatus(400)
		c.Data["json"] = map[string]string{"error": "Invalid rule ID"}
		c.ServeJSON()
		return
	}

	// Get the existing rule
	existingRule, err := models.GetWAFRuleByID(ruleID)
	if err != nil {
		c.Ctx.Output.SetStatus(404)
		c.Data["json"] = map[string]string{"error": "Rule not found"}
		c.ServeJSON()
		return
	}

	// Get the site
	site, err := models.GetSiteByID(existingRule.SiteID)
	if err != nil {
		c.Ctx.Output.SetStatus(404)
		c.Data["json"] = map[string]string{"error": "Site not found"}
		c.ServeJSON()
		return
	}

	// Check if user has permission to manage the site
	if !site.CanUserManageSite(userID, userRole) {
		c.Ctx.Output.SetStatus(403)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	// Parse request body
	var updatedRule models.WAFRule
	if err := json.Unmarshal(c.Ctx.Input.RequestBody, &updatedRule); err != nil {
		c.Ctx.Output.SetStatus(400)
		c.Data["json"] = map[string]string{"error": "Invalid request body: " + err.Error()}
		c.ServeJSON()
		return
	}

	// Set the ID and keep creation metadata
	updatedRule.ID = ruleID
	updatedRule.SiteID = existingRule.SiteID
	updatedRule.CreatedAt = existingRule.CreatedAt
	updatedRule.CreatedBy = existingRule.CreatedBy
	updatedRule.UpdatedAt = time.Now()

	// Validate rule parameters
	if err := c.ruleGenerator.ValidateRuleParameters(&updatedRule); err != nil {
		c.Ctx.Output.SetStatus(400)
		c.Data["json"] = map[string]string{"error": "Invalid rule parameters: " + err.Error()}
		c.ServeJSON()
		return
	}

	// Update the rule
	if err := models.UpdateWAFRule(&updatedRule); err != nil {
		c.Ctx.Output.SetStatus(500)
		c.Data["json"] = map[string]string{"error": "Failed to update rule: " + err.Error()}
		c.ServeJSON()
		return
	}

	// Reload WAF for the site
	if c.wafManager == nil {
		logs.Warning("WAF manager not available, rule updated but WAF not reloaded")
	} else {
		if err := c.wafManager.ReloadWAF(updatedRule.SiteID); err != nil {
			logs.Error("Failed to reload WAF for site %d: %v", updatedRule.SiteID, err)
			// Continue - don't fail the entire operation if just the reload fails
		} else {
			logs.Info("WAF rules reloaded for site %d", updatedRule.SiteID)
		}
	}

	c.Data["json"] = updatedRule
	c.ServeJSON()
}

// DeleteRule deletes a WAF rule
func (c *WAFRuleController) DeleteRule() {
	// Get user ID and role from context (set by middleware)
	userID := c.Ctx.Input.GetData("userID").(int)
	userRole := c.Ctx.Input.GetData("userRole").(models.Role)

	// Get rule ID from URL parameter
	ruleIDStr := c.Ctx.Input.Param(":id")
	ruleID, err := strconv.Atoi(ruleIDStr)
	if err != nil {
		c.Ctx.Output.SetStatus(400)
		c.Data["json"] = map[string]string{"error": "Invalid rule ID"}
		c.ServeJSON()
		return
	}

	// Get the rule
	rule, err := models.GetWAFRuleByID(ruleID)
	if err != nil {
		c.Ctx.Output.SetStatus(404)
		c.Data["json"] = map[string]string{"error": "Rule not found"}
		c.ServeJSON()
		return
	}

	// Get the site
	site, err := models.GetSiteByID(rule.SiteID)
	if err != nil {
		c.Ctx.Output.SetStatus(404)
		c.Data["json"] = map[string]string{"error": "Site not found"}
		c.ServeJSON()
		return
	}

	// Check if user has permission to manage the site
	if !site.CanUserManageSite(userID, userRole) {
		c.Ctx.Output.SetStatus(403)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	// Store site ID for WAF reload
	siteID := rule.SiteID

	// Delete the rule
	if err := models.DeleteWAFRule(ruleID); err != nil {
		c.Ctx.Output.SetStatus(500)
		c.Data["json"] = map[string]string{"error": "Failed to delete rule: " + err.Error()}
		c.ServeJSON()
		return
	}

	// Reload WAF for the site
	if c.wafManager == nil {
		logs.Warning("WAF manager not available, rule deleted but WAF not reloaded")
	} else {
		if err := c.wafManager.ReloadWAF(siteID); err != nil {
			logs.Error("Failed to reload WAF for site %d: %v", siteID, err)
			// Continue - don't fail the entire operation if just the reload fails
		} else {
			logs.Info("WAF rules reloaded for site %d", siteID)
		}
	}

	c.Data["json"] = map[string]string{"message": "Rule deleted successfully"}
	c.ServeJSON()
}

// ToggleRuleStatus toggles a rule's status between enabled and disabled
func (c *WAFRuleController) ToggleRuleStatus() {
	// Get user ID and role from context (set by middleware)
	userID := c.Ctx.Input.GetData("userID").(int)
	userRole := c.Ctx.Input.GetData("userRole").(models.Role)

	// Get rule ID from URL parameter
	ruleIDStr := c.Ctx.Input.Param(":id")
	ruleID, err := strconv.Atoi(ruleIDStr)
	if err != nil {
		c.Ctx.Output.SetStatus(400)
		c.Data["json"] = map[string]string{"error": "Invalid rule ID"}
		c.ServeJSON()
		return
	}

	// Get the rule
	rule, err := models.GetWAFRuleByID(ruleID)
	if err != nil {
		c.Ctx.Output.SetStatus(404)
		c.Data["json"] = map[string]string{"error": "Rule not found"}
		c.ServeJSON()
		return
	}

	// Get the site
	site, err := models.GetSiteByID(rule.SiteID)
	if err != nil {
		c.Ctx.Output.SetStatus(404)
		c.Data["json"] = map[string]string{"error": "Site not found"}
		c.ServeJSON()
		return
	}

	// Check if user has permission to manage the site
	if !site.CanUserManageSite(userID, userRole) {
		c.Ctx.Output.SetStatus(403)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	// Toggle rule status
	if err := models.ToggleWAFRuleStatus(ruleID); err != nil {
		c.Ctx.Output.SetStatus(500)
		c.Data["json"] = map[string]string{"error": "Failed to toggle rule status: " + err.Error()}
		c.ServeJSON()
		return
	}

	// Get updated rule
	updatedRule, err := models.GetWAFRuleByID(ruleID)
	if err != nil {
		c.Ctx.Output.SetStatus(500)
		c.Data["json"] = map[string]string{"error": "Failed to get updated rule: " + err.Error()}
		c.ServeJSON()
		return
	}

	// Reload WAF for the site
	if c.wafManager != nil {
		if err := c.wafManager.ReloadWAF(updatedRule.SiteID); err != nil {
			c.Ctx.Output.SetStatus(500)
			c.Data["json"] = map[string]string{"error": "Failed to reload WAF: " + err.Error()}
			c.ServeJSON()
			return
		}
	}

	status := "enabled"
	if updatedRule.Status == models.StatusDisabled {
		status = "disabled"
	}

	c.Data["json"] = map[string]interface{}{
		"message": fmt.Sprintf("Rule %s successfully", status),
		"rule":    updatedRule,
	}
	c.ServeJSON()
}

// GetRuleTemplates returns available rule templates
func (c *WAFRuleController) GetRuleTemplates() {
	templates := []map[string]interface{}{
		{
			"id":          "ip_block",
			"name":        "IP Block",
			"type":        models.IPBlockRule,
			"description": "Block requests from specific IP addresses",
			"parameters": []map[string]interface{}{
				{"name": "ipAddress", "type": "string", "description": "IP address or CIDR notation (e.g., 192.168.1.1 or 192.168.1.0/24)"},
			},
		},
		{
			"id":          "rate_limit",
			"name":        "Rate Limit",
			"type":        models.RateLimitRule,
			"description": "Limit requests from an IP address within a time window",
			"parameters": []map[string]interface{}{
				{"name": "requestLimit", "type": "number", "description": "Maximum number of requests allowed"},
				{"name": "timeWindow", "type": "number", "description": "Time window in seconds"},
			},
		},
		{
			"id":          "sqli",
			"name":        "SQL Injection Protection",
			"type":        models.SQLiRule,
			"description": "Protect against SQL injection attacks",
			"parameters": []map[string]interface{}{
				{"name": "target", "type": "string", "description": "Target variable (e.g., ARGS, REQUEST_COOKIES)", "default": "ARGS"},
				{"name": "pattern", "type": "string", "description": "Regular expression to match SQL injection patterns"},
			},
		},
		{
			"id":          "xss",
			"name":        "XSS Protection",
			"type":        models.XSSRule,
			"description": "Protect against Cross-Site Scripting attacks by detecting and blocking malicious JavaScript in requests",
			"parameters": []map[string]interface{}{
				{"name": "target", "type": "string", "description": "Target variable (e.g., ARGS, REQUEST_COOKIES)", "default": "ARGS"},
				{"name": "pattern", "type": "string", "description": "Regular expression to match XSS patterns", "default": "<script|javascript:|onload=|onerror="},
			},
		},
		{
			"id":          "path_traversal",
			"name":        "Path Traversal Protection",
			"type":        models.PathTraversalRule,
			"description": "Protect against directory traversal attacks",
			"parameters": []map[string]interface{}{
				{"name": "target", "type": "string", "description": "Target variable (e.g., ARGS, REQUEST_URI)", "default": "REQUEST_URI"},
				{"name": "pattern", "type": "string", "description": "Regular expression to match path traversal patterns"},
			},
		},
		{
			"id":          "custom",
			"name":        "Custom Rule",
			"type":        models.CustomRule,
			"description": "Create a custom ModSecurity compatible rule",
			"parameters": []map[string]interface{}{
				{"name": "ruleText", "type": "text", "description": "Complete ModSecurity rule text"},
			},
		},
	}

	c.Data["json"] = templates
	c.ServeJSON()
}

// TestRule tests a rule without saving it
func (c *WAFRuleController) TestRule() {
	// Parse request body
	var rule models.WAFRule
	if err := json.Unmarshal(c.Ctx.Input.RequestBody, &rule); err != nil {
		c.Ctx.Output.SetStatus(400)
		c.Data["json"] = map[string]interface{}{
			"success": false,
			"error":   "Invalid request body: " + err.Error(),
		}
		c.ServeJSON()
		return
	}

	// Validate rule parameters
	if err := c.ruleGenerator.ValidateRuleParameters(&rule); err != nil {
		c.Ctx.Output.SetStatus(400)
		c.Data["json"] = map[string]interface{}{
			"success": false,
			"error":   "Invalid rule parameters: " + err.Error(),
		}
		c.ServeJSON()
		return
	}

	// Generate rule text
	ruleText, err := c.ruleGenerator.GenerateRule(&rule)
	if err != nil {
		c.Ctx.Output.SetStatus(400)
		c.Data["json"] = map[string]interface{}{
			"success": false,
			"error":   "Failed to generate rule: " + err.Error(),
		}
		c.ServeJSON()
		return
	}

	// Try to validate the rule by creating a test WAF instance
	if c.wafManager != nil {
		// Create a temporary file with just this rule
		tmpFile, err := os.CreateTemp("", "wafrule-test-*.conf")
		if err == nil {
			defer os.Remove(tmpFile.Name())
			if _, err := tmpFile.WriteString(ruleText); err == nil {
				tmpFile.Close()

				// Try to create a WAF with this rule
				testCfg := coraza.NewWAFConfig().WithDirectivesFromFile(tmpFile.Name())
				_, err := coraza.NewWAF(testCfg)
				if err != nil {
					c.Ctx.Output.SetStatus(400)
					c.Data["json"] = map[string]interface{}{
						"success":  false,
						"error":    "Rule failed validation: " + err.Error(),
						"ruleText": ruleText,
					}
					c.ServeJSON()
					return
				}
			}
		}
	}

	// Return the rule text
	c.Data["json"] = map[string]interface{}{
		"success":  true,
		"ruleText": ruleText,
		"message":  "Rule validated successfully",
	}
	c.ServeJSON()
}
