<div class="row justify-content-center mt-5">
    <div class="col-md-8 text-center">
        <div class="card shadow-lg border-0">
            <div class="card-body p-5">
                <h1 class="display-1 fw-bold text-danger">{{.ErrorCode}}</h1>
                <h2 class="mb-4">{{.ErrorMessage}}</h2>
                
                {{if eq .ErrorCode 404}}
                <p class="mb-4">The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.</p>
                {{else if eq .ErrorCode 500}}
                <p class="mb-4">Our servers are experiencing issues. Please try again later or contact support if the problem persists.</p>
                {{else if eq .ErrorCode 401}}
                <p class="mb-4">You must log in to access this resource.</p>
                {{else if eq .ErrorCode 403}}
                <p class="mb-4">You don't have permission to access this resource.</p>
                {{end}}
                
                <div class="mt-5">
                    <a href="/" class="btn btn-primary me-3">
                        <i class="bi bi-house-door"></i> Go Home
                    </a>
                    <a href="javascript:history.back()" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left"></i> Go Back
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>