package controllers

import (
	"SeproWAF/models"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"net/http"
	"strconv"

	"github.com/beego/beego/v2/client/orm"
	"github.com/beego/beego/v2/server/web"
)

// CertificateController handles certificate management operations
type CertificateController struct {
	web.Controller
}

// CertificateRequest represents the request body for certificate operations
type CertificateRequest struct {
	Name        string `json:"name"`
	Certificate string `json:"certificate"`
	PrivateKey  string `json:"private_key"`
}

// ListCertificates returns all certificates owned by the current user
func (c *CertificateController) ListCertificates() {
	// Get user ID from context
	userID := c.Ctx.Input.GetData("userID").(int)
	userRole := c.Ctx.Input.GetData("userRole").(models.Role)

	var certs []*models.Certificate
	o := orm.NewOrm()

	// If admin, return all certificates, otherwise only user's certificates
	if userRole == models.RoleAdmin {
		_, err := o.QueryTable(new(models.Certificate).TableName()).All(&certs)
		if err != nil {
			c.Ctx.Output.SetStatus(http.StatusInternalServerError)
			c.Data["json"] = map[string]string{"error": "Failed to fetch certificates: " + err.Error()}
			c.ServeJSON()
			return
		}
	} else {
		_, err := o.QueryTable(new(models.Certificate).TableName()).Filter("user_id", userID).All(&certs)
		if err != nil {
			c.Ctx.Output.SetStatus(http.StatusInternalServerError)
			c.Data["json"] = map[string]string{"error": "Failed to fetch certificates: " + err.Error()}
			c.ServeJSON()
			return
		}
	}

	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = certs
	c.ServeJSON()
}

// GetCertificate returns details of a specific certificate
func (c *CertificateController) GetCertificate() {
	// Get user ID from context
	userID := c.Ctx.Input.GetData("userID").(int)
	userRole := c.Ctx.Input.GetData("userRole").(models.Role)

	// Get certificate ID from URL parameter
	certID, err := strconv.Atoi(c.Ctx.Input.Param(":id"))
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid certificate ID"}
		c.ServeJSON()
		return
	}

	// Get the certificate
	cert, err := models.GetCertificateByID(certID)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusNotFound)
		c.Data["json"] = map[string]string{"error": "Certificate not found"}
		c.ServeJSON()
		return
	}

	// Check if user has permission to view the certificate
	if cert.UserID != userID && userRole != models.RoleAdmin {
		c.Ctx.Output.SetStatus(http.StatusForbidden)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = cert
	c.ServeJSON()
}

// UploadCertificate creates a new certificate
func (c *CertificateController) UploadCertificate() {
	// Get user ID from context
	userID := c.Ctx.Input.GetData("userID").(int)

	// Parse request body
	var req CertificateRequest
	if err := json.Unmarshal(c.Ctx.Input.RequestBody, &req); err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid request format"}
		c.ServeJSON()
		return
	}

	// Validate certificate and private key
	if req.Certificate == "" || req.PrivateKey == "" {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Certificate and private key are required"}
		c.ServeJSON()
		return
	}

	// Parse the certificate to extract metadata
	block, _ := pem.Decode([]byte(req.Certificate))
	if block == nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid certificate format"}
		c.ServeJSON()
		return
	}

	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Failed to parse certificate: " + err.Error()}
		c.ServeJSON()
		return
	}

	// Create the certificate record
	certificate := &models.Certificate{
		Name:        req.Name,
		Domain:      cert.Subject.CommonName,
		Certificate: req.Certificate,
		PrivateKey:  req.PrivateKey,
		IssuedBy:    cert.Issuer.CommonName,
		NotBefore:   cert.NotBefore,
		NotAfter:    cert.NotAfter,
		UserID:      userID,
	}

	// Save the certificate
	o := orm.NewOrm()
	_, err = o.Insert(certificate)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusInternalServerError)
		c.Data["json"] = map[string]string{"error": "Failed to save certificate: " + err.Error()}
		c.ServeJSON()
		return
	}

	c.Ctx.Output.SetStatus(http.StatusCreated)
	c.Data["json"] = certificate
	c.ServeJSON()
}

// DeleteCertificate deletes a certificate
func (c *CertificateController) DeleteCertificate() {
	// Get user ID from context
	userID := c.Ctx.Input.GetData("userID").(int)
	userRole := c.Ctx.Input.GetData("userRole").(models.Role)

	// Get certificate ID from URL parameter
	certID, err := strconv.Atoi(c.Ctx.Input.Param(":id"))
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Invalid certificate ID"}
		c.ServeJSON()
		return
	}

	// Get the certificate
	cert, err := models.GetCertificateByID(certID)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusNotFound)
		c.Data["json"] = map[string]string{"error": "Certificate not found"}
		c.ServeJSON()
		return
	}

	// Check if user has permission to delete the certificate
	if cert.UserID != userID && userRole != models.RoleAdmin {
		c.Ctx.Output.SetStatus(http.StatusForbidden)
		c.Data["json"] = map[string]string{"error": "Access denied"}
		c.ServeJSON()
		return
	}

	// Check if certificate is in use
	o := orm.NewOrm()
	inUse := o.QueryTable(new(models.Site).TableName()).Filter("certificate_id", certID).Exist()
	if inUse {
		c.Ctx.Output.SetStatus(http.StatusBadRequest)
		c.Data["json"] = map[string]string{"error": "Cannot delete certificate because it is in use by one or more sites"}
		c.ServeJSON()
		return
	}

	// Delete the certificate
	_, err = o.Delete(cert)
	if err != nil {
		c.Ctx.Output.SetStatus(http.StatusInternalServerError)
		c.Data["json"] = map[string]string{"error": "Failed to delete certificate: " + err.Error()}
		c.ServeJSON()
		return
	}

	c.Ctx.Output.SetStatus(http.StatusOK)
	c.Data["json"] = map[string]string{"message": "Certificate deleted successfully"}
	c.ServeJSON()
}
