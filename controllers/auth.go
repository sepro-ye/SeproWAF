package controllers

import (
	"SeproWAF/models"
	"encoding/json"
	"net/http"
	"time"

	"github.com/beego/beego/v2/client/orm"
	"github.com/beego/beego/v2/server/web"
	"github.com/golang-jwt/jwt/v5"
)

// AuthController handles authentication related operations
type AuthController struct {
	web.Controller
}

// LoginRequest represents the login request body
type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

// RegisterRequest represents the registration request body
type RegisterRequest struct {
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

// TokenResponse represents the token response
type TokenResponse struct {
	Token     string `json:"token"`
	ExpiresAt int64  `json:"expires_at"`
	UserID    int    `json:"user_id"`
	Username  string `json:"username"`
	Role      string `json:"role"`
}

// Register handles user registration
func (c *AuthController) Register() {
	var req RegisterRequest
	if err := json.Unmarshal(c.Ctx.Input.RequestBody, &req); err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid request"}
		c.ServeJSON()
		return
	}

	// Validate request data
	if req.Username == "" || req.Email == "" || req.Password == "" {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Username, email, and password are required"}
		c.ServeJSON()
		return
	}

	// Create new user
	user := &models.User{
		Username: req.Username,
		Email:    req.Email,
	}

	if err := user.SetPassword(req.Password); err != nil {
		c.Ctx.Output.SetStatus(http.StatusInternalServerError)
		c.Data["json"] = map[string]string{"error": "Failed to hash password"}
		c.ServeJSON()
		return
	}

	o := orm.NewOrm()
	_, err := o.Insert(user)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Username or email already exists"}
		c.ServeJSON()
		return
	}

	c.Ctx.Output.SetStatus(http.StatusCreated)
	c.Data["json"] = map[string]string{"message": "User registered successfully"}
	c.ServeJSON()
}

// Login handles user authentication
func (c *AuthController) Login() {
	var req LoginRequest
	if err := json.Unmarshal(c.Ctx.Input.RequestBody, &req); err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid request format"}
		c.ServeJSON()
		return
	}

	// Find user by username
	user := &models.User{Username: req.Username}
	o := orm.NewOrm()
	err := o.QueryTable(user.TableName()).Filter("username", req.Username).One(user)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusUnauthorized)
		c.Data["json"] = map[string]string{"error": "Invalid credentials"}
		c.ServeJSON()
		return
	}

	// Check password
	if !user.CheckPassword(req.Password) {
		c.Ctx.Output.SetStatus(http.StatusUnauthorized)
		c.Data["json"] = map[string]string{"error": "Invalid credentials"}
		c.ServeJSON()
		return
	}

	// Generate JWT token
	secret, _ := web.AppConfig.String("JWTSecret")
	expirationTime := time.Now().Add(24 * time.Hour)
	claims := jwt.MapClaims{
		"user_id":  user.ID,
		"username": user.Username,
		"role":     user.Role,
		"exp":      expirationTime.Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(secret))
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusInternalServerError)
		c.Data["json"] = map[string]string{"error": "Failed to generate token"}
		c.ServeJSON()
		return
	}

	// Return token response
	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = TokenResponse{
		Token:     tokenString,
		ExpiresAt: expirationTime.Unix(),
		UserID:    user.ID,
		Username:  user.Username,
		Role:      string(user.Role),
	}
	c.ServeJSON()
}

// Logout handles user logout
func (c *AuthController) Logout() {
	// Get the token from the Authorization header
	authHeader := c.Ctx.Input.Header("Authorization")
	if authHeader != "" && len(authHeader) > 7 && authHeader[:7] == "Bearer " {
		tokenString := authHeader[7:] // Remove 'Bearer ' prefix

		// Parse token to get expiration time
		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			secret, _ := web.AppConfig.String("JWTSecret")
			return []byte(secret), nil
		})

		if err == nil && token.Valid {
			if claims, ok := token.Claims.(jwt.MapClaims); ok {
				// Get expiration time
				if exp, ok := claims["exp"].(float64); ok {
					expiryTime := time.Unix(int64(exp), 0)

					// Blacklist the token
					err = models.BlacklistToken(tokenString, expiryTime)
					if err != nil {
						c.Ctx.Output.SetStatus(http.StatusInternalServerError)
						c.Data["json"] = map[string]string{"error": "Failed to invalidate token"}
						c.ServeJSON()
						return
					}
				}
			}
		}
	}

	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = map[string]string{"message": "Logged out successfully"}
	c.ServeJSON()
}
