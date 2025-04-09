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

// Show toast notification - Tailwind CSS version (no Bootstrap dependency)
function showToast(message, type = 'success') {
    const toastContainer = document.getElementById('toast-container');
    if (!toastContainer) {
        const container = document.createElement('div');
        container.id = 'toast-container';
        container.className = 'fixed top-4 right-4 z-50 flex flex-col gap-2';
        document.body.appendChild(container);
    }
    
    // Map types to Tailwind colors
    const typeColors = {
        'success': 'bg-emerald-500',
        'danger': 'bg-red-500',
        'warning': 'bg-amber-500',
        'info': 'bg-sky-500'
    };
    
    const id = 'toast-' + Date.now();
    const toastEl = document.createElement('div');
    toastEl.id = id;
    toastEl.className = `${typeColors[type] || 'bg-emerald-500'} text-white p-4 rounded-lg shadow-lg transform transition-all duration-300 ease-in-out flex items-center justify-between max-w-sm`;
    toastEl.setAttribute('role', 'alert');
    toastEl.innerHTML = `
        <div class="flex items-center">
            <span class="mr-2">
                ${type === 'success' ? '<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path></svg>' : ''}
                ${type === 'danger' ? '<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path></svg>' : ''}
                ${type === 'warning' ? '<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path></svg>' : ''}
                ${type === 'info' ? '<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2h.01a1 1 0 100-2H9z" clip-rule="evenodd"></path><path d="M9 13h2v-4H9v4z"></path></svg>' : ''}
            </span>
            <span class="text-sm font-medium">${message}</span>
        </div>
        <button class="ml-4 text-white hover:text-gray-100 focus:outline-none">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
        </button>
    `;
    
    document.getElementById('toast-container').appendChild(toastEl);
    
    // Add animation classes
    setTimeout(() => {
        toastEl.classList.add('opacity-100', 'translate-y-0');
    }, 10);
    
    // Add click event for the close button
    toastEl.querySelector('button').addEventListener('click', () => {
        dismissToast(toastEl);
    });
    
    // Auto-dismiss after 5 seconds
    setTimeout(() => {
        dismissToast(toastEl);
    }, 5000);
}

function dismissToast(toastEl) {
    // Start dismiss animation
    toastEl.classList.add('opacity-0', '-translate-y-2');
    
    // Remove from DOM after animation completes
    setTimeout(() => {
        if (toastEl && toastEl.parentNode) {
            toastEl.parentNode.removeChild(toastEl);
        }
    }, 300);
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