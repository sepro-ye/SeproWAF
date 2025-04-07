package proxy

import (
	"SeproWAF/models"
	"context"
	"fmt"
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"
	"sync"
	"time"

	"github.com/beego/beego/v2/client/orm"
	"github.com/beego/beego/v2/core/logs"
)

// ProxyServer represents the reverse proxy server
type ProxyServer struct {
	server      *http.Server
	domainMap   map[string]*SiteProxy
	mapMutex    sync.RWMutex
	port        int
	defaultHost string
}

// SiteProxy represents a site's proxy configuration
type SiteProxy struct {
	Site             *models.Site
	ReverseProxy     *httputil.ReverseProxy
	LastAccessedTime time.Time
}

// NewProxyServer creates a new proxy server
func NewProxyServer(port int) *ProxyServer {
	server := &ProxyServer{
		domainMap:   make(map[string]*SiteProxy),
		mapMutex:    sync.RWMutex{},
		port:        port,
		defaultHost: "localhost",
	}

	// Create HTTP server
	server.server = &http.Server{
		Addr:    fmt.Sprintf(":%d", port),
		Handler: server,
	}

	return server
}

// Start starts the proxy server
func (ps *ProxyServer) Start() error {
	// Load active sites from database
	err := ps.LoadActiveSites()
	if err != nil {
		return fmt.Errorf("failed to load active sites: %v", err)
	}

	// Start monitoring for site changes
	go ps.MonitorSiteChanges()

	// Start the server
	logs.Info("Starting reverse proxy server on port %d", ps.port)
	return ps.server.ListenAndServe()
}

// Stop stops the proxy server
func (ps *ProxyServer) Stop() error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	logs.Info("Stopping reverse proxy server")
	return ps.server.Shutdown(ctx)
}

// LoadActiveSites loads all active sites from the database
func (ps *ProxyServer) LoadActiveSites() error {
	o := orm.NewOrm()
	var sites []*models.Site

	_, err := o.QueryTable(new(models.Site).TableName()).
		Filter("status", models.SiteStatusActive).
		All(&sites)

	if err != nil {
		return err
	}

	for _, site := range sites {
		err = ps.AddOrUpdateSite(site)
		if err != nil {
			logs.Error("Failed to add site %s: %v", site.Domain, err)
		}
	}

	return nil
}

// MonitorSiteChanges periodically checks for changes in site configurations
func (ps *ProxyServer) MonitorSiteChanges() {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			ps.LoadActiveSites() // Refresh the site list
		}
	}
}

// ServeHTTP handles HTTP requests
func (ps *ProxyServer) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	host := r.Host

	// Strip port from host if present
	if hostWithoutPort, _, err := net.SplitHostPort(host); err == nil {
		host = hostWithoutPort
	}

	// Find the site proxy for this host
	ps.mapMutex.RLock()
	siteProxy, exists := ps.domainMap[host]
	ps.mapMutex.RUnlock()

	// If site not found, return 404
	if !exists {
		logs.Debug("Domain not found: %s", host)
		http.Error(w, "Site not found", http.StatusNotFound)
		return
	}

	// Update last access time
	siteProxy.LastAccessedTime = time.Now()

	// Update request count
	go func(siteID int) {
		site := &models.Site{ID: siteID}
		o := orm.NewOrm()
		if err := o.Read(site); err != nil {
			logs.Error("Failed to read site %d: %v", siteID, err)
			return
		}
		site.RequestCount++
		if _, err := o.Update(site, "RequestCount"); err != nil {
			logs.Error("Failed to update request count for site %d: %v", siteID, err)
		}
	}(siteProxy.Site.ID)

	// Forward the request to the backend server
	siteProxy.ReverseProxy.ServeHTTP(w, r)
}

// AddOrUpdateSite adds or updates a site in the proxy
func (ps *ProxyServer) AddOrUpdateSite(site *models.Site) error {
	// Skip if site is not active
	if site.Status != models.SiteStatusActive {
		// Remove site if it exists
		ps.RemoveSite(site.Domain)
		return nil
	}

	// Parse the target URL
	targetURL, err := url.Parse(site.TargetURL)
	if err != nil {
		return fmt.Errorf("invalid target URL for site %s: %v", site.Domain, err)
	}

	// Create a reverse proxy
	proxy := httputil.NewSingleHostReverseProxy(targetURL)

	// Configure custom error handling for the proxy
	proxy.ErrorHandler = func(w http.ResponseWriter, r *http.Request, err error) {
		logs.Error("Proxy error for %s: %v", site.Domain, err)
		http.Error(w, "Backend server error", http.StatusBadGateway)
	}

	// Modify the director to update the Host header
	originalDirector := proxy.Director
	proxy.Director = func(req *http.Request) {
		originalDirector(req)

		// Update the Host header to the target host
		req.Host = targetURL.Host
	}

	// Create or update site proxy
	siteProxy := &SiteProxy{
		Site:             site,
		ReverseProxy:     proxy,
		LastAccessedTime: time.Now(),
	}

	// Add to domain map
	ps.mapMutex.Lock()
	ps.domainMap[site.Domain] = siteProxy
	ps.mapMutex.Unlock()

	logs.Info("Added/updated site in proxy: %s -> %s", site.Domain, site.TargetURL)
	return nil
}

// RemoveSite removes a site from the proxy
func (ps *ProxyServer) RemoveSite(domain string) {
	ps.mapMutex.Lock()
	defer ps.mapMutex.Unlock()

	if _, exists := ps.domainMap[domain]; exists {
		delete(ps.domainMap, domain)
		logs.Info("Removed site from proxy: %s", domain)
	}
}
