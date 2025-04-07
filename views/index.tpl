<div class="container px-4 py-5 my-5 text-center">
    <div class="row align-items-center g-5 py-5">
        <div class="col-lg-6">
            <h1 class="display-5 fw-bold text-body-emphasis lh-1 mb-3">Web Application Firewall as a Service</h1>
            <p class="lead mb-4">
                Protect your web applications from attacks with our easy-to-use WAF. Deploy in minutes, get instant protection against SQL injection, XSS, and other common threats.
            </p>
            <div class="d-grid gap-2 d-md-flex justify-content-md-start">
                {{if .IsAuthenticated}}
                <a href="/dashboard" class="btn btn-primary btn-lg px-4 me-md-2">Dashboard</a>
                <a href="/waf/sites" class="btn btn-outline-secondary btn-lg px-4">Manage Sites</a>
                {{else}}
                <a href="/auth/register" class="btn btn-primary btn-lg px-4 me-md-2">Get Started</a>
                <a href="/auth/login" class="btn btn-outline-secondary btn-lg px-4">Login</a>
                {{end}}
            </div>
        </div>
        <div class="col-lg-6">
            <img src="/static/img/waf-illustration.svg" class="d-block mx-lg-auto img-fluid" alt="WAF Illustration" width="700" height="500" loading="lazy">
        </div>
    </div>
</div>

<div class="container px-4 py-5" id="featured-3">
    <h2 class="pb-2 border-bottom">Key Features</h2>
    <div class="row g-4 py-5 row-cols-1 row-cols-lg-3">
        <div class="feature col">
            <div class="feature-icon bg-primary bg-gradient">
                <i class="bi bi-shield-check"></i>
            </div>
            <h3>Protection Against Attacks</h3>
            <p>Guard against OWASP Top 10 vulnerabilities including SQL injection, XSS, CSRF, and more.</p>
        </div>
        <div class="feature col">
            <div class="feature-icon bg-primary bg-gradient">
                <i class="bi bi-speedometer2"></i>
            </div>
            <h3>Real-time Monitoring</h3>
            <p>Get instant notifications about attacks and monitor your applications' traffic in real-time.</p>
        </div>
        <div class="feature col">
            <div class="feature-icon bg-primary bg-gradient">
                <i class="bi bi-gear"></i>
            </div>
            <h3>Easy Management</h3>
            <p>Simple interface to manage protected sites, security rules, and view comprehensive logs.</p>
        </div>
    </div>
</div>