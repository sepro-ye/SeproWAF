package models

import (
	"time"

	"github.com/beego/beego/v2/client/orm"
)

// Certificate represents an SSL/TLS certificate
type Certificate struct {
	ID          int       `orm:"pk;auto"`
	Name        string    `orm:"size(128)"`
	Domain      string    `orm:"size(255)"`
	Certificate string    `orm:"type(text)"` // PEM encoded certificate
	PrivateKey  string    `orm:"type(text)"` // PEM encoded private key
	IssuedBy    string    `orm:"size(255)"`  // Certificate issuer
	NotBefore   time.Time // Validity start date
	NotAfter    time.Time // Expiration date
	UserID      int       `orm:"column(user_id)"`
	CreatedAt   time.Time `orm:"auto_now_add"`
	UpdatedAt   time.Time `orm:"auto_now"`
}

// TableName provides the name of the table
func (c *Certificate) TableName() string {
	return "certificates"
}

func init() {
	orm.RegisterModel(new(Certificate))
}

// GetCertificateByID returns a certificate by its ID
func GetCertificateByID(id int) (*Certificate, error) {
	o := orm.NewOrm()
	cert := &Certificate{ID: id}
	err := o.Read(cert)
	return cert, err
}

// GetCertificatesByUserID returns all certificates owned by a user
func GetCertificatesByUserID(userID int) ([]*Certificate, error) {
	var certs []*Certificate
	o := orm.NewOrm()
	_, err := o.QueryTable(new(Certificate).TableName()).Filter("user_id", userID).All(&certs)
	return certs, err
}

// GetCertificateByDomain returns a certificate for a specific domain
func GetCertificateByDomain(domain string) (*Certificate, error) {
	o := orm.NewOrm()
	cert := &Certificate{}
	err := o.QueryTable(new(Certificate).TableName()).Filter("domain", domain).One(cert)
	return cert, err
}

// IsExpired checks if the certificate is expired
func (c *Certificate) IsExpired() bool {
	return time.Now().After(c.NotAfter)
}

// IsValid checks if the certificate is valid
func (c *Certificate) IsValid() bool {
	now := time.Now()
	return now.After(c.NotBefore) && now.Before(c.NotAfter)
}
