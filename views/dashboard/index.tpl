<div class="flex flex-wrap mb-4">
    <div class="w-full">
        <h1 class="text-2xl font-bold">Dashboard</h1>
        <p class="text-xl font-light">Welcome back, {{.Username}}!</p>
    </div>
</div>

<div class="flex flex-wrap mb-4">
    <div class="w-full md:w-1/4 px-2">
        <div class="bg-white rounded-lg shadow-md">
            <div class="p-4">
                <div class="flex justify-between items-center mb-3">
                    <div class="bg-blue-500 text-white p-3 rounded-lg">
                        <i class="bi bi-globe"></i>
                    </div>
                    <h3 class="text-xl font-bold" id="sites-count">--</h3>
                </div>
                <h6 class="text-gray-500">Protected Sites</h6>
            </div>
            <div class="px-4 py-2 border-t border-gray-100">
                <a href="/waf/sites" class="no-underline text-blue-500 hover:text-blue-700">View all <i class="bi bi-arrow-right"></i></a>
            </div>
        </div>
    </div>
    
    <div class="w-full md:w-1/4 px-2">
        <div class="bg-white rounded-lg shadow-md">
            <div class="p-4">
                <div class="flex justify-between items-center mb-3">
                    <div class="bg-red-500 text-white p-3 rounded-lg">
                        <i class="bi bi-shield-x"></i>
                    </div>
                    <h3 class="text-xl font-bold" id="attacks-count">--</h3>
                </div>
                <h6 class="text-gray-500">Attacks Blocked (24h)</h6>
            </div>
            <div class="px-4 py-2 border-t border-gray-100">
                <a href="/waf/logs" class="no-underline text-blue-500 hover:text-blue-700">View logs <i class="bi bi-arrow-right"></i></a>
            </div>
        </div>
    </div>
    
    <div class="w-full md:w-1/4 px-2">
        <div class="bg-white rounded-lg shadow-md">
            <div class="p-4">
                <div class="flex justify-between items-center mb-3">
                    <div class="bg-green-500 text-white p-3 rounded-lg">
                        <i class="bi bi-check-circle"></i>
                    </div>
                    <h3 class="text-xl font-bold" id="requests-count">--</h3>
                </div>
                <h6 class="text-gray-500">Requests (24h)</h6>
            </div>
            <div class="px-4 py-2 border-t border-gray-100">
                <a href="/waf/logs" class="no-underline text-blue-500 hover:text-blue-700">View all <i class="bi bi-arrow-right"></i></a>
            </div>
        </div>
    </div>
    
    <div class="w-full md:w-1/4 px-2">
        <div class="bg-white rounded-lg shadow-md">
            <div class="p-4">
                <div class="flex justify-between items-center mb-3">
                    <div class="bg-yellow-500 text-white p-3 rounded-lg">
                        <i class="bi bi-shield-check"></i>
                    </div>
                    <h3 class="text-xl font-bold" id="rules-count">--</h3>
                </div>
                <h6 class="text-gray-500">Active Rules</h6>
            </div>
            <div class="px-4 py-2 border-t border-gray-100">
                <a href="/waf/rules" class="no-underline text-blue-500 hover:text-blue-700">Manage rules <i class="bi bi-arrow-right"></i></a>
            </div>
        </div>
    </div>
</div>

<div class="flex flex-wrap mb-4">
    <div class="w-full md:w-2/3 px-2">
        <div class="bg-white rounded-lg shadow-md">
            <div class="px-4 py-3 border-b border-gray-200">
                <h5 class="font-semibold text-lg mb-0">Traffic Overview</h5>
            </div>
            <div class="p-4">
                <canvas id="trafficChart" class="h-[300px]"></canvas>
            </div>
        </div>
    </div>
    <div class="w-full md:w-1/3 px-2">
        <div class="bg-white rounded-lg shadow-md">
            <div class="px-4 py-3 border-b border-gray-200">
                <h5 class="font-semibold text-lg mb-0">Attack Types</h5>
            </div>
            <div class="p-4">
                <canvas id="attackTypesChart" class="h-[300px]"></canvas>
            </div>
        </div>
    </div>
</div>

<div class="flex flex-wrap">
    <div class="w-full md:w-1/2 px-2">
        <div class="bg-white rounded-lg shadow-md">
            <div class="px-4 py-3 border-b border-gray-200 flex justify-between items-center">
                <h5 class="font-semibold text-lg mb-0">Recent Attacks</h5>
                <a href="/waf/logs" class="px-3 py-1 text-sm rounded border border-blue-500 text-blue-500 hover:bg-blue-500 hover:text-white">View All</a>
            </div>
            <div class="p-0">
                <div class="overflow-x-auto">
                    <table class="min-w-full table-auto [&>tbody>tr:hover]:bg-gray-100">
                        <thead>
                            <tr class="bg-gray-50 border-b border-gray-200">
                                <th class="px-4 py-2 text-left">Time</th>
                                <th class="px-4 py-2 text-left">IP Address</th>
                                <th class="px-4 py-2 text-left">Attack Type</th>
                                <th class="px-4 py-2 text-left">Site</th>
                            </tr>
                        </thead>
                        <tbody id="recent-attacks">
                            <tr>
                                <td colspan="4" class="text-center py-4">Loading...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <div class="w-full md:w-1/2 px-2">
        <div class="bg-white rounded-lg shadow-md">
            <div class="px-4 py-3 border-b border-gray-200 flex justify-between items-center">
                <h5 class="font-semibold text-lg mb-0">Protected Sites</h5>
                <a href="/waf/sites" class="px-3 py-1 text-sm rounded border border-blue-500 text-blue-500 hover:bg-blue-500 hover:text-white">Manage Sites</a>
            </div>
            <div class="p-0">
                <div class="overflow-x-auto">
                    <table class="min-w-full table-auto [&>tbody>tr:hover]:bg-gray-100">
                        <thead>
                            <tr class="bg-gray-50 border-b border-gray-200">
                                <th class="px-4 py-2 text-left">Domain</th>
                                <th class="px-4 py-2 text-left">Status</th>
                                <th class="px-4 py-2 text-left">Traffic (24h)</th>
                                <th class="px-4 py-2 text-left">Attacks (24h)</th>
                            </tr>
                        </thead>
                        <tbody id="protected-sites">
                            <tr>
                                <td colspan="4" class="text-center py-4">Loading...</td>
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
                <td class="px-4 py-2 border-b border-gray-200">${attack.time}</td>
                <td class="px-4 py-2 border-b border-gray-200">${attack.ip}</td>
                <td class="px-4 py-2 border-b border-gray-200"><span class="inline-block px-2 py-1 text-xs font-semibold rounded-full bg-red-500 text-white">${attack.type}</span></td>
                <td class="px-4 py-2 border-b border-gray-200">${attack.site}</td>
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
                <td class="px-4 py-2 border-b border-gray-200">${site.domain}</td>
                <td class="px-4 py-2 border-b border-gray-200"><span class="inline-block px-2 py-1 text-xs font-semibold rounded-full bg-green-500 text-white">${site.status}</span></td>
                <td class="px-4 py-2 border-b border-gray-200">${site.traffic}</td>
                <td class="px-4 py-2 border-b border-gray-200">${site.attacks}</td>
            `;
            tbody.appendChild(tr);
        });
    }
    
    // Load dashboard data
    fetchDashboardData();
});
</script>