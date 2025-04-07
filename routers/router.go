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

	// Admin-only API routes
	web.Router("/api/users", &controllers.UserController{}, "get:GetUsers")
	web.InsertFilter("/api/users", web.BeforeRouter, middleware.RBACMiddleware(models.RoleAdmin))

	web.Router("/api/user/:id/delete", &controllers.UserController{}, "delete:DeleteUser")
	web.InsertFilter("/api/user/:id/delete", web.BeforeRouter, middleware.RBACMiddleware(models.RoleAdmin))
}
