<div class="row mb-4">
    <div class="col">
        <h1>Upload SSL/TLS Certificate</h1>
        <p class="lead">Upload your certificate to enable HTTPS for your sites</p>
    </div>
</div>

<div class="row">
    <div class="col-md-8 mx-auto">
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">Certificate Information</h5>
            </div>
            <div class="card-body">
                <form id="upload-certificate-form">
                    <div class="mb-3">
                        <label for="certificate-name" class="form-label">Certificate Name</label>
                        <input type="text" class="form-control" id="certificate-name" required>
                        <div class="form-text">A friendly name to identify this certificate</div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="certificate-content" class="form-label">SSL Certificate (PEM Format)</label>
                        <textarea class="form-control font-monospace" id="certificate-content" rows="8" required></textarea>
                        <div class="form-text">Paste your certificate in PEM format (including BEGIN/END CERTIFICATE headers)</div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="private-key" class="form-label">Private Key (PEM Format)</label>
                        <textarea class="form-control font-monospace" id="private-key" rows="8" required></textarea>
                        <div class="form-text">Paste your private key in PEM format (including BEGIN/END PRIVATE KEY headers)</div>
                    </div>
                    
                    <div class="alert alert-danger d-none" id="upload-error"></div>
                    
                    <div class="d-flex justify-content-between">
                        <a href="/waf/certificates" class="btn btn-secondary">Cancel</a>
                        <button type="submit" class="btn btn-primary">Upload Certificate</button>
                    </div>
                </form>
            </div>
        </div>
        
        <div class="card mt-4">
            <div class="card-header bg-light">
                <h5 class="card-title mb-0">Help & Information</h5>
            </div>
            <div class="card-body">
                <h6>Certificate Requirements</h6>
                <ul>
                    <li>Certificate must be in PEM format (base64 encoded)</li>
                    <li>Certificate must include the full chain (if applicable)</li>
                    <li>Private key must not be password protected</li>
                </ul>
                
                <h6>How to Get SSL Certificates</h6>
                <ul>
                    <li><strong>Let's Encrypt:</strong> Free certificates valid for 90 days</li>
                    <li><strong>Commercial CA:</strong> Paid certificates from providers like DigiCert, Comodo, etc.</li>
                    <li><strong>Self-signed:</strong> Generate certificates for testing (not recommended for production)</li>
                </ul>
                
                <h6>Example Certificate Format</h6>
<pre class="bg-light p-2"><code>-----BEGIN CERTIFICATE-----
MIIDTTCCAjWgAwIBAgIJANVz6kIyTGOEMA0GCSqGSIb3DQEBCwUAMD0xCzAJBgNV
BAYTAlVTMQswCQYDVQQIDAJDQTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQ
...
-----END CERTIFICATE-----</code></pre>

                <h6>Example Private Key Format</h6>
<pre class="bg-light p-2"><code>-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDBj08sp5++4anG
cmQxJjAkBgNVBAYTAlVTMQwwCgYDVQQIEwNXQTERMA8GA1UEBxMIS2lya2xhbmQx
...
-----END PRIVATE KEY-----</code></pre>
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
            errorElement.classList.remove('d-none');
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
            errorElement.classList.remove('d-none');
        }
    });
    
    // Helper function to validate PEM format (basic check)
    function isPEMFormat(text) {
        return text.includes('-----BEGIN') && text.includes('-----END');
    }
});
</script>