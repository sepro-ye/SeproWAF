package models

import (
	"encoding/json"
	"time"

	"github.com/beego/beego/v2/client/orm"
)

func init() {
	orm.RegisterModel(new(WAFRule))
}

// WAFRuleType defines the type of WAF rule
type WAFRuleType string

const (
	// Rule types
	IPBlockRule       WAFRuleType = "IP_BLOCK"
	RateLimitRule     WAFRuleType = "RATE_LIMIT"
	SQLiRule          WAFRuleType = "SQLI"
	XSSRule           WAFRuleType = "XSS"
	PathTraversalRule WAFRuleType = "PATH_TRAVERSAL"
	CustomRule        WAFRuleType = "CUSTOM"
)

// WAFRuleAction defines possible actions for WAF rules
type WAFRuleAction string

const (
	ActionBlock WAFRuleAction = "block"
	ActionAllow WAFRuleAction = "allow"
	ActionLog   WAFRuleAction = "log"
)

// WAFRuleStatus defines the status of a WAF rule
type WAFRuleStatus string

const (
	StatusEnabled  WAFRuleStatus = "enabled"
	StatusDisabled WAFRuleStatus = "disabled"
)

// WAFRule represents a custom WAF rule
type WAFRule struct {
	ID          int           `orm:"auto;pk" json:"id"`
	SiteID      int           `orm:"column(site_id)" json:"siteId"`
	Name        string        `orm:"size(100)" json:"name"`
	Description string        `orm:"type(text);null" json:"description"`
	Type        WAFRuleType   `orm:"size(20)" json:"type"`
	Action      WAFRuleAction `orm:"size(20)" json:"action"`
	Status      WAFRuleStatus `orm:"size(20);default(enabled)" json:"status"`
	Parameters  string        `orm:"type(jsonb)" json:"-"` // Stored as JSON in database
	Params      interface{}   `orm:"-" json:"parameters"`  // Used for JSON marshaling/unmarshaling
	RuleText    string        `orm:"type(text)" json:"ruleText,omitempty"`
	Priority    int           `orm:"default(100)" json:"priority"`
	CreatedAt   time.Time     `orm:"auto_now_add;type(datetime)" json:"createdAt"`
	UpdatedAt   time.Time     `orm:"auto_now;type(datetime)" json:"updatedAt"`
	CreatedBy   int           `orm:"column(created_by)" json:"createdBy"`
}

// TableName returns the table name for the model
func (r *WAFRule) TableName() string {
	return "waf_rules"
}

// MarshalJSON customizes the JSON output
func (r *WAFRule) MarshalJSON() ([]byte, error) {
	type Alias WAFRule

	if r.Parameters != "" {
		var params interface{}
		if err := json.Unmarshal([]byte(r.Parameters), &params); err != nil {
			return nil, err
		}
		r.Params = params
	}

	return json.Marshal(&struct {
		*Alias
	}{
		Alias: (*Alias)(r),
	})
}

// UnmarshalJSON customizes JSON parsing
func (r *WAFRule) UnmarshalJSON(data []byte) error {
	type Alias WAFRule
	aux := &struct {
		*Alias
	}{
		Alias: (*Alias)(r),
	}

	if err := json.Unmarshal(data, &aux); err != nil {
		return err
	}

	if r.Params != nil {
		params, err := json.Marshal(r.Params)
		if err != nil {
			return err
		}
		r.Parameters = string(params)
	}

	return nil
}

// GetWAFRules retrieves all WAF rules for a site
func GetWAFRules(siteID int) ([]*WAFRule, error) {
	o := orm.NewOrm()
	var rules []*WAFRule

	_, err := o.QueryTable(new(WAFRule)).
		Filter("site_id", siteID).
		OrderBy("-priority", "id").
		All(&rules)

	if err != nil {
		return nil, err
	}

	return rules, nil
}

// GetWAFRuleByID retrieves a WAF rule by ID
func GetWAFRuleByID(id int) (*WAFRule, error) {
	o := orm.NewOrm()
	rule := WAFRule{ID: id}

	err := o.Read(&rule)
	if err != nil {
		return nil, err
	}

	return &rule, nil
}

// GetActiveWAFRules retrieves all active WAF rules for a site
func GetActiveWAFRules(siteID int) ([]*WAFRule, error) {
	o := orm.NewOrm()
	var rules []*WAFRule

	_, err := o.QueryTable(new(WAFRule)).
		Filter("site_id", siteID).
		Filter("status", StatusEnabled).
		OrderBy("-priority", "id").
		All(&rules)

	if err != nil {
		return nil, err
	}

	return rules, nil
}

// InsertWAFRule inserts a new WAF rule
func InsertWAFRule(rule *WAFRule) error {
	o := orm.NewOrm()
	_, err := o.Insert(rule)
	return err
}

// UpdateWAFRule updates an existing WAF rule
func UpdateWAFRule(rule *WAFRule) error {
	o := orm.NewOrm()
	_, err := o.Update(rule)
	return err
}

// DeleteWAFRule deletes a WAF rule by ID
func DeleteWAFRule(id int) error {
	o := orm.NewOrm()
	_, err := o.Delete(&WAFRule{ID: id})
	return err
}

// ToggleWAFRuleStatus toggles a WAF rule's status
func ToggleWAFRuleStatus(id int) error {
	o := orm.NewOrm()
	rule := WAFRule{ID: id}

	if err := o.Read(&rule); err != nil {
		return err
	}

	if rule.Status == StatusEnabled {
		rule.Status = StatusDisabled
	} else {
		rule.Status = StatusEnabled
	}

	_, err := o.Update(&rule, "Status")
	return err
}
