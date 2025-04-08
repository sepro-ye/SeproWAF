<div class="row mb-4">
    <div class="col-md-8">
        <h1>{{.Site.Name}}</h1>
        <p class="lead">
            <span class="badge bg-{{if eq .Site.Status "active"}}success{{else if eq .Site.Status "pending"}}warning{{else}}danger{{end}}">
                {{.Site.Status}}
            </span>
            {{.Site.Domain}}
        </p>
    </div>
    <div class="col-md-4 text-md-end">
        <div class="btn-group" role="group">
            <a href="/waf/sites/{{.Site.ID}}/edit" class="btn btn-outline-secondary">
                <i class="bi bi-pencil"></i> Edit
            </a>
            <button type="button" class="btn {{if eq .Site.Status "active"}}btn-outline-warning{{else}}btn-outline-success{{end}}" id="toggle-status-btn">
                <i class="bi {{if eq .Site.Status "active"}}bi-pause-circle{{else}}bi-play-circle{{end}}"></i>
                {{if eq .Site.Status "active"}}Disable{{else}}Enable{{end}}
            </button>
            <button type="button" class="btn btn-outline-danger" id="delete-site-btn">
                <i class="bi bi-trash"></i> Delete
            </button>
        </div>
    </div>
</div>

<div class="row mb-4">
    <div class="col-md-12">
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">Site Information</h5>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6">
                        <dl class="row">
                            <dt class="col-sm-4">Name:</dt>
                            <dd class="col-sm-8">{{.Site.Name}}</dd>
                            
                            <dt class="col-sm-4">Domain:</dt>
                            <dd class="col-sm-8">{{.Site.Domain}}</dd>
                            
                            <dt class="col-sm-4">Target URL:</dt>
                            <dd class="col-sm-8">{{.Site.TargetURL}}</dd>
                            
                            <dt class="col-sm-4">Status:</dt>
                            <dd class="col-sm-8">
                                <span class="badge bg-{{if eq .Site.Status "active"}}success{{else if eq .Site.Status "pending"}}warning{{else}}danger{{end}}">
                                    {{.Site.Status}}
                                </span>
                            </dd>

                            <dt class="col-sm-4">WAF Protection:</dt>
                            <dd class="col-sm-8">
                                <div class="d-flex align-items-center">
                                    <div class="form-check form-switch me-2">
                                        <input class="form-check-input" type="checkbox" id="waf-toggle" {{if .Site.WAFEnabled}}checked{{end}}
                                           {{if ne .Site.Status "active"}}disabled{{end}}>
                                    </div>
                                    <span id="waf-status" class="badge {{if .Site.WAFEnabled}}bg-success{{else}}bg-secondary{{end}}">
                                        {{if .Site.WAFEnabled}}Enabled{{else}}Disabled{{end}}
                                    </span>
                                </div>
                                <small class="text-muted" id="waf-help-text">
                                    {{if ne .Site.Status "active"}}
                                    WAF toggle is disabled because site is not active
                                    {{else}}
                                    Toggle the Web Application Firewall protection for this site
                                    {{end}}
                                </small>
                            </dd>

                            <dt class="col-sm-4">HTTPS:</dt>
                            <dd class="col-sm-8">
                                {{if .HasValidCertificate}}
                                <div class="alert alert-success">
                                    <i class="bi bi-lock-fill"></i> HTTPS is <strong>enabled</strong> for this site
                                    <p class="mb-0 mt-2">
                                        <strong>HTTP:</strong> <code>http://{{.Site.Domain}}:{{.ProxyPort}}</code><br>
                                        <strong>HTTPS:</strong> <code>https://{{.Site.Domain}}:{{.ProxyHTTPSPort}}</code>
                                    </p>
                                </div>
                                {{else}}
                                <div class="alert alert-secondary">
                                    <i class="bi bi-unlock"></i> HTTPS is <strong>disabled</strong> for this site
                                    <p class="mb-0">To enable HTTPS, <a href="/waf/certificates/upload">upload an SSL certificate</a> and assign it to this site.</p>
                                </div>
                                {{end}}
                            </dd>
                        </dl>
                    </div>
                    <div class="col-md-6">
                        <dl class="row">
                            <dt class="col-sm-4">Created:</dt>
                            <dd class="col-sm-8" id="created-date">Loading...</dd>
                            
                            <dt class="col-sm-4">Total Requests:</dt>
                            <dd class="col-sm-8">{{.Site.RequestCount}}</dd>
                            
                            <dt class="col-sm-4">Blocked Requests:</dt>
                            <dd class="col-sm-8">{{.Site.BlockedCount}}</dd>
                            
                            <dt class="col-sm-4">Block Rate:</dt>
                            <dd class="col-sm-8" id="block-rate">Calculating...</dd>
                        </dl>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="row mb-4">
    <div class="col-md-12">
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">How to Use the Reverse Proxy</h5>
            </div>
            <div class="card-body">
                {{if eq .Site.Status "active"}}
                <div class="alert alert-success">
                    <i class="bi bi-check-circle-fill"></i> This site is <strong>active</strong> and being served by the reverse proxy
                </div>
                <p>To route traffic through the proxy, you need to:</p>
                <ol>
                    <li>Point your domain's DNS records to the server running SeproWAF</li>
                    <li>Make sure the domain <strong>{{.Site.Domain}}</strong> resolves to this server's IP address</li>
                    <li>The proxy server is listening on port <code>{{.ProxyPort}}</code>. You may need to configure your web server or firewall to forward traffic to this port.</li>
                </ol>
                <div class="alert alert-info">
                    <h6><i class="bi bi-info-circle"></i> For local testing</h6>
                    <p>If testing locally, add an entry to your hosts file:</p>
                    <pre><code>127.0.0.1  {{.Site.Domain}}</code></pre>
                    <p class="mb-0">Then access the site at:
                        <a href="http://{{.Site.Domain}}:{{.ProxyPort}}" target="_blank">http://{{.Site.Domain}}:{{.ProxyPort}}</a>
                        
                        {{if .HasValidCertificate}}
                        or 
                        <a href="https://{{.Site.Domain}}:{{.ProxyHTTPSPort}}" target="_blank">https://{{.Site.Domain}}:{{.ProxyHTTPSPort}}</a>
                        {{else}}
                        <br><small class="text-muted">(HTTPS is not available - no certificate configured)</small>
                        {{end}}
                    </p>
                </div>
                {{else}}
                <div class="alert alert-warning">
                    <i class="bi bi-exclamation-triangle-fill"></i> This site is currently <strong>inactive</strong>
                </div>
                <p>Activate the site using the toggle button above to enable proxy functionality.</p>
                {{end}}
            </div>
        </div>
    </div>
