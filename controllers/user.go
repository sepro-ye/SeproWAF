package controllers

import (
	"SeproWAF/models"
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/beego/beego/v2/client/orm"
	"github.com/beego/beego/v2/server/web"
)

// UserController handles user management operations
type UserController struct {
	web.Controller
}

// GetProfile returns the current user's profile
func (c *UserController) GetProfile() {
	// Get user ID from context (set by middleware)
	userID := c.Ctx.Input.GetData("userID").(int)

	o := orm.NewOrm()
	user := models.User{ID: userID}
	err := o.Read(&user)

	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusNotFound)
		c.Data["json"] = map[string]string{"error": "User not found"}
		c.ServeJSON()
		return
	}

	// Omit password from response
	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = map[string]interface{}{
		"id":         user.ID,
		"username":   user.Username,
		"email":      user.Email,
		"role":       user.Role,
		"created_at": user.CreatedAt,
	}
	c.ServeJSON()
}

// GetUsers returns a list of all users (admin only)
func (c *UserController) GetUsers() {
	// Get user role from context (set by middleware)
	role := c.Ctx.Input.GetData("userRole").(models.Role)

	// Check if user is admin
	if role != models.RoleAdmin {
		c.Ctx.Output.SetStatus(http.StatusForbidden)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	o := orm.NewOrm()
	var users []models.User

	_, err := o.QueryTable("users").All(&users)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusInternalServerError)
		c.Data["json"] = map[string]string{"error": "Failed to fetch users"}
		c.ServeJSON()
		return
	}

	// Prepare response without sensitive info
	var result []map[string]interface{}
	for _, user := range users {
		result = append(result, map[string]interface{}{
			"id":         user.ID,
			"username":   user.Username,
			"email":      user.Email,
			"role":       user.Role,
			"created_at": user.CreatedAt,
		})
	}

	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = result
	c.ServeJSON()
}

// GetUser returns details of a specific user
func (c *UserController) GetUser() {
	// Get user role and ID from context (set by middleware)
	currentUserRole := c.Ctx.Input.GetData("userRole").(models.Role)
	currentUserID := c.Ctx.Input.GetData("userID").(int)

	// Get requested user ID from URL parameter
	requestedUserID, err := strconv.Atoi(c.Ctx.Input.Param(":id"))
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid user ID"}
		c.ServeJSON()
		return
	}

	// Check if user is admin or requesting their own profile
	if currentUserRole != models.RoleAdmin && currentUserID != requestedUserID {
		c.Ctx.Output.SetStatus(http.StatusForbidden)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	o := orm.NewOrm()
	user := models.User{ID: requestedUserID}
	err = o.Read(&user)

	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusNotFound)
		c.Data["json"] = map[string]string{"error": "User not found"}
		c.ServeJSON()
		return
	}

	// Omit password from response
	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = map[string]interface{}{
		"id":         user.ID,
		"username":   user.Username,
		"email":      user.Email,
		"role":       user.Role,
		"created_at": user.CreatedAt,
	}
	c.ServeJSON()
}

// UpdateUser updates a user's information
func (c *UserController) UpdateUser() {
	// Get user role and ID from context (set by middleware)
	currentUserRole := c.Ctx.Input.GetData("userRole").(models.Role)
	currentUserID := c.Ctx.Input.GetData("userID").(int)

	// Get requested user ID from URL parameter
	requestedUserID, err := strconv.Atoi(c.Ctx.Input.Param(":id"))
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid user ID"}
		c.ServeJSON()
		return
	}

	// Check if user is admin or updating their own profile
	if currentUserRole != models.RoleAdmin && currentUserID != requestedUserID {
		c.Ctx.Output.SetStatus(http.StatusForbidden)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	// Parse request body
	var updateData struct {
		Email    string `json:"email"`
		Password string `json:"password,omitempty"`
	}

	if err := json.Unmarshal(c.Ctx.Input.RequestBody, &updateData); err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid request"}
		c.ServeJSON()
		return
	}

	// Fetch the user
	o := orm.NewOrm()
	user := models.User{ID: requestedUserID}
	err = o.Read(&user)

	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusNotFound)
		c.Data["json"] = map[string]string{"error": "User not found"}
		c.ServeJSON()
		return
	}

	// Update fields
	if updateData.Email != "" {
		user.Email = updateData.Email
	}

	if updateData.Password != "" {
		if err := user.SetPassword(updateData.Password); err != nil {
			c.Ctx.Output.SetStatus(http.StatusInternalServerError)
			c.Data["json"] = map[string]string{"error": "Failed to update password"}
			c.ServeJSON()
			return
		}
	}

	// Save changes
	_, err = o.Update(&user)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusInternalServerError)
		c.Data["json"] = map[string]string{"error": "Failed to update user"}
		c.ServeJSON()
		return
	}

	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = map[string]string{"message": "User updated successfully"}
	c.ServeJSON()
}

// DeleteUser deletes a user (admin only)
func (c *UserController) DeleteUser() {
	// Get user role from context (set by middleware)
	role := c.Ctx.Input.GetData("userRole").(models.Role)

	// Check if user is admin
	if role != models.RoleAdmin {
		c.Ctx.Output.SetStatus(http.StatusForbidden)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	// Get user ID from URL parameter
	userID, err := strconv.Atoi(c.Ctx.Input.Param(":id"))
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid user ID"}
		c.ServeJSON()
		return
	}

	// Delete the user
	o := orm.NewOrm()
	user := models.User{ID: userID}
	_, err = o.Delete(&user)

	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusInternalServerError)
		c.Data["json"] = map[string]string{"error": "Failed to delete user"}
		c.ServeJSON()
		return
	}

	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = map[string]string{"message": "User deleted successfully"}
	c.ServeJSON()
}
