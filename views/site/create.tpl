<div class="row mb-4">
    <div class="col">
        <h1>Add New Site</h1>
    </div>
</div>

<div class="row">
    <div class="col-md-8 mx-auto">
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">Site Information</h5>
            </div>
            <div class="card-body">
                <form id="create-site-form">
                    <div class="mb-3">
                        <label for="site-name" class="form-label">Site Name</label>
                        <input type="text" class="form-control" id="site-name" required>
                        <div class="form-text">A friendly name to identify your site</div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="site-domain" class="form-label">Domain</label>
                        <input type="text" class="form-control" id="site-domain" required>
                        <div class="form-text">The domain that visitors will use to access your site (e.g. example.com)</div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="site-target" class="form-label">Target URL</label>
                        <input type="text" class="form-control" id="site-target" required>
                        <div class="form-text">The backend server URL where traffic will be forwarded (e.g. http://backend-server:8080)</div>
                    </div>
                    
                    <div class="alert alert-danger d-none" id="create-site-error"></div>
                    
                    <div class="d-flex justify-content-between">
                        <a href="/waf/sites" class="btn btn-secondary">Cancel</a>
                        <button type="submit" class="btn btn-primary">Create Site</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const createSiteForm = document.getElementById('create-site-form');
    const errorElement = document.getElementById('create-site-error');
    
    createSiteForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const name = document.getElementById('site-name').value;
        const domain = document.getElementById('site-domain').value;
        const targetURL = document.getElementById('site-target').value;
        
        // Basic validation
        if (!name || !domain || !targetURL) {
            errorElement.textContent = 'All fields are required';
            errorElement.classList.remove('d-none');
            return;
        }
        
        try {
            const response = await api.post('/sites', {
                name: name,
                domain: domain,
                target_url: targetURL
            });
            
            showToast('Site created successfully!', 'success');
            
            // Redirect to site details page
            setTimeout(() => {
                window.location.href = `/waf/sites/${response.data.ID}`;
            }, 1000);
        } catch (error) {
            console.error('Error creating site:', error);
            
            let errorMessage = 'Failed to create site';
            if (error.response && error.response.data && error.response.data.error) {
                errorMessage = error.response.data.error;
            }
            
            errorElement.textContent = errorMessage;
            errorElement.classList.remove('d-none');
        }
    });
});
</script>