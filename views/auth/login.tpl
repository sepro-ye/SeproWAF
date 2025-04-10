<div class="flex justify-center items-center bg-gray-50 px-4 py-20">
  <div class="mx-auto w-full max-w-xl bg-white border border-gray-200 rounded-2xl shadow-xl p-10">
    <h2 class="text-center text-4xl font-bold text-gray-800 mb-6">Welcome Back</h2>
    <p class="text-center text-gray-500 text-lg mb-8">Sign in to continue to your account</p>

    <form id="login-form" class="space-y-5">
      <div>
        <label for="username" class="block text-sm font-semibold text-gray-700 mb-2">Username</label>
        <div class="relative">
          <input
            type="text"
            id="username"
            name="username"
            placeholder="Enter your username"
            required
            class="w-full rounded-xl border border-gray-300 bg-white py-3 px-4 text-base shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          />
        </div>
      </div>

      <div>
        <label for="password" class="block text-sm font-semibold text-gray-700 mb-2">Password</label>
        <div class="relative">
          <input
            type="password"
            id="password"
            name="password"
            placeholder="••••••••"
            required
            class="w-full rounded-xl border border-gray-300 bg-white py-3 px-4 text-base shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          />
        </div>
      </div>

      <div id="login-error" class="hidden p-4 text-red-700 bg-red-100 border border-red-300 rounded-xl text-sm"></div>

      <button
        type="submit"
        class="w-full py-3 bg-blue-600 hover:bg-blue-700 transition-all duration-200 text-white font-semibold text-lg rounded-xl shadow-md"
      >
        Sign In
      </button>
    </form>

    <div class="mt-6 text-center">
      <p class="text-sm text-gray-600">
        Don’t have an account?
        <a href="/auth/register" class="text-blue-600 hover:text-blue-800 font-medium">Create one</a>
      </p>
    </div>
  </div>
</div>

<script>
  document.addEventListener('DOMContentLoaded', function () {
    const loginForm = document.getElementById('login-form');
    const loginError = document.getElementById('login-error');

    loginForm.addEventListener('submit', async function (e) {
      e.preventDefault();

      const username = document.getElementById('username').value;
      const password = document.getElementById('password').value;

      loginError.classList.add('hidden');

      try {
        const response = await api.post('/auth/login', {
          username: username,
          password: password
        });

        const { token, user_id, username: user, role } = response.data;

        setAuth(token, {
          id: user_id,
          username: user,
          role: role
        });

        showToast('Login successful! Redirecting...', 'success');

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
        loginError.classList.remove('hidden');
      }
    });
  });
</script>
