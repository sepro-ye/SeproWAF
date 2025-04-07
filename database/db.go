package database

import (
	"github.com/beego/beego/v2/client/orm"
	"github.com/beego/beego/v2/core/logs"
	"github.com/beego/beego/v2/server/web"
	_ "github.com/go-sql-driver/mysql"
)

// InitDatabase initializes the database connection
func InitDatabase() error {
	// Get database configuration from app.conf
	dbUser, _ := web.AppConfig.String("MYSQL_USER")
	dbPass, _ := web.AppConfig.String("MYSQL_PASSWORD")
	dbHost, _ := web.AppConfig.String("MYSQL_HOST")
	dbPort, _ := web.AppConfig.String("MYSQL_PORT")
	dbName, _ := web.AppConfig.String("MYSQL_DATABASE")

	// Format: username:password@tcp(host:port)/dbname?charset=utf8&loc=Local
	dsn := dbUser + ":" + dbPass + "@tcp(" + dbHost + ":" + dbPort + ")/" + dbName + "?charset=utf8&loc=Local"

	// Register driver
	err := orm.RegisterDriver("mysql", orm.DRMySQL)
	if err != nil {
		logs.Error("Failed to register MySQL driver:", err)
		return err
	}

	// Register default database
	err = orm.RegisterDataBase("default", "mysql", dsn)
	if err != nil {
		logs.Error("Failed to register database:", err)
		return err
	}

	logs.Info("Database connection established successfully")
	return nil
}

// MigrateDatabase creates or updates database tables
func MigrateDatabase() error {
	// Create tables automatically
	err := orm.RunSyncdb("default", false, true)
	if err != nil {
		logs.Error("Failed to sync database:", err)
		return err
	}

	logs.Info("Database schema migrated successfully")
	return nil
}
