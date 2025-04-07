<div class="row">
    <div class="col-md-6 mx-auto">
        <div class="auth-container">
            <h2 class="text-center mb-4">Register</h2>
            <form id="register-form">
                <div class="mb-3">
                    <label for="username" class="form-label">Username</label>
                    <input type="text" class="form-control" id="username" name="username" required>
                </div>
                <div class="mb-3">
                    <label for="email" class="form-label">Email</label>
                    <input type="email" class="form-control" id="email" name="email" required>
                </div>
                <div class="mb-3">
                    <label for="password" class="form-label">Password</label>
                    <input type="password" class="form-control" id="password" name="password" required>
                </div>
                <div class="mb-3">
                    <label for="confirm-password" class="form-label">Confirm Password</label>
                    <input type="password" class="form-control" id="confirm-password" name="confirm-password" required>
                </div>
                <div class="alert alert-danger d-none" id="register-error"></div>
                <div class="d-grid gap-2">
                    <button type="submit" class="btn btn-primary">Register</button>
                </div>
            </form>
            <div class="text-center mt-3">
                <p>Already have an account? <a href="/auth/login">Login</a></p>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const registerForm = document.getElementById('register-form');
    const registerError = document.getElementById('register-error');

    registerForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const username = document.getElementById('username').value;
        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirm-password').value;
        
        if (password !== confirmPassword) {
            registerError.textContent = 'Passwords do not match.';
            registerError.classList.remove('d-none');
            return;
        }
        
        try {
            const response = await api.post('/auth/register', {
                username: username,
                email: email,
                password: password
            });
            
            showToast('Registration successful! Please log in.');
            setTimeout(() => {
                window.location.href = '/auth/login';
            }, 1500);
        } catch (error) {
            registerError.textContent = error.response?.data?.error || 'Registration failed. Please try again.';
            registerError.classList.remove('d-none');
        }
    });
});
</script>