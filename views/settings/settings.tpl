<div class="max-w-4xl mx-auto p-6 space-y-10">
  
  <!-- General Settings -->
  <section class="bg-white shadow-md rounded-lg p-6">
    <h2 class="text-xl font-bold text-gray-800 mb-4">⚙️ General Settings</h2>
    <form class="space-y-4">
      <div>
        <label for="site-name" class="block text-sm font-medium text-gray-700">Site Name</label>
        <input type="text" id="site-name" name="site-name" placeholder="Enter your site name"
               class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-blue-500 focus:border-blue-500" />
      </div>

      <div>
        <label for="language" class="block text-sm font-medium text-gray-700">Language</label>
        <select id="language" name="language"
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-blue-500 focus:border-blue-500">
          <option>English</option>
          <option>Arabic</option>
        </select>
      </div>

      <div>
        <label for="theme" class="block text-sm font-medium text-gray-700">Theme</label>
        <select id="theme" name="theme"
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-blue-500 focus:border-blue-500">
          <option>Light</option>
          <option>Dark</option>
        </select>
      </div>

      <div>
        <label for="runmode" class="block text-sm font-medium text-gray-700">Run Mode</label>
        <select id="runmode" name="runmode"
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-blue-500 focus:border-blue-500">
          <option>Development</option>
          <option>Production</option>
        </select>
      </div>

      <button type="submit"
              class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition">Save</button>
    </form>
  </section>

  <!-- Profile Settings -->
  <section class="bg-white shadow-md rounded-lg p-6">
    <h2 class="text-xl font-bold text-gray-800 mb-4">👤 Profile Settings</h2>
    <form class="space-y-4">
      <div>
        <label for="full-name" class="block text-sm font-medium text-gray-700">Full Name</label>
        <input type="text" id="full-name" name="full-name" placeholder="Your full name"
               class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-indigo-500 focus:border-indigo-500" />
      </div>

      <div>
        <label for="username" class="block text-sm font-medium text-gray-700">Username</label>
        <input type="text" id="username" name="username" placeholder="Username"
               class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-indigo-500 focus:border-indigo-500" />
      </div>

      <div>
        <label for="email" class="block text-sm font-medium text-gray-700">Email Address</label>
        <input type="email" id="email" name="email" placeholder="you@example.com"
               class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-indigo-500 focus:border-indigo-500" />
      </div>

      <div>
        <label for="profile-picture" class="block text-sm font-medium text-gray-700">Profile Picture</label>
        <input type="file" id="profile-picture" name="profile-picture"
               class="mt-1 block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100" />
      </div>

      <div>
        <label for="bio" class="block text-sm font-medium text-gray-700">Bio</label>
        <textarea id="bio" name="bio" rows="4" placeholder="Write a short bio..."
                  class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-indigo-500 focus:border-indigo-500"></textarea>
      </div>

      <button type="submit"
              class="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700 transition">Update Profile</button>
    </form>
  </section>

</div>
