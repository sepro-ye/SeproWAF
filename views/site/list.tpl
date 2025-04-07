<div class="row mb-4">
    <div class="col-md-6">
        <h1>Protected Sites</h1>
    </div>
    <div class="col-md-6 text-end">
        <a href="/waf/sites/new" class="btn btn-primary">
            <i class="bi bi-plus-circle"></i> Add New Site
        </a>
    </div>
</div>

<div class="row mb-4">
    <div class="col-md-12">
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">Your Protected Websites</h5>
            </div>
            <div class="card-body p-0">
                <div id="sites-loading" class="text-center py-4">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-2">Loading sites...</p>
                </div>
                <div id="sites-empty" class="text-center py-4 d-none">
                    <i class="bi bi-globe fs-1 text-muted"></i>
                    <p class="mt-2">You don't have any protected sites yet.</p>
                    <a href="/waf/sites/new" class="btn btn-primary">Add Your First Site</a>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover mb-0" id="sites-table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Domain</th>
                                <th>Status</th>
                                <th>Requests (24h)</th>
                                <th>Attacks Blocked (24h)</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="sites-tbody">
                            <!-- Sites will be loaded here via JavaScript -->
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
                <p>Are you sure you want to delete <strong id="delete-site-name"></strong>?</p>
                <p class="text-danger">This action cannot be undone.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger" id="confirm-delete">Delete</button>
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
    
    document.addEventListener('click', function(e) {
        if (e.target.closest('.delete-site')) {
            const btn = e.target.closest('.delete-site');
            const siteId = btn.dataset.id;
            const siteName = btn.dataset.name;
            
            // Set the site to delete
            siteToDelete = siteId;
            document.getElementById('delete-site-name').textContent = siteName;
            
            // Show modal
            const modal = new bootstrap.Modal(document.getElementById('deleteModal'));
            modal.show();
        }
    });
    
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
        document.getElementById('sites-loading').classList.add('d-none');
        document.getElementById('sites-empty').classList.remove('d-none');
    }
}

// Render sites table
function renderSites(sites) {
    const tbody = document.getElementById('sites-tbody');
    const loading = document.getElementById('sites-loading');
    const empty = document.getElementById('sites-empty');
    const table = document.getElementById('sites-table');
    
    loading.classList.add('d-none');
    
    if (sites.length === 0) {
        empty.classList.remove('d-none');
        table.classList.add('d-none');
        return;
    }
    
    table.classList.remove('d-none');
    empty.classList.add('d-none');
    
    tbody.innerHTML = '';
    
    sites.forEach(site => {
        const row = document.createElement('tr');
        
        const statusClass = site.status === 'active' ? 'success' : 
                          (site.status === 'pending' ? 'warning' : 'danger');
        
        row.innerHTML = `
            <td>
                <a href="/waf/sites/${site.ID}" class="text-decoration-none fw-bold">
                    ${site.Name}
                </a>
            </td>
            <td>${site.Domain}</td>
            <td><span class="badge bg-${statusClass}">${site.Status}</span></td>
            <td>${site.RequestCount || '0'}</td>
            <td>${site.BlockedCount || '0'}</td>
            <td>
                <div class="btn-group">
                    <a href="/waf/sites/${site.ID}" class="btn btn-sm btn-outline-primary" title="View">
                        <i class="bi bi-eye"></i>
                    </a>
                    <a href="/waf/sites/${site.ID}/edit" class="btn btn-sm btn-outline-secondary" title="Edit">
                        <i class="bi bi-pencil"></i>
                    </a>
                    <button type="button" class="btn btn-sm btn-outline-danger delete-site" 
                        data-id="${site.ID}" data-name="${site.Name}" title="Delete">
                        <i class="bi bi-trash"></i>
                    </button>
                </div>
            </td>
        `;
        
        tbody.appendChild(row);
    });
}

// Delete a site
async function deleteSite(siteId) {
    try {
        await api.delete(`/sites/${siteId}`);
        
        // Close modal
        const modal = bootstrap.Modal.getInstance(document.getElementById('deleteModal'));
        modal.hide();
        
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