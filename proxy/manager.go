package proxy

import (
	"SeproWAF/models"
	"fmt"
	"sync"

	"github.com/beego/beego/v2/core/logs"
	"github.com/beego/beego/v2/server/web"
)

var (
	proxyServer *ProxyServer
	proxyMutex  sync.Mutex
)

// InitializeProxyServer initializes the reverse proxy server
func InitializeProxyServer() error {
	proxyMutex.Lock()
	defer proxyMutex.Unlock()

	// Check if server is already running
	if proxyServer != nil {
		return nil
	}

	// Get proxy port from config
	proxyPort, err := web.AppConfig.Int("ProxyPort")
	if err != nil {
		proxyPort = 8080 // Default port if not specified
	}

	// Create and start the proxy server
	proxyServer = NewProxyServer(proxyPort)

	// Start the server in a goroutine
	go func() {
		if err := proxyServer.Start(); err != nil {
			logs.Error("Proxy server error: %v", err)
		}
	}()

	logs.Info("Reverse proxy server initialized on port %d", proxyPort)
	return nil
}

// StopProxyServer stops the proxy server
func StopProxyServer() error {
	proxyMutex.Lock()
	defer proxyMutex.Unlock()

	if proxyServer != nil {
		err := proxyServer.Stop()
		proxyServer = nil
		return err
	}
	return nil
}

// RefreshSite adds or updates a site in the proxy
func RefreshSite(site *models.Site) error {
	proxyMutex.Lock()
	defer proxyMutex.Unlock()

	if proxyServer == nil {
		return fmt.Errorf("proxy server not initialized")
	}

	return proxyServer.AddOrUpdateSite(site)
}

// RemoveSiteFromProxy removes a site from the proxy
func RemoveSiteFromProxy(domain string) {
	proxyMutex.Lock()
	defer proxyMutex.Unlock()

	if proxyServer != nil {
		proxyServer.RemoveSite(domain)
	}
}
