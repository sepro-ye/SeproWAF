<div class="flex flex-wrap mb-4">
    <div class="md:w-1/2">
        <h1>Security Log Details</h1>
        <p class="text-gray-600">Transaction ID: <span id="transaction-id">Loading...</span></p>
    </div>
    <div class="md:w-1/2 text-right">
        <a href="/waf/logs" class="px-4 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded">
            <i class="bi bi-arrow-left"></i> Back to Logs
        </a>
    </div>
</div>

<div id="log-loading" class="text-center py-8">
    <div class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-blue-600 border-t-transparent" role="status">
        <span class="sr-only">Loading...</span>
    </div>
    <p class="mt-2">Loading log details...</p>
</div>

<div id="log-content" class="hidden">
    <!-- Log Overview -->
    <div class="flex flex-wrap mb-4">
        <div class="w-full">
            <div class="bg-white rounded-lg shadow mb-4" id="overview-card">
                <div class="px-4 py-3 border-b">
                    <h5 class="text-lg font-medium mb-0">Overview</h5>
                </div>
                <div class="p-4">
                    <div class="flex flex-wrap">
                        <div class="w-full md:w-1/2 mb-4 md:mb-0">
                            <dl class="grid grid-cols-3 gap-4">
                                <dt class="col-span-1 font-medium">Time:</dt>
                                <dd class="col-span-2" id="time">-</dd>
                                
                                <dt class="col-span-1 font-medium">Site:</dt>
                                <dd class="col-span-2" id="domain">-</dd>
                                
                                <dt class="col-span-1 font-medium">Client IP:</dt>
                                <dd class="col-span-2" id="client-ip">-</dd>
                                
                                <dt class="col-span-1 font-medium">User Agent:</dt>
                                <dd class="col-span-2" id="user-agent">-</dd>
                                
                                <dt class="col-span-1 font-medium">Method:</dt>
                                <dd class="col-span-2" id="method">-</dd>
                                
                                <dt class="col-span-1 font-medium">URI:</dt>
                                <dd class="col-span-2" id="uri">-</dd>
                            </dl>
                        </div>
                        <div class="w-full md:w-1/2">
                            <dl class="grid grid-cols-3 gap-4">
                                <dt class="col-span-1 font-medium">Action:</dt>
                                <dd class="col-span-2">
                                    <span id="action" class="px-2 py-1 text-xs font-medium rounded-full text-white">-</span>
                                </dd>
                                
                                <dt class="col-span-1 font-medium">Severity:</dt>
                                <dd class="col-span-2">
                                    <span id="severity" class="px-2 py-1 text-xs font-medium rounded-full text-white">-</span>
                                </dd>
                                
                                <dt class="col-span-1 font-medium">Category:</dt>
                                <dd class="col-span-2" id="category">-</dd>
                                
                                <dt class="col-span-1 font-medium">Status:</dt>
                                <dd class="col-span-2" id="status">-</dd>
                                
                                <dt class="col-span-1 font-medium">Response Size:</dt>
                                <dd class="col-span-2" id="response-size">-</dd>
                                
                                <dt class="col-span-1 font-medium">Processing Time:</dt>
                                <dd class="col-span-2" id="processing-time">-</dd>
                            </dl>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Tab Navigation -->
    <div class="border-b border-gray-200 mb-4">
        <nav class="-mb-px flex">
            <button type="button" class="tab-btn active border-b-2 border-blue-500 py-2 px-4 text-sm font-medium text-blue-600" data-tab="request-tab">
                Request Details
            </button>
            <button type="button" class="tab-btn py-2 px-4 text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300" data-tab="response-tab">
                Response Details
            </button>
            <button type="button" class="tab-btn py-2 px-4 text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300" data-tab="rule-matches-tab">
                Rule Matches
            </button>
            <button type="button" class="tab-btn py-2 px-4 text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300" data-tab="raw-data-tab">
                Raw Data
            </button>
        </nav>
    </div>
    
    <!-- Tab Content -->
    <div class="tab-content" id="request-tab">
        <div class="flex flex-wrap mb-4">
            <div class="w-full">
                <div class="bg-white rounded-lg shadow mb-4">
                    <div class="px-4 py-3 border-b">
                        <h5 class="text-lg font-medium mb-0">Request Headers</h5>
                    </div>
                    <div class="p-4">
                        <div id="request-headers-content">
                            <div class="text-center text-gray-500">No request headers data available</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="flex flex-wrap mb-4">
            <div class="w-full">
                <div class="bg-white rounded-lg shadow">
                    <div class="px-4 py-3 border-b">
                        <h5 class="text-lg font-medium mb-0">Request Body</h5>
                    </div>
                    <div class="p-4">
                        <div id="request-body-content">
                            <div class="text-center text-gray-500">No request body data available</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="tab-content hidden" id="response-tab">
        <div class="flex flex-wrap mb-4">
            <div class="w-full">
                <div class="bg-white rounded-lg shadow mb-4">
                    <div class="px-4 py-3 border-b">
                        <h5 class="text-lg font-medium mb-0">Response Headers</h5>
                    </div>
                    <div class="p-4">
                        <div id="response-headers-content">
                            <div class="text-center text-gray-500">No response headers data available</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="flex flex-wrap mb-4">
            <div class="w-full">
                <div class="bg-white rounded-lg shadow">
                    <div class="px-4 py-3 border-b">
                        <h5 class="text-lg font-medium mb-0">Response Body</h5>
                    </div>
                    <div class="p-4">
                        <div id="response-body-content">
                            <div class="text-center text-gray-500">No response body data available</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="tab-content hidden" id="rule-matches-tab">
        <div class="flex flex-wrap mb-4">
            <div class="w-full">
                <div class="bg-white rounded-lg shadow">
                    <div class="px-4 py-3 border-b">
                        <h5 class="text-lg font-medium mb-0">Matched Rules</h5>
                    </div>
                    <div class="p-4">
                        <div id="rule-matches-content">
                            <div class="text-center text-gray-500">No rule matches data available</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="tab-content hidden" id="raw-data-tab">
        <div class="flex flex-wrap mb-4">
            <div class="w-full">
                <div class="bg-white rounded-lg shadow">
                    <div class="px-4 py-3 border-b">
                        <h5 class="text-lg font-medium mb-0">Raw JSON Data</h5>
                    </div>
                    <div class="p-4">
                        <pre id="raw-json" class="bg-gray-100 p-4 rounded-md overflow-x-auto text-sm"></pre>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div id="log-error" class="hidden">
    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
        <p class="font-bold">Error</p>
        <p id="error-message">Failed to load log details.</p>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const logId = {{.LogID}};
    
    // Load log details
    loadLogDetails(logId);
    
    // Tab switching
    document.querySelectorAll('.tab-btn').forEach(button => {
        button.addEventListener('click', function() {
            // Hide all tab contents
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.classList.add('hidden');
            });
            
            // Remove active class from all buttons
            document.querySelectorAll('.tab-btn').forEach(btn => {
                btn.classList.remove('active', 'border-b-2', 'border-blue-500', 'text-blue-600');
                btn.classList.add('text-gray-500');
            });
            
            // Show the selected tab content
            const tabId = this.dataset.tab;
            document.getElementById(tabId).classList.remove('hidden');
            
            // Set this button as active
            this.classList.add('active', 'border-b-2', 'border-blue-500', 'text-blue-600');
            this.classList.remove('text-gray-500');
        });
    });
    
    // Load log details from API
    async function loadLogDetails(id) {
        try {
            const response = await api.get(`/waf/logs/${id}`);
            
            // Hide loading, show content
            document.getElementById('log-loading').classList.add('hidden');
            
            // Check if the response has the expected structure
            if (response.data && response.data.success) {
                document.getElementById('log-content').classList.remove('hidden');
                
                // Render log details - access the nested properties
                renderLogDetails(response.data.log, response.data.details);
            } else {
                throw new Error('Invalid response format');
            }
        } catch (error) {
            console.error('Error loading log details:', error);
            document.getElementById('log-loading').classList.add('hidden');
            document.getElementById('log-error').classList.remove('hidden');
            document.getElementById('error-message').textContent = 'Failed to load log details: ' + (error.message || 'Unknown error');
        }
    }
    
    function renderLogDetails(log, details) {
        // Set transaction ID
        document.getElementById('transaction-id').textContent = log.TransactionID;
        
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
        
        // Fill in overview data
        document.getElementById('time').textContent = formattedDate;
        document.getElementById('domain').textContent = log.Domain;
        document.getElementById('client-ip').textContent = log.ClientIP;
        document.getElementById('user-agent').textContent = log.UserAgent || 'Not available';
        document.getElementById('method').textContent = log.Method;
        
        // URI with query string if available
        let uriDisplay = log.URI;
        if (log.QueryString) {
            uriDisplay += '?' + log.QueryString;
        }
        document.getElementById('uri').textContent = uriDisplay;
        
        // Action with color
        const actionElement = document.getElementById('action');
        actionElement.textContent = log.Action.toUpperCase();
        switch (log.Action) {
            case 'blocked':
            case 'blocked_response':
                actionElement.classList.add('bg-red-500');
                break;
            case 'allowed':
                actionElement.classList.add('bg-green-500');
                break;
            default:
                actionElement.classList.add('bg-gray-500');
        }
        
        // Severity with color
        const severityElement = document.getElementById('severity');
        if (log.Severity) {
            severityElement.textContent = log.Severity.toUpperCase();
            switch (log.Severity) {
                case 'critical':
                    severityElement.classList.add('bg-red-500');
                    break;
                case 'high':
                    severityElement.classList.add('bg-orange-500');
                    break;
                case 'medium':
                    severityElement.classList.add('bg-yellow-500');
                    break;
                case 'low':
                    severityElement.classList.add('bg-blue-500');
                    break;
                default:
                    severityElement.classList.add('bg-gray-500');
            }
        } else {
            severityElement.textContent = 'N/A';
            severityElement.classList.add('bg-gray-500');
        }
        
        document.getElementById('category').textContent = log.Category || 'N/A';
        
        // Status display
        let statusDisplay = `${log.StatusCode}`;
        if (log.BlockStatusCode) {
            statusDisplay += ` → ${log.BlockStatusCode}`;
        }
        document.getElementById('status').textContent = statusDisplay;
        
        // Format response size
        document.getElementById('response-size').textContent = formatBytes(log.ResponseSize);
        
        // Processing time
        document.getElementById('processing-time').textContent = `${log.ProcessingTime} ms`;
        
        // Process details if available
        if (details && details.length > 0) {
            processLogDetails(details);
        }
        
        // Add raw JSON data
        document.getElementById('raw-json').textContent = JSON.stringify({log, details}, null, 2);
    }
    
    function processLogDetails(details) {
        details.forEach(detail => {
            try {
                const content = JSON.parse(detail.Content);
                
                switch (detail.DetailType) {
                    case 'request_headers':
                        renderHeaders('request-headers-content', content);
                        break;
                    case 'request_body':
                        renderBody('request-body-content', content);
                        break;
                    case 'response_headers':
                        renderHeaders('response-headers-content', content);
                        break;
                    case 'response_body':
                        renderBody('response-body-content', content);
                        break;
                    case 'rule_matches':
                        renderRuleMatches(content);
                        break;
                }
            } catch (error) {
                console.error('Error parsing detail:', error);
            }
        });
    }
    
    function renderHeaders(containerId, headers) {
        const container = document.getElementById(containerId);
        
        if (!headers || Object.keys(headers).length === 0) {
            container.innerHTML = '<div class="text-center text-gray-500">No headers data available</div>';
            return;
        }
        
        let html = '<div class="overflow-x-auto"><table class="w-full border mb-0">';
        html += '<thead><tr class="bg-gray-100"><th class="px-4 py-2 text-left">Header</th><th class="px-4 py-2 text-left">Value</th></tr></thead>';
        html += '<tbody>';
        
        for (const [key, value] of Object.entries(headers)) {
            if (Array.isArray(value)) {
                for (const val of value) {
                    html += `<tr class="border-t"><td class="px-4 py-2 font-medium">${escapeHtml(key)}</td><td class="px-4 py-2">${escapeHtml(val)}</td></tr>`;
                }
            } else {
                html += `<tr class="border-t"><td class="px-4 py-2 font-medium">${escapeHtml(key)}</td><td class="px-4 py-2">${escapeHtml(value)}</td></tr>`;
            }
        }
        
        html += '</tbody></table></div>';
        container.innerHTML = html;
    }
    
    function renderBody(containerId, body) {
        const container = document.getElementById(containerId);
        
        if (!body) {
            container.innerHTML = '<div class="text-center text-gray-500">No body data available</div>';
            return;
        }
        
        let content;
        if (typeof body === 'string') {
            content = escapeHtml(body);
        } else {
            try {
                content = escapeHtml(JSON.stringify(body, null, 2));
            } catch (e) {
                content = escapeHtml(String(body));
            }
        }
        
        container.innerHTML = `<pre class="bg-gray-100 p-4 rounded-md overflow-x-auto text-sm">${content}</pre>`;
    }
    
    function renderRuleMatches(matches) {
        const container = document.getElementById('rule-matches-content');
        
        if (!matches || !Array.isArray(matches) || matches.length === 0) {
            container.innerHTML = '<div class="text-center text-gray-500">No rule matches found</div>';
            return;
        }
        
        let html = '';
        
        matches.forEach((match, index) => {
            let severityClass;
            if (match.severity) {
                switch (match.severity.toLowerCase()) {
                    case 'critical': severityClass = 'bg-red-500'; break;
                    case 'high': severityClass = 'bg-orange-500'; break;
                    case 'medium': severityClass = 'bg-yellow-500'; break;
                    case 'low': severityClass = 'bg-blue-500'; break;
                    default: severityClass = 'bg-gray-500';
                }
            } else {
                severityClass = 'bg-gray-500';
            }
            
            html += `
                <div class="mb-4 border rounded-md overflow-hidden">
                    <div class="px-4 py-2 ${severityClass} text-white font-medium">
                        Rule ID: ${match.id || 'N/A'}
                    </div>
                    <div class="p-4">
                        <h6 class="font-medium mb-2">${escapeHtml(match.name || 'Default Rules')}</h6>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <p class="text-sm text-gray-600 mb-1">Message:</p>
                                <p class="mb-3">${escapeHtml(match.message || 'No message')}</p>
                            </div>
                            <div>
                                <p class="text-sm text-gray-600 mb-1">Details:</p>
                                <div class="flex flex-wrap mb-3">
                                    <div class="w-1/2 mb-2">
                                        <span class="text-sm font-medium">Severity:</span>
                                        <span class="px-2 py-1 text-xs font-medium rounded-full ${severityClass} text-white">
                                            ${match.severity ? match.severity.toUpperCase() : 'N/A'}
                                        </span>
                                    </div>
                                    <div class="w-1/2 mb-2">
                                        <span class="text-sm font-medium">Category:</span>
                                        <span>${match.category || 'N/A'}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        ${match.data ? `
                        <div class="mt-2">
                            <p class="text-sm text-gray-600 mb-1">Match Data:</p>
                            <pre class="bg-gray-100 p-2 rounded-md overflow-x-auto text-xs">${escapeHtml(match.data)}</pre>
                        </div>` : ''}
                    </div>
                </div>
            `;
        });
        
        container.innerHTML = html;
    }
    
    // Helper functions
    function escapeHtml(unsafe) {
        return String(unsafe)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }
    
    function formatBytes(bytes, decimals = 2) {
        if (bytes === 0) return '0 Bytes';
        
        const k = 1024;
        const dm = decimals < 0 ? 0 : decimals;
        const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
        
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }
});
</script>

<style>
/* Tab styling */
.tab-btn.active {
    border-bottom-width: 2px;
}

/* Code display */
pre {
    white-space: pre-wrap;
    word-break: break-word;
}

/* Make sure tables are responsive */
.overflow-x-auto {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
}
</style>