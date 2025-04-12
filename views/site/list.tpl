<div class="flex flex-wrap mb-4">
    <div class="md:w-1/2">
        <h1>Protected Sites</h1>
    </div>
    <div class="md:w-1/2 text-right">
        <a href="/waf/sites/new" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded">
            <i class="bi bi-plus-circle"></i> Add New Site
        </a>
    </div>
</div>

<div class="flex flex-wrap mb-4">
    <div class="md:w-full">
        <div class="bg-white rounded-lg shadow">
            <div class="px-4 py-3 border-b">
                <h5 class="text-lg font-medium mb-0">Your Protected Websites</h5>
            </div>
            <div class="p-0">
                <div id="sites-loading" class="text-center py-4">
                    <div class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-blue-600 border-t-transparent" role="status">
                        <span class="sr-only">Loading...</span>
                    </div>
                    <p class="mt-2">Loading sites...</p>
                </div>
                <div id="sites-empty" class="text-center py-4 hidden">
                    <i class="bi bi-globe text-4xl text-gray-500"></i>
                    <p class="mt-2">You don't have any protected sites yet.</p>
                    <a href="/waf/sites/new" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded">Add Your First Site</a>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full mb-0" id="sites-table">
                        <thead>
                            <tr>
                                <th class="px-4 py-2 text-left">Name</th>
                                <th class="px-4 py-2 text-left">Domain</th>
                                <th class="px-4 py-2 text-left">Status</th>
                                <th class="px-4 py-2 text-left">Requests (24h)</th>
                                <th class="px-4 py-2 text-left">Attacks Blocked (24h)</th>
                                <th class="px-4 py-2 text-left">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="sites-tbody" class="divide-y">
                            <!-- Sites will be loaded here via JavaScript -->
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
                <h5 class="text-lg font-medium">Delete Site</h5>
                <button type="button" class="text-gray-500 hover:text-gray-700" id="close-modal">
                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>
            <div class="px-4 py-3">
                <p>Are you sure you want to delete <strong id="delete-site-name"></strong>?</p>
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
    // Load sites
    loadSites();
    
    // Handle delete confirmation
    let siteToDelete = null;
    const deleteModal = document.getElementById('deleteModal');
    
    document.addEventListener('click', function(e) {
        if (e.target.closest('.delete-site')) {
            const btn = e.target.closest('.delete-site');
            const siteId = btn.dataset.id;
            const siteName = btn.dataset.name;
            
            // Set the site to delete
            siteToDelete = siteId;
            document.getElementById('delete-site-name').textContent = siteName;
            
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
        if (siteToDelete) {
            deleteSite(siteToDelete);
        }
    });
});

// Load sites from API
async function loadSites() {
    try {
        const response = await api.get('/sites');
        renderSites(response.data);
    } catch (error) {
        console.error('Error loading sites:', error);
        showToast('Failed to load sites', 'danger');
        document.getElementById('sites-loading').classList.add('hidden');
        document.getElementById('sites-empty').classList.remove('hidden');
    }
}

