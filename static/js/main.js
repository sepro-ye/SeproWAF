// Main JavaScript file for SeproWAF UI

// Token management
const TOKEN_KEY = 'sepro_waf_token';
const USER_DATA = 'sepro_waf_user';

// Get auth token
function getToken() {
    return localStorage.getItem(TOKEN_KEY);
}

// Set auth token and user data
function setAuth(token, userData) {
    // Store in localStorage for API requests
    localStorage.setItem(TOKEN_KEY, token);
    localStorage.setItem(USER_DATA, JSON.stringify(userData));
    
    // Also set a cookie for page navigation authentication
    document.cookie = `jwt_token=${token}; path=/; max-age=86400; SameSite=Strict`;
}

// Clear auth data on logout
function clearAuth() {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_DATA);
    
    // Also clear the auth cookie
    document.cookie = "jwt_token=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT";
}

// Check if user is logged in
function isLoggedIn() {
    return !!getToken();
}

// Get user data
function getUserData() {
    const data = localStorage.getItem(USER_DATA);
    return data ? JSON.parse(data) : null;
}

// API client setup
const api = axios.create({
    baseURL: '/api',
    headers: {
        'Content-Type': 'application/json'
    }
});

// Add token to requests
api.interceptors.request.use(config => {
    const token = getToken();
    if (token) {
        config.headers['Authorization'] = `Bearer ${token}`;
    }
    return config;
});

// Handle unauthorized responses
api.interceptors.response.use(
    response => response,
    error => {
        if (error.response && error.response.status === 401) {
            clearAuth();
            window.location.href = '/auth/login';
        }
        return Promise.reject(error);
    }
);

// Show toast notification
function showToast(message, type = 'success') {
    const toastContainer = document.getElementById('toast-container');
    if (!toastContainer) {
        const container = document.createElement('div');
        container.id = 'toast-container';
        container.className = 'toast-container position-fixed top-0 end-0 p-3';
        document.body.appendChild(container);
    }
    
    const id = 'toast-' + Date.now();
    const html = `
        <div id="${id}" class="toast align-items-center text-white bg-${type} border-0" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex">
                <div class="toast-body">
                    ${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        </div>
    `;
    
    document.getElementById('toast-container').innerHTML += html;
    const toastEl = document.getElementById(id);
    const toast = new bootstrap.Toast(toastEl);
    toast.show();
    
    // Remove toast after it's hidden
    toastEl.addEventListener('hidden.bs.toast', () => {
        toastEl.remove();
    });
}

// Logout functionality
document.addEventListener('DOMContentLoaded', function() {
    const logoutBtn = document.getElementById('logout-btn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', async function(e) {
            e.preventDefault();
            
            try {
                // Send request with JWT token in header (handled by interceptor)
                await api.post('/auth/logout');
                showToast('Logged out successfully', 'success');
            } catch (error) {
                console.error('Logout error:', error);
                showToast('Error during logout', 'danger');
            } finally {
                clearAuth();
                window.location.href = '/auth/login';
            }
        });
    }
});