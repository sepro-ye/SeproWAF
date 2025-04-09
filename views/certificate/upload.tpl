<div class="flex flex-wrap mb-4">
    <div class="w-full">
        <h1 class="text-2xl font-bold">Upload SSL/TLS Certificate</h1>
        <p class="text-xl text-gray-600">Upload your certificate to enable HTTPS for your sites</p>
    </div>
</div>

<div class="flex flex-wrap">
    <div class="w-full md:w-2/3 mx-auto">
        <div class="bg-white rounded-lg shadow-md">
            <div class="px-4 py-3 border-b border-gray-200">
                <h5 class="text-lg font-semibold mb-0">Certificate Information</h5>
            </div>
            <div class="p-4">
                <form id="upload-certificate-form">
                    <div class="mb-5">
                        <label for="certificate-name" class="block text-sm font-medium text-gray-700 mb-1">
                            Certificate Name <span class="text-red-500">*</span>
                        </label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
                                </svg>
                            </div>
                            <input type="text" id="certificate-name" name="certificate-name" placeholder="e.g. My Website Certificate" 
                                class="pl-10 pr-3 py-2 mt-1 block w-full rounded-md border-gray-300 bg-gray-50 
                                text-gray-900 shadow-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500 
                                focus:ring-opacity-30 focus:outline-none transition duration-200 ease-in-out
                                hover:bg-gray-100" required>
                        </div>
                        <div class="mt-1 text-sm text-gray-500">A friendly name to identify this certificate</div>
                    </div>
                    
                    <div class="mb-5">
                        <label for="certificate-content" class="block text-sm font-medium text-gray-700 mb-1">
                            SSL Certificate (PEM Format) <span class="text-red-500">*</span>
                        </label>
                        <div class="relative">
                            <div class="absolute top-2 left-0 pl-3 flex items-start pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                                </svg>
                            </div>
                            <textarea id="certificate-content" name="certificate-content" 
                                placeholder="-----BEGIN CERTIFICATE-----
MIIDTTCCAjWgAwIBAgIJANVz6kIyTGOEMA0GCSqGSIb3DQEBCwUAMD0xCzAJBgNV
...
-----END CERTIFICATE-----"
                                class="pl-10 pr-3 py-2 mt-1 block w-full rounded-md border-gray-300 bg-gray-50 
                                text-gray-900 shadow-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500 
                                focus:ring-opacity-30 focus:outline-none transition duration-200 ease-in-out
                                hover:bg-gray-100 font-mono text-sm" rows="8" required></textarea>
                        </div>
                        <div class="mt-1 text-sm text-gray-500">Paste your certificate in PEM format (including BEGIN/END CERTIFICATE headers)</div>
                    </div>
                    
                    <div class="mb-5">
                        <label for="private-key" class="block text-sm font-medium text-gray-700 mb-1">
                            Private Key (PEM Format) <span class="text-red-500">*</span>
                        </label>
                        <div class="relative">
                            <div class="absolute top-2 left-0 pl-3 flex items-start pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" />
                                </svg>
                            </div>
                            <textarea id="private-key" name="private-key"
                                placeholder="-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDBj08sp5++4anG
