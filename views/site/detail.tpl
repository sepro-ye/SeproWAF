<div class="flex flex-wrap mb-4">
    <div class="w-full md:w-2/3">
        <h1>{{.Site.Name}}</h1>
        <p class="text-xl">
            <span class="px-2 py-1 text-xs font-medium rounded-full {{if eq .Site.Status "active"}}bg-green-500{{else if eq .Site.Status "pending"}}bg-yellow-500{{else}}bg-red-500{{end}} text-white">
                {{.Site.Status}}
            </span>
            {{.Site.Domain}}
        </p>
    </div>
    <div class="w-full md:w-1/3 md:text-right">
        <div class="inline-flex rounded-md shadow-sm" role="group">
            <a href="/waf/sites/{{.Site.ID}}/edit" class="px-3 py-2 text-sm font-medium border border-gray-400 text-gray-700 bg-white hover:bg-gray-100 rounded-l-md">
                <i class="bi bi-pencil"></i> Edit
            </a>
            <button type="button" class="px-3 py-2 text-sm font-medium border border-l-0 {{if eq .Site.Status "active"}}border-yellow-400 text-yellow-700 hover:bg-yellow-100{{else}}border-green-400 text-green-700 hover:bg-green-100{{end}}" id="toggle-status-btn">
                <i class="bi {{if eq .Site.Status "active"}}bi-pause-circle{{else}}bi-play-circle{{end}}"></i>
                {{if eq .Site.Status "active"}}Disable{{else}}Enable{{end}}
            </button>
            <button type="button" class="px-3 py-2 text-sm font-medium border border-l-0 border-red-400 text-red-700 bg-white hover:bg-red-100 rounded-r-md" id="delete-site-btn">
                <i class="bi bi-trash"></i> Delete
            </button>
        </div>
    </div>
</div>

