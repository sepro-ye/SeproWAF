package main

import (
	"SeproWAF/database"
	_ "SeproWAF/models"
	"flag"
	"fmt"
	"os"

	"github.com/beego/beego/v2/server/web"
)

// Command line flags
var (
	configPath  = flag.String("config", "../../conf/app.conf", "Path to configuration file")
	migrate     = flag.Bool("migrate", false, "Run database migrations")
	createAdmin = flag.Bool("create-admin", false, "Create admin user")
	adminUser   = flag.String("admin-user", "admin", "Admin username")
	adminEmail  = flag.String("admin-email", "admin@admin.com", "Admin email")
	adminPass   = flag.String("admin-pass", "", "Admin password")
	seed        = flag.Bool("seed", false, "Seed demo data")
)

func init() {
	flag.Parse()

	// Load configuration
	err := web.LoadAppConfig("ini", *configPath)
	if err != nil {
		fmt.Printf("Failed to load config: %v\n", err)
		os.Exit(1)
	}

	// Initialize database connection
	if err := database.InitDatabase(); err != nil {
		fmt.Printf("Failed to initialize database: %v\n", err)
		os.Exit(1)
	}
}

func main() {
	// Run migrations if requested
	if *migrate {
		fmt.Println("Running database migrations...")
		if err := database.MigrateDatabase(); err != nil {
			fmt.Printf("Migration failed: %v\n", err)
			os.Exit(1)
		}
		fmt.Println("Database migrations completed successfully")
	}

	// Create admin user if requested
	if *createAdmin {
		if *adminPass == "" {
			fmt.Println("Error: Admin password is required")
			flag.PrintDefaults()
			os.Exit(1)
		}

		fmt.Printf("Creating admin user '%s'...\n", *adminUser)
		id, err := database.SeedAdminUser(*adminUser, *adminEmail, *adminPass)
		if err != nil {
			fmt.Printf("Failed to create admin user: %v\n", err)
			os.Exit(1)
		}
		if id > 0 {
			fmt.Printf("Admin user created with ID: %d\n", id)
			fmt.Printf("Username: %s\n", *adminUser)
			fmt.Printf("Email: %s\n", *adminEmail)
			fmt.Println("Please keep these credentials safe!")
		} else {
			fmt.Println("Admin user already exists, no action taken")
		}
	}

	// Seed demo data if requested
	if *seed {
		fmt.Println("Seeding demo data...")
		if err := database.SeedDemoData(); err != nil {
			fmt.Printf("Failed to seed demo data: %v\n", err)
			os.Exit(1)
		}
		fmt.Println("Demo data seeded successfully")
	}

	// If no actions were specified, print help
	if !*migrate && !*createAdmin && !*seed {
		fmt.Println("No actions specified")
		flag.PrintDefaults()
	}
}
