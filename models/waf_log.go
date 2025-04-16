package models

import (
	"time"

	"github.com/beego/beego/v2/client/orm"
)

// WAFLog represents a WAF security event log
type WAFLog struct {
	ID              int       `orm:"auto;pk;column(id)"`
	TransactionID   string    `orm:"size(64);index;column(transaction_id)"`
	SiteID          int       `orm:"index;column(site_id)"`
	Domain          string    `orm:"size(255);index;column(domain)"`
	ClientIP        string    `orm:"size(45);index;column(client_ip)"`
	Method          string    `orm:"size(10);index;column(method)"`
	URI             string    `orm:"size(1024);column(uri)"`
	QueryString     string    `orm:"type(text);null;column(query_string)"`
	Protocol        string    `orm:"size(20);column(protocol)"`
	UserAgent       string    `orm:"size(512);column(user_agent)"`
	Referer         string    `orm:"type(longtext);null;column(referer)"`
	JA4Fingerprint  string    `orm:"size(64);index;null;column(ja4_fingerprint)"`
	Action          string    `orm:"size(20);index;column(action)"`
	StatusCode      int       `orm:"index;column(status_code)"`
	BlockStatusCode int       `orm:"index;null;column(block_status_code)"`
	ResponseSize    int64     `orm:"column(response_size)"`
	MatchedRules    string    `orm:"type(text);null;column(matched_rules)"`
	Severity        string    `orm:"size(20);index;null;column(severity)"`
	Category        string    `orm:"size(50);index;null;column(category)"`
	ProcessingTime  int       `orm:"column(processing_time)"`
	CreatedAt       time.Time `orm:"auto_now_add;type(datetime);index;column(created_at)"`
}

// TableName specifies the database table name
func (l *WAFLog) TableName() string {
	return "waf_log"
}

// WAFLogDetail represents detailed information about a WAF log entry
type WAFLogDetail struct {
	ID            int64  `orm:"auto;column(id)"`
	WAFLogID      int64  `orm:"column(waf_log_id)"`
	TransactionID string `orm:"column(transaction_id);size(64)"`
	DetailType    string `orm:"column(detail_type);size(50)"`
	Content       string `orm:"column(content);type(text)"`
}

// TableName specifies the database table name
func (d *WAFLogDetail) TableName() string {
	return "waf_log_detail"
}

func init() {
	orm.RegisterModel(new(WAFLog), new(WAFLogDetail))
}