</div>

<div class="row mb-4">
    <div class="col-md-6">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title mb-0">Traffic Overview</h5>
                <div class="btn-group btn-group-sm">
                    <button type="button" class="btn btn-outline-secondary active" data-period="24h">24h</button>
                    <button type="button" class="btn btn-outline-secondary" data-period="7d">7d</button>
                    <button type="button" class="btn btn-outline-secondary" data-period="30d">30d</button>
                </div>
            </div>
            <div class="card-body">
                <canvas id="trafficChart" height="250"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title mb-0">Attack Types</h5>
                <div class="btn-group btn-group-sm">
                    <button type="button" class="btn btn-outline-secondary active" data-period="24h">24h</button>
                    <button type="button" class="btn btn-outline-secondary" data-period="7d">7d</button>
                    <button type="button" class="btn btn-outline-secondary" data-period="30d">30d</button>
                </div>
            </div>
            <div class="card-body">
                <canvas id="attackTypesChart" height="250"></canvas>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-12">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title mb-0">Recent Attacks</h5>
                <a href="/waf/logs?site={{.Site.ID}}" class="btn btn-sm btn-outline-primary">View All Logs</a>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>Time</th>
                                <th>IP Address</th>
                                <th>Attack Type</th>
                                <th>Rule ID</th>
                                <th>Request Path</th>
                            </tr>
                        </thead>
                        <tbody id="recent-attacks">
                            <tr>
                                <td colspan="5" class="text-center">Loading recent attacks...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Delete Site</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete <strong>{{.Site.Name}}</strong>?</p>
                <p class="text-danger">This action cannot be undone and will remove all settings and statistics for this site.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger" id="confirm-delete">Delete</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    const siteId = {{.Site.ID}};
    
    // Format created date
    const createdDate = new Date('{{.Site.CreatedAt}}');
    document.getElementById('created-date').textContent = createdDate.toLocaleString();
    
    // Calculate block rate
    const requestCount = {{.Site.RequestCount}};
    const blockedCount = {{.Site.BlockedCount}};
    let blockRate = 0;
    
    if (requestCount > 0) {
        blockRate = (blockedCount / requestCount * 100).toFixed(2);
    }
    
    document.getElementById('block-rate').textContent = blockRate + '%';
    
    // Toggle WAF protection
    document.getElementById('waf-toggle').addEventListener('change', async function() {
        const wafStatus = document.getElementById('waf-status');
        const wafHelpText = document.getElementById('waf-help-text');
        const isEnabled = this.checked;
        
        try {
            // Call the toggle WAF API endpoint
            const response = await api.post(`/sites/${siteId}/toggle-waf`);
            
            // Update UI to reflect new state
            if (response.data.wafEnabled) {
                wafStatus.textContent = 'Enabled';
                wafStatus.className = 'badge bg-success';
                wafHelpText.textContent = 'Web Application Firewall protection is enabled for this site';
                showToast('WAF protection enabled successfully', 'success');
            } else {
                wafStatus.textContent = 'Disabled';
                wafStatus.className = 'badge bg-secondary';
                wafHelpText.textContent = 'Web Application Firewall protection is disabled for this site';
                showToast('WAF protection disabled successfully', 'warning');
            }
        } catch (error) {
            console.error('Error toggling WAF protection:', error);
            // Revert toggle to previous state if there was an error
            this.checked = !isEnabled;
            showToast('Failed to change WAF protection state', 'danger');
        }
    });
    
    // Toggle site status
    document.getElementById('toggle-status-btn').addEventListener('click', async function() {
        try {
            await api.post(`/sites/${siteId}/toggle-status`);
            showToast('Site status updated successfully', 'success');
            // Reload the page to show the new status
            setTimeout(() => {
                window.location.reload();
            }, 1000);
        } catch (error) {
            console.error('Error updating site status:', error);
            showToast('Failed to update site status', 'danger');
        }
    });
    
    // Delete site
    document.getElementById('delete-site-btn').addEventListener('click', function() {
        const modal = new bootstrap.Modal(document.getElementById('deleteModal'));
        modal.show();
    });
    
    document.getElementById('confirm-delete').addEventListener('click', async function() {
        try {
            await api.delete(`/sites/${siteId}`);
            showToast('Site deleted successfully', 'success');
            // Redirect to sites list
            setTimeout(() => {
                window.location.href = '/waf/sites';
            }, 1000);
        } catch (error) {
            console.error('Error deleting site:', error);
            showToast('Failed to delete site', 'danger');
            // Hide modal
            const modal = bootstrap.Modal.getInstance(document.getElementById('deleteModal'));
            modal.hide();
        }
    });
    
    // Load site statistics and charts
    loadSiteStats();
    renderTrafficChart();
    renderAttackTypesChart();
    loadRecentAttacks();
    
    // Load site stats
    async function loadSiteStats() {
        try {
            const response = await api.get(`/sites/${siteId}/stats`);
            // Update stats if needed
        } catch (error) {
            console.error('Error loading site stats:', error);
        }
    }
    
    // Traffic chart
    function renderTrafficChart() {
        const ctx = document.getElementById('trafficChart').getContext('2d');
        
        // Sample data - in a real app, this would come from an API
        const data = {
            labels: ['00:00', '03:00', '06:00', '09:00', '12:00', '15:00', '18:00', '21:00'],
            datasets: [
                {
                    label: 'Total Requests',
                    data: [65, 59, 80, 81, 56, 55, 40, 88],
                    borderColor: '#3498db',
                    backgroundColor: 'rgba(52, 152, 219, 0.1)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4
                },
                {
                    label: 'Blocked Requests',
                    data: [12, 19, 3, 5, 2, 3, 20, 33],
                    borderColor: '#e74c3c',
                    backgroundColor: 'rgba(231, 76, 60, 0.1)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4
                }
            ]
        };
        
        new Chart(ctx, {
            type: 'line',
            data: data,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }
    
    // Attack types chart
    function renderAttackTypesChart() {
        const ctx = document.getElementById('attackTypesChart').getContext('2d');
        
        // Sample data - in a real app, this would come from an API
        const data = {
            labels: ['SQL Injection', 'XSS', 'CSRF', 'Path Traversal', 'Other'],
            datasets: [{
                data: [45, 25, 12, 8, 10],
                backgroundColor: [
                    '#e74c3c',
                    '#f39c12',
                    '#2ecc71',
                    '#3498db',
                    '#9b59b6'
                ],
                borderWidth: 1
            }]
        };
        
        new Chart(ctx, {
            type: 'doughnut',
            data: data,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right'
                    }
                }
            }
        });
    }
    
    // Load recent attacks
    function loadRecentAttacks() {
        // Sample data - in a real app, this would come from an API
        const attacks = [
            { time: '2025-04-07 12:34:56', ip: '192.168.1.100', type: 'SQL Injection', rule: '942100', path: '/login.php' },
            { time: '2025-04-07 12:30:22', ip: '192.168.1.101', type: 'XSS', rule: '941110', path: '/contact.php' },
            { time: '2025-04-07 12:28:15', ip: '192.168.1.102', type: 'Path Traversal', rule: '930110', path: '/download.php' },
            { time: '2025-04-07 12:25:44', ip: '192.168.1.103', type: 'SQL Injection', rule: '942190', path: '/search.php' },
            { time: '2025-04-07 12:22:10', ip: '192.168.1.104', type: 'XSS', rule: '941120', path: '/comment.php' }
        ];
        
        const tbody = document.getElementById('recent-attacks');
        tbody.innerHTML = '';
        
        if (attacks.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" class="text-center">No recent attacks detected</td></tr>';
            return;
        }
        
        attacks.forEach(attack => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${attack.time}</td>
                <td>${attack.ip}</td>
                <td><span class="badge bg-danger">${attack.type}</span></td>
                <td>${attack.rule}</td>
                <td>${attack.path}</td>
            `;
            tbody.appendChild(tr);
        });
    }
    
    // Time period selector for charts
    document.querySelectorAll('.btn-group[data-period]').forEach(group => {
        group.addEventListener('click', function(e) {
            if (e.target.tagName === 'BUTTON') {
                // Remove active class from all buttons in this group
                this.querySelectorAll('.btn').forEach(btn => btn.classList.remove('active'));
                // Add active class to clicked button
                e.target.classList.add('active');
                
                // Get selected period
                const period = e.target.getAttribute('data-period');
                
                // Update charts based on period
                // In a real app, you'd fetch new data here
                console.log(`Updating charts with period: ${period}`);
            }
        });
    });
});
</script>