<div class="flex flex-wrap mb-4">
    <div class="w-full">
        <div class="bg-white rounded-lg shadow">
            <div class="px-4 py-3 border-b">
                <h5 class="text-lg font-medium mb-0">Site Information</h5>
            </div>
            <div class="p-4">
                <div class="flex flex-wrap">
                    <div class="w-full md:w-1/2">
                        <dl class="grid grid-cols-3 gap-4">
                            <dt class="col-span-1 font-medium">Name:</dt>
                            <dd class="col-span-2">{{.Site.Name}}</dd>
                            
                            <dt class="col-span-1 font-medium">Domain:</dt>
                            <dd class="col-span-2">{{.Site.Domain}}</dd>
                            
                            <dt class="col-span-1 font-medium">Target URL:</dt>
                            <dd class="col-span-2">{{.Site.TargetURL}}</dd>
                            
                            <dt class="col-span-1 font-medium">Status:</dt>
                            <dd class="col-span-2">
                                <span class="px-2 py-1 text-xs font-medium rounded-full {{if eq .Site.Status "active"}}bg-green-500{{else if eq .Site.Status "pending"}}bg-yellow-500{{else}}bg-red-500{{end}} text-white">
                                    {{.Site.Status}}
                                </span>
                            </dd>

                            <dt class="col-span-1 font-medium">WAF Protection:</dt>
                            <dd class="col-span-2">
                                <div class="flex items-center">
                                    <div class="relative inline-block w-10 mr-2 align-middle select-none">
                                        <input type="checkbox" id="waf-toggle" class="toggle-checkbox absolute block w-6 h-6 rounded-full bg-white border-4 appearance-none cursor-pointer"
                                            {{if .Site.WAFEnabled}}checked{{end}} {{if ne .Site.Status "active"}}disabled{{end}}>
                                        <label for="waf-toggle" class="toggle-label block overflow-hidden h-6 rounded-full bg-gray-300 cursor-pointer"></label>
                                    </div>
                                    <span id="waf-status" class="px-2 py-1 text-xs font-medium rounded-full {{if .Site.WAFEnabled}}bg-green-500{{else}}bg-gray-500{{end}} text-white">
                                        {{if .Site.WAFEnabled}}Enabled{{else}}Disabled{{end}}
                                    </span>
                                </div>
                                <p class="text-xs text-gray-500 mt-1" id="waf-help-text">
                                    {{if ne .Site.Status "active"}}
                                    WAF toggle is disabled because site is not active
                                    {{else}}
                                    Toggle the Web Application Firewall protection for this site
                                    {{end}}
                                </p>
                            </dd>

                            <dt class="col-span-1 font-medium">HTTPS:</dt>
                            <dd class="col-span-2">
                                {{if .HasValidCertificate}}
                                <div class="p-4 rounded-md bg-green-100 text-green-700 border border-green-200">
                                    <i class="bi bi-lock-fill"></i> HTTPS is <strong>enabled</strong> for this site
                                    <p class="mb-0 mt-2">
                                        <strong>HTTP:</strong> <code>http://{{.Site.Domain}}:{{.ProxyPort}}</code><br>
                                        <strong>HTTPS:</strong> <code>https://{{.Site.Domain}}:{{.ProxyHTTPSPort}}</code>
                                    </p>
                                </div>
                                {{else}}
                                <div class="p-4 rounded-md bg-gray-100 text-gray-700 border border-gray-200">
                                    <i class="bi bi-unlock"></i> HTTPS is <strong>disabled</strong> for this site
                                    <p class="mb-0">To enable HTTPS, <a href="/waf/certificates/upload">upload an SSL certificate</a> and assign it to this site.</p>
                                </div>
                                {{end}}
                            </dd>
                        </dl>
                    </div>
                    <div class="w-full md:w-1/2">
                        <dl class="grid grid-cols-3 gap-4">
                            <dt class="col-span-1 font-medium">Created:</dt>
                            <dd class="col-span-2" id="created-date">Loading...</dd>
                            
                            <dt class="col-span-1 font-medium">Total Requests:</dt>
                            <dd class="col-span-2">{{.Site.RequestCount}}</dd>
                            
                            <dt class="col-span-1 font-medium">Blocked Requests:</dt>
                            <dd class="col-span-2">{{.Site.BlockedCount}}</dd>
                            
                            <dt class="col-span-1 font-medium">Block Rate:</dt>
                            <dd class="col-span-2" id="block-rate">Calculating...</dd>
                        </dl>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="flex flex-wrap mb-4">
    <div class="w-full">
        <div class="bg-white rounded-lg shadow">
            <div class="px-4 py-3 border-b">
                <h5 class="text-lg font-medium mb-0">How to Use the Reverse Proxy</h5>
            </div>
            <div class="p-4">
                {{if eq .Site.Status "active"}}
                <div class="p-4 rounded-md bg-green-100 text-green-700 border border-green-200">
                    <i class="bi bi-check-circle-fill"></i> This site is <strong>active</strong> and being served by the reverse proxy
                </div>
                <p>To route traffic through the proxy, you need to:</p>
                <ol>
                    <li>Point your domain's DNS records to the server running SeproWAF</li>
                    <li>Make sure the domain <strong>{{.Site.Domain}}</strong> resolves to this server's IP address</li>
                    <li>The proxy server is listening on port <code>{{.ProxyPort}}</code>. You may need to configure your web server or firewall to forward traffic to this port.</li>
                </ol>
                <div class="p-4 rounded-md bg-blue-100 text-blue-700 border border-blue-200">
                    <h6 class="font-medium"><i class="bi bi-info-circle"></i> For local testing</h6>
                    <p>If testing locally, add an entry to your hosts file:</p>
                    <pre class="bg-gray-100 p-2 rounded"><code>127.0.0.1  {{.Site.Domain}}</code></pre>
                    <p class="mb-0">Then access the site at:
                        <a href="http://{{.Site.Domain}}:{{.ProxyPort}}" target="_blank" class="text-blue-600 hover:text-blue-800">http://{{.Site.Domain}}:{{.ProxyPort}}</a>
                        
                        {{if .HasValidCertificate}}
                        or 
                        <a href="https://{{.Site.Domain}}:{{.ProxyHTTPSPort}}" target="_blank" class="text-blue-600 hover:text-blue-800">https://{{.Site.Domain}}:{{.ProxyHTTPSPort}}</a>
                        {{else}}
                        <br><span class="text-xs text-gray-500">(HTTPS is not available - no certificate configured)</span>
                        {{end}}
                    </p>
                </div>
                {{else}}
                <div class="p-4 rounded-md bg-yellow-100 text-yellow-700 border border-yellow-200">
                    <i class="bi bi-exclamation-triangle-fill"></i> This site is currently <strong>inactive</strong>
                </div>
                <p>Activate the site using the toggle button above to enable proxy functionality.</p>
                {{end}}
            </div>
        </div>
    </div>