// Render sites table
async function renderSites(sites) {
    const tbody = document.getElementById('sites-tbody');
    const loading = document.getElementById('sites-loading');
    const empty = document.getElementById('sites-empty');
    const table = document.getElementById('sites-table');
    
    loading.classList.add('hidden');
    
    if (sites.length === 0) {
        empty.classList.remove('hidden');
        table.classList.add('hidden');
        return;
    }
    
    table.classList.remove('hidden');
    empty.classList.add('hidden');
    
    tbody.innerHTML = '';
    
    // First render all sites with placeholder for stats
    sites.forEach(site => {
        const row = document.createElement('tr');
        row.className = 'hover:bg-gray-50';
        row.setAttribute('data-site-id', site.ID);
        
        let statusClass;
        switch (site.Status ? site.Status.toLowerCase() : '') {
            case 'active': 
                statusClass = 'bg-green-500'; 
                break;
            case 'pending': 
                statusClass = 'bg-yellow-500'; 
                break;
            default: 
                statusClass = 'bg-red-500';
        }
        
        row.innerHTML = `
            <td class="px-4 py-2">
                <a href="/waf/sites/${site.ID}" class="no-underline font-bold text-blue-600 hover:text-blue-800">
                    ${site.Name}
                </a>
            </td>
            <td class="px-4 py-2">${site.Domain}</td>
            <td class="px-4 py-2">
                <span class="px-2 py-1 text-xs font-medium rounded-full ${statusClass} text-white">
                    ${site.Status || 'Unknown'}
                </span>
            </td>
            <td class="px-4 py-2 requests-count">
                <span class="inline-block h-4 w-4 animate-spin rounded-full border-2 border-blue-600 border-t-transparent" role="status"></span>
            </td>
            <td class="px-4 py-2 attacks-count">
                <span class="inline-block h-4 w-4 animate-spin rounded-full border-2 border-blue-600 border-t-transparent" role="status"></span>
            </td>
            <td class="px-4 py-2">
                <div class="inline-flex rounded-md shadow-sm">
                    <a href="/waf/sites/${site.ID}" class="px-2 py-1 text-sm border border-blue-600 text-blue-600 hover:bg-blue-600 hover:text-white rounded-l-md" title="View">
                        <i class="bi bi-eye"></i>
                    </a>
                    <a href="/waf/sites/${site.ID}/edit" class="px-2 py-1 text-sm border-t border-b border-gray-500 text-gray-700 hover:bg-gray-500 hover:text-white" title="Edit">
                        <i class="bi bi-pencil"></i>
                    </a>
                    <button type="button" class="px-2 py-1 text-sm border border-red-600 text-red-600 hover:bg-red-600 hover:text-white rounded-r-md delete-site" 
                        data-id="${site.ID}" data-name="${site.Name}" title="Delete">
                        <i class="bi bi-trash"></i>
                    </button>
                </div>
            </td>
        `;
        
        tbody.appendChild(row);
    });
    
    // Then fetch stats for each site
    for (const site of sites) {
        try {
            const response = await api.get(`/sites/${site.ID}/logs`, {
                params: {
                    page: 1,
                    page_size: 1
                }
            });
            
            const row = tbody.querySelector(`tr[data-site-id="${site.ID}"]`);
            if (!row) continue;
            
            const requestsCell = row.querySelector('.requests-count');
            const attacksCell = row.querySelector('.attacks-count');
            
            if (response.data && response.data.success && response.data.stats) {
                // Use 24h stats for the list view
                const requests = response.data.stats.requests_24h || 0;
                const attacks = response.data.stats.attacks_24h || 0;
                
                // Update cells with real data
                if (requestsCell) requestsCell.textContent = requests;
                if (attacksCell) attacksCell.textContent = attacks;
            } else {
                // Fallback to site's stored counts if API doesn't return stats
                if (requestsCell) requestsCell.textContent = site.RequestCount || '0';
                if (attacksCell) attacksCell.textContent = site.BlockedCount || '0';
            }
        } catch (error) {
            console.error(`Error fetching stats for site ${site.ID}:`, error);
            
            // Find the row and update with fallback values on error
            const row = tbody.querySelector(`tr[data-site-id="${site.ID}"]`);
            if (row) {
                const requestsCell = row.querySelector('.requests-count');
                const attacksCell = row.querySelector('.attacks-count');
                
                if (requestsCell) requestsCell.textContent = site.RequestCount || '0';
                if (attacksCell) attacksCell.textContent = site.BlockedCount || '0';
            }
        }
    }
}

// Delete a site
async function deleteSite(siteId) {
    try {
        await api.delete(`/sites/${siteId}`);
        
        // Close modal
        document.getElementById('deleteModal').classList.add('hidden');
        
        // Show success message
        showToast('Site deleted successfully', 'success');
        
        // Reload sites
        loadSites();
    } catch (error) {
        console.error('Error deleting site:', error);
        showToast('Failed to delete site', 'danger');
    }
}
</script>