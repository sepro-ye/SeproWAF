<div class="flex flex-wrap mb-4">
    <div class="md:w-1/2">
        <h1>WAF Security Logs</h1>
        <p class="text-gray-600">View security events and blocked attacks</p>
    </div>
    <div class="md:w-1/2 text-right">
        <div class="inline-flex rounded-md shadow-sm" role="group" id="time-range-selector">
            <button type="button" class="px-3 py-2 text-sm font-medium border border-gray-400 text-gray-700 bg-gray-100 rounded-l-md active" data-range="24h">24 Hours</button>
            <button type="button" class="px-3 py-2 text-sm font-medium border-t border-b border-gray-400 text-gray-700 bg-white" data-range="7d">7 Days</button>
            <button type="button" class="px-3 py-2 text-sm font-medium border border-gray-400 text-gray-700 bg-white rounded-r-md" data-range="30d">30 Days</button>
        </div>
        <button id="refreshBtn" class="ml-2 px-3 py-2 text-sm font-medium border border-blue-600 text-blue-600 hover:bg-blue-600 hover:text-white rounded">
            <i class="bi bi-arrow-clockwise"></i> Refresh
        </button>
    </div>
</div>

<div class="flex flex-wrap mb-4">
    <div class="w-full">
        <div class="bg-white rounded-lg shadow">
            <div class="px-4 py-3 border-b">
                <h5 class="text-lg font-medium mb-0">Filters</h5>
            </div>
            <div class="p-4">
                <form id="logFilterForm" class="flex flex-wrap">
                    <div class="w-full md:w-1/4 px-2 mb-3">
                        <label for="site_id" class="block text-sm font-medium text-gray-700 mb-1">Site</label>
                        <div class="relative">
                            <select id="site_id" name="site_id" class="block w-full rounded-md border-gray-300 bg-white pl-3 pr-10 py-2 text-base focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 shadow-sm appearance-none">
                                <option value="">All Sites</option>
                                <!-- Sites will be loaded dynamically -->
                            </select>
                            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
                                <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                </svg>
                            </div>
                        </div>
                    </div>
                    <div class="w-full md:w-1/4 px-2 mb-3">
                        <label for="client_ip" class="block text-sm font-medium text-gray-700 mb-1">Client IP</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9-3-9m-9 9a9 9 0 019-9" />
                                </svg>
                            </div>
                            <input type="text" id="client_ip" name="client_ip" class="block w-full pl-10 pr-3 py-2 rounded-md border-gray-300 shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500" placeholder="e.g. 192.168.1.1">
                        </div>
                    </div>
                    <div class="w-full md:w-1/4 px-2 mb-3">
                        <label for="action" class="block text-sm font-medium text-gray-700 mb-1">Action</label>
                        <div class="relative">
                            <select id="action" name="action" class="block w-full rounded-md border-gray-300 bg-white pl-3 pr-10 py-2 text-base focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 shadow-sm appearance-none">
                                <option value="">All Actions</option>
                                <option value="allowed">Allowed</option>
                                <option value="blocked">Blocked</option>
                                <option value="blocked_response">Blocked Response</option>
                            </select>
                            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
                                <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                </svg>
                            </div>
                        </div>
                    </div>
                    <div class="w-full md:w-1/4 px-2 mb-3">
                        <label for="severity" class="block text-sm font-medium text-gray-700 mb-1">Severity</label>
                        <div class="relative">
                            <select id="severity" name="severity" class="block w-full rounded-md border-gray-300 bg-white pl-3 pr-10 py-2 text-base focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 shadow-sm appearance-none">
                                <option value="">All Severities</option>
                                <option value="critical">Critical</option>
                                <option value="high">High</option>
                                <option value="medium">Medium</option>
                                <option value="low">Low</option>
                            </select>
                            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
                                <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                </svg>
                            </div>
                        </div>
                    </div>
                    <div class="w-full md:w-1/4 px-2 mb-3">
                        <label for="method" class="block text-sm font-medium text-gray-700 mb-1">Method</label>
                        <div class="relative">
                            <select id="method" name="method" class="block w-full rounded-md border-gray-300 bg-white pl-3 pr-10 py-2 text-base focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 shadow-sm appearance-none">
                                <option value="">All Methods</option>
                                <option value="GET">GET</option>
                                <option value="POST">POST</option>
                                <option value="PUT">PUT</option>
                                <option value="DELETE">DELETE</option>
                                <option value="HEAD">HEAD</option>
                            </select>
                            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
                                <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                </svg>
                            </div>
                        </div>
                    </div>
                    <div class="w-full md:w-1/4 px-2 mb-3">
                        <label for="uri" class="block text-sm font-medium text-gray-700 mb-1">URI</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101" />
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.828 14.828a4 4 0 015.656 0l4 4a4 4 0 01-5.656 5.656l-1.102-1.101" />
                                </svg>
                            </div>
                            <input type="text" id="uri" name="uri" class="block w-full pl-10 pr-3 py-2 rounded-md border-gray-300 shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500" placeholder="e.g. /admin">
                        </div>
                    </div>
                    <div class="w-full md:w-1/4 px-2 mb-3">
                        <label for="start_date" class="block text-sm font-medium text-gray-700 mb-1">Start Date & Time</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                </svg>
                            </div>
                            <input type="datetime-local" id="start_date" name="start_date" step="1" class="block w-full pl-10 pr-3 py-2 rounded-md border-gray-300 shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        </div>
                    </div>
                    <div class="w-full md:w-1/4 px-2 mb-3">
                        <label for="end_date" class="block text-sm font-medium text-gray-700 mb-1">End Date & Time</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                </svg>
                            </div>
                            <input type="datetime-local" id="end_date" name="end_date" step="1" class="block w-full pl-10 pr-3 py-2 rounded-md border-gray-300 shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        </div>
                    </div>
                    <div class="w-full flex justify-end px-2">
                        <button type="button" id="clearFiltersBtn" class="px-4 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded mr-2">
                            Clear Filters
                        </button>
                        <button type="submit" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded">
                            Apply Filters
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<div class="flex flex-wrap mb-4">
    <div class="md:w-full">
        <div class="bg-white rounded-lg shadow">
            <div class="px-4 py-3 border-b flex justify-between items-center">
                <h5 class="text-lg font-medium mb-0">Security Events</h5>
                <span id="log-count" class="text-sm text-gray-600">
                    Showing <span id="shown-count">0</span> of <span id="total-count">0</span> events
                </span>
            </div>
            <div class="p-0">
                <div id="logs-loading" class="text-center py-4">
                    <div class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-blue-600 border-t-transparent" role="status">
                        <span class="sr-only">Loading...</span>
                    </div>
                    <p class="mt-2">Loading security logs...</p>
                </div>
                <div id="logs-empty" class="text-center py-4 hidden">
                    <i class="bi bi-shield-check text-4xl text-gray-500"></i>
                    <p class="mt-2">No security events found for the selected filters.</p>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full mb-0" id="logs-table">
                        <thead>
                            <tr>
                                <th class="px-4 py-2 text-left">Time</th>
                                <th class="px-4 py-2 text-left">Site</th>
                                <th class="px-4 py-2 text-left">Client IP</th>
                                <th class="px-4 py-2 text-left">Method</th>
                                <th class="px-4 py-2 text-left">URI</th>
                                <th class="px-4 py-2 text-left">Action</th>
                                <th class="px-4 py-2 text-left">Severity</th>
                                <th class="px-4 py-2 text-left">Status</th>
                                <th class="px-4 py-2 text-left">Details</th>
                            </tr>
                        </thead>
                        <tbody id="logs-tbody" class="divide-y">
                            <!-- Security logs will be loaded here via JavaScript -->
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="px-4 py-3 border-t">
                <div class="flex justify-between">
                    <div>
                        <div class="relative">
                            <select id="page-size" class="rounded-md border-gray-300 shadow-sm bg-white pl-3 pr-10 py-2 text-base focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 appearance-none">
                                <option value="10">10 per page</option>
                                <option value="20" selected>20 per page</option>
                                <option value="50">50 per page</option>
                                <option value="100">100 per page</option>
                            </select>
                            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
                                <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                </svg>
                            </div>
                        </div>
                    </div>
                    <div class="flex space-x-1" id="pagination-container">
                        <!-- Pagination will be loaded here -->
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Variables for pagination
    let currentPage = 1;
    let pageSize = 20;
    let timeRange = '24h';
    
    // Load sites for filter dropdown
    loadSites();
    
    // Load initial logs
    loadLogs();
    
    // Event listeners
    document.getElementById('logFilterForm').addEventListener('submit', function(e) {
        e.preventDefault();
        currentPage = 1;
        loadLogs();
    });
    
    document.getElementById('refreshBtn').addEventListener('click', function() {
        loadLogs();
    });
    
    document.getElementById('clearFiltersBtn').addEventListener('click', function() {
        document.getElementById('logFilterForm').reset();
        // Reset the date fields explicitly
        document.getElementById('start_date').value = '';
        document.getElementById('end_date').value = '';
        currentPage = 1;
        timeRange = '24h'; // Reset to default time range
        
        // Update the active button in time range selector
        document.querySelectorAll('#time-range-selector button').forEach(btn => {
            if (btn.dataset.range === timeRange) {
                btn.classList.add('active', 'bg-gray-100');
                btn.classList.remove('bg-white');
            } else {
                btn.classList.remove('active', 'bg-gray-100');
                btn.classList.add('bg-white');
            }
        });
        
        // Set default date range
        setDateRangeFromPreset(timeRange);
        
        loadLogs();
    });
    
    document.getElementById('page-size').addEventListener('change', function() {
        pageSize = parseInt(this.value);
        currentPage = 1;
        loadLogs();
    });
    
    // Time range selector
    document.getElementById('time-range-selector').addEventListener('click', function(e) {
        if (e.target.tagName === 'BUTTON') {
            // Update active button
            document.querySelectorAll('#time-range-selector button').forEach(btn => {
                btn.classList.remove('active', 'bg-gray-100');
                btn.classList.add('bg-white');
            });
            
            e.target.classList.add('active', 'bg-gray-100');
            e.target.classList.remove('bg-white');
            
            // Update time range and reload logs
            timeRange = e.target.dataset.range;
            
            // Set date inputs based on time range
            setDateRangeFromPreset(timeRange);
            
            currentPage = 1;
            loadLogs();
        }
    });
    
    // Functions
    function formatDatetime(date) {
        // Format date for datetime-local input (YYYY-MM-DDThh:mm:ss)
        // This formats the date in the local timezone, which is what datetime-local expects
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        const seconds = String(date.getSeconds()).padStart(2, '0');
        
        return `${year}-${month}-${day}T${hours}:${minutes}:${seconds}`;
    }

    function setDateRangeFromPreset(range) {
        const now = new Date();
        const startDateInput = document.getElementById('start_date');
        const endDateInput = document.getElementById('end_date');
        
        // Clear existing values
        startDateInput.value = '';
        endDateInput.value = '';
        
        // Set end date to now with time component
        const endDate = formatDatetime(now);
        endDateInput.value = endDate;
        
        // Set start date based on range
        let startDate;
        switch(range) {
            case '24h':
                const yesterday = new Date(now);
                yesterday.setHours(now.getHours() - 24);
                startDate = formatDatetime(yesterday);
                break;
            case '7d':
                const sevenDaysAgo = new Date(now);
                sevenDaysAgo.setDate(now.getDate() - 7);
                startDate = formatDatetime(sevenDaysAgo);
                break;
            case '30d':
                const thirtyDaysAgo = new Date(now);
                thirtyDaysAgo.setDate(now.getDate() - 30);
                startDate = formatDatetime(thirtyDaysAgo);
                break;
        }
        
        startDateInput.value = startDate;
    }
    
    async function loadSites() {
        try {
            const response = await api.get('/sites');
            const siteSelect = document.getElementById('site_id');
            
            // Get site_id from URL query parameters if present
            const urlParams = new URLSearchParams(window.location.search);
            const siteIdParam = urlParams.get('site_id');
            
            // Add site options
            response.data.forEach(site => {
                const option = document.createElement('option');
                option.value = site.ID;
                option.textContent = site.Name;
                
                // Set selected if matches URL parameter
                if (siteIdParam && siteIdParam == site.ID) {
                    option.selected = true;
                }
                
                siteSelect.appendChild(option);
            });
            
            // If we had a site_id in URL, trigger a filter
            if (siteIdParam) {
                loadLogs();
            }
        } catch (error) {
            console.error('Error loading sites:', error);
            showToast('Failed to load sites', 'danger');
        }
    }
    
    async function loadLogs() {
        const formData = new FormData(document.getElementById('logFilterForm'));
        const params = new URLSearchParams();
        
        // Add form data to params with proper handling of datetime inputs
        for (const [key, value] of formData.entries()) {
            if (value) {
                // For datetime-local inputs, we need to handle the date conversion properly
                if (key === 'start_date' || key === 'end_date') {
                    try {
                        const dateObj = new Date(value);
                        if (!isNaN(dateObj.getTime())) {
                            // Format the date as if it's in +03:00 without altering time
                            const pad = (num) => String(num).padStart(2, '0');
                            const year = dateObj.getFullYear();
                            const month = pad(dateObj.getMonth() + 1);
                            const day = pad(dateObj.getDate());
                            const hours = pad(dateObj.getHours());
                            const minutes = pad(dateObj.getMinutes());
                            const seconds = pad(dateObj.getSeconds());

                            // Just append +03:00 without offsetting the date
                            const formatted = `${year}-${month}-${day}T${hours}:${minutes}:${seconds}+03:00`;

                            params.append(key, formatted);
                        } else {
                            console.warn(`Invalid date for ${key}: ${value}`);
                        }
                    } catch (e) {
                        console.error(`Error parsing date for ${key}: ${e.message}`);
                    }
                } else {
                    params.append(key, value);
                }
            }
        }
        
        // Add pagination
        params.append('page', currentPage);
        params.append('page_size', pageSize);
                
        // Show loading
        document.getElementById('logs-loading').classList.remove('hidden');
        document.getElementById('logs-table').classList.add('hidden');
        document.getElementById('logs-empty').classList.add('hidden');
        
        try {
            const response = await api.get(`/waf/logs?${params.toString()}`);
            
            // Hide loading
            document.getElementById('logs-loading').classList.add('hidden');
            
            // Handle nested response structure
            const responseData = response.data;
            
            if (!responseData.data || responseData.data.length === 0) {
                document.getElementById('logs-empty').classList.remove('hidden');
                document.getElementById('logs-table').classList.add('hidden');
                document.getElementById('shown-count').textContent = '0';
                document.getElementById('total-count').textContent = '0';
                document.getElementById('pagination-container').innerHTML = '';
                return;
            }
            
            // Render logs with the correct data array
            renderLogs(responseData.data);
            
            // Update counts using the nested structure
            document.getElementById('shown-count').textContent = responseData.data.length;
            document.getElementById('total-count').textContent = responseData.pagination.total;
            
            // Render pagination with the correct pagination object
            renderPagination(responseData.pagination.page, responseData.pagination.total_pages);
            
            // Show table
            document.getElementById('logs-table').classList.remove('hidden');
        } catch (error) {
            console.error('Error loading logs:', error);
            showToast('Failed to load security logs', 'danger');
            document.getElementById('logs-loading').classList.add('hidden');
            document.getElementById('logs-empty').classList.remove('hidden');
        }
    }
    
    function renderLogs(logs) {
        const tbody = document.getElementById('logs-tbody');
        tbody.innerHTML = '';
        
        if (!Array.isArray(logs)) {
            console.error('Expected logs to be an array, but got:', logs);
            return;
        }
        
        logs.forEach(log => {
            const row = document.createElement('tr');
            row.className = 'hover:bg-gray-50';
            
            // Format date
            const date = new Date(log.CreatedAt);
            const formattedDate = new Intl.DateTimeFormat('default', {
                year: 'numeric',
                month: 'short',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            }).format(date);
            
            // Determine action color
            let actionClass;
            switch (log.Action) {
                case 'blocked':
                case 'blocked_response':
                    actionClass = 'bg-red-500';
                    break;
                case 'allowed':
                    actionClass = 'bg-green-500';
                    break;
                default:
                    actionClass = 'bg-gray-500';
            }
            
            // Determine severity color
            let severityClass;
            switch (log.Severity) {
                case 'critical':
                    severityClass = 'bg-red-500';
                    break;
                case 'high':
                    severityClass = 'bg-orange-500';
                    break;
                case 'medium':
                    severityClass = 'bg-yellow-500';
                    break;
                case 'low':
                    severityClass = 'bg-blue-500';
                    break;
                default:
                    severityClass = 'bg-gray-500';
            }
            
            // Build status display
            let statusDisplay = log.StatusCode;
            if (log.BlockStatusCode) {
                statusDisplay += ` → ${log.BlockStatusCode}`;
            }
            
            // Truncate URI if too long
            const uri = log.URI.length > 30 ? log.URI.substring(0, 27) + '...' : log.URI;
            
            row.innerHTML = `
                <td class="px-4 py-2">${formattedDate}</td>
                <td class="px-4 py-2">${log.Domain}</td>
                <td class="px-4 py-2">${log.ClientIP}</td>
                <td class="px-4 py-2">${log.Method}</td>
                <td class="px-4 py-2" title="${log.URI}">${uri}</td>
                <td class="px-4 py-2">
                    <span class="px-2 py-1 text-xs font-medium rounded-full ${actionClass} text-white">
                        ${log.Action}
                    </span>
                </td>
                <td class="px-4 py-2">
                    ${log.Severity ? `
                    <span class="px-2 py-1 text-xs font-medium rounded-full ${severityClass} text-white">
                        ${log.Severity}
                    </span>` : 'N/A'}
                </td>
                <td class="px-4 py-2">${statusDisplay}</td>
                <td class="px-4 py-2">
                    <a href="/waf/logs/${log.ID}" class="px-2 py-1 text-sm border border-blue-600 text-blue-600 hover:bg-blue-600 hover:text-white rounded">
                        <i class="bi bi-search"></i> View
                    </a>
                </td>
            `;
            
            tbody.appendChild(row);
        });
    }
    
    function renderPagination(currentPage, totalPages) {
        const container = document.getElementById('pagination-container');
        container.innerHTML = '';
        
        if (totalPages <= 1) {
            return;
        }
        
        // Previous button
        if (currentPage > 1) {
            addPaginationButton(container, currentPage - 1, '&laquo; Prev');
        }
        
        // Page numbers
        const startPage = Math.max(1, currentPage - 2);
        const endPage = Math.min(totalPages, currentPage + 2);
        
        if (startPage > 1) {
            addPaginationButton(container, 1, '1');
            if (startPage > 2) {
                addPaginationEllipsis(container);
            }
        }
        
        for (let i = startPage; i <= endPage; i++) {
            addPaginationButton(container, i, i.toString(), i === currentPage);
        }
        
        if (endPage < totalPages) {
            if (endPage < totalPages - 1) {
                addPaginationEllipsis(container);
            }
            addPaginationButton(container, totalPages, totalPages.toString());
        }
        
        // Next button
        if (currentPage < totalPages) {
            addPaginationButton(container, currentPage + 1, 'Next &raquo;');
        }
    }
    
    function addPaginationButton(container, page, label, isActive = false) {
        const button = document.createElement('button');
        button.innerHTML = label;
        button.className = isActive 
            ? 'px-3 py-1 text-sm font-medium border border-blue-600 bg-blue-600 text-white rounded'
            : 'px-3 py-1 text-sm font-medium border border-gray-300 text-gray-700 hover:bg-gray-100 rounded';
        
        button.addEventListener('click', function() {
            currentPage = page;
            loadLogs();
        });
        
        container.appendChild(button);
    }
    
    function addPaginationEllipsis(container) {
        const span = document.createElement('span');
        span.innerHTML = '...';
        span.className = 'px-3 py-1 text-sm font-medium text-gray-700';
        container.appendChild(span);
    }
    
    // Initialize with default time range
    setDateRangeFromPreset(timeRange);
});
</script>

<style>
/* Add styles for severity and action badges */
.severity-critical { background-color: #ef4444 !important; }
.severity-high { background-color: #f97316 !important; }
.severity-medium { background-color: #eab308 !important; }
.severity-low { background-color: #3b82f6 !important; }

.action-blocked { background-color: #ef4444 !important; }
.action-allowed { background-color: #22c55e !important; }
.action-blocked_response { background-color: #ef4444 !important; }

/* Make sure table is responsive */
.overflow-x-auto {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
}
</style>