</div>

<div class="flex flex-wrap mb-4">
    <div class="w-full md:w-1/2">
        <div class="bg-white rounded-lg shadow">
            <div class="px-4 py-3 border-b flex justify-between items-center">
                <h5 class="text-lg font-medium mb-0">Traffic Overview</h5>
                <div class="inline-flex rounded-md shadow-sm">
                    <button type="button" class="px-2 py-1 text-sm font-medium border border-gray-400 text-gray-700 bg-gray-100 rounded-l-md active" data-period="24h">24h</button>
                    <button type="button" class="px-2 py-1 text-sm font-medium border-t border-b border-gray-400 text-gray-700 bg-white hover:bg-gray-100" data-period="7d">7d</button>
                    <button type="button" class="px-2 py-1 text-sm font-medium border border-gray-400 text-gray-700 bg-white hover:bg-gray-100 rounded-r-md" data-period="30d">30d</button>
                </div>
            </div>
            <div class="p-4">
                <canvas id="trafficChart" height="250"></canvas>
            </div>
        </div>
    </div>
    <div class="w-full md:w-1/2">
        <div class="bg-white rounded-lg shadow">
            <div class="px-4 py-3 border-b flex justify-between items-center">
                <h5 class="text-lg font-medium mb-0">Attack Types</h5>
                <div class="inline-flex rounded-md shadow-sm">
                    <button type="button" class="px-2 py-1 text-sm font-medium border border-gray-400 text-gray-700 bg-gray-100 rounded-l-md active" data-period="24h">24h</button>
                    <button type="button" class="px-2 py-1 text-sm font-medium border-t border-b border-gray-400 text-gray-700 bg-white hover:bg-gray-100" data-period="7d">7d</button>
                    <button type="button" class="px-2 py-1 text-sm font-medium border border-gray-400 text-gray-700 bg-white hover:bg-gray-100 rounded-r-md" data-period="30d">30d</button>
                </div>
            </div>
            <div class="p-4">
                <canvas id="attackTypesChart" height="250"></canvas>
            </div>
        </div>
    </div>
</div>

<div class="flex flex-wrap">
    <div class="w-full">
        <div class="bg-white rounded-lg shadow">
            <div class="px-4 py-3 border-b flex justify-between items-center">
                <h5 class="text-lg font-medium mb-0">Recent Attacks</h5>
                <a href="/waf/logs?site={{.Site.ID}}" class="px-3 py-1 text-sm border border-blue-600 text-blue-600 hover:bg-blue-600 hover:text-white rounded-md">View All Logs</a>
            </div>
            <div class="p-0">
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-4 py-2 text-left text-sm font-medium text-gray-700">Time</th>
                                <th class="px-4 py-2 text-left text-sm font-medium text-gray-700">IP Address</th>
                                <th class="px-4 py-2 text-left text-sm font-medium text-gray-700">Attack Type</th>
                                <th class="px-4 py-2 text-left text-sm font-medium text-gray-700">Rule ID</th>
                                <th class="px-4 py-2 text-left text-sm font-medium text-gray-700">Request Path</th>
                            </tr>
                        </thead>
                        <tbody id="recent-attacks" class="divide-y">
                            <tr>
                                <td colspan="5" class="px-4 py-2 text-center">Loading recent attacks...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Add this to your site detail tabs section -->