...
-----END PRIVATE KEY-----"
                                class="pl-10 pr-3 py-2 mt-1 block w-full rounded-md border-gray-300 bg-gray-50 
                                text-gray-900 shadow-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500 
                                focus:ring-opacity-30 focus:outline-none transition duration-200 ease-in-out
                                hover:bg-gray-100 font-mono text-sm" rows="8" required></textarea>
                        </div>
                        <div class="mt-1 text-sm text-gray-500">Paste your private key in PEM format (including BEGIN/END PRIVATE KEY headers)</div>
                    </div>
                    
                    <div class="p-4 mb-4 text-red-700 bg-red-100 border border-red-200 rounded hidden" id="upload-error"></div>
                    
                    <div class="flex justify-between mt-8">
                        <a href="/waf/certificates" class="px-6 py-2 bg-gray-500 text-white rounded hover:bg-gray-600 transition duration-200 ease-in-out flex items-center">
                            <svg class="h-5 w-5 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 17l-5-5m0 0l5-5m-5 5h12" />
                            </svg>
                            Cancel
                        </a>
                        <button type="submit" class="px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 shadow transition duration-200 ease-in-out flex items-center">
                            <svg class="h-5 w-5 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                            </svg>
                            Upload Certificate
                        </button>
                    </div>
                </form>
            </div>
        </div>
        
        <div class="bg-white rounded-lg shadow-md mt-4">
            <div class="px-4 py-3 border-b border-gray-200 bg-blue-50">
                <h5 class="text-lg font-semibold mb-0 flex items-center">
                    <svg class="h-5 w-5 mr-2 text-blue-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    Help & Information
                </h5>
            </div>
            <div class="p-4">
                <h6 class="font-semibold mb-2 flex items-center text-gray-700">
                    <svg class="h-4 w-4 mr-1 text-blue-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                    </svg>
                    Certificate Requirements
                </h6>
                <ul class="list-disc pl-5 mb-4 space-y-1 text-gray-700">
                    <li>Certificate must be in PEM format (base64 encoded)</li>
                    <li>Certificate must include the full chain (if applicable)</li>
                    <li>Private key must not be password protected</li>
                </ul>
                
                <h6 class="font-semibold mb-2 flex items-center text-gray-700">
                    <svg class="h-4 w-4 mr-1 text-blue-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    How to Get SSL Certificates
                </h6>
                <ul class="list-disc pl-5 mb-4 space-y-1 text-gray-700">
                    <li><span class="font-semibold">Let's Encrypt:</span> Free certificates valid for 90 days</li>
                    <li><span class="font-semibold">Commercial CA:</span> Paid certificates from providers like DigiCert, Comodo, etc.</li>
                    <li><span class="font-semibold">Self-signed:</span> Generate certificates for testing (not recommended for production)</li>
                </ul>
                
                <h6 class="font-semibold mb-2 flex items-center text-gray-700">
                    <svg class="h-4 w-4 mr-1 text-blue-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                    Example Certificate Format
                </h6>
                <pre class="bg-gray-50 p-3 rounded-md mb-4 font-mono text-sm overflow-x-auto border border-gray-200">-----BEGIN CERTIFICATE-----
MIIDTTCCAjWgAwIBAgIJANVz6kIyTGOEMA0GCSqGSIb3DQEBCwUAMD0xCzAJBgNV
BAYTAlVTMQswCQYDVQQIDAJDQTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQ
...
-----END CERTIFICATE-----</pre>

                <h6 class="font-semibold mb-2 flex items-center text-gray-700">
                    <svg class="h-4 w-4 mr-1 text-blue-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" />
                    </svg>
                    Example Private Key Format
                </h6>
                <pre class="bg-gray-50 p-3 rounded-md font-mono text-sm overflow-x-auto border border-gray-200">-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDBj08sp5++4anG
cmQxJjAkBgNVBAYTAlVTMQwwCgYDVQQIEwNXQTERMA8GA1UEBxMIS2lya2xhbmQx
...
-----END PRIVATE KEY-----</pre>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const uploadForm = document.getElementById('upload-certificate-form');
    const errorElement = document.getElementById('upload-error');
    
    uploadForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const name = document.getElementById('certificate-name').value;
        const certificate = document.getElementById('certificate-content').value;
        const privateKey = document.getElementById('private-key').value;
        
        // Basic validation
        if (!name || !certificate || !privateKey) {
            errorElement.textContent = 'All fields are required';
            errorElement.classList.remove('hidden');
            return;
        }
        
        // Validate PEM format
        if (!isPEMFormat(certificate)) {
            errorElement.textContent = 'Certificate must be in valid PEM format with BEGIN/END headers';
            errorElement.classList.remove('hidden');
            return;
        }
        
        if (!isPEMFormat(privateKey)) {
            errorElement.textContent = 'Private key must be in valid PEM format with BEGIN/END headers';
            errorElement.classList.remove('hidden');
            return;
        }
        
        try {
            await api.post('/certificates', {
                name: name,
                certificate: certificate,
                private_key: privateKey
            });
            
            showToast('Certificate uploaded successfully!', 'success');
            
            // Redirect to certificate list page
            setTimeout(() => {
                window.location.href = '/waf/certificates';
            }, 1000);
        } catch (error) {
            console.error('Error uploading certificate:', error);
            
            let errorMessage = 'Failed to upload certificate';
            if (error.response && error.response.data && error.response.data.error) {
                errorMessage = error.response.data.error;
            }
            
            errorElement.textContent = errorMessage;
            errorElement.classList.remove('hidden');
        }
    });
    
    // Helper function to validate PEM format (basic check)
    function isPEMFormat(text) {
        return text.includes('-----BEGIN') && text.includes('-----END');
    }
});
</script>

<style>
/* Custom focus for textareas */
textarea:focus {
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.3);
}
</style>