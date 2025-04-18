<!-- Full-width hero section with space theme -->
<div class="relative overflow-hidden bg-slate-900 min-h-screen">
    <!-- Background with space/planet effect -->
    <div class="absolute inset-0 z-0">
        <div class="absolute inset-0 bg-gradient-to-b from-indigo-900/20 to-slate-900"></div>
        <div class="absolute bottom-0 left-0 right-0 h-1/2 bg-gradient-to-t from-slate-900 to-transparent"></div>
        <div class="absolute top-1/4 right-1/4 w-96 h-96 rounded-full bg-indigo-700/20 blur-3xl"></div>
        <div class="absolute top-1/3 left-1/3 w-96 h-96 rounded-full bg-blue-700/20 blur-3xl"></div>
    </div>


    <!-- Hero section -->
    <div class="relative z-10 max-w-7xl mx-auto px-4 pt-40 pb-32 sm:px-6 lg:px-8 flex flex-col items-center">
        <h1 class="text-4xl sm:text-5xl md:text-6xl font-bold text-white text-center leading-tight mb-6">
            Secure your applications <br class="hidden md:block">with enterprise-grade WAF
        </h1>
        <p class="text-lg sm:text-xl text-slate-300 text-center mb-10 max-w-3xl">
            Protect your web applications from OWASP top 10 threats with advanced WAF capabilities, real-time monitoring, and customized security rules.
        </p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center">
            {{if .IsAuthenticated}}
            <a href="/waf/sites" class="inline-block bg-blue-600 hover:bg-blue-700 text-white font-medium px-8 py-3 rounded-lg transition-colors duration-200 text-center">
                Manage protected sites
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline ml-2" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd" d="M12.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-2.293-2.293a1 1 0 010-1.414z" clip-rule="evenodd" />
                </svg>
            </a>
            <a href="#features" class="inline-block bg-slate-700 hover:bg-slate-800 text-white font-medium px-8 py-3 rounded-lg transition-colors duration-200 text-center">
                Learn more
            </a>
            {{else}}
            <a href="/auth/register" class="inline-block bg-blue-600 hover:bg-blue-700 text-white font-medium px-8 py-3 rounded-lg transition-colors duration-200 text-center">
                Get started free
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline ml-2" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd" d="M12.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-2.293-2.293a1 1 0 010-1.414z" clip-rule="evenodd" />
                </svg>
            </a>
            <a href="/auth/login" class="inline-block bg-slate-700 hover:bg-slate-800 text-white font-medium px-8 py-3 rounded-lg transition-colors duration-200 text-center">
                Login
            </a>
            {{end}}
        </div>
    </div>

    <!-- Dashboard preview mockup -->
    <div class="relative z-10 max-w-6xl mx-auto px-4">
        <div class="bg-slate-800/50 backdrop-blur-sm border border-slate-700/50 rounded-lg shadow-2xl overflow-hidden">
            <div class="p-2">
                <div class="flex items-center gap-1 absolute left-4 top-4">
                    <div class="w-3 h-3 rounded-full bg-red-500"></div>
                    <div class="w-3 h-3 rounded-full bg-yellow-500"></div>
                    <div class="w-3 h-3 rounded-full bg-green-500"></div>
                </div>
                <img src="/static/img/dash-screen.png" alt="SeproWAF Dashboard" class="w-full rounded" />
            </div>
        </div>
    </div>
</div>

