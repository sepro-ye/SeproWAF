<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{.Title}} - SeproWAF</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="/static/css/main.css">
    {{.CSS}}
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="/">
                <i class="bi bi-shield-lock"></i> SeproWAF
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <!-- Always visible navigation items -->
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="/">Home</a>
                    </li>
                    
                    <!-- Navigation items for authenticated users -->
                    <li class="nav-item auth-required d-none">
                        <a class="nav-link" href="/dashboard">Dashboard</a>
                    </li>
                    <li class="nav-item auth-required d-none">
                        <a class="nav-link" href="/waf/sites">Protected Sites</a>
                    </li>
                    <li class="nav-item auth-required d-none">
                        <a class="nav-link" href="/waf/logs">Logs</a>
                    </li>
                    <li class="nav-item auth-required d-none">
                        <a class="nav-link" href="/waf/rules">Rules</a>
                    </li>
                    <li class="nav-item auth-required d-none">
                        <a class="nav-link" href="/waf/certificates">
                            <i class="bi bi-shield-lock"></i> Certificates
                        </a>
                    </li>
                    
                    <!-- Admin only items -->
                    <li class="nav-item admin-only d-none">
                        <a class="nav-link" href="/admin/users">Users</a>
                    </li>
                </ul>
                
                <!-- User menu for authenticated users -->
                <ul class="navbar-nav auth-required d-none">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                            <i class="bi bi-person-circle"></i> <span class="username">{{.Username}}</span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><a class="dropdown-item" href="/user/profile">Profile</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="#" id="logout-btn">Logout</a></li>
                        </ul>
                    </li>
                </ul>
                
                <!-- Login/Register links for non-authenticated users -->
                <ul class="navbar-nav auth-not-required">
                    <li class="nav-item">
                        <a class="nav-link" href="/auth/login">Login</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/auth/register">Register</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        {{.LayoutContent}}
    </div>

    <footer class="bg-light py-4 mt-5">
        <div class="container text-center">
            <p class="mb-0">&copy; 2025 SeproWAF - Web Application Firewall as a Service</p>
        </div>
    </footer>

    <div id="toast-container" class="toast-container position-fixed top-0 end-0 p-3"></div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <script src="/static/js/main.js"></script>
    {{.JS}}
    <script>
    // Check authentication status on page load
    document.addEventListener('DOMContentLoaded', function() {
        // Update navigation based on auth status
        updateNavigation();
    });

    function updateNavigation() {
        const isAuthenticated = isLoggedIn();
        const userData = getUserData();
        
        // Get nav elements
        const authRequiredItems = document.querySelectorAll('.auth-required');
        const authNotRequiredItems = document.querySelectorAll('.auth-not-required');
        const adminItems = document.querySelectorAll('.admin-only');
        
        if (isAuthenticated && userData) {
            // Show authenticated user elements
            authRequiredItems.forEach(item => item.classList.remove('d-none'));
            
            // Hide non-authenticated elements
            authNotRequiredItems.forEach(item => item.classList.add('d-none'));
            
            // Set username
            const usernameEls = document.querySelectorAll('.username');
            usernameEls.forEach(el => {
                if (el) el.textContent = userData.username;
            });
            
            // Show admin items if admin
            if (userData.role === 'admin') {
                adminItems.forEach(item => item.classList.remove('d-none'));
            } else {
                adminItems.forEach(item => item.classList.add('d-none'));
            }
        } else {
            // Hide authenticated user elements
            authRequiredItems.forEach(item => item.classList.add('d-none'));
            
            // Show non-authenticated elements
            authNotRequiredItems.forEach(item => item.classList.remove('d-none'));
            
            // Hide admin items
            adminItems.forEach(item => item.classList.add('d-none'));
        }
    }
    </script>
</body>
</html>