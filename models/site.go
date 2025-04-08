package models

import (
	"time"

	"github.com/beego/beego/v2/client/orm"
)

// SiteStatus represents the status of a protected site
type SiteStatus string

const (
	SiteStatusActive   SiteStatus = "active"
	SiteStatusInactive SiteStatus = "inactive"
	SiteStatusPending  SiteStatus = "pending"
)

// Site represents a website protected by the WAF
type Site struct {
	ID                int        `orm:"pk;auto"`
	Name              string     `orm:"size(128)"`
	Domain            string     `orm:"size(255);unique"`
	TargetURL         string     `orm:"size(255)"` // Backend server URL to proxy to
	Status            SiteStatus `orm:"size(16);default(pending)"`
	UserID            int        `orm:"column(user_id)"`                  // Owner of the site
	RequestCount      int64      `orm:"default(0)"`                       // Total requests processed
	BlockedCount      int64      `orm:"default(0)"`                       // Total requests blocked
	WAFEnabled        bool       `orm:"default(true)"`                    // Whether WAF protection is enabled
	CertificateID     *int       `orm:"column(certificate_id);null"`      // SSL certificate ID (if any)
	CustomRulesIDs    string     `orm:"column(custom_rules_ids);null"`    // Comma-separated list of custom rule IDs
	EnabledRulesetIDs string     `orm:"column(enabled_ruleset_ids);null"` // Comma-separated list of enabled ruleset IDs
	Settings          string     `orm:"type(text);null"`                  // JSON-encoded settings
	CreatedAt         time.Time  `orm:"auto_now_add"`
	UpdatedAt         time.Time  `orm:"auto_now"`
}

// TableName provides the name of the table
func (s *Site) TableName() string {
	return "sites"
}

func init() {
	orm.RegisterModel(new(Site))
}

// GetSitesByUserID returns all sites owned by a user
func GetSitesByUserID(userID int) ([]*Site, error) {
	var sites []*Site
	o := orm.NewOrm()
	_, err := o.QueryTable(new(Site).TableName()).Filter("user_id", userID).All(&sites)
	return sites, err
}

// GetSiteByID returns a site by its ID
func GetSiteByID(id int) (*Site, error) {
	o := orm.NewOrm()
	site := &Site{ID: id}
	err := o.Read(site)
	return site, err
}

// GetSiteByDomain returns a site by its domain
func GetSiteByDomain(domain string) (*Site, error) {
	o := orm.NewOrm()
	site := &Site{}
	err := o.QueryTable(new(Site).TableName()).Filter("domain", domain).One(site)
	return site, err
}

// CanUserManageSite checks if a user has permission to manage this site
func (s *Site) CanUserManageSite(userID int, userRole Role) bool {
	// Admin can manage any site
	if userRole == RoleAdmin {
		return true
	}

	// Regular users can only manage their own sites
	return s.UserID == userID
}

// IncrementRequestCount increments the request counter
func (s *Site) IncrementRequestCount() error {
	o := orm.NewOrm()
	s.RequestCount++
	_, err := o.Update(s, "RequestCount")
	return err
}

// IncrementBlockedCount increments the blocked request counter
func (s *Site) IncrementBlockedCount() error {
	o := orm.NewOrm()
	s.BlockedCount++
	_, err := o.Update(s, "BlockedCount")
	return err
}

// GetCertificate returns the SSL certificate for this site, if any
func (s *Site) GetCertificate() (*Certificate, error) {
	if s.CertificateID == nil {
		return nil, nil
	}

	return GetCertificateByID(*s.CertificateID)
}

// HasValidCertificate checks if the site has a valid certificate
// This is a simple check without loading the certificate
func (s *Site) HasValidCertificate() bool {
	return s.CertificateID != nil
}
