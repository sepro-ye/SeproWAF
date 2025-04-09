<div class="flex flex-wrap items-center mb-4">
    <div class="w-full md:w-1/2">
        <h1 class="text-2xl font-bold text-gray-800">User Management</h1>
    </div>
    <div class="w-full md:w-1/2 text-left md:text-right mt-4 md:mt-0">
        <button type="button" id="open-create-modal-btn" class="bg-blue-600 hover:bg-blue-700 text-white font-medium px-4 py-2 rounded-md transition-colors duration-200">
            <i class="bi bi-person-plus mr-1"></i> Add User
        </button>
    </div>
</div>

<div class="bg-white rounded-xl shadow-md overflow-hidden">
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Username</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Created</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
            </thead>
            <tbody id="users-table-body" class="bg-white divide-y divide-gray-200">
                <tr>
                    <td colspan="6" class="px-6 py-4 text-center text-sm text-gray-500">Loading users...</td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<!-- Create User Modal -->
<div id="createUserModal" class="fixed inset-0 z-50 hidden overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen p-4">
        <!-- Modal backdrop -->
        <div class="fixed inset-0 bg-black bg-opacity-50 transition-opacity modal-backdrop"></div>
        
        <!-- Modal content -->
        <div class="bg-white rounded-lg shadow-xl max-w-md w-full z-10 transform transition-all">
            <div class="flex items-center justify-between px-6 py-4 border-b">
                <h3 class="text-lg font-medium text-gray-900">Add New User</h3>
                <button type="button" class="close-modal text-gray-400 hover:text-gray-500">
                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
            <div class="p-6">
                <form id="create-user-form">
                    <div class="mb-4">
                        <label for="new-username" class="block text-sm font-medium text-gray-700 mb-1">Username</label>
                        <input type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" id="new-username" name="username" required>
                    </div>
                    <div class="mb-4">
                        <label for="new-email" class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                        <input type="email" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" id="new-email" name="email" required>
                    </div>
                    <div class="mb-4">
                        <label for="new-password" class="block text-sm font-medium text-gray-700 mb-1">Password</label>
                        <input type="password" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" id="new-password" name="password" required>
                    </div>
                    <div class="mb-4">
                        <label for="new-role" class="block text-sm font-medium text-gray-700 mb-1">Role</label>
                        <select class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" id="new-role" name="role">
                            <option value="user">User</option>
                            <option value="admin">Admin</option>
                        </select>
                    </div>
                    <div class="hidden bg-red-50 border border-red-400 text-red-700 px-4 py-3 rounded" id="create-user-error"></div>
                </form>
            </div>
            <div class="px-6 py-4 border-t bg-gray-50 flex justify-end space-x-3">
                <button type="button" class="close-modal px-4 py-2 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-md transition-colors duration-200">Cancel</button>
                <button type="button" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md transition-colors duration-200" id="create-user-btn">Create User</button>
            </div>
        </div>
    </div>
</div>

<!-- Edit User Modal -->
<div id="editUserModal" class="fixed inset-0 z-50 hidden overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen p-4">
        <!-- Modal backdrop -->
        <div class="fixed inset-0 bg-black bg-opacity-50 transition-opacity modal-backdrop"></div>
        
        <!-- Modal content -->
        <div class="bg-white rounded-lg shadow-xl max-w-md w-full z-10 transform transition-all">
            <div class="flex items-center justify-between px-6 py-4 border-b">
                <h3 class="text-lg font-medium text-gray-900">Edit User</h3>
                <button type="button" class="close-modal text-gray-400 hover:text-gray-500">
                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
            <div class="p-6">
                <form id="edit-user-form">
                    <input type="hidden" id="edit-user-id">
                    <div class="mb-4">
                        <label for="edit-username" class="block text-sm font-medium text-gray-700 mb-1">Username</label>
                        <input type="text" class="w-full px-3 py-2 bg-gray-100 border border-gray-300 rounded-md text-gray-500 cursor-not-allowed" id="edit-username" readonly>
                    </div>
                    <div class="mb-4">
                        <label for="edit-email" class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                        <input type="email" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" id="edit-email" required>
                    </div>
                    <div class="mb-4">
                        <label for="edit-role" class="block text-sm font-medium text-gray-700 mb-1">Role</label>
                        <select class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" id="edit-role">
                            <option value="user">User</option>
                            <option value="admin">Admin</option>
                        </select>
                    </div>
                    <div class="hidden bg-red-50 border border-red-400 text-red-700 px-4 py-3 rounded" id="edit-user-error"></div>
                </form>
            </div>
            <div class="px-6 py-4 border-t bg-gray-50 flex justify-end space-x-3">
                <button type="button" class="close-modal px-4 py-2 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-md transition-colors duration-200">Cancel</button>
                <button type="button" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md transition-colors duration-200" id="edit-user-btn">Save Changes</button>
            </div>
        </div>
    </div>
