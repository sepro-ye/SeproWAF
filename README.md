# SeproWAF

**SeproWAF** is a Web Application Firewall (WAF) built using the [Beego](https://beego.me/) framework in Go. It provides robust security capabilities including authentication, user management, site protection, SSL-enabled proxying, and WAF filtering powered by [Coraza](https://www.coraza.io/).

---

## 🚀 Features

- JWT-based user authentication  
- Role-based access control (Admin & User roles)  
- RESTful API structure  
- User and site management system  
- MySQL database integration  
- Optional reverse proxy with SSL support  
- WAF integration using Coraza (Core Rule Set powered)

---

## 📦 Prerequisites

Make sure you have the following installed:

- Go `v1.23+`  
- MySQL Server  
- Git  

---

## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/sepro-ye/SeproWAF.git
   cd SeproWAF

   git submodule update --init --recursive
   ```

2. **Install Go dependencies**
   ```bash
   go mod tidy
   ```

3. **Configure the database and JWT in `app.conf`**
   ```
   MYSQL_USER=your_db_user
   MYSQL_PASSWORD=your_db_password
   MYSQL_HOST=localhost
   MYSQL_PORT=3306
   MYSQL_DATABASE=sepro_waf

   JWTSecret=your-secret-key-here

   # Proxy configuration
   ProxyPort = 8080
   ProxyHTTPSPort = 8443

   # WAF configuration
   WAFRulesDir = rules/
   WAFLogDir = logs/waf
   ```

---

## 🗄️ Database Setup

Use the `wafdb` tool to initialize and manage the database.

1. **Run migrations**
   ```bash
   go run cmd/wafdb/main.go --migrate
   ```

2. **Create an admin user**
   ```bash
   go run main.go --create-admin \
     --admin-user=admin \
     --admin-email=admin@example.com \
     --admin-pass=admin
   ```

---

## ▶️ Running the Application

Start the server using:

```bash
bee run
```

The app will be available at:  
👉 **http://localhost:8000**

---

## 📡 API Endpoints

### 🔐 Authentication
- `POST /api/auth/register` – Register a new user  
- `POST /api/auth/login` – Login  
- `POST /api/auth/logout` – Logout *(Requires authentication)*

### 👤 User Management
- `GET /api/user/profile` – Get current user profile *(Auth required)*  
- `GET /api/user/:id` – Get a specific user *(Auth required)*  
- `PUT /api/user/:id` – Update a user *(Auth required)*  
- `DELETE /api/user/:id/delete` – Delete a user *(Admin only)*  
- `GET /api/users` – List all users *(Admin only)*

### 🌐 Site Management
- `GET /api/sites` – List all sites *(Auth required)*  
- `POST /api/sites` – Create a new site  
- `GET /api/sites/:id` – Get site details  
- `PUT /api/sites/:id` – Update a site  
- `DELETE /api/sites/:id` – Delete a site  
- `POST /api/sites/:id/toggle-status` – Enable/disable a site  
- `POST /api/sites/:id/toggle-waf` – Enable/disable WAF for a site  
- `GET /api/sites/:id/stats` – View site stats (e.g., requests blocked)

### 🔐 SSL Certificate Management
- `GET /api/certificates` – List uploaded certificates  
- `POST /api/certificates` – Upload a new certificate  
- `GET /api/certificates/:id` – View a certificate  
- `DELETE /api/certificates/:id` – Delete a certificate

---

## 🧑‍💻 UI Views

Accessible through a browser at `http://localhost:8000`:

- `/` – Home page  
- `/auth/login` – Login page  
- `/auth/register` – Register page  
- `/dashboard` – User/admin dashboard  
- `/user/profile` – View user profile  
- `/admin/users` – Admin-only user list

### 🔧 Site Management UI
- `/waf/sites` – List of protected sites  
- `/waf/sites/new` – Add a new site  
- `/waf/sites/:id` – View site details  
- `/waf/sites/:id/edit` – Edit site configuration

### 🔐 Certificate Management UI
- `/waf/certificates` – Uploaded SSL certificates  
- `/waf/certificates/upload` – Upload new certificate

---

## 🛡️ WAF & Proxy (Optional)

SeproWAF includes an integrated **reverse proxy** to forward traffic to backend apps while enforcing security policies via **Coraza WAF**.

- Core Rule Set (CRS) is included via Git submodule (`rules/coreruleset/`)
- SSL termination and forwarding supported (via uploaded certs)
- WAF rules are evaluated before forwarding requests
- Toggle WAF per site using the API or UI

---

## 🗂️ Project Structure

```
SeproWAF/
├── cmd/             # Command-line tools
│   └── wafdb/       # Database setup & migrations
├── conf/            # Configuration files
├── controllers/     # Route handlers (UI & API)
├── database/        # DB initialization and queries
├── middleware/      # JWT & RBAC middleware
├── models/          # Data models and ORM logic
├── routers/         # Beego router definitions
├── static/          # Static assets (JS, CSS, etc.)
├── tests/           # Unit and integration tests
├── views/           # HTML templates for UI
├── proxy/           # WAF engine and reverse proxy logic
├── rules/           # CoreRuleSet (as a submodule)
├── go.mod           # Go module file
├── go.sum           # Dependency checksums
└── main.go          # App entry point
```

---

## 🧪 Development

Run all tests using:

```bash
go test ./...
```

---
Test commit and push
Test commit and push 2

```