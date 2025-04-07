package models

import (
	"crypto/sha256"
	"encoding/hex"
	"time"

	"github.com/beego/beego/v2/client/orm"
)

// BlacklistedToken represents a token that has been invalidated
type BlacklistedToken struct {
	ID        int    `orm:"pk;auto"`
	TokenHash string `orm:"size(64);unique"` // Store SHA-256 hash instead of full token
	ExpiresAt time.Time
	CreatedAt time.Time `orm:"auto_now_add"`
}

// TableName provides the name of the table
func (t *BlacklistedToken) TableName() string {
	return "blacklisted_tokens"
}

func init() {
	orm.RegisterModel(new(BlacklistedToken))
}

// hashToken creates a SHA-256 hash of the token
func hashToken(token string) string {
	hash := sha256.Sum256([]byte(token))
	return hex.EncodeToString(hash[:])
}

// IsTokenBlacklisted checks if a token is in the blacklist
func IsTokenBlacklisted(tokenString string) bool {
	o := orm.NewOrm()
	tokenHash := hashToken(tokenString)
	return o.QueryTable(new(BlacklistedToken).TableName()).
		Filter("token_hash", tokenHash).
		Filter("expires_at__gte", time.Now()).
		Exist()
}

// BlacklistToken adds a token to the blacklist
func BlacklistToken(tokenString string, expiresAt time.Time) error {
	o := orm.NewOrm()
	tokenHash := hashToken(tokenString)
	_, err := o.Insert(&BlacklistedToken{
		TokenHash: tokenHash,
		ExpiresAt: expiresAt,
	})
	return err
}

// CleanupExpiredTokens removes expired tokens from the blacklist
func CleanupExpiredTokens() (int64, error) {
	o := orm.NewOrm()
	return o.QueryTable(new(BlacklistedToken).TableName()).
		Filter("expires_at__lt", time.Now()).
		Delete()
}