</div>

<!-- Delete User Modal -->
<div id="deleteUserModal" class="fixed inset-0 z-50 hidden overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen p-4">
        <!-- Modal backdrop -->
        <div class="fixed inset-0 bg-black bg-opacity-50 transition-opacity modal-backdrop"></div>
        
        <!-- Modal content -->
        <div class="bg-white rounded-lg shadow-xl max-w-md w-full z-10 transform transition-all">
            <div class="flex items-center justify-between px-6 py-4 border-b">
                <h3 class="text-lg font-medium text-gray-900">Delete User</h3>
                <button type="button" class="close-modal text-gray-400 hover:text-gray-500">
                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
            <div class="p-6">
                <p class="mb-4">Are you sure you want to delete this user? This action cannot be undone.</p>
                <p><strong>Username:</strong> <span id="delete-username" class="font-medium"></span></p>
                <input type="hidden" id="delete-user-id">
            </div>
            <div class="px-6 py-4 border-t bg-gray-50 flex justify-end space-x-3">
                <button type="button" class="close-modal px-4 py-2 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-md transition-colors duration-200">Cancel</button>
                <button type="button" class="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-md transition-colors duration-200" id="confirm-delete-btn">Delete User</button>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Modal management
    function setupModals() {
        // Open modal functions
        document.getElementById('open-create-modal-btn').addEventListener('click', function() {
            document.getElementById('createUserModal').classList.remove('hidden');
            document.body.classList.add('overflow-hidden');
        });
        
        // Close modal functions
        document.querySelectorAll('.close-modal').forEach(button => {
            button.addEventListener('click', function() {
                const modal = this.closest('.fixed');
                closeModal(modal);
            });
        });
        
        // Close on backdrop click
        document.querySelectorAll('.modal-backdrop').forEach(backdrop => {
            backdrop.addEventListener('click', function() {
                const modal = this.closest('.fixed');
                closeModal(modal);
            });
        });
        
        // Close modals with Escape key
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                document.querySelectorAll('.fixed:not(.hidden)').forEach(modal => {
                    closeModal(modal);
                });
            }
        });
    }
    
    function closeModal(modal) {
        modal.classList.add('hidden');
        document.body.classList.remove('overflow-hidden');
    }
    
    // Load users
    async function loadUsers() {
        try {
            const response = await api.get('/users');
            renderUsersTable(response.data);
        } catch (error) {
            console.error('Error loading users:', error);
            showToast('Failed to load users', 'danger');
        }
    }
    
    // Render users table
    function renderUsersTable(users) {
        const tbody = document.getElementById('users-table-body');
        tbody.innerHTML = '';
        
        if (users.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="px-6 py-4 text-center text-sm text-gray-500">No users found</td></tr>';
            return;
        }
        
        users.forEach(user => {
            const tr = document.createElement('tr');
            tr.className = 'hover:bg-gray-50';
            tr.innerHTML = `
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${user.id}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${user.username}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${user.email}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm">
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${user.role === 'admin' ? 'bg-red-100 text-red-800' : 'bg-blue-100 text-blue-800'}">
                        ${user.role}
                    </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${new Date(user.created_at).toLocaleString()}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button class="edit-user-btn mr-2 text-blue-600 hover:text-blue-900 focus:outline-none" data-id="${user.id}">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <button class="delete-user-btn text-red-600 hover:text-red-900 focus:outline-none" data-id="${user.id}" data-username="${user.username}">
                        <i class="bi bi-trash"></i>
                    </button>
                </td>
            `;
            tbody.appendChild(tr);
        });
        
        // Add event listeners to edit and delete buttons
        document.querySelectorAll('.edit-user-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const userId = this.getAttribute('data-id');
                openEditUserModal(userId);
            });
        });
        
        document.querySelectorAll('.delete-user-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const userId = this.getAttribute('data-id');
                const username = this.getAttribute('data-username');
                openDeleteUserModal(userId, username);
            });
        });
    }
    
    // Create user
    document.getElementById('create-user-btn').addEventListener('click', async function() {
        const username = document.getElementById('new-username').value;
        const email = document.getElementById('new-email').value;
        const password = document.getElementById('new-password').value;
        const role = document.getElementById('new-role').value;
        const errorElement = document.getElementById('create-user-error');
        
        if (!username || !email || !password) {
            errorElement.textContent = 'All fields are required';
            errorElement.classList.remove('hidden');
            return;
        }
        
        try {
            await api.post('/auth/register', {
                username,
                email,
                password,
                role
            });
            
            // Close modal and refresh user list
            closeModal(document.getElementById('createUserModal'));
            
            // Clear form
            document.getElementById('new-username').value = '';
            document.getElementById('new-email').value = '';
            document.getElementById('new-password').value = '';
            document.getElementById('new-role').value = 'user';
            
            showToast('User created successfully', 'success');
            loadUsers();
        } catch (error) {
            errorElement.textContent = error.response?.data?.error || 'Failed to create user';
            errorElement.classList.remove('hidden');
        }
    });
    
    // Open edit user modal
    async function openEditUserModal(userId) {
        try {
            const response = await api.get(`/user/${userId}`);
            const user = response.data;
            
            document.getElementById('edit-user-id').value = user.id;
            document.getElementById('edit-username').value = user.username;
            document.getElementById('edit-email').value = user.email;
            document.getElementById('edit-role').value = user.role;
            
            // Show modal
            document.getElementById('editUserModal').classList.remove('hidden');
            document.body.classList.add('overflow-hidden');
        } catch (error) {
            console.error('Error fetching user details:', error);
            showToast('Failed to fetch user details', 'danger');
        }
    }
    
    // Edit user
    document.getElementById('edit-user-btn').addEventListener('click', async function() {
        const userId = document.getElementById('edit-user-id').value;
        const email = document.getElementById('edit-email').value;
        const role = document.getElementById('edit-role').value;
        const errorElement = document.getElementById('edit-user-error');
        
        if (!email) {
            errorElement.textContent = 'Email is required';
            errorElement.classList.remove('hidden');
            return;
        }
        
        try {
            await api.put(`/user/${userId}`, {
                email,
                role
            });
            
            // Close modal and refresh user list
            closeModal(document.getElementById('editUserModal'));
            
            showToast('User updated successfully', 'success');
            loadUsers();
        } catch (error) {
            errorElement.textContent = error.response?.data?.error || 'Failed to update user';
            errorElement.classList.remove('hidden');
        }
    });
    
    // Open delete user modal
    function openDeleteUserModal(userId, username) {
        document.getElementById('delete-user-id').value = userId;
        document.getElementById('delete-username').textContent = username;
        
        // Show modal
        document.getElementById('deleteUserModal').classList.remove('hidden');
        document.body.classList.add('overflow-hidden');
    }
    
    // Delete user
    document.getElementById('confirm-delete-btn').addEventListener('click', async function() {
        const userId = document.getElementById('delete-user-id').value;
        
        try {
            await api.delete(`/user/${userId}/delete`);
            
            // Close modal and refresh user list
            closeModal(document.getElementById('deleteUserModal'));
            
            showToast('User deleted successfully', 'success');
            loadUsers();
        } catch (error) {
            console.error('Error deleting user:', error);
            showToast('Failed to delete user', 'danger');
        }
    });
    
    // Initialize
    setupModals();
    loadUsers();
});
</script>