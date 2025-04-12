<div class="flex flex-wrap mb-4">
    <div class="w-full">
        <h1 class="text-2xl font-bold">Dashboard</h1>
        <p class="text-xl font-light">Welcome back, {{.Username}}!</p>
    </div>
</div>

<div class="flex flex-wrap mb-4">
    <div class="w-full md:w-1/3 px-2">
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
    
    <div class="w-full md:w-1/3 px-2">
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
    
    <div class="w-full md:w-1/3 px-2">
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
            // Fetch dashboard stats
            const stats = await api.get('/dashboard/stats');
            if (stats.data && stats.data.success) {
                document.getElementById('sites-count').textContent = stats.data.sites_count || '0';
                document.getElementById('attacks-count').textContent = stats.data.attacks_count || '0';
                document.getElementById('requests-count').textContent = stats.data.requests_count || '0';
            }
            
            // Get traffic data for the chart
            const trafficData = await api.get('/dashboard/traffic');
            if (trafficData.data && trafficData.data.success) {
                renderTrafficChart(trafficData.data.traffic);
            } else {
                renderTrafficChart(null);
            }
            
            // Get attack type distribution
            const attackTypesData = await api.get('/dashboard/attack-types');
            if (attackTypesData.data && attackTypesData.data.success) {
                renderAttackTypesChart(attackTypesData.data.attack_types);
            } else {
                renderAttackTypesChart(null);
            }
            
            // Get recent attacks
            const recentAttacksData = await api.get('/waf/logs', {
                params: {
                    page: 1,
                    page_size: 5,
                    action: 'blocked'  // Changed from 'block' to 'blocked'
                }
            });
            
            if (recentAttacksData.data && recentAttacksData.data.success) {
                renderRecentAttacks(recentAttacksData.data.data);
            } else {
                renderRecentAttacks([]);
            }
            
            // Get protected sites
            const sitesData = await api.get('/sites');
            if (sitesData.data && sitesData.status === 200) {
                renderProtectedSites(sitesData.data);
            } else {
                renderProtectedSites([]);
            }
        } catch (error) {
            console.error('Error fetching dashboard data:', error);
            showToast('Failed to load dashboard data', 'danger');
        }
    }
    
    // Traffic chart
    function renderTrafficChart(data) {
        const ctx = document.getElementById('trafficChart').getContext('2d');
        
        // Use actual data if available, otherwise use placeholder data
        const labels = data?.labels || Array.from({length: 24}, (_, i) => `${23-i}h ago`).reverse();
        
        const chartData = {
            labels: labels,
            datasets: [
                {
                    label: 'Legitimate Traffic',
                    data: data?.legitimate || Array.from({length: 24}, () => Math.floor(Math.random() * 100) + 100),
                    borderColor: '#3498db',
                    backgroundColor: 'rgba(52, 152, 219, 0.1)',
                    fill: true,
                    tension: 0.3
                },
                {
                    label: 'Blocked Attacks',
                    data: data?.blocked || Array.from({length: 24}, () => Math.floor(Math.random() * 20)),
                    borderColor: '#e74c3c',
                    backgroundColor: 'rgba(231, 76, 60, 0.1)',
                    fill: true,
                    tension: 0.3
                }
            ]
        };
        
        new Chart(ctx, {
            type: 'line',
            data: chartData,
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
    function renderAttackTypesChart(data) {
        const ctx = document.getElementById('attackTypesChart').getContext('2d');
        
        // Use actual data if available, otherwise use placeholder data
        const labels = data?.labels || ['SQL Injection', 'XSS', 'CSRF', 'Path Traversal', 'Other'];
        const values = data?.values || [45, 25, 12, 8, 10];
        
        const chartData = {
            labels: labels,
            datasets: [{
                data: values,
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
            data: chartData,
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
    function renderRecentAttacks(attacks) {
        const tbody = document.getElementById('recent-attacks');
        tbody.innerHTML = '';
        
        if (!attacks || attacks.length === 0) {
            const tr = document.createElement('tr');
            tr.innerHTML = `<td colspan="4" class="text-center py-4">No recent attacks</td>`;
            tbody.appendChild(tr);
            return;
        }
        
        // Add console logging to see the structure of attack data
        
        attacks.forEach(attack => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td class="px-4 py-2 border-b border-gray-200">${formatDate(attack.CreatedAt || attack.created_at)}</td>
                <td class="px-4 py-2 border-b border-gray-200">${attack.ClientIP || attack.client_ip}</td>
                <td class="px-4 py-2 border-b border-gray-200">
                    <span class="inline-block px-2 py-1 text-xs font-semibold rounded-full bg-red-500 text-white">
                        ${attack.Category || attack.category || 'Unknown'}
                    </span>
                </td>
                <td class="px-4 py-2 border-b border-gray-200">${attack.Domain || attack.domain}</td>
            `;
            tbody.appendChild(tr);
        });
    }
    
    // Protected sites table
    function renderProtectedSites(sites) {
        const tbody = document.getElementById('protected-sites');
        tbody.innerHTML = '';
        
        if (!sites || sites.length === 0) {
            const tr = document.createElement('tr');
            tr.innerHTML = `<td colspan="4" class="text-center py-4">No protected sites</td>`;
            tbody.appendChild(tr);
            return;
        }
        
        // Show loading indicator
        tbody.innerHTML = `<tr><td colspan="4" class="text-center py-4">Loading site statistics...</td></tr>`;
        
        // Create a function to fetch stats for all sites
        const fetchAllSiteStats = async () => {
            tbody.innerHTML = ''; // Clear loading message
            
            // Process each site
            for (const site of sites) {
                try {
                    // Create a row for this site with placeholder values
                    const tr = document.createElement('tr');
                    tr.innerHTML = `
                        <td class="px-4 py-2 border-b border-gray-200">${site.Domain}</td>
                        <td class="px-4 py-2 border-b border-gray-200">
                            <span class="inline-block px-2 py-1 text-xs font-semibold rounded-full 
                                ${site.WAFEnabled ? 'bg-green-500' : 'bg-gray-500'} text-white">
                                ${site.WAFEnabled ? 'Active' : 'Inactive'}
                            </span>
                        </td>
                        <td class="px-4 py-2 border-b border-gray-200">
                            <span class="loading-placeholder">Loading...</span>
                        </td>
                        <td class="px-4 py-2 border-b border-gray-200">
                            <span class="loading-placeholder">Loading...</span>
                        </td>
                    `;
                    tbody.appendChild(tr);
                    
                    // Fetch the site logs data
                    const response = await api.get(`/sites/${site.ID}/logs`, {
                        params: {
                            page: 1,
                            page_size: 1 // We only need the stats, not the actual logs
                        }
                    });
                    
                    // Update the row with the stats data
                    if (response.data && response.data.success && response.data.stats) {
                        const statsData = response.data.stats;
                        const cells = tr.querySelectorAll('td');
                        
                        // Update traffic count (requests_24h)
                        cells[2].innerHTML = formatNumber(statsData.requests_24h || 0);
                        
                        // Update attacks count (attacks_24h)
                        cells[3].innerHTML = formatNumber(statsData.attacks_24h || 0);
                    } else {
                        // If there was an error or no stats, show zeros
                        const cells = tr.querySelectorAll('td');
                        cells[2].innerHTML = '0';
                        cells[3].innerHTML = '0';
                    }
                } catch (error) {
                    console.error(`Error fetching stats for site ${site.Domain}:`, error);
                    // Leave the row with error indicators if needed
                }
            }
        };
        
        // Start fetching stats for all sites
        fetchAllSiteStats();
    }
    
    // Helper function to format date
    function formatDate(dateString) {
        if (!dateString) return '--';
        const date = new Date(dateString);
        return date.toLocaleString();
    }
    
    // Helper function to format numbers
    function formatNumber(num) {
        if (num >= 1000) {
            return (num / 1000).toFixed(1) + 'K';
        }
        return num.toString();
    }
    
    // Load dashboard data
    fetchDashboardData();
});
</script>