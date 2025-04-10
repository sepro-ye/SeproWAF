<div class="flex flex-wrap mb-4">
    <div class="md:w-1/2">
        <h1 class="text-2xl font-bold">WAF Rules for {{.Site.Domain}}</h1>
        <p class="text-gray-600 mt-1">Manage your site's security rules</p>
    </div>
    <div class="md:w-1/2 text-right">
        <a href="/waf/sites/{{.SiteID}}/rules/new" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded inline-flex items-center">
            <i class="bi bi-plus-circle mr-2"></i> Add New Rule
        </a>
    </div>
</div>

<div class="flex flex-wrap mb-4">
    <div class="md:w-full">
        <div class="bg-white rounded-lg shadow">
            <div class="px-4 py-3 border-b flex justify-between items-center">
                <h5 class="text-lg font-medium mb-0">
                    <i class="bi bi-shield-lock text-blue-600 mr-2"></i>Active Rules
                </h5>
                <button id="refreshRulesBtn" class="px-3 py-1 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded inline-flex items-center">
                    <i class="bi bi-arrow-repeat mr-1"></i> Refresh
                </button>
            </div>
            <div class="p-0">
                <div id="rules-loading" class="text-center py-8">
                    <div class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-blue-600 border-t-transparent" role="status">
                        <span class="sr-only">Loading...</span>
                    </div>
                    <p class="mt-2">Loading rules...</p>
                </div>
                <div id="rules-empty" class="text-center py-8 hidden">
                    <i class="bi bi-shield text-4xl text-gray-500"></i>
                    <p class="mt-2">No WAF rules defined for this site yet.</p>
                    <a href="/waf/sites/{{.SiteID}}/rules/new" class="mt-4 inline-block px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded">
                        Create Your First Rule
                    </a>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full mb-0" id="rules-table">
                        <thead>
                            <tr class="bg-gray-50">
                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Created</th>
                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="rules-tbody" class="divide-y">
                            <!-- Rules will be loaded here via JavaScript -->
                        </tbody>
                    </table>
                </div>
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
                <h5 class="text-lg font-medium">Delete Rule</h5>
                <button type="button" class="text-gray-500 hover:text-gray-700" id="close-modal">
                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>
            <div class="px-4 py-3">
                <p>Are you sure you want to delete <strong id="delete-rule-name"></strong>?</p>
                <p class="text-red-500">This action cannot be undone.</p>
            </div>
            <div class="px-4 py-3 border-t flex justify-end space-x-2">
                <button type="button" class="px-4 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded" id="cancel-delete">Cancel</button>
                <button type="button" class="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded" id="confirm-delete">Delete</button>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Load rules
    loadRules();
    
    // Refresh button event
    document.getElementById('refreshRulesBtn').addEventListener('click', loadRules);
    
    // Handle delete confirmation
    let ruleToDelete = null;
    const deleteModal = document.getElementById('deleteModal');
    
    document.addEventListener('click', function(e) {
        if (e.target.closest('.delete-rule')) {
            const btn = e.target.closest('.delete-rule');
            const ruleId = btn.dataset.id;
            const ruleName = btn.dataset.name;
            
            // Set the rule to delete
            ruleToDelete = ruleId;
            document.getElementById('delete-rule-name').textContent = ruleName;
            
            // Show modal
            deleteModal.classList.remove('hidden');
        }
    });
    
    // Close modal events
    document.getElementById('close-modal').addEventListener('click', closeModal);
    document.getElementById('cancel-delete').addEventListener('click', closeModal);
    document.getElementById('modal-backdrop').addEventListener('click', closeModal);
    
    function closeModal() {
        deleteModal.classList.add('hidden');
    }
    
    document.getElementById('confirm-delete').addEventListener('click', function() {
        if (ruleToDelete) {
            deleteRule(ruleToDelete);
        }
    });
});

// Load rules from API
async function loadRules() {
    try {
        document.getElementById('rules-loading').classList.remove('hidden');
        document.getElementById('rules-table').classList.add('hidden');
        document.getElementById('rules-empty').classList.add('hidden');
        
        const response = await axios.get('/api/sites/{{.SiteID}}/waf/rules', {
            headers: {
                'Authorization': 'Bearer ' + localStorage.getItem('sepro_waf_token')
            }
        });
        
        renderRules(response.data);
    } catch (error) {
        console.error('Error loading rules:', error);
        showToast('Failed to load rules', 'danger');
        document.getElementById('rules-loading').classList.add('hidden');
        document.getElementById('rules-empty').classList.remove('hidden');
    }
}

