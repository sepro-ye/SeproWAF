<div class="max-w-7xl mx-auto px-4 py-12 md:py-16 my-8">
    <div class="grid md:grid-cols-2 gap-8 items-center">
        <!-- Hero Text Content -->
        <div class="text-center md:text-left">
            <h1 class="text-4xl md:text-5xl font-bold text-slate-800 leading-tight mb-4">Web Application Firewall as a Service</h1>
            <p class="text-lg md:text-xl text-slate-600 mb-8">
                Protect your web applications from attacks with our easy-to-use WAF. Deploy in minutes, get instant protection against SQL injection, XSS, and other common threats.
            </p>
            <div class="flex flex-col sm:flex-row gap-3 justify-center md:justify-start">
                {{if .IsAuthenticated}}
                <a href="/dashboard" class="inline-block bg-blue-600 hover:bg-blue-700 text-white font-medium px-6 py-3 rounded-lg transition-colors duration-200">Dashboard</a>
                <a href="/waf/sites" class="inline-block bg-white hover:bg-gray-100 text-gray-700 border border-gray-300 font-medium px-6 py-3 rounded-lg transition-colors duration-200">Manage Sites</a>
                {{else}}
                <a href="/auth/register" class="inline-block bg-blue-600 hover:bg-blue-700 text-white font-medium px-6 py-3 rounded-lg transition-colors duration-200">Get Started</a>
                <a href="/auth/login" class="inline-block bg-white hover:bg-gray-100 text-gray-700 border border-gray-300 font-medium px-6 py-3 rounded-lg transition-colors duration-200">Login</a>
                {{end}}
            </div>
        </div>
        <!-- Hero Image -->
        <div class="mt-8 md:mt-0">
            <img src="/static/img/waf-illustration.svg" class="max-w-full h-auto mx-auto" alt="WAF Illustration" width="700" height="500" loading="lazy">
        </div>
    </div>
</div>

<!-- Features Section -->
<div class="max-w-7xl mx-auto px-4 py-12" id="features">
    <h2 class="text-3xl font-bold text-center md:text-left text-slate-800 pb-3 border-b border-gray-200 mb-10">Key Features</h2>
    
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-8">
        <!-- Feature 1 -->
        <div class="bg-white p-6 rounded-xl shadow-sm hover:shadow-md transition-shadow duration-300">
            <div class="w-14 h-14 rounded-full bg-blue-600 text-white flex items-center justify-center mb-5">
                <i class="bi bi-shield-check text-2xl"></i>
            </div>
            <h3 class="text-xl font-semibold text-slate-800 mb-3">Protection Against Attacks</h3>
            <p class="text-slate-600">Guard against OWASP Top 10 vulnerabilities including SQL injection, XSS, CSRF, and more.</p>
        </div>
        
        <!-- Feature 2 -->
        <div class="bg-white p-6 rounded-xl shadow-sm hover:shadow-md transition-shadow duration-300">
            <div class="w-14 h-14 rounded-full bg-blue-600 text-white flex items-center justify-center mb-5">
                <i class="bi bi-speedometer2 text-2xl"></i>
            </div>
            <h3 class="text-xl font-semibold text-slate-800 mb-3">Real-time Monitoring</h3>
            <p class="text-slate-600">Get instant notifications about attacks and monitor your applications' traffic in real-time.</p>
        </div>
        
        <!-- Feature 3 -->
        <div class="bg-white p-6 rounded-xl shadow-sm hover:shadow-md transition-shadow duration-300">
            <div class="w-14 h-14 rounded-full bg-blue-600 text-white flex items-center justify-center mb-5">
                <i class="bi bi-gear text-2xl"></i>
            </div>
            <h3 class="text-xl font-semibold text-slate-800 mb-3">Easy Management</h3>
            <p class="text-slate-600">Simple interface to manage protected sites, security rules, and view comprehensive logs.</p>
        </div>
    </div>
</div>

<!-- Testimonials Section -->
<div class="bg-gray-50 py-16">
    <div class="max-w-7xl mx-auto px-4">
        <h2 class="text-3xl font-bold text-center text-slate-800 mb-12">Trusted by Security Professionals</h2>
        
        <div class="grid md:grid-cols-3 gap-8">
            <!-- Testimonial 1 -->
            <div class="bg-white p-6 rounded-xl shadow-sm">
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
            <div class="bg-white p-6 rounded-xl shadow-sm">
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
            <div class="bg-white p-6 rounded-xl shadow-sm">
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
<div class="max-w-7xl mx-auto px-4 py-16">
    <div class="bg-blue-600 rounded-2xl shadow-xl p-8 md:p-12 text-center">
        <h2 class="text-3xl font-bold text-white mb-4">Ready to secure your applications?</h2>
        <p class="text-blue-100 text-lg mb-8 max-w-3xl mx-auto">Join thousands of organizations that trust SeproWAF to protect their web applications from emerging threats.</p>
        <div class="flex flex-col sm:flex-row justify-center gap-4">
            <a href="/auth/register" class="inline-block bg-white hover:bg-gray-100 text-blue-600 font-medium px-8 py-3 rounded-lg transition-colors duration-200">Start Free Trial</a>
            <a href="#features" class="inline-block bg-blue-700 hover:bg-blue-800 text-white font-medium px-8 py-3 rounded-lg transition-colors duration-200">Learn More</a>
        </div>
    </div>
</div>