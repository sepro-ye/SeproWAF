<div class="flex justify-between items-center mb-6">
    <h1 class="text-2xl font-bold text-gray-800">User Profile</h1>
</div>

<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
    <!-- Profile Information Card -->
    <div class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="bg-gray-50 px-6 py-4 border-b border-gray-200">
            <h2 class="text-lg font-semibold text-gray-800">Profile Information</h2>
        </div>
        <div class="p-6">
            <form id="profile-form">
                <div class="mb-4">
                    <label for="username" class="block text-sm font-medium text-gray-700 mb-1">Username</label>
                    <input type="text" id="username" value="{{.Username}}" readonly
                        class="w-full px-3 py-2 bg-gray-100 border border-gray-300 rounded-md text-gray-500 cursor-not-allowed">
                </div>
                <div class="mb-4">
                    <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                    <input type="email" id="email" name="email" value="{{.Email}}"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                </div>
                <div class="mb-4">
                    <label for="role" class="block text-sm font-medium text-gray-700 mb-1">Role</label>
                    <input type="text" id="role" value="{{.Role}}" readonly 
                        class="w-full px-3 py-2 bg-gray-100 border border-gray-300 rounded-md text-gray-500 cursor-not-allowed">
                </div>
                
                <!-- Success message -->
                <div id="profile-success" class="hidden mb-4 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative"></div>
                
                <!-- Error message -->
                <div id="profile-error" class="hidden mb-4 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative"></div>
                
                <button type="submit" 
                    class="bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition duration-200">
                    Update Profile
                </button>
            </form>
        </div>
    </div>
    
    <!-- Change Password Card -->
    <div class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="bg-gray-50 px-6 py-4 border-b border-gray-200">
            <h2 class="text-lg font-semibold text-gray-800">Change Password</h2>
        </div>
        <div class="p-6">
            <form id="password-form">
                <div class="mb-4">
                    <label for="current-password" class="block text-sm font-medium text-gray-700 mb-1">Current Password</label>
                    <input type="password" id="current-password" name="current-password" required
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                </div>
                <div class="mb-4">
                    <label for="new-password" class="block text-sm font-medium text-gray-700 mb-1">New Password</label>
                    <input type="password" id="new-password" name="new-password" required
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                </div>
                <div class="mb-4">
                    <label for="confirm-password" class="block text-sm font-medium text-gray-700 mb-1">Confirm New Password</label>
                    <input type="password" id="confirm-password" name="confirm-password" required
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                </div>
                
                <!-- Success message -->
                <div id="password-success" class="hidden mb-4 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative"></div>
                
                <!-- Error message -->
                <div id="password-error" class="hidden mb-4 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative"></div>
                
                <button type="submit" 
                    class="bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition duration-200">
                    Change Password
                </button>
            </form>
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
            profileSuccess.classList.remove('hidden');
            profileError.classList.add('hidden');
        } catch (error) {
            profileError.textContent = error.response?.data?.error || 'Failed to update profile';
            profileError.classList.remove('hidden');
            profileSuccess.classList.add('hidden');
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
            passwordError.classList.remove('hidden');
            passwordSuccess.classList.add('hidden');
            return;
        }
        
        const userData = getUserData();
        
        try {
            await api.put(`/user/${userData.id}`, {
                password: newPassword
            });
            
            passwordSuccess.textContent = 'Password changed successfully';
            passwordSuccess.classList.remove('hidden');
            passwordError.classList.add('hidden');
            
            // Clear password fields
            document.getElementById('current-password').value = '';
            document.getElementById('new-password').value = '';
            document.getElementById('confirm-password').value = '';
        } catch (error) {
            passwordError.textContent = error.response?.data?.error || 'Failed to change password';
            passwordError.classList.remove('hidden');
            passwordSuccess.classList.add('hidden');
        }
    });
});
</script>