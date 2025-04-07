<div class="row mb-4">
    <div class="col-md-6">
        <h1>User Management</h1>
    </div>
    <div class="col-md-6 text-end">
        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createUserModal">
            <i class="bi bi-person-plus"></i> Add User
        </button>
    </div>
</div>

<div class="card">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-striped table-hover mb-0">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Created</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="users-table-body">
                    <tr>
                        <td colspan="6" class="text-center">Loading users...</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Create User Modal -->
<div class="modal fade" id="createUserModal" tabindex="-1" aria-labelledby="createUserModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="createUserModalLabel">Add New User</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="create-user-form">
                    <div class="mb-3">
                        <label for="new-username" class="form-label">Username</label>
                        <input type="text" class="form-control" id="new-username" name="username" required>
                    </div>
                    <div class="mb-3">
                        <label for="new-email" class="form-label">Email</label>
                        <input type="email" class="form-control" id="new-email" name="email" required>
                    </div>
                    <div class="mb-3">
                        <label for="new-password" class="form-label">Password</label>
                        <input type="password" class="form-control" id="new-password" name="password" required>
                    </div>
                    <div class="mb-3">
                        <label for="new-role" class="form-label">Role</label>
                        <select class="form-select" id="new-role" name="role">
                            <option value="user">User</option>
                            <option value="admin">Admin</option>
                        </select>
                    </div>
                    <div class="alert alert-danger d-none" id="create-user-error"></div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" id="create-user-btn">Create User</button>
            </div>
        </div>
    </div>
</div>

<!-- Edit User Modal -->
<div class="modal fade" id="editUserModal" tabindex="-1" aria-labelledby="editUserModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="editUserModalLabel">Edit User</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="edit-user-form">
                    <input type="hidden" id="edit-user-id">
                    <div class="mb-3">
                        <label for="edit-username" class="form-label">Username</label>
                        <input type="text" class="form-control" id="edit-username" readonly>
                    </div>
                    <div class="mb-3">
                        <label for="edit-email" class="form-label">Email</label>
                        <input type="email" class="form-control" id="edit-email" required>
                    </div>
                    <div class="mb-3">
                        <label for="edit-role" class="form-label">Role</label>
                        <select class="form-select" id="edit-role">
                            <option value="user">User</option>
                            <option value="admin">Admin</option>
                        </select>
                    </div>
                    <div class="alert alert-danger d-none" id="edit-user-error"></div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" id="edit-user-btn">Save Changes</button>
            </div>
        </div>
    </div>
</div>

<!-- Delete User Modal -->
<div class="modal fade" id="deleteUserModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Delete User</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete this user? This action cannot be undone.</p>
                <p><strong>Username:</strong> <span id="delete-username"></span></p>
                <input type="hidden" id="delete-user-id">
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger" id="confirm-delete-btn">Delete User</button>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
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
            tbody.innerHTML = '<tr><td colspan="6" class="text-center">No users found</td></tr>';
            return;
        }
        
        users.forEach(user => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${user.id}</td>
                <td>${user.username}</td>
                <td>${user.email}</td>
                <td><span class="badge bg-${user.role === 'admin' ? 'danger' : 'primary'}">${user.role}</span></td>
                <td>${new Date(user.created_at).toLocaleString()}</td>
                <td>
                    <button class="btn btn-sm btn-outline-primary edit-user-btn" data-id="${user.id}">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <button class="btn btn-sm btn-outline-danger delete-user-btn" data-id="${user.id}" data-username="${user.username}">
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
            errorElement.classList.remove('d-none');
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
            const modal = bootstrap.Modal.getInstance(document.getElementById('createUserModal'));
            modal.hide();
            
            // Clear form
            document.getElementById('new-username').value = '';
            document.getElementById('new-email').value = '';
            document.getElementById('new-password').value = '';
            document.getElementById('new-role').value = 'user';
            
            showToast('User created successfully', 'success');
            loadUsers();
        } catch (error) {
            errorElement.textContent = error.response?.data?.error || 'Failed to create user';
            errorElement.classList.remove('d-none');
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
            
            const modal = new bootstrap.Modal(document.getElementById('editUserModal'));
            modal.show();
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
            errorElement.classList.remove('d-none');
            return;
        }
        
        try {
            await api.put(`/user/${userId}`, {
                email,
                role
            });
            
            // Close modal and refresh user list
            const modal = bootstrap.Modal.getInstance(document.getElementById('editUserModal'));
            modal.hide();
            
            showToast('User updated successfully', 'success');
            loadUsers();
        } catch (error) {
            errorElement.textContent = error.response?.data?.error || 'Failed to update user';
            errorElement.classList.remove('d-none');
        }
    });
    
    // Open delete user modal
    function openDeleteUserModal(userId, username) {
        document.getElementById('delete-user-id').value = userId;
        document.getElementById('delete-username').textContent = username;
        
        const modal = new bootstrap.Modal(document.getElementById('deleteUserModal'));
        modal.show();
    }
    
    // Delete user
    document.getElementById('confirm-delete-btn').addEventListener('click', async function() {
        const userId = document.getElementById('delete-user-id').value;
        
        try {
            await api.delete(`/user/${userId}/delete`);
            
            // Close modal and refresh user list
            const modal = bootstrap.Modal.getInstance(document.getElementById('deleteUserModal'));
            modal.hide();
            
            showToast('User deleted successfully', 'success');
            loadUsers();
        } catch (error) {
            console.error('Error deleting user:', error);
            showToast('Failed to delete user', 'danger');
        }
    });
    
    // Initial load
    loadUsers();
});
</script>