<div id="rules-tab" class="tab-content hidden">
    <div class="flex flex-wrap mb-4">
        <div class="md:w-1/2">
            <h2 class="text-xl font-bold">WAF Rules</h2>
            <p class="text-gray-600">Protection rules for this website</p>
        </div>
        <div class="md:w-1/2 text-right">
            <a href="/waf/sites/{{.Site.ID}}/rules" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded inline-flex items-center">
                <i class="bi bi-shield-lock mr-2"></i> Manage Rules
            </a>
        </div>
    </div>
    
    <div class="bg-white rounded-lg shadow">
        <div class="px-4 py-3 border-b">
            <h5 class="text-lg font-medium mb-0">Active Protection Rules</h5>
        </div>
        <div class="p-4">
            <div id="site-rules-loading" class="text-center py-4">
                <div class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-blue-600 border-t-transparent" role="status">
                    <span class="sr-only">Loading...</span>
                </div>
                <p class="mt-2">Loading rules...</p>
            </div>
            
            <div id="site-rules-summary" class="hidden">
                <div class="flex flex-wrap">
                    <div class="w-full md:w-1/4 p-2">
                        <div class="bg-blue-100 rounded-lg p-4 text-center">
                            <div class="text-3xl font-bold text-blue-700" id="rule-count-total">0</div>
                            <div class="text-sm text-blue-800">Total Rules</div>
                        </div>
                    </div>
                    <div class="w-full md:w-1/4 p-2">
                        <div class="bg-green-100 rounded-lg p-4 text-center">
                            <div class="text-3xl font-bold text-green-700" id="rule-count-enabled">0</div>
                            <div class="text-sm text-green-800">Enabled Rules</div>
                        </div>
                    </div>
                    <div class="w-full md:w-1/4 p-2">
                        <div class="bg-red-100 rounded-lg p-4 text-center">
                            <div class="text-3xl font-bold text-red-700" id="rule-count-blocked">0</div>
                            <div class="text-sm text-red-800">Attacks Blocked (24h)</div>
                        </div>
                    </div>
                    <div class="w-full md:w-1/4 p-2">
                        <div class="bg-yellow-100 rounded-lg p-4 text-center">
                            <div class="text-3xl font-bold text-yellow-700" id="rule-types-count">0</div>
                            <div class="text-sm text-yellow-800">Protection Types</div>
                        </div>
                    </div>
                </div>
                
                <div class="mt-4">
                    <h6 class="font-medium mb-2">Recently Active Rules</h6>
                    <div class="overflow-x-auto">
                        <table class="w-full mb-0" id="recent-rules-table">
                            <thead>
                                <tr class="bg-gray-50">
                                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Rule</th>
                                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Trigger Count</th>
                                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Last Triggered</th>
                                </tr>
                            </thead>
                            <tbody id="recent-rules-tbody" class="divide-y">
                                <!-- Will be populated via JavaScript -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <div id="site-rules-empty" class="hidden text-center py-6">
                <i class="bi bi-shield-slash text-4xl text-gray-400"></i>
                <p class="mt-3 text-gray-600">No WAF rules have been set up for this site yet.</p>
                <a href="/waf/sites/{{.Site.ID}}/rules/new" class="mt-3 inline-block px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded">
                    Add Your First Rule
                </a>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteModal" class="fixed inset-0 z-50 hidden overflow-y-auto" aria-hidden="true">
    <div class="flex items-center justify-center min-h-screen p-4">
        <div class="fixed inset-0 bg-black bg-opacity-50 transition-opacity" id="modal-backdrop"></div>
        <div class="bg-white rounded-lg shadow-xl max-w-md w-full z-10">
            <div class="px-4 py-3 border-b flex justify-between items-center">
                <h5 class="text-lg font-medium">Delete Site</h5>
                <button type="button" class="text-gray-500 hover:text-gray-700" id="modal-close">
                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>
            <div class="px-4 py-3">
                <p>Are you sure you want to delete <strong>{{.Site.Name}}</strong>?</p>
                <p class="text-red-500">This action cannot be undone and will remove all settings and statistics for this site.</p>
            </div>
            <div class="px-4 py-3 border-t flex justify-end space-x-2">
                <button type="button" class="px-4 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded" id="cancel-delete">Cancel</button>
                <button type="button" class="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded" id="confirm-delete">Delete</button>
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
                wafStatus.className = 'px-2 py-1 text-xs font-medium rounded-full bg-green-500 text-white';
                wafHelpText.textContent = 'Web Application Firewall protection is enabled for this site';
                showToast('WAF protection enabled successfully', 'success');
            } else {
                wafStatus.textContent = 'Disabled';
                wafStatus.className = 'px-2 py-1 text-xs font-medium rounded-full bg-gray-500 text-white';
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
        document.getElementById('deleteModal').classList.remove('hidden');
    });
    
    document.getElementById('modal-close').addEventListener('click', closeModal);
    document.getElementById('cancel-delete').addEventListener('click', closeModal);
    document.getElementById('modal-backdrop').addEventListener('click', closeModal);
    
    function closeModal() {
        document.getElementById('deleteModal').classList.add('hidden');
    }
    
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
            closeModal();
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
            tbody.innerHTML = '<tr><td colspan="5" class="px-4 py-2 text-center">No recent attacks detected</td></tr>';
            return;
        }
        
        attacks.forEach(attack => {
            const tr = document.createElement('tr');
            tr.className = 'hover:bg-gray-50';
            tr.innerHTML = `
                <td class="px-4 py-2">${attack.time}</td>
                <td class="px-4 py-2">${attack.ip}</td>
                <td class="px-4 py-2"><span class="px-2 py-1 text-xs font-medium rounded-full bg-red-500 text-white">${attack.type}</span></td>
                <td class="px-4 py-2">${attack.rule}</td>
                <td class="px-4 py-2">${attack.path}</td>
            `;
            tbody.appendChild(tr);
        });
    }
    
    // Time period selector for charts
    document.querySelectorAll('.inline-flex[data-period]').forEach(group => {
        group.addEventListener('click', function(e) {
            if (e.target.tagName === 'BUTTON') {
                // Remove active class and background from all buttons in this group
                this.querySelectorAll('.active').forEach(btn => {
                    btn.classList.remove('active', 'bg-gray-100');
                    btn.classList.add('bg-white');
                });
                
                // Add active class and background to clicked button
                e.target.classList.add('active', 'bg-gray-100');
                e.target.classList.remove('bg-white');
                
                // Get selected period
                const period = e.target.getAttribute('data-period');
                
                // Update charts based on period
                // In a real app, you'd fetch new data here
            }
        });
    });
    
    // Set up tabs navigation
    const tabButtons = document.querySelectorAll('[data-tab]');
    const tabContents = document.querySelectorAll('[id$="-tab"]');  // All elements with IDs ending in "-tab"

    // Set initial active tab (use first tab by default)
    if (tabContents.length > 0) {
        tabContents[0].classList.remove('hidden');
        tabContents[0].classList.add('block');
        
        if (tabButtons.length > 0) {
            tabButtons[0].classList.add('active', 'border-b-2', 'border-blue-500', 'text-blue-600');
        }
    }

    // Add click handler to tab buttons
    tabButtons.forEach(button => {
        button.addEventListener('click', function() {
            const targetId = this.getAttribute('data-tab');
            
            // Hide all tabs
            tabContents.forEach(tab => {
                tab.classList.add('hidden');
                tab.classList.remove('block');
            });
            
            // Remove active state from all buttons
            tabButtons.forEach(btn => {
                btn.classList.remove('active', 'border-b-2', 'border-blue-500', 'text-blue-600');
            });
            
            // Show selected tab
            const targetTab = document.getElementById(targetId);
            if (targetTab) {
                targetTab.classList.remove('hidden');
                targetTab.classList.add('block');
                
                // Activate the tab button
                this.classList.add('active', 'border-b-2', 'border-blue-500', 'text-blue-600');
                
                // Load data for specific tabs
                if (targetId === 'rules-tab') {
                    loadSiteRules();
                }
            }
        });
    });
});

