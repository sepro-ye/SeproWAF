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

	// Get proxy ports from config
	httpPort, err := web.AppConfig.Int("ProxyPort")
	if err != nil {
		httpPort = 8080 // Default HTTP port if not specified
	}

	httpsPort, err := web.AppConfig.Int("ProxyHTTPSPort")
	if err != nil {
		httpsPort = 8443 // Default HTTPS port if not specified
	}

	// Create and start the proxy server
	proxyServer = NewProxyServer(httpPort, httpsPort)

	// Start the server in a goroutine
	go func() {
		if err := proxyServer.Start(); err != nil {
			logs.Error("Proxy server error: %v", err)
		}
	}()

	return nil
}

// StopProxyServer stops the proxy server
func StopProxyServer() error {
	proxyMutex.Lock()
	defer proxyMutex.Unlock()

	if proxyServer != nil {
		err := proxyServer.Stop()
		proxyServer = nil

		// Shutdown the WAF log service
		if wafLogService != nil {
			wafLogService.Shutdown()
		}

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
