package database

import (
	"database/sql"

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
	dsn := dbUser + ":" + dbPass + "@tcp(" + dbHost + ":" + dbPort + ")/" + dbName + "?charset=utf8mb4&loc=Local"

	// Ensure the database exists
	if err := ensureDatabaseExists(dbUser, dbPass, dbHost, dbPort, dbName); err != nil {
		return err
	}

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

// ensureDatabaseExists ensures that the database exists, creating it if necessary
func ensureDatabaseExists(dbUser, dbPass, dbHost, dbPort, dbName string) error {
	// Use the sql package to execute the SQL statement
	db, err := sql.Open("mysql", dbUser+":"+dbPass+"@tcp("+dbHost+":"+dbPort+")/")
	if err != nil {
		logs.Error("Failed to connect to MySQL server:", err)
		return err
	}
	defer db.Close()

	_, err = db.Exec("CREATE DATABASE IF NOT EXISTS " + dbName)
	if err != nil {
		logs.Error("Failed to create database:", err)
	}
	return err
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