// Add this code to load rule data when the rules tab is active
async function loadSiteRules() {
    const siteId = {{.Site.ID}};
    
    document.getElementById('site-rules-loading').classList.remove('hidden');
    document.getElementById('site-rules-summary').classList.add('hidden');
    document.getElementById('site-rules-empty').classList.add('hidden');
    
    try {
        const response = await api.get(`/sites/${siteId}/waf/rules`);
        const rules = response.data;

        if (!rules || rules.length === 0) {
            document.getElementById('site-rules-loading').classList.add('hidden');
            document.getElementById('site-rules-empty').classList.remove('hidden');
            return;
        }

        // Count enabled rules
        const enabledRules = rules.filter(rule => rule.status === 'enabled').length;

        // Count unique rule types
        const uniqueTypes = [...new Set(rules.map(rule => rule.type))].length;

        // Update counters
        document.getElementById('rule-count-total').textContent = rules.length;
        document.getElementById('rule-count-enabled').textContent = enabledRules;
        document.getElementById('rule-types-count').textContent = uniqueTypes;

        // Mock data for attacks blocked - in a real app you'd get this from your API
        document.getElementById('rule-count-blocked').textContent = Math.floor(Math.random() * 100);

        // Sort by last trigger time (mocked here)
        const recentRules = [...rules].sort(() => Math.random() - 0.5).slice(0, 5);

        // Populate recent rules table
        const tbody = document.getElementById('recent-rules-tbody');
        tbody.innerHTML = '';

        recentRules.forEach(rule => {
            const row = document.createElement('tr');
            row.className = 'hover:bg-gray-50';

            // Format type for display
            const formattedType = formatRuleType(rule.type);
            const typeBadgeClass = getTypeBadgeClass(rule.type);

            // Generate mock trigger count and time for demo purposes
            const triggerCount = Math.floor(Math.random() * 50);
            const lastTriggered = new Date(Date.now() - Math.floor(Math.random() * 86400000)).toLocaleString();

            row.innerHTML = `
                <td class="px-4 py-2 font-medium">${rule.name}</td>
                <td class="px-4 py-2">
                    <span class="px-2 py-1 text-xs font-medium rounded-full ${typeBadgeClass}">
                        ${formattedType}
                    </span>
                </td>
                <td class="px-4 py-2">${triggerCount}</td>
                <td class="px-4 py-2">${lastTriggered}</td>
            `;

            tbody.appendChild(row);
        });

        document.getElementById('site-rules-loading').classList.add('hidden');
        document.getElementById('site-rules-summary').classList.remove('hidden');
    } catch (error) {
        console.error('Error loading site rules:', error);
        document.getElementById('site-rules-loading').classList.add('hidden');
        document.getElementById('site-rules-empty').classList.remove('hidden');
    }
}

