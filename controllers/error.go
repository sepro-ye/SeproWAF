package controllers

import (
	beego "github.com/beego/beego/v2/server/web"
)

// ErrorController handles HTTP errors
type ErrorController struct {
	beego.Controller
}

// Error404 handles 404 errors
func (c *ErrorController) Error404() {
	c.Data["Title"] = "Page Not Found - SeproWAF"
	c.Data["ErrorCode"] = 404
	c.Data["ErrorMessage"] = "The page you're looking for doesn't exist"
	c.Layout = "layout.tpl"
	c.TplName = "error.tpl"
}

// Error500 handles 500 errors
func (c *ErrorController) Error500() {
	c.Data["Title"] = "Server Error - SeproWAF"
	c.Data["ErrorCode"] = 500
	c.Data["ErrorMessage"] = "Internal server error"
	c.Layout = "layout.tpl"
	c.TplName = "error.tpl"
}

// Error401 handles unauthorized errors
func (c *ErrorController) Error401() {
	c.Data["Title"] = "Unauthorized - SeproWAF"
	c.Data["ErrorCode"] = 401
	c.Data["ErrorMessage"] = "You're not authorized to access this resource"
	c.Layout = "layout.tpl"
	c.TplName = "error.tpl"
}

// Error403 handles forbidden errors
func (c *ErrorController) Error403() {
	c.Data["Title"] = "Access Denied - SeproWAF"
	c.Data["ErrorCode"] = 403
	c.Data["ErrorMessage"] = "Access to this resource is forbidden"
	c.Layout = "layout.tpl"
	c.TplName = "error.tpl"
}
