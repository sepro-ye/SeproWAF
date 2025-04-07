package models

import (
	"time"

	"github.com/beego/beego/v2/client/orm"
	"golang.org/x/crypto/bcrypt"
)

// Role type for user roles
type Role string

const (
	RoleAdmin Role = "admin"
	RoleUser  Role = "user"
)

// User represents a user in the WAF system
type User struct {
	ID        int       `orm:"pk;auto"`
	Username  string    `orm:"size(128);unique"`
	Email     string    `orm:"size(128);unique"`
	Password  string    `orm:"size(128)"`
	Role      Role      `orm:"size(16);default(user)"`
	CreatedAt time.Time `orm:"auto_now_add"`
	UpdatedAt time.Time `orm:"auto_now"`
}

// TableName provides the name of the table in the database
func (u *User) TableName() string {
	return "users"
}

// SetPassword hashes the password before saving
func (u *User) SetPassword(password string) error {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	u.Password = string(hashedPassword)
	return nil
}

// CheckPassword verifies the provided password against the stored hash
func (u *User) CheckPassword(password string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(password))
	return err == nil
}

// IsAdmin checks if the user has admin role
func (u *User) IsAdmin() bool {
	return u.Role == RoleAdmin
}

// IsUser checks if the user has user role
func (u *User) IsUser() bool {
	return u.Role == RoleUser
}

func init() {
	orm.RegisterModel(new(User))
}
