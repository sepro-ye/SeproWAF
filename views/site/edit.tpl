<div class="flex flex-wrap mb-5">
    <div class="w-full">
        <h1>Edit Site - {{.Site.Name}}</h1>
    </div>
</div>

<div class="flex flex-wrap">
    <div class="w-full md:w-2/3 mx-auto">
        <div class="bg-white rounded-lg shadow">
            <div class="px-4 py-3 border-b">
                <h5 class="text-lg font-medium mb-0">Site Information</h5>
            </div>
            <div class="p-4">
                <form id="edit-site-form">
                    <div class="mb-5">
                        <label for="site-name" class="block text-sm font-medium text-gray-700 mb-1">Site Name</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                                </svg>
                            </div>
                            <input type="text" id="site-name" name="site-name" value="{{.Site.Name}}" 
                                class="pl-10 pr-3 py-2 mt-1 block w-full rounded-md border-gray-300 bg-gray-50 
                                text-gray-900 shadow-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500 
                                focus:ring-opacity-30 focus:outline-none transition duration-200 ease-in-out
                                hover:bg-gray-100" required>
                        </div>
                        <div class="mt-1 text-sm text-gray-500">A friendly name to identify your site</div>
                    </div>
                    
                    <div class="mb-5">
                        <label for="site-domain" class="block text-sm font-medium text-gray-700 mb-1">Domain</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9" />
                                </svg>
                            </div>
                            <input type="text" id="site-domain" name="site-domain" value="{{.Site.Domain}}" 
                                class="pl-10 pr-3 py-2 mt-1 block w-full rounded-md border-gray-300 bg-gray-50 
                                text-gray-900 shadow-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500 
                                focus:ring-opacity-30 focus:outline-none transition duration-200 ease-in-out
                                hover:bg-gray-100" required>
                        </div>
                        <div class="mt-1 text-sm text-gray-500">The domain that visitors will use to access your site (e.g. example.com)</div>
                    </div>
                    
                    <div class="mb-5">
                        <label for="site-target" class="block text-sm font-medium text-gray-700 mb-1">Target URL</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" />
                                </svg>
                            </div>
                            <input type="text" id="site-target" name="site-target" value="{{.Site.TargetURL}}" 
                                class="pl-10 pr-3 py-2 mt-1 block w-full rounded-md border-gray-300 bg-gray-50 
                                text-gray-900 shadow-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500 
                                focus:ring-opacity-30 focus:outline-none transition duration-200 ease-in-out
                                hover:bg-gray-100" required>
                        </div>
                        <div class="mt-1 text-sm text-gray-500">The backend server URL where traffic will be forwarded (e.g. http://backend-server:8080)</div>
                    </div>

                    {{if .IsAdmin}}
                    <div class="mb-5">
                        <label for="site-status" class="block text-sm font-medium text-gray-700 mb-1">Status</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                            </div>
                            <select id="site-status" name="site-status"
                                class="pl-10 pr-10 py-2 mt-1 block w-full rounded-md border-gray-300 bg-gray-50 
                                text-gray-900 shadow-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500 
                                focus:ring-opacity-30 focus:outline-none transition duration-200 ease-in-out
                                hover:bg-gray-100 appearance-none">
                                <option value="pending" {{if eq .Site.Status "pending"}}selected{{end}}>Pending</option>
                                <option value="active" {{if eq .Site.Status "active"}}selected{{end}}>Active</option>
                                <option value="inactive" {{if eq .Site.Status "inactive"}}selected{{end}}>Inactive</option>
                            </select>
                            <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                </svg>
                            </div>
                        </div>
                        <div class="mt-1 text-sm text-gray-500">Site operational status</div>
                    </div>
                    {{end}}
                    
                    <div class="mb-5">
                        <label for="site-certificate" class="block text-sm font-medium text-gray-700 mb-1">SSL Certificate (optional)</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                                </svg>
                            </div>
                            <select id="site-certificate" name="site-certificate"
                                class="pl-10 pr-10 py-2 mt-1 block w-full rounded-md border-gray-300 bg-gray-50 
                                text-gray-900 shadow-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500 
                                focus:ring-opacity-30 focus:outline-none transition duration-200 ease-in-out
                                hover:bg-gray-100 appearance-none">
                                <option value="">None (HTTP only)</option>
                                <!-- Certificates will be loaded dynamically with JavaScript -->
                            </select>
                            <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                </svg>
                            </div>
                        </div>
                        <div class="mt-1 text-sm text-gray-500">
                            Select an SSL certificate to enable HTTPS for this site or 
                            <a href="/waf/certificates/upload" target="_blank" class="text-blue-600 hover:text-blue-800 transition duration-200 ease-in-out">upload a new certificate</a>
                        </div>
                    </div>
                    
                    <div class="p-4 rounded-md bg-red-100 text-red-700 border border-red-200 hidden" id="edit-site-error"></div>
                    <div class="p-4 rounded-md bg-green-100 text-green-700 border border-green-200 hidden" id="edit-site-success">Site updated successfully!</div>
                    
                    <div class="flex justify-between mt-8">
                        <a href="/waf/sites/{{.Site.ID}}" class="px-6 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded-md transition duration-200 ease-in-out">Cancel</a>
                        <button type="submit" class="px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md shadow transition duration-200 ease-in-out flex items-center">
                            <svg class="h-5 w-5 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4" />
                            </svg>
                            Save Changes
                        </button>
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
            errorElement.classList.remove('hidden');
            successElement.classList.add('hidden');
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
            errorElement.classList.add('hidden');
            successElement.classList.remove('hidden');
            
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
            errorElement.classList.remove('hidden');
            successElement.classList.add('hidden');
        }
    });
});
</script>