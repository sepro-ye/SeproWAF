<div class="row mb-4">
    <div class="col">
        <h1>Edit Site - {{.Site.Name}}</h1>
    </div>
</div>

<div class="row">
    <div class="col-md-8 mx-auto">
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">Site Information</h5>
            </div>
            <div class="card-body">
                <form id="edit-site-form">
                    <div class="mb-3">
                        <label for="site-name" class="form-label">Site Name</label>
                        <input type="text" class="form-control" id="site-name" value="{{.Site.Name}}" required>
                        <div class="form-text">A friendly name to identify your site</div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="site-domain" class="form-label">Domain</label>
                        <input type="text" class="form-control" id="site-domain" value="{{.Site.Domain}}" required>
                        <div class="form-text">The domain that visitors will use to access your site (e.g. example.com)</div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="site-target" class="form-label">Target URL</label>
                        <input type="text" class="form-control" id="site-target" value="{{.Site.TargetURL}}" required>
                        <div class="form-text">The backend server URL where traffic will be forwarded (e.g. http://backend-server:8080)</div>
                    </div>

                    {{if .IsAdmin}}
                    <div class="mb-3">
                        <label for="site-status" class="form-label">Status</label>
                        <select class="form-select" id="site-status">
                            <option value="pending" {{if eq .Site.Status "pending"}}selected{{end}}>Pending</option>
                            <option value="active" {{if eq .Site.Status "active"}}selected{{end}}>Active</option>
                            <option value="inactive" {{if eq .Site.Status "inactive"}}selected{{end}}>Inactive</option>
                        </select>
                        <div class="form-text">Site operational status</div>
                    </div>
                    {{end}}
                    
                    <div class="mb-3">
                        <label for="site-certificate" class="form-label">SSL Certificate (optional)</label>
                        <select class="form-select" id="site-certificate">
                            <option value="">None (HTTP only)</option>
                            <!-- Certificates will be loaded dynamically with JavaScript -->
                        </select>
                        <div class="form-text">
                            Select an SSL certificate to enable HTTPS for this site or 
                            <a href="/waf/certificates/upload" target="_blank">upload a new certificate</a>
                        </div>
                    </div>
                    
                    <div class="alert alert-danger d-none" id="edit-site-error"></div>
                    <div class="alert alert-success d-none" id="edit-site-success">Site updated successfully!</div>
                    
                    <div class="d-flex justify-content-between">
                        <a href="/waf/sites/{{.Site.ID}}" class="btn btn-secondary">Cancel</a>
                        <button type="submit" class="btn btn-primary">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const editSiteForm = document.getElementById('edit-site-form');
    const errorElement = document.getElementById('edit-site-error');
    const successElement = document.getElementById('edit-site-success');
    const siteId = {{.Site.ID}};
    
    async function loadCertificates() {
        try {
            const response = await api.get('/certificates');
            const certificates = response.data;
            const selectElement = document.getElementById('site-certificate');
            
            if (certificates && certificates.length > 0) {
                certificates.forEach(cert => {
                    const option = document.createElement('option');
                    option.value = cert.ID;
                    option.textContent = `${cert.Name} (${cert.Domain}, expires ${new Date(cert.NotAfter).toLocaleDateString()})`;
                    
                    // Check if this is the currently selected certificate
                    if ({{if .Site.CertificateID}}cert.ID === {{.Site.CertificateID}}{{else}}false{{end}}) {
                        option.selected = true;
                    }
                    
                    selectElement.appendChild(option);
                });
            } else {
                const option = document.createElement('option');
                option.value = "";
                option.textContent = "No certificates available";
                option.disabled = true;
                selectElement.appendChild(option);
            }
        } catch (error) {
            console.error('Error loading certificates:', error);
            const selectElement = document.getElementById('site-certificate');
            const option = document.createElement('option');
            option.value = "";
            option.textContent = "Failed to load certificates";
            option.disabled = true;
            selectElement.appendChild(option);
        }
    }

    loadCertificates();
    
    editSiteForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const name = document.getElementById('site-name').value;
        const domain = document.getElementById('site-domain').value;
        const targetURL = document.getElementById('site-target').value;
        
        // Get status if admin
        let status;
        const statusElement = document.getElementById('site-status');
        if (statusElement) {
            status = statusElement.value;
        }
        
        const certificateId = document.getElementById('site-certificate').value;
        
        // Basic validation
        if (!name || !domain || !targetURL) {
            errorElement.textContent = 'All fields are required';
            errorElement.classList.remove('d-none');
            successElement.classList.add('d-none');
            return;
        }
        
        try {
            // Prepare data object
            const data = {
                name: name,
                domain: domain,
                target_url: targetURL
            };
            
            // Add status if admin
            if (status) {
                data.status = status;
            }
            
            // Add certificate ID to the data object if selected
            if (certificateId) {
                data.certificate_id = parseInt(certificateId);
            } else {
                data.certificate_id = null;
            }
            
            await api.put(`/sites/${siteId}`, data);
            
            // Show success message
            errorElement.classList.add('d-none');
            successElement.classList.remove('d-none');
            
            // Redirect after short delay
            setTimeout(() => {
                window.location.href = `/waf/sites/${siteId}`;
            }, 1000);
        } catch (error) {
            console.error('Error updating site:', error);
            
            let errorMessage = 'Failed to update site';
            if (error.response && error.response.data && error.response.data.error) {
                errorMessage = error.response.data.error;
            }
            
            errorElement.textContent = errorMessage;
            errorElement.classList.remove('d-none');
            successElement.classList.add('d-none');
        }
    });
});
</script>