package middleware

import (
	"SeproWAF/models"
	"net/http"
	"strings"

	"github.com/beego/beego/v2/server/web"
	"github.com/beego/beego/v2/server/web/context"
	"github.com/golang-jwt/jwt/v5"
)

// JWTMiddleware validates JWT tokens and sets user information in the context
func JWTMiddleware() web.FilterFunc {
	return func(ctx *context.Context) {
		// Skip middleware for login and register routes
		if ctx.Request.URL.Path == "/api/auth/login" || ctx.Request.URL.Path == "/api/auth/register" {
			return
		}

		// Get the JWT token from the Authorization header
		authHeader := ctx.Input.Header("Authorization")
		if authHeader == "" {
			ctx.Output.SetStatus(http.StatusUnauthorized)
			ctx.Output.JSON(map[string]string{"error": "Authorization header missing"}, true, false)
			return
		}

		// Check if the header has the Bearer prefix
		parts := strings.SplitN(authHeader, " ", 2)
		if !(len(parts) == 2 && parts[0] == "Bearer") {
			ctx.Output.SetStatus(http.StatusUnauthorized)
			ctx.Output.JSON(map[string]string{"error": "Invalid authorization format"}, true, false)
			return
		}

		tokenString := parts[1]

		// Check if the token is blacklisted
		if models.IsTokenBlacklisted(tokenString) {
			ctx.Output.SetStatus(http.StatusUnauthorized)
			ctx.Output.JSON(map[string]string{"error": "Token has been invalidated, please login again"}, true, false)
			return
		}

		// Parse and validate the token
		secret, _ := web.AppConfig.String("JWTSecret")
		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			return []byte(secret), nil
		})

		if err != nil || !token.Valid {
			ctx.Output.SetStatus(http.StatusUnauthorized)
			ctx.Output.JSON(map[string]string{"error": "Invalid or expired token"}, true, false)
			return
		}

		// Extract claims
		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			ctx.Output.SetStatus(http.StatusUnauthorized)
			ctx.Output.JSON(map[string]string{"error": "Invalid token claims"}, true, false)
			return
		}

		// Set user information in context
		ctx.Input.SetData("userID", int(claims["user_id"].(float64)))
		ctx.Input.SetData("username", claims["username"].(string))
		ctx.Input.SetData("userRole", models.Role(claims["role"].(string)))
	}
}

// RBACMiddleware checks if the user has the required role
func RBACMiddleware(requiredRole models.Role) web.FilterFunc {
	return func(ctx *context.Context) {
		// Get user role from context (set by JWTMiddleware)
		userRole, ok := ctx.Input.GetData("userRole").(models.Role)
		if !ok {
			ctx.Output.SetStatus(http.StatusUnauthorized)
			ctx.Output.JSON(map[string]string{"error": "Authentication required"}, true, false)
			return
		}

		// Check if user has the required role
		if requiredRole == models.RoleAdmin && userRole != models.RoleAdmin {
			ctx.Output.SetStatus(http.StatusForbidden)
			ctx.Output.JSON(map[string]string{"error": "Access denied"}, true, false)
			return
		}
	}
}
