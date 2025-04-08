package database

import (
	"github.com/beego/beego/v2/client/orm"
	"github.com/beego/beego/v2/core/logs"
)

// RunMigrations runs database migrations
func RunMigrations() error {
	logs.Info("Running database migrations...")

	// Add WAFEnabled column to sites table if it doesn't exist
	_, err := orm.NewOrm().Raw("ALTER TABLE sites ADD COLUMN IF NOT EXISTS waf_enabled BOOLEAN NOT NULL DEFAULT TRUE").Exec()
	if err != nil {
		logs.Error("Failed to add WAFEnabled column to sites table: %v", err)
		return err
	}
	logs.Info("Migration: Added WAFEnabled column to sites table")

	return nil
}
