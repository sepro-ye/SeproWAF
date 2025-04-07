<div class="row">
    <div class="col-md-6 mx-auto">
        <div class="auth-container">
            <h2 class="text-center mb-4">Login</h2>
            <form id="login-form">
                <div class="mb-3">
                    <label for="username" class="form-label">Username</label>
                    <input type="text" class="form-control" id="username" name="username" required>
                </div>
                <div class="mb-3">
                    <label for="password" class="form-label">Password</label>
                    <input type="password" class="form-control" id="password" name="password" required>
                </div>
                <div class="alert alert-danger d-none" id="login-error"></div>
                <div class="d-grid gap-2">
                    <button type="submit" class="btn btn-primary">Login</button>
                </div>
            </form>
            <div class="text-center mt-3">
                <p>Don't have an account? <a href="/auth/register">Register</a></p>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const loginForm = document.getElementById('login-form');
    const loginError = document.getElementById('login-error');

    loginForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const username = document.getElementById('username').value;
        const password = document.getElementById('password').value;
        
        loginError.classList.add('d-none');
        
        try {
            console.log('Attempting to login...');
            const response = await api.post('/auth/login', {
                username: username,
                password: password
            });
            
            console.log('Login response:', response.data);
            
            const { token, user_id, username: user, role, expires_at } = response.data;
            
            // Store token and user data
            setAuth(token, {
                id: user_id,
                username: user,
                role: role
            });
            
            showToast('Login successful! Redirecting...', 'success');
            
            // Redirect to dashboard after short delay
            setTimeout(() => {
                window.location.href = '/dashboard';
            }, 1000);
        } catch (error) {
            console.error('Login error:', error);
            let errorMessage = 'Login failed. Please check your credentials.';
            
            if (error.response && error.response.data) {
                errorMessage = error.response.data.error || errorMessage;
            }
            
            loginError.textContent = errorMessage;
            loginError.classList.remove('d-none');
        }
    });
});
</script>