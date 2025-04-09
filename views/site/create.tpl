<div class="flex flex-wrap mb-4">
    <div class="w-full">
        <h1>Add New Site</h1>
    </div>
</div>

<div class="flex flex-wrap">
    <div class="w-full md:w-2/3 mx-auto">
        <div class="bg-white rounded-lg shadow">
            <div class="px-4 py-3 border-b">
                <h5 class="text-lg font-medium mb-0">Site Information</h5>
            </div>
            <div class="p-4">
                <form id="create-site-form">
                    <div class="mb-5">
                        <label for="site-name" class="block text-sm font-medium text-gray-700 mb-1">Site Name</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                                </svg>
                            </div>
                            <input type="text" id="site-name" name="site-name" placeholder="My Awesome Website" 
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
                            <input type="text" id="site-domain" name="site-domain" placeholder="example.com" 
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
                            <input type="text" id="site-target" name="site-target" placeholder="http://backend-server:8080" 
                                class="pl-10 pr-3 py-2 mt-1 block w-full rounded-md border-gray-300 bg-gray-50 
                                text-gray-900 shadow-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500 
                                focus:ring-opacity-30 focus:outline-none transition duration-200 ease-in-out
                                hover:bg-gray-100" required>
                        </div>
                        <div class="mt-1 text-sm text-gray-500">The backend server URL where traffic will be forwarded (e.g. http://backend-server:8080)</div>
                    </div>
                    
                    <div class="p-4 rounded-md bg-red-100 text-red-700 border border-red-200 hidden" id="create-site-error"></div>
                    
                    <div class="flex justify-between mt-8">
                        <a href="/waf/sites" class="px-6 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded-md transition duration-200 ease-in-out">Cancel</a>
                        <button type="submit" class="px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md shadow transition duration-200 ease-in-out flex items-center">
                            <svg class="h-5 w-5 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                            </svg>
                            Create Site
                        </button>
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
            errorElement.classList.remove('hidden');
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
            errorElement.classList.remove('hidden');
        }
    });
});
</script>