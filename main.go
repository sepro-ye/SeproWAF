package main

import (
	"SeproWAF/controllers"
	"SeproWAF/database"
	"SeproWAF/models"
	"SeproWAF/proxy"
	_ "SeproWAF/routers"
	"time"

	"github.com/beego/beego/v2/core/logs"
	beego "github.com/beego/beego/v2/server/web"
)

func init() {
	// Enable CopyRequestBody to access request body in controllers
	beego.BConfig.CopyRequestBody = true

	// Initialize database
	if err := database.InitDatabase(); err != nil {
		logs.Critical("Failed to initialize database: %v", err)
		panic(err)
	}

	// Run migrations
	if err := database.MigrateDatabase(); err != nil {
		logs.Critical("Failed to migrate database: %v", err)
		panic(err)
	}

	// Initialize the database connection pool
	pool := database.GetPool()

	// Configure based on app.conf settings
	maxIdle, _ := beego.AppConfig.Int("DBMaxIdleConns")
	maxOpen, _ := beego.AppConfig.Int("DBMaxOpenConns")
	maxLifetime, _ := beego.AppConfig.Int("DBConnMaxLifetime")

	if maxIdle <= 0 {
		maxIdle = 50
	}
	if maxOpen <= 0 {
		maxOpen = 100
	}
	if maxLifetime <= 0 {
		maxLifetime = 300
	}

	pool.ConfigurePool(maxIdle, maxOpen, time.Duration(maxLifetime)*time.Second)

	// Schedule token cleanup
	go func() {
		// Run immediately once at startup
		_, err := models.CleanupExpiredTokens()
		if err != nil {
			logs.Error("Initial token cleanup failed: %v", err)
		}

		ticker := time.NewTicker(6 * time.Hour) // Run every 6 hours
		defer ticker.Stop()

		for range ticker.C {
			count, err := models.CleanupExpiredTokens()
			if err != nil {
				logs.Error("Failed to clean up expired tokens: %v", err)
			} else {
				logs.Info("Cleaned up %d expired tokens", count)
			}
		}
	}()
}

func main() {
	// Configure development settings
	if beego.BConfig.RunMode == "dev" {
		beego.BConfig.WebConfig.DirectoryIndex = true
		beego.BConfig.WebConfig.StaticDir["/swagger"] = "swagger"
	}

	// Initialize proxy server
	err := proxy.InitializeProxyServer()
	if err != nil {
		logs.Error("Failed to initialize proxy server: %v", err)
		// Continue anyway - the UI will still work
	}

	// Register error handler
	beego.ErrorController(&controllers.ErrorController{})

	// Log application startup
	logs.Info("Starting SeproWAF application...")
	beego.Run()
}
