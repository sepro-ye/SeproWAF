<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{.Title}} - SeproWAF</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="/static/css/main.css">
    {{.CSS}}
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    maxWidth: {
                        '8xl': '88rem', // or whatever value you want
                    },
                    colors: {
                        primary: '#3b82f6',
                        secondary: '#10b981',
                        dark: '#1e293b'
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-gray-50 flex flex-col min-h-screen">
    <nav class="bg-slate-800 text-white shadow-lg">
        <div class="w-full max-w-8xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex items-center">
                    <a class="flex items-center font-bold text-xl text-white hover:text-blue-300 transition" href="/">
                        <i class="bi bi-shield-lock mr-2"></i> SeproWAF
                    </a>
                </div>
                
                <!-- Mobile menu button -->
                <div class="flex items-center sm:hidden">
                    <button id="mobile-menu-button" type="button" class="inline-flex items-center justify-center p-2 rounded-md text-gray-300 hover:text-white hover:bg-slate-700 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white">
                        <span class="sr-only">Open main menu</span>
                        <svg class="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                        </svg>
                    </button>
                </div>
                
                <!-- Desktop menu -->
                <div class="hidden sm:flex sm:items-center sm:ml-6">
                    <div class="flex space-x-4">
                        <a href="/" class="px-3 py-2 rounded-md text-sm font-medium text-white hover:bg-slate-700 hover:text-white">Home</a>
                        
                        <!-- Navigation items for authenticated users -->
                        <a href="/dashboard" class="auth-required hidden px-3 py-2 rounded-md text-sm font-medium text-gray-300 hover:bg-slate-700 hover:text-white">Dashboard</a>
                        <a href="/waf/sites" class="auth-required hidden px-3 py-2 rounded-md text-sm font-medium text-gray-300 hover:bg-slate-700 hover:text-white">Protected Sites</a>
                        <a href="/waf/logs" class="auth-required hidden px-3 py-2 rounded-md text-sm font-medium text-gray-300 hover:bg-slate-700 hover:text-white">Logs</a>
                        <a href="/waf/rules" class="auth-required hidden px-3 py-2 rounded-md text-sm font-medium text-gray-300 hover:bg-slate-700 hover:text-white">Rules</a>
                        <a href="/waf/certificates" class="auth-required hidden px-3 py-2 rounded-md text-sm font-medium text-gray-300 hover:bg-slate-700 hover:text-white">
                            <i class="bi bi-shield-lock mr-1"></i> Certificates
                        </a>
                        
                        <!-- Admin only items -->
                        <a href="/admin/users" class="admin-only hidden px-3 py-2 rounded-md text-sm font-medium text-gray-300 hover:bg-slate-700 hover:text-white">Users</a>
                    </div>
                    
                    <!-- User menu for authenticated users -->
                    <div class="auth-required hidden ml-4 relative">
                        <div>
                            <button id="user-menu-button" type="button" class="flex items-center text-sm rounded-full focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-slate-800 focus:ring-white">
                                <span class="sr-only">Open user menu</span>
                                <i class="bi bi-person-circle text-xl mr-1"></i>
                                <span class="username">{{.Username}}</span>
                                <svg class="ml-1 h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                                    <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
                                </svg>
                            </button>
                        </div>
                        <div id="user-menu" class="hidden origin-top-right absolute right-0 mt-2 w-48 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 py-1 z-10">
                            <a href="/user/profile" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">Profile</a>
                            <div class="border-t border-gray-100"></div>
                            <a href="#" id="logout-btn" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">Logout</a>
                        </div>
                    </div>
                    
                    <!-- Login/Register links for non-authenticated users -->
                    <div class="auth-not-required flex items-center space-x-2">
                        <a href="/auth/login" class="px-3 py-2 rounded-md text-sm font-medium text-gray-300 hover:bg-slate-700 hover:text-white">Login</a>
                        <a href="/auth/register" class="bg-blue-500 hover:bg-blue-600 px-3 py-2 rounded-md text-sm font-medium text-white transition">Register</a>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Mobile menu -->
        <div id="mobile-menu" class="hidden sm:hidden">
            <div class="px-2 pt-2 pb-3 space-y-1">
                <a href="/" class="block px-3 py-2 rounded-md text-base font-medium text-white hover:bg-slate-700">Home</a>
                
                <!-- Mobile navigation for authenticated users -->
                <a href="/dashboard" class="auth-required hidden block px-3 py-2 rounded-md text-base font-medium text-gray-300 hover:bg-slate-700 hover:text-white">Dashboard</a>
                <a href="/waf/sites" class="auth-required hidden block px-3 py-2 rounded-md text-base font-medium text-gray-300 hover:bg-slate-700 hover:text-white">Protected Sites</a>
                <a href="/waf/logs" class="auth-required hidden block px-3 py-2 rounded-md text-base font-medium text-gray-300 hover:bg-slate-700 hover:text-white">Logs</a>
                <a href="/waf/rules" class="auth-required hidden block px-3 py-2 rounded-md text-base font-medium text-gray-300 hover:bg-slate-700 hover:text-white">Rules</a>
                <a href="/waf/certificates" class="auth-required hidden block px-3 py-2 rounded-md text-base font-medium text-gray-300 hover:bg-slate-700 hover:text-white">Certificates</a>
                
                <!-- Mobile admin only items -->
                <a href="/admin/users" class="admin-only hidden block px-3 py-2 rounded-md text-base font-medium text-gray-300 hover:bg-slate-700 hover:text-white">Users</a>
                
                <!-- Mobile user menu -->
                <div class="auth-required hidden pt-4 pb-3 border-t border-gray-700">
                    <div class="flex items-center px-5">
                        <div class="flex-shrink-0">
                            <i class="bi bi-person-circle text-xl"></i>
                        </div>
                        <div class="ml-3">
                            <div class="text-base font-medium text-white username">{{.Username}}</div>
                        </div>
                    </div>
                    <div class="mt-3 px-2 space-y-1">
                        <a href="/user/profile" class="block px-3 py-2 rounded-md text-base font-medium text-gray-300 hover:bg-slate-700 hover:text-white">Profile</a>
                        <a href="#" id="mobile-logout-btn" class="block px-3 py-2 rounded-md text-base font-medium text-gray-300 hover:bg-slate-700 hover:text-white">Logout</a>
                    </div>
                </div>
                
                <!-- Mobile login/register -->
                <div class="auth-not-required space-y-1">
                    <a href="/auth/login" class="block px-3 py-2 rounded-md text-base font-medium text-gray-300 hover:bg-slate-700 hover:text-white">Login</a>
                    <a href="/auth/register" class="block px-3 py-2 rounded-md text-base font-medium bg-blue-500 text-white hover:bg-blue-600">Register</a>
                </div>
            </div>
        </div>
    </nav>

    <div class="w-full max-w-8xl mx-auto px-4 sm:px-6 lg:px-8 py-6 flex-grow">
        {{.LayoutContent}}
    </div>

    <footer class="bg-slate-800 text-white py-6 mt-auto">
        <div class="w-full max-w-8xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <p class="text-gray-300">&copy; 2025 SeproWAF - Web Application Firewall as a Service</p>
        </div>
    </footer>

    <!-- Toast container -->
    <div id="toast-container" class="fixed top-4 right-4 z-50 flex flex-col gap-2"></div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <script src="/static/js/main.js"></script>
    {{.JS}}
    <script>
    // Mobile menu toggle
    document.getElementById('mobile-menu-button').addEventListener('click', function() {
        const menu = document.getElementById('mobile-menu');
        menu.classList.toggle('hidden');
    });
    
    // User dropdown toggle
    document.getElementById('user-menu-button')?.addEventListener('click', function() {
        const menu = document.getElementById('user-menu');
        menu.classList.toggle('hidden');
    });
    
    // Close user menu when clicking outside
    document.addEventListener('click', function(event) {
        const userMenu = document.getElementById('user-menu');
        const userMenuButton = document.getElementById('user-menu-button');
        if (userMenu && !userMenu.contains(event.target) && 
            userMenuButton && !userMenuButton.contains(event.target)) {
            userMenu.classList.add('hidden');
        }
    });
    
    // Check authentication status on page load
    document.addEventListener('DOMContentLoaded', function() {
        // Update navigation based on auth status
        updateNavigation();
        
        // Add logout functionality
        document.getElementById('logout-btn')?.addEventListener('click', handleLogout);
        document.getElementById('mobile-logout-btn')?.addEventListener('click', handleLogout);
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
            authRequiredItems.forEach(item => item.classList.remove('hidden'));
            
            // Hide non-authenticated elements
            authNotRequiredItems.forEach(item => item.classList.add('hidden'));
            
            // Set username
            const usernameEls = document.querySelectorAll('.username');
            usernameEls.forEach(el => {
                if (el) el.textContent = userData.username;
            });
            
            // Show admin items if admin
            if (userData.role === 'admin') {
                adminItems.forEach(item => item.classList.remove('hidden'));
            } else {
                adminItems.forEach(item => item.classList.add('hidden'));
            }
        } else {
            // Hide authenticated user elements
            authRequiredItems.forEach(item => item.classList.add('hidden'));
            
            // Show non-authenticated elements
            authNotRequiredItems.forEach(item => item.classList.remove('hidden'));
            
            // Hide admin items
            adminItems.forEach(item => item.classList.add('hidden'));
        }
    }
    
    function handleLogout(e) {
        e.preventDefault();
        // Your logout logic here
        localStorage.removeItem('auth_token');
        localStorage.removeItem('user_data');
        window.location.href = '/';
    }
    </script>
</body>
</html>