// Render rules table
function renderRules(rules) {
    const tbody = document.getElementById('rules-tbody');
    const loading = document.getElementById('rules-loading');
    const empty = document.getElementById('rules-empty');
    const table = document.getElementById('rules-table');
    
    loading.classList.add('hidden');
    
    if (!rules || rules.length === 0) {
        empty.classList.remove('hidden');
        table.classList.add('hidden');
        return;
    }
    
    table.classList.remove('hidden');
    empty.classList.add('hidden');
    
    tbody.innerHTML = '';
    
    rules.forEach(rule => {
        const row = document.createElement('tr');
        row.className = 'hover:bg-gray-50';
        
        // Format rule type for display
        const formattedType = formatRuleType(rule.type);
        
        // Format date
        const createdDate = new Date(rule.created_at).toLocaleString();
        
        // Status indicator
        const statusBadge = rule.status === 'enabled' 
            ? '<span class="px-2 py-1 text-xs font-medium rounded-full bg-green-500 text-white">Enabled</span>'
            : '<span class="px-2 py-1 text-xs font-medium rounded-full bg-gray-500 text-white">Disabled</span>';
        
        // Type badge
        const typeBadgeClass = getTypeBadgeClass(rule.type);
        
        row.innerHTML = `
            <td class="px-4 py-2">${rule.id}</td>
            <td class="px-4 py-2 font-medium">${rule.name}</td>
            <td class="px-4 py-2">
                <span class="px-2 py-1 text-xs font-medium rounded-full ${typeBadgeClass}">
                    ${formattedType}
                </span>
            </td>
            <td class="px-4 py-2">${statusBadge}</td>
            <td class="px-4 py-2">${createdDate}</td>
            <td class="px-4 py-2">
                <div class="inline-flex rounded-md shadow-sm">
                    <a href="/waf/sites/{{.SiteID}}/rules/${rule.id}/edit" class="px-2 py-1 text-sm border border-blue-600 text-blue-600 hover:bg-blue-600 hover:text-white rounded-l-md" title="Edit">
                        <i class="bi bi-pencil"></i>
                    </a>
                    <button type="button" class="px-2 py-1 text-sm border-t border-b border-gray-500 toggle-rule ${rule.status === 'enabled' ? 'text-yellow-600 hover:bg-yellow-600' : 'text-green-600 hover:bg-green-600'} hover:text-white" 
                        data-id="${rule.id}" data-status="${rule.status}" title="${rule.status === 'enabled' ? 'Disable' : 'Enable'}">
                        <i class="bi ${rule.status === 'enabled' ? 'bi-pause' : 'bi-play'}"></i>
                    </button>
                    <button type="button" class="px-2 py-1 text-sm border border-red-600 text-red-600 hover:bg-red-600 hover:text-white rounded-r-md delete-rule" 
                        data-id="${rule.id}" data-name="${rule.name}" title="Delete">
                        <i class="bi bi-trash"></i>
                    </button>
                </div>
            </td>
        `;
        
        tbody.appendChild(row);
    });
    
    // Add event listener for toggle buttons
    document.querySelectorAll('.toggle-rule').forEach(btn => {
        btn.addEventListener('click', function() {
            toggleRule(this.dataset.id, this.dataset.status);
        });
    });
}

// Format rule type for display
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

// Get badge class for rule type
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

// Toggle rule status
async function toggleRule(ruleId, currentStatus) {
    try {
        await axios.post(`/api/waf/rules/${ruleId}/toggle`, {}, {
            headers: {
                'Authorization': 'Bearer ' + localStorage.getItem('sepro_waf_token')
            }
        });
        
        showToast(`Rule ${currentStatus === 'enabled' ? 'disabled' : 'enabled'} successfully`, 'success');
        loadRules();
    } catch (error) {
        console.error('Error toggling rule:', error);
        showToast('Failed to toggle rule status', 'danger');
    }
}

// Delete a rule
async function deleteRule(ruleId) {
    try {
        await axios.delete(`/api/waf/rules/${ruleId}`, {
            headers: {
                'Authorization': 'Bearer ' + localStorage.getItem('sepro_waf_token')
            }
        });
        
        // Close modal
        document.getElementById('deleteModal').classList.add('hidden');
        
        // Show success message
        showToast('Rule deleted successfully', 'success');
        
        // Reload rules
        loadRules();
    } catch (error) {
        console.error('Error deleting rule:', error);
        showToast('Failed to delete rule', 'danger');
    }
}
</script>