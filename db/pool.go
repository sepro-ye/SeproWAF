package db

import (
	"database/sql"
	"sync"
	"time"

	"github.com/beego/beego/v2/client/orm"
	"github.com/beego/beego/v2/core/logs"
	_ "github.com/go-sql-driver/mysql"
)

var (
	poolInstance *ConnectionPool
	poolOnce     sync.Once
)

// ConnectionPool manages database connections
type ConnectionPool struct {
	db           *sql.DB
	maxIdleConns int
	maxOpenConns int
	maxLifetime  time.Duration
	mutex        sync.Mutex
}

// GetPool returns a singleton connection pool
func GetPool() *ConnectionPool {
	poolOnce.Do(func() {
		// Get the underlying database connection from orm
		db, err := orm.GetDB()
		if err != nil {
			logs.Error("Failed to get database connection: %v", err)
			return
		}

		poolInstance = &ConnectionPool{
			db:           db,
			maxIdleConns: 50,
			maxOpenConns: 100,
			maxLifetime:  time.Minute * 5,
		}

		// Configure connection pool
		poolInstance.db.SetMaxIdleConns(poolInstance.maxIdleConns)
		poolInstance.db.SetMaxOpenConns(poolInstance.maxOpenConns)
		poolInstance.db.SetConnMaxLifetime(poolInstance.maxLifetime)

		logs.Info("Database connection pool initialized with %d max connections", poolInstance.maxOpenConns)
	})

	return poolInstance
}

// GetOrm returns an orm object from the pool
func (p *ConnectionPool) GetOrm() orm.Ormer {
	return orm.NewOrmUsingDB("default")
}

// ConfigurePool adjusts the pool settings
func (p *ConnectionPool) ConfigurePool(maxIdle, maxOpen int, maxLifetime time.Duration) {
	p.mutex.Lock()
	defer p.mutex.Unlock()

	p.maxIdleConns = maxIdle
	p.maxOpenConns = maxOpen
	p.maxLifetime = maxLifetime

	p.db.SetMaxIdleConns(maxIdle)
	p.db.SetMaxOpenConns(maxOpen)
	p.db.SetConnMaxLifetime(maxLifetime)

	logs.Info("Connection pool reconfigured: maxIdle=%d, maxOpen=%d, maxLifetime=%v",
		maxIdle, maxOpen, maxLifetime)
}
