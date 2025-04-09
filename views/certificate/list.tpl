<div class="flex flex-wrap mb-4">
    <div class="w-full md:w-2/3">
        <h1 class="text-2xl font-bold">SSL Certificates</h1>
        <p class="text-xl text-gray-600">Manage SSL/TLS certificates for your sites</p>
    </div>
    <div class="w-full md:w-1/3 text-left md:text-right">
        <a href="/waf/certificates/upload" class="px-3 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 inline-flex items-center">
            <i class="bi bi-plus-circle mr-1"></i> Upload New Certificate
        </a>
    </div>
</div>

<div class="flex flex-wrap">
    <div class="w-full">
        <div class="bg-white rounded-lg shadow-md">
            <div class="px-4 py-3 border-b border-gray-200">
                <h5 class="text-lg font-semibold mb-0">Your Certificates</h5>
            </div>
            <div class="p-0">
                <div class="overflow-x-auto">
                    <table class="min-w-full table-auto mb-0 [&>tbody>tr:hover]:bg-gray-100">
                        <thead>
                            <tr class="bg-gray-50 border-b border-gray-200">
                                <th class="px-4 py-2 text-left">Name</th>
                                <th class="px-4 py-2 text-left">Domain</th>
                                <th class="px-4 py-2 text-left">Issuer</th>
                                <th class="px-4 py-2 text-left">Expiry Date</th>
                                <th class="px-4 py-2 text-left">Status</th>
                                <th class="px-4 py-2 text-left">Actions</th>
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
<div id="deleteModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 flex">
    <div class="relative p-4 w-full max-w-md mx-auto md:h-auto flex items-center">
        <div class="bg-white rounded-lg shadow-xl w-full">
            <div class="px-4 py-3 border-b border-gray-200 flex justify-between items-center">
                <h5 class="text-lg font-semibold">Delete Certificate</h5>
                <button type="button" class="text-gray-500 hover:text-gray-700 focus:outline-none" data-bs-dismiss="modal">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>
            <div class="p-4">
                <p>Are you sure you want to delete this certificate?</p>
                <p class="text-red-600">This action cannot be undone. Sites using this certificate will lose HTTPS functionality.</p>
                <div id="delete-error" class="p-4 mb-4 text-red-700 bg-red-100 border border-red-200 rounded hidden"></div>
            </div>
            <div class="px-4 py-3 border-t border-gray-200 flex justify-end space-x-3">
                <button type="button" class="px-3 py-2 bg-gray-500 text-white rounded hover:bg-gray-600" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="px-3 py-2 bg-red-600 text-white rounded hover:bg-red-700" id="confirm-delete">Delete</button>
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
                            <p class="mb-0">If you want to enable HTTPS, <a href="/waf/certificates/upload" class="text-blue-600 hover:text-blue-800">upload a certificate</a>.</p>
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
                
                let statusClass = 'green';
                let statusText = 'Valid';
                
                if (daysUntilExpiry <= 0) {
                    statusClass = 'red';
                    statusText = 'Expired';
                } else if (daysUntilExpiry <= 30) {
                    statusClass = 'yellow';
                    statusText = `Expires in ${daysUntilExpiry} days`;
                } else {
                    statusText = `Valid for ${daysUntilExpiry} days`;
                }
                
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td class="px-4 py-2 border-b border-gray-200">${cert.Name}</td>
                    <td class="px-4 py-2 border-b border-gray-200">${cert.Domain}</td>
                    <td class="px-4 py-2 border-b border-gray-200">${cert.IssuedBy || 'Unknown'}</td>
                    <td class="px-4 py-2 border-b border-gray-200">${expiryDate.toLocaleDateString()}</td>
                    <td class="px-4 py-2 border-b border-gray-200"><span class="inline-block px-2 py-1 text-xs font-semibold rounded-full bg-${statusClass}-500 text-white">${statusText}</span></td>
                    <td class="px-4 py-2 border-b border-gray-200">
                        <div class="inline-flex">
                            <button class="px-2 py-1 border border-red-600 text-red-600 rounded hover:bg-red-600 hover:text-white" data-cert-id="${cert.ID}" data-cert-name="${cert.Name}" onclick="showDeleteModal(this)">
                                <i class="bi bi-trash"></i>
                            </button>
                        </div>
                    </td>
                `;
                tbody.appendChild(tr);
            });
            
        } catch (error) {
            console.error('Error loading certificates:', error);
            const tbody = document.getElementById('certificate-list');
            tbody.innerHTML = `
                <tr>
                    <td colspan="6" class="text-center py-4 text-red-600">
                        Failed to load certificates. Please try again.
                    </td>
                </tr>
            `;
        }
    }
    
    // Add this global function for showing the modal
    window.showDeleteModal = function(button) {
        const certId = button.getAttribute('data-cert-id');
        const certName = button.getAttribute('data-cert-name');
        document.getElementById('confirm-delete').setAttribute('data-cert-id', certId);
        document.querySelector('#deleteModal p:first-child').textContent = 
            `Are you sure you want to delete certificate "${certName}"?`;
            
        // Show the modal
        document.getElementById('deleteModal').classList.remove('hidden');
    }
    
    // Modal close button
    document.querySelector('#deleteModal button[data-bs-dismiss="modal"]').addEventListener('click', function() {
        document.getElementById('deleteModal').classList.add('hidden');
    });
    
    // Delete certificate
    document.getElementById('confirm-delete').addEventListener('click', async function() {
        const certId = this.getAttribute('data-cert-id');
        const errorElement = document.getElementById('delete-error');
        errorElement.classList.add('hidden');
        
        try {
            await api.delete(`/certificates/${certId}`);
            
            // Hide the modal
            document.getElementById('deleteModal').classList.add('hidden');
            
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
            errorElement.classList.remove('hidden');
        }
    });
});
</script>