package routers

import (
	"SeproWAF/controllers"
	"SeproWAF/middleware"
	"SeproWAF/models"

	"github.com/beego/beego/v2/server/web"
)

func init() {
	// UI Routes
	web.Router("/", &controllers.MainController{})
	web.Router("/auth/login", &controllers.UIController{}, "get:Login")
	web.Router("/auth/register", &controllers.UIController{}, "get:Register")
	web.Router("/dashboard", &controllers.UIController{}, "get:Dashboard")
	web.Router("/user/profile", &controllers.UIController{}, "get:UserProfile")
	web.Router("/admin/users", &controllers.UIController{}, "get:UserList")

	// UI Routes for Site Management (now part of UIController)
	web.Router("/waf/sites", &controllers.UIController{}, "get:SiteList")
	web.Router("/waf/sites/new", &controllers.UIController{}, "get:SiteCreate")
	web.Router("/waf/sites/:id", &controllers.UIController{}, "get:SiteDetail")
	web.Router("/waf/sites/:id/edit", &controllers.UIController{}, "get:SiteEdit")

	// UI Routes for Certificate Management
	web.Router("/waf/certificates", &controllers.UIController{}, "get:CertificateList")
	web.Router("/waf/certificates/upload", &controllers.UIController{}, "get:CertificateUpload")

	// UI Routes for WAF Rule Management
	web.Router("/waf/sites/:id/rules", &controllers.UIController{}, "get:WAFRuleList")
	web.Router("/waf/sites/:id/rules/new", &controllers.UIController{}, "get:WAFRuleCreate")
	web.Router("/waf/sites/:id/rules/:ruleId/edit", &controllers.UIController{}, "get:WAFRuleEdit")
	web.Router("/settings", &controllers.UIController{}, "get:Settings")
	web.Router("/waf/logs", &controllers.UIController{}, "get:WAFLogsList")
	web.Router("/waf/logs/:id", &controllers.UIController{}, "get:WAFLogDetail")

	// API Routes
	// Public API routes
	web.Router("/api/auth/register", &controllers.AuthController{}, "post:Register")
	web.Router("/api/auth/login", &controllers.AuthController{}, "post:Login")

	// Apply JWT authentication middleware to all routes except login and register
	web.InsertFilter("/api/*", web.BeforeRouter, middleware.JWTMiddleware())

	// Protected API routes - available to authenticated users
	web.Router("/api/auth/logout", &controllers.AuthController{}, "post:Logout")
	web.Router("/api/user/profile", &controllers.UserController{}, "get:GetProfile")
	web.Router("/api/user/:id", &controllers.UserController{}, "get:GetUser;put:UpdateUser")

	// API Routes for Site Management
	web.Router("/api/sites", &controllers.SiteController{}, "get:ListSites;post:CreateSite")
	web.Router("/api/sites/:id", &controllers.SiteController{}, "get:GetSite;put:UpdateSite;delete:DeleteSite")
	web.Router("/api/sites/:id/toggle-status", &controllers.SiteController{}, "post:ToggleSiteStatus")
	web.Router("/api/sites/:id/toggle-waf", &controllers.SiteController{}, "post:ToggleWAF")
	web.Router("/api/sites/:id/stats", &controllers.SiteController{}, "get:GetSiteStats")

	// API Routes for Certificate Management
	web.Router("/api/certificates", &controllers.CertificateController{}, "get:ListCertificates;post:UploadCertificate")
	web.Router("/api/certificates/:id", &controllers.CertificateController{}, "get:GetCertificate;delete:DeleteCertificate")

	// API Routes for WAF Rule Management
	web.Router("/api/sites/:siteId/waf/rules", &controllers.WAFRuleController{}, "get:GetRules;post:CreateRule")
	web.Router("/api/waf/rules/:id", &controllers.WAFRuleController{}, "get:GetRule;put:UpdateRule;delete:DeleteRule")
	web.Router("/api/waf/rules/:id/toggle", &controllers.WAFRuleController{}, "post:ToggleRuleStatus")
	web.Router("/api/waf/templates", &controllers.WAFRuleController{}, "get:GetRuleTemplates")
	web.Router("/api/waf/test-rule", &controllers.WAFRuleController{}, "post:TestRule")

	// WAF logs routes
	web.Router("/api/waf/logs", &controllers.WAFLogsController{}, "get:GetLogs")
	web.Router("/api/waf/logs/:id", &controllers.WAFLogsController{}, "get:GetLogDetails")

	// Admin-only API routes
	web.Router("/api/users", &controllers.UserController{}, "get:GetUsers")
	web.InsertFilter("/api/users", web.BeforeRouter, middleware.RBACMiddleware(models.RoleAdmin))

	web.Router("/api/user/:id/delete", &controllers.UserController{}, "delete:DeleteUser")
	web.InsertFilter("/api/user/:id/delete", web.BeforeRouter, middleware.RBACMiddleware(models.RoleAdmin))
}