<!-- Features Section -->
<div class="bg-slate-100 py-24" id="features">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-20">
            <h2 class="text-3xl font-bold text-slate-800">Advanced Web Protection Features</h2>
            <p class="mt-4 text-xl text-slate-600 max-w-3xl mx-auto">
                SeproWAF provides comprehensive protection against the most critical web application security risks.
            </p>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-8">
            <!-- Feature 1 -->
            <div class="bg-white p-8 rounded-xl shadow-sm hover:shadow-md transition-shadow duration-300">
                <div class="w-14 h-14 rounded-full bg-blue-600 text-white flex items-center justify-center mb-5">
                    <i class="bi bi-shield-check text-2xl"></i>
                </div>
                <h3 class="text-xl font-semibold text-slate-800 mb-3">OWASP Top 10 Protection</h3>
                <p class="text-slate-600">Defend against SQL injection, XSS, CSRF, and other critical vulnerabilities with proven rule sets based on OWASP Core Rule Set.</p>
            </div>
            
            <!-- Feature 2 -->
            <div class="bg-white p-8 rounded-xl shadow-sm hover:shadow-md transition-shadow duration-300">
                <div class="w-14 h-14 rounded-full bg-blue-600 text-white flex items-center justify-center mb-5">
                    <i class="bi bi-speedometer2 text-2xl"></i>
                </div>
                <h3 class="text-xl font-semibold text-slate-800 mb-3">Real-time Threat Detection</h3>
                <p class="text-slate-600">Monitor and analyze traffic in real time with detailed logs and instant notifications about potential security incidents.</p>
            </div>
            
            <!-- Feature 3 -->
            <div class="bg-white p-8 rounded-xl shadow-sm hover:shadow-md transition-shadow duration-300">
                <div class="w-14 h-14 rounded-full bg-blue-600 text-white flex items-center justify-center mb-5">
                    <i class="bi bi-gear text-2xl"></i>
                </div>
                <h3 class="text-xl font-semibold text-slate-800 mb-3">Custom Rule Management</h3>
                <p class="text-slate-600">Create and manage custom security rules tailored to your specific application requirements and security needs.</p>
            </div>
        </div>
    </div>
</div>

<!-- Testimonials Section -->
<div class="bg-white py-24">
    <div class="max-w-7xl mx-auto px-4">
        <div class="text-center mb-16">
            <h2 class="text-3xl font-bold text-slate-800 mb-4">Trusted by Security Professionals</h2>
            <p class="text-xl text-slate-600 max-w-3xl mx-auto">
                Security teams rely on SeproWAF for robust protection against evolving threats.
            </p>
        </div>
        
        <div class="grid md:grid-cols-3 gap-8">
            <!-- Testimonials remain the same - they're already relevant to the project -->
            <!-- Testimonial 1 -->
            <div class="bg-slate-50 p-6 rounded-xl shadow-sm">
                <div class="flex items-center mb-4">
                    <div class="text-yellow-400 flex">
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                    </div>
                </div>
                <p class="text-slate-600 italic mb-4">"SeproWAF saved our company from multiple attacks. Easy to set up and the real-time notifications are a game-changer."</p>
                <div class="flex items-center">
                    <div class="font-medium text-slate-800">Sarah Johnson</div>
                    <div class="mx-2">•</div>
                    <div class="text-slate-500">Security Engineer</div>
                </div>
            </div>
            
            <!-- Testimonial 2 -->
            <div class="bg-slate-50 p-6 rounded-xl shadow-sm">
                <div class="flex items-center mb-4">
                    <div class="text-yellow-400 flex">
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                    </div>
                </div>
                <p class="text-slate-600 italic mb-4">"The simplicity of managing multiple sites while maintaining robust security makes this WAF solution perfect for our clients."</p>
                <div class="flex items-center">
                    <div class="font-medium text-slate-800">Michael Chen</div>
                    <div class="mx-2">•</div>
                    <div class="text-slate-500">DevOps Lead</div>
                </div>
            </div>
            
            <!-- Testimonial 3 -->
            <div class="bg-slate-50 p-6 rounded-xl shadow-sm">
                <div class="flex items-center mb-4">
                    <div class="text-yellow-400 flex">
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                    </div>
                </div>
                <p class="text-slate-600 italic mb-4">"We've reduced our security incidents by 87% since implementing SeproWAF. The custom rules feature is incredibly powerful."</p>
                <div class="flex items-center">
                    <div class="font-medium text-slate-800">Alex Rodriguez</div>
                    <div class="mx-2">•</div>
                    <div class="text-slate-500">CTO, TechSecure</div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- CTA Section -->
<div class="bg-blue-600 py-16">
    <div class="max-w-7xl mx-auto px-4 text-center">
        <h2 class="text-3xl font-bold text-white mb-4">Ready to secure your applications?</h2>
        <p class="text-blue-100 text-lg mb-8 max-w-3xl mx-auto">Join thousands of organizations that trust SeproWAF to protect their web applications from emerging threats.</p>
        <div class="flex flex-col sm:flex-row justify-center gap-4">
            <a href="/auth/register" class="inline-block bg-white hover:bg-gray-100 text-blue-600 font-medium px-8 py-3 rounded-lg transition-colors duration-200">Start Free Trial</a>
            <a href="#features" class="inline-block bg-blue-700 hover:bg-blue-800 text-white font-medium px-8 py-3 rounded-lg transition-colors duration-200">Learn More</a>
        </div>
    </div>
</div>