package controllers

import (
	"SeproWAF/models"
	"strings"

	"github.com/beego/beego/v2/client/orm"
	"github.com/beego/beego/v2/core/logs"
	"github.com/beego/beego/v2/server/web"
	"github.com/golang-jwt/jwt/v5"
)

// UIController handles UI page rendering
type UIController struct {
	web.Controller
}

// Auth pages
func (c *UIController) Login() {
	c.Data["Title"] = "Login"
	c.Layout = "layout.tpl"
	c.TplName = "auth/login.tpl"
}

func (c *UIController) Register() {
	c.Data["Title"] = "Register"
	c.Layout = "layout.tpl"
	c.TplName = "auth/register.tpl"
}

// Dashboard page
func (c *UIController) Dashboard() {
	// Try to get user from Authorization header first
	user := c.GetUserFromAuthHeader()

	// If not found in header, try cookie
	if user == nil {
		// Try localStorage via JavaScript check
		c.Data["Title"] = "Dashboard"
		c.Data["CheckAuth"] = true // Flag to trigger client-side auth check
		c.Layout = "layout.tpl"
		c.TplName = "dashboard/index.tpl"
		return
	}

	// User is authenticated
	c.Data["Title"] = "Dashboard"
	c.Data["Username"] = user.Username
	c.Data["IsAuthenticated"] = true
	c.Data["IsAdmin"] = user.IsAdmin()
	c.Layout = "layout.tpl"
	c.TplName = "dashboard/index.tpl"
}

// User profile
func (c *UIController) UserProfile() {
	// Get authenticated user with the more complete method
	user := c.GetUserFromJWT()
	if user == nil {
		c.Ctx.Redirect(302, "/auth/login")
		return
	}

	// Successful authentication
	c.Data["Title"] = "User Profile"
	c.Data["Username"] = user.Username
	c.Data["Email"] = user.Email
	c.Data["Role"] = user.Role
	c.Data["IsAuthenticated"] = true
	c.Data["IsAdmin"] = user.IsAdmin()

	c.Layout = "layout.tpl"
	c.TplName = "user/profile.tpl"
}

// User management (admin only)
func (c *UIController) UserList() {
	user := c.GetUserFromJWT()
	if user == nil {
		c.Redirect("/auth/login", 302)
		return
	}

	if !user.IsAdmin() {
		c.Redirect("/dashboard", 302)
		return
	}

	c.Data["Title"] = "User Management"
	c.Data["Username"] = user.Username
	c.Data["IsAuthenticated"] = true
	c.Data["IsAdmin"] = user.IsAdmin()
	c.Layout = "layout.tpl"
	c.TplName = "user/list.tpl"
}

// Helper to get user from JWT token
func (c *UIController) GetUserFromJWT() *models.User {
	authHeader := c.Ctx.Input.Header("Authorization")
	if authHeader == "" {
		// Try to get token from cookie
		jwtCookie := c.Ctx.GetCookie("jwt_token")
		if jwtCookie == "" {
			return nil
		}
		authHeader = "Bearer " + jwtCookie
	}

	parts := strings.SplitN(authHeader, " ", 2)
	if !(len(parts) == 2 && parts[0] == "Bearer") {
		return nil
	}

	tokenString := parts[1]
	secret, _ := web.AppConfig.String("JWTSecret")
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return []byte(secret), nil
	})

	if err != nil || !token.Valid {
		return nil
	}

	// Extract claims
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return nil
	}

	// Get user from database
	userID := int(claims["user_id"].(float64))
	o := orm.NewOrm()
	user := models.User{ID: userID}
	err = o.Read(&user)
	if err != nil {
		return nil
	}

	return &user
}

// GetUserFromAuthHeader retrieves user from Authorization header
func (c *UIController) GetUserFromAuthHeader() *models.User {
	authHeader := c.Ctx.Input.Header("Authorization")
	if authHeader == "" {
		return nil
	}

	parts := strings.SplitN(authHeader, " ", 2)
	if !(len(parts) == 2 && parts[0] == "Bearer") {
		return nil
	}

	tokenString := parts[1]
	secret, _ := web.AppConfig.String("JWTSecret")
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return []byte(secret), nil
	})

	if err != nil || !token.Valid {
		return nil
	}

	// Extract claims
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return nil
	}

	// Get user from database
	userID := int(claims["user_id"].(float64))
	o := orm.NewOrm()
	user := models.User{ID: userID}
	err = o.Read(&user)
	if err != nil {
		return nil
	}

	return &user
}

// GetToken extracts the JWT token from request headers or cookies
func (c *UIController) GetToken() string {
	// Try Authorization header first
	authHeader := c.Ctx.Input.Header("Authorization")
	if authHeader != "" && strings.HasPrefix(authHeader, "Bearer ") {
		return strings.TrimPrefix(authHeader, "Bearer ")
	}

	// Try cookie next
	jwtCookie := c.Ctx.GetCookie("jwt_token")
	if jwtCookie != "" {
		return jwtCookie
	}

	// Log the headers and cookies for debugging
	logs.Debug("Headers: %v", c.Ctx.Request.Header)
	logs.Debug("Cookies: %v", c.Ctx.Request.Cookies())

	// No valid token found
	return ""
}

// GetUserFromToken parses the token and retrieves the user
func (c *UIController) GetUserFromToken(tokenString string) *models.User {
	// Parse the token
	secret, _ := web.AppConfig.String("JWTSecret")
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return []byte(secret), nil
	})

	if err != nil || !token.Valid {
		logs.Error("Invalid token: %v", err)
		return nil
	}

	// Get claims
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		logs.Error("Failed to get claims from token")
		return nil
	}

	// Get user ID from claims
	userID, ok := claims["user_id"].(float64)
	if !ok {
		logs.Error("Failed to get user_id from claims")
		return nil
	}

	// Fetch user from database
	o := orm.NewOrm()
	user := models.User{ID: int(userID)}
	err = o.Read(&user)
	if err != nil {
		logs.Error("Failed to find user with ID %d: %v", int(userID), err)
		return nil
	}

	return &user
}
