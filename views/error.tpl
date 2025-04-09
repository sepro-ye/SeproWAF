<div class="flex justify-center mt-12 px-4">
    <div class="w-full max-w-3xl text-center">
        <div class="bg-white rounded-xl shadow-lg overflow-hidden">
            <div class="p-8 md:p-10">
                <h1 class="text-7xl font-bold text-red-600 mb-2">{{.ErrorCode}}</h1>
                <h2 class="text-2xl font-medium text-gray-800 mb-6">{{.ErrorMessage}}</h2>
                
                {{if eq .ErrorCode 404}}
                <p class="text-lg text-gray-600 mb-8">The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.</p>
                {{else if eq .ErrorCode 500}}
                <p class="text-lg text-gray-600 mb-8">Our servers are experiencing issues. Please try again later or contact support if the problem persists.</p>
                {{else if eq .ErrorCode 401}}
                <p class="text-lg text-gray-600 mb-8">You must log in to access this resource.</p>
                {{else if eq .ErrorCode 403}}
                <p class="text-lg text-gray-600 mb-8">You don't have permission to access this resource.</p>
                {{end}}
                
                <div class="mt-8 flex flex-col sm:flex-row justify-center gap-4">
                    <a href="/" class="inline-flex items-center justify-center bg-blue-600 hover:bg-blue-700 text-white font-medium px-6 py-3 rounded-lg transition-colors duration-200">
                        <i class="bi bi-house-door mr-2"></i> Go Home
                    </a>
                    <a href="javascript:history.back()" class="inline-flex items-center justify-center bg-white hover:bg-gray-100 text-gray-700 border border-gray-300 font-medium px-6 py-3 rounded-lg transition-colors duration-200">
                        <i class="bi bi-arrow-left mr-2"></i> Go Back
                    </a>
                </div>
                
                <!-- Added help message -->
                <div class="mt-8 text-gray-500 text-sm">
                    Need help? <a href="/contact" class="text-blue-600 hover:underline">Contact support</a>
                </div>
            </div>
        </div>
        
        <!-- Added error illustration -->
        <div class="mt-8">
            <svg class="mx-auto h-36 w-auto text-gray-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"></circle>
                <path d="M12 8v4M12 16h.01"></path>
            </svg>
        </div>
    </div>
</div>