<div class="row mb-4">
    <div class="col-md-8">
        <h1>SSL Certificates</h1>
        <p class="lead">Manage SSL/TLS certificates for your sites</p>
    </div>
    <div class="col-md-4 text-md-end">
        <a href="/waf/certificates/upload" class="btn btn-primary">
            <i class="bi bi-plus-circle"></i> Upload New Certificate
        </a>
    </div>
</div>

<div class="row">
    <div class="col-md-12">
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">Your Certificates</h5>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Domain</th>
                                <th>Issuer</th>
                                <th>Expiry Date</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="certificate-list">
                            <tr>
                                <td colspan="6" class="text-center py-4">Loading certificates...</td>
                            </tr>
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
                <h5 class="modal-title">Delete Certificate</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete this certificate?</p>
                <p class="text-danger">This action cannot be undone. Sites using this certificate will lose HTTPS functionality.</p>
                <div id="delete-error" class="alert alert-danger d-none"></div>
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
    loadCertificates();
    
    // Function to load certificates
    async function loadCertificates() {
        try {
            const response = await api.get('/certificates');
            const certificates = response.data;
            const tbody = document.getElementById('certificate-list');
            
            if (certificates.length === 0) {
                tbody.innerHTML = `
                    <tr>
                        <td colspan="6" class="text-center py-4">
                            <p class="mb-0">No certificates found.</p>
                            <p class="mb-0">SSL certificates are optional - you can continue using HTTP without them.</p>
                            <p class="mb-0">If you want to enable HTTPS, <a href="/waf/certificates/upload">upload a certificate</a>.</p>
                        </td>
                    </tr>
                `;
                return;
            }
            
            tbody.innerHTML = '';
            
            certificates.forEach(cert => {
                const expiryDate = new Date(cert.NotAfter);
                const now = new Date();
                const daysUntilExpiry = Math.ceil((expiryDate - now) / (1000 * 60 * 60 * 24));
                
                let statusClass = 'success';
                let statusText = 'Valid';
                
                if (daysUntilExpiry <= 0) {
                    statusClass = 'danger';
                    statusText = 'Expired';
                } else if (daysUntilExpiry <= 30) {
                    statusClass = 'warning';
                    statusText = `Expires in ${daysUntilExpiry} days`;
                } else {
                    statusText = `Valid for ${daysUntilExpiry} days`;
                }
                
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${cert.Name}</td>
                    <td>${cert.Domain}</td>
                    <td>${cert.IssuedBy || 'Unknown'}</td>
                    <td>${expiryDate.toLocaleDateString()}</td>
                    <td><span class="badge bg-${statusClass}">${statusText}</span></td>
                    <td>
                        <div class="btn-group btn-group-sm">
                            <button class="btn btn-outline-danger" data-cert-id="${cert.ID}" data-cert-name="${cert.Name}" data-bs-toggle="modal" data-bs-target="#deleteModal">
                                <i class="bi bi-trash"></i>
                            </button>
                        </div>
                    </td>
                `;
                tbody.appendChild(tr);
            });
            
            // Set up delete button event handlers
            document.querySelectorAll('[data-cert-id]').forEach(button => {
                button.addEventListener('click', function() {
                    const certId = this.getAttribute('data-cert-id');
                    const certName = this.getAttribute('data-cert-name');
                    document.getElementById('confirm-delete').setAttribute('data-cert-id', certId);
                    document.querySelector('.modal-body p:first-child').textContent = 
                        `Are you sure you want to delete certificate "${certName}"?`;
                });
            });
            
        } catch (error) {
            console.error('Error loading certificates:', error);
            const tbody = document.getElementById('certificate-list');
            tbody.innerHTML = `
                <tr>
                    <td colspan="6" class="text-center py-4 text-danger">
                        Failed to load certificates. Please try again.
                    </td>
                </tr>
            `;
        }
    }
    
    // Delete certificate
    document.getElementById('confirm-delete').addEventListener('click', async function() {
        const certId = this.getAttribute('data-cert-id');
        const errorElement = document.getElementById('delete-error');
        errorElement.classList.add('d-none');
        
        try {
            await api.delete(`/certificates/${certId}`);
            
            // Hide the modal
            const modal = bootstrap.Modal.getInstance(document.getElementById('deleteModal'));
            modal.hide();
            
            // Show success message and reload the list
            showToast('Certificate deleted successfully', 'success');
            loadCertificates();
        } catch (error) {
            console.error('Error deleting certificate:', error);
            let errorMessage = 'Failed to delete certificate';
            
            if (error.response && error.response.data && error.response.data.error) {
                errorMessage = error.response.data.error;
            }
            
            errorElement.textContent = errorMessage;
            errorElement.classList.remove('d-none');
        }
    });
});
</script>