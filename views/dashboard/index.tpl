<div class="row mb-4">
    <div class="col">
        <h1>Dashboard</h1>
        <p class="lead">Welcome back, {{.Username}}!</p>
    </div>
</div>

<div class="row mb-4">
    <div class="col-md-3">
        <div class="card stats-card">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div class="stats-icon bg-primary text-white">
                        <i class="bi bi-globe"></i>
                    </div>
                    <h3 class="mb-0" id="sites-count">--</h3>
                </div>
                <h6 class="text-muted">Protected Sites</h6>
            </div>
            <div class="card-footer bg-transparent border-0">
                <a href="/waf/sites" class="text-decoration-none">View all <i class="bi bi-arrow-right"></i></a>
            </div>
        </div>
    </div>
    
    <div class="col-md-3">
        <div class="card stats-card">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div class="stats-icon bg-danger text-white">
                        <i class="bi bi-shield-x"></i>
                    </div>
                    <h3 class="mb-0" id="attacks-count">--</h3>
                </div>
                <h6 class="text-muted">Attacks Blocked (24h)</h6>
            </div>
            <div class="card-footer bg-transparent border-0">
                <a href="/waf/logs" class="text-decoration-none">View logs <i class="bi bi-arrow-right"></i></a>
            </div>
        </div>
    </div>
    
    <div class="col-md-3">
        <div class="card stats-card">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div class="stats-icon bg-success text-white">
                        <i class="bi bi-check-circle"></i>
                    </div>
                    <h3 class="mb-0" id="requests-count">--</h3>
                </div>
                <h6 class="text-muted">Requests (24h)</h6>
            </div>
            <div class="card-footer bg-transparent border-0">
                <a href="/waf/logs" class="text-decoration-none">View all <i class="bi bi-arrow-right"></i></a>
            </div>
        </div>
    </div>
    
    <div class="col-md-3">
        <div class="card stats-card">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div class="stats-icon bg-warning text-white">
                        <i class="bi bi-shield-check"></i>
                    </div>
                    <h3 class="mb-0" id="rules-count">--</h3>
                </div>
                <h6 class="text-muted">Active Rules</h6>
            </div>
            <div class="card-footer bg-transparent border-0">
                <a href="/waf/rules" class="text-decoration-none">Manage rules <i class="bi bi-arrow-right"></i></a>
            </div>
        </div>
    </div>
</div>

<div class="row mb-4">
    <div class="col-md-8">
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">Traffic Overview</h5>
            </div>
            <div class="card-body">
                <canvas id="trafficChart" height="300"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">Attack Types</h5>
            </div>
            <div class="card-body">
                <canvas id="attackTypesChart" height="300"></canvas>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-6">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title mb-0">Recent Attacks</h5>
                <a href="/waf/logs" class="btn btn-sm btn-outline-primary">View All</a>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>Time</th>
                                <th>IP Address</th>
                                <th>Attack Type</th>
                                <th>Site</th>
                            </tr>
                        </thead>
                        <tbody id="recent-attacks">
                            <tr>
                                <td colspan="4" class="text-center">Loading...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title mb-0">Protected Sites</h5>
                <a href="/waf/sites" class="btn btn-sm btn-outline-primary">Manage Sites</a>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>Domain</th>
                                <th>Status</th>
                                <th>Traffic (24h)</th>
                                <th>Attacks (24h)</th>
                            </tr>
                        </thead>
                        <tbody id="protected-sites">
                            <tr>
                                <td colspan="4" class="text-center">Loading...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Check if we're authenticated
    if (!isLoggedIn()) {
        showToast('Please login to continue', 'warning');
        setTimeout(() => {
            window.location.href = '/auth/login';
        }, 1000);
        return;
    }
    
    // If we're authenticated, load dashboard data
    const userData = getUserData();
    if (userData) {
        // Set user name in UI if needed
        if (document.querySelector('.username-display')) {
            document.querySelector('.username-display').textContent = userData.username;
        }
    }

    // Fetch dashboard data
    async function fetchDashboardData() {
        try {
            // In a real implementation, you would fetch this data from your API
            // This is placeholder data for demonstration
            
            // Update stats
            document.getElementById('sites-count').textContent = '3';
            document.getElementById('attacks-count').textContent = '125';
            document.getElementById('requests-count').textContent = '5.2K';
            document.getElementById('rules-count').textContent = '42';
            
            // Generate sample data for charts
            renderTrafficChart();
            renderAttackTypesChart();
            renderRecentAttacks();
            renderProtectedSites();
        } catch (error) {
            console.error('Error fetching dashboard data:', error);
            showToast('Failed to load dashboard data', 'danger');
        }
    }
    
    // Traffic chart
    function renderTrafficChart() {
        const ctx = document.getElementById('trafficChart').getContext('2d');
        
        const labels = Array.from({length: 24}, (_, i) => `${23-i}h ago`).reverse();
        const data = {
            labels: labels,
            datasets: [
                {
                    label: 'Legitimate Traffic',
                    data: Array.from({length: 24}, () => Math.floor(Math.random() * 100) + 100),
                    borderColor: '#3498db',
                    backgroundColor: 'rgba(52, 152, 219, 0.1)',
                    fill: true,
                    tension: 0.3
                },
                {
                    label: 'Blocked Attacks',
                    data: Array.from({length: 24}, () => Math.floor(Math.random() * 20)),
                    borderColor: '#e74c3c',
                    backgroundColor: 'rgba(231, 76, 60, 0.1)',
                    fill: true,
                    tension: 0.3
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
                },
                plugins: {
                    legend: {
                        position: 'top',
                    }
                }
            }
        });
    }
    
    // Attack types chart
    function renderAttackTypesChart() {
        const ctx = document.getElementById('attackTypesChart').getContext('2d');
        
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
                ]
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
    
    // Recent attacks table
    function renderRecentAttacks() {
        const attacksData = [
            { time: '2025-04-07 10:23', ip: '192.168.1.45', type: 'SQL Injection', site: 'example.com' },
            { time: '2025-04-07 10:15', ip: '45.82.144.12', type: 'XSS', site: 'myapp.com' },
            { time: '2025-04-07 09:58', ip: '172.217.22.14', type: 'CSRF', site: 'example.com' },
            { time: '2025-04-07 09:42', ip: '91.195.240.94', type: 'Path Traversal', site: 'blog.example.com' },
            { time: '2025-04-07 09:36', ip: '104.18.21.226', type: 'SQL Injection', site: 'myapp.com' }
        ];
        
        const tbody = document.getElementById('recent-attacks');
        tbody.innerHTML = '';
        
        attacksData.forEach(attack => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${attack.time}</td>
                <td>${attack.ip}</td>
                <td><span class="badge bg-danger">${attack.type}</span></td>
                <td>${attack.site}</td>
            `;
            tbody.appendChild(tr);
        });
    }
    
    // Protected sites table
    function renderProtectedSites() {
        const sitesData = [
            { domain: 'example.com', status: 'Active', traffic: '2.3K', attacks: '58' },
            { domain: 'myapp.com', status: 'Active', traffic: '1.8K', attacks: '42' },
            { domain: 'blog.example.com', status: 'Active', traffic: '1.1K', attacks: '25' }
        ];
        
        const tbody = document.getElementById('protected-sites');
        tbody.innerHTML = '';
        
        sitesData.forEach(site => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${site.domain}</td>
                <td><span class="badge bg-success">${site.status}</span></td>
                <td>${site.traffic}</td>
                <td>${site.attacks}</td>
            `;
            tbody.appendChild(tr);
        });
    }
    
    // Load dashboard data
    fetchDashboardData();
});
</script>