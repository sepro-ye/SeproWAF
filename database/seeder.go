package database

import (
	"SeproWAF/models"
	"errors"

	"github.com/beego/beego/v2/client/orm"
	"github.com/beego/beego/v2/core/logs"
)

// SeedAdminUser creates an admin user if it doesn't already exist
func SeedAdminUser(username, email, password string) (int64, error) {
	if username == "" || email == "" || password == "" {
		return 0, errors.New("username, email, and password are required")
	}

	o := orm.NewOrm()

	// Check if admin already exists
	exist := o.QueryTable(new(models.User)).Filter("Username", username).Exist()
	if exist {
		logs.Info("Admin user already exists")
		return 0, nil
	}

	// Create admin user
	admin := &models.User{
		Username: username,
		Email:    email,
		Role:     models.RoleAdmin,
	}

	if err := admin.SetPassword(password); err != nil {
		logs.Error("Failed to set password:", err)
		return 0, err
	}

	// Insert admin
	id, err := o.Insert(admin)
	if err != nil {
		logs.Error("Failed to create admin:", err)
		return 0, err
	}

	logs.Info("Admin user created with ID:", id)
	return id, nil
}

// SeedDemoData creates demo data for testing
func SeedDemoData() error {
	// You can add code here to seed test data for your WAF system
	// For example: create sample sites, rules, etc.
	return nil
}
