package models

import (
	"time"

	"github.com/beego/beego/v2/client/orm"
)

// WAFLog represents a WAF security event log
type WAFLog struct {
	ID              int    `orm:"auto;pk"`
	TransactionID   string `orm:"size(64);index"`
	SiteID          int    `orm:"index"`
	Domain          string `orm:"size(255);index"`
	ClientIP        string `orm:"size(45);index"`
	Method          string `orm:"size(10);index"`
	URI             string `orm:"size(1024)"`
	QueryString     string `orm:"type(text);null"`
	Protocol        string `orm:"size(20)"`
	UserAgent       string `orm:"size(512)"`
	Referer         string `orm:"type(longtext);null"` // Change from size(1024) to type(text)
	JA4Fingerprint  string `orm:"size(64);index;null"`
	Action          string `orm:"size(20);index"` // allowed, blocked, monitored
	StatusCode      int    `orm:"index"`
	BlockStatusCode int    `orm:"index;null"` // Status code used when blocking
	ResponseSize    int64
	MatchedRules    string    `orm:"type(text);null"`     // JSON-encoded matched rules
	Severity        string    `orm:"size(20);index;null"` // critical, high, medium, low
	Category        string    `orm:"size(50);index;null"` // SQLi, XSS, etc.
	ProcessingTime  int       // Processing time in milliseconds
	CreatedAt       time.Time `orm:"auto_now_add;type(datetime);index"`
}

// WAFLogDetail represents detailed information about a WAF log entry
type WAFLogDetail struct {
	ID            int64  `orm:"auto"`
	WAFLogID      int64  `orm:"column(waf_log_id)"`
	TransactionID string `orm:"column(transaction_id);size(64)"`
	DetailType    string `orm:"column(detail_type);size(50)"`
	Content       string `orm:"column(content);type(text)"`
}

func init() {
	orm.RegisterModel(new(WAFLog), new(WAFLogDetail))
}
