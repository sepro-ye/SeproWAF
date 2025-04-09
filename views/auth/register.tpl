<div class="flex justify-center items-center bg-gray-50 px-4 py-20">
  <div class="mx-auto w-full max-w-xl bg-white border border-gray-200 rounded-2xl shadow-xl p-10">
    <h2 class="text-center text-4xl font-bold text-gray-800 mb-6">Create an Account</h2>
    <p class="text-center text-gray-500 text-lg mb-8">Join us by creating a new account</p>

    <form id="register-form" class="space-y-5">
      <div>
        <label for="username" class="block text-sm font-semibold text-gray-700 mb-2">Username</label>
        <input
          type="text"
          id="username"
          name="username"
          placeholder="Choose a username"
          required
          class="w-full rounded-xl border border-gray-300 bg-white py-3 px-4 text-base shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        />
      </div>

      <div>
        <label for="email" class="block text-sm font-semibold text-gray-700 mb-2">Email</label>
        <input
          type="email"
          id="email"
          name="email"
          placeholder="you@example.com"
          required
          class="w-full rounded-xl border border-gray-300 bg-white py-3 px-4 text-base shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        />
      </div>

      <div>
        <label for="password" class="block text-sm font-semibold text-gray-700 mb-2">Password</label>
        <input
          type="password"
          id="password"
          name="password"
          placeholder="••••••••"
          required
          class="w-full rounded-xl border border-gray-300 bg-white py-3 px-4 text-base shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        />
      </div>

      <div>
        <label for="confirm-password" class="block text-sm font-semibold text-gray-700 mb-2">Confirm Password</label>
        <input
          type="password"
          id="confirm-password"
          name="confirm-password"
          placeholder="••••••••"
          required
          class="w-full rounded-xl border border-gray-300 bg-white py-3 px-4 text-base shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        />
      </div>

      <div id="register-error" class="hidden p-4 text-red-700 bg-red-100 border border-red-300 rounded-xl text-sm"></div>

      <button
        type="submit"
        class="w-full py-3 bg-blue-600 hover:bg-blue-700 transition-all duration-200 text-white font-semibold text-lg rounded-xl shadow-md"
      >
        Register
      </button>
    </form>

    <div class="mt-6 text-center">
      <p class="text-sm text-gray-600">
        Already have an account?
        <a href="/auth/login" class="text-blue-600 hover:text-blue-800 font-medium">Login</a>
      </p>
    </div>
  </div>
</div>

<script>
  document.addEventListener('DOMContentLoaded', function () {
    const registerForm = document.getElementById('register-form');
    const registerError = document.getElementById('register-error');

    registerForm.addEventListener('submit', async function (e) {
      e.preventDefault();

      const username = document.getElementById('username').value;
      const email = document.getElementById('email').value;
      const password = document.getElementById('password').value;
      const confirmPassword = document.getElementById('confirm-password').value;

      registerError.classList.add('hidden');

      if (password !== confirmPassword) {
        registerError.textContent = 'Passwords do not match.';
        registerError.classList.remove('hidden');
        return;
      }

      try {
        const response = await api.post('/auth/register', {
          username,
          email,
          password
        });

        showToast('Registration successful! Please log in.');
        setTimeout(() => {
          window.location.href = '/auth/login';
        }, 1500);
      } catch (error) {
        console.error('Register error:', error);
        const errorMessage = error.response?.data?.error || 'Registration failed. Please try again.';
        registerError.textContent = errorMessage;
        registerError.classList.remove('hidden');
      }
    });
  });
</script>