// These utility functions should be consistent with those in the rule list view
function formatRuleType(type) {
    switch(type) {
        case 'ip_block': return 'IP Block';
        case 'rate_limit': return 'Rate Limit';
        case 'sqli': return 'SQL Injection';
        case 'xss': return 'XSS Protection';
        case 'path_traversal': return 'Path Traversal';
        case 'custom': return 'Custom Rule';
        default: return type;
    }
}

function getTypeBadgeClass(type) {
    switch(type) {
        case 'ip_block': return 'bg-blue-500 text-white';
        case 'rate_limit': return 'bg-yellow-500 text-white';
        case 'sqli': return 'bg-red-500 text-white';
        case 'xss': return 'bg-pink-500 text-white';
        case 'path_traversal': return 'bg-orange-500 text-white';
        case 'custom': return 'bg-purple-500 text-white';
        default: return 'bg-gray-500 text-white';
    }
}

// Load rules when tab is shown
document.addEventListener('DOMContentLoaded', function() {
    // If rules tab is initially active
    if (document.getElementById('rules-tab').classList.contains('block')) {
        loadSiteRules();
    }
    
    // Add event listeners to tab buttons if you have them
    const ruleTabButton = document.querySelector('[data-target="#rules-tab"]');
    if (ruleTabButton) {
        ruleTabButton.addEventListener('click', loadSiteRules);
    }
});
</script>

<!-- Add CSS for toggle switch -->
<style>
    .toggle-checkbox:checked {
        right: 0;
        border-color: #10B981;
    }
    .toggle-checkbox:checked + .toggle-label {
        background-color: #10B981;
    }
    .toggle-label {
        transition: background-color 0.2s ease;
    }
</style>