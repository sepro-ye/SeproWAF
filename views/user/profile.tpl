<div class="row mb-4">
    <div class="col">
        <h1>User Profile</h1>
    </div>
</div>

<div class="row">
    <div class="col-md-6">
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">Profile Information</h5>
            </div>
            <div class="card-body">
                <form id="profile-form">
                    <div class="mb-3">
                        <label for="username" class="form-label">Username</label>
                        <input type="text" class="form-control" id="username" value="{{.Username}}" readonly>
                    </div>
                    <div class="mb-3">
                        <label for="email" class="form-label">Email</label>
                        <input type="email" class="form-control" id="email" name="email" value="{{.Email}}">
                    </div>
                    <div class="mb-3">
                        <label for="role" class="form-label">Role</label>
                        <input type="text" class="form-control" id="role" value="{{.Role}}" readonly>
                    </div>
                    <div class="alert alert-success d-none" id="profile-success"></div>
                    <div class="alert alert-danger d-none" id="profile-error"></div>
                    <button type="submit" class="btn btn-primary">Update Profile</button>
                </form>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">Change Password</h5>
            </div>
            <div class="card-body">
                <form id="password-form">
                    <div class="mb-3">
                        <label for="current-password" class="form-label">Current Password</label>
                        <input type="password" class="form-control" id="current-password" name="current-password" required>
                    </div>
                    <div class="mb-3">
                        <label for="new-password" class="form-label">New Password</label>
                        <input type="password" class="form-control" id="new-password" name="new-password" required>
                    </div>
                    <div class="mb-3">
                        <label for="confirm-password" class="form-label">Confirm New Password</label>
                        <input type="password" class="form-control" id="confirm-password" name="confirm-password" required>
                    </div>
                    <div class="alert alert-success d-none" id="password-success"></div>
                    <div class="alert alert-danger d-none" id="password-error"></div>
                    <button type="submit" class="btn btn-primary">Change Password</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const profileForm = document.getElementById('profile-form');
    const profileSuccess = document.getElementById('profile-success');
    const profileError = document.getElementById('profile-error');
    
    const passwordForm = document.getElementById('password-form');
    const passwordSuccess = document.getElementById('password-success');
    const passwordError = document.getElementById('password-error');
    
    // Update profile
    profileForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const email = document.getElementById('email').value;
        const userData = getUserData();
        
        try {
            await api.put(`/user/${userData.id}`, {
                email: email
            });
            
            profileSuccess.textContent = 'Profile updated successfully';
            profileSuccess.classList.remove('d-none');
            profileError.classList.add('d-none');
        } catch (error) {
            profileError.textContent = error.response?.data?.error || 'Failed to update profile';
            profileError.classList.remove('d-none');
            profileSuccess.classList.add('d-none');
        }
    });
    
    // Change password
    passwordForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const currentPassword = document.getElementById('current-password').value;
        const newPassword = document.getElementById('new-password').value;
        const confirmPassword = document.getElementById('confirm-password').value;
        
        if (newPassword !== confirmPassword) {
            passwordError.textContent = 'New passwords do not match';
            passwordError.classList.remove('d-none');
            passwordSuccess.classList.add('d-none');
            return;
        }
        
        const userData = getUserData();
        
        try {
            await api.put(`/user/${userData.id}`, {
                password: newPassword
            });
            
            passwordSuccess.textContent = 'Password changed successfully';
            passwordSuccess.classList.remove('d-none');
            passwordError.classList.add('d-none');
            
            // Clear password fields
            document.getElementById('current-password').value = '';
            document.getElementById('new-password').value = '';
            document.getElementById('confirm-password').value = '';
        } catch (error) {
            passwordError.textContent = error.response?.data?.error || 'Failed to change password';
            passwordError.classList.remove('d-none');
            passwordSuccess.classList.add('d-none');
        }
    });
});
</script>