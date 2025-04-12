package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"text/template"

	"SeproWAF/models"

	"github.com/beego/beego/v2/core/logs"
)

// RuleTemplate defines a template for generating ModSecurity rules
type RuleTemplate struct {
	ID             string
	Name           string
	Description    string
	Template       string
	RequiredParams []string
}

// RuleGenerator generates ModSecurity rules from templates
type RuleGenerator struct {
	templates map[models.WAFRuleType]map[string]*template.Template
}

// NewRuleGenerator creates a new rule generator
func NewRuleGenerator() *RuleGenerator {
	rg := &RuleGenerator{
		templates: make(map[models.WAFRuleType]map[string]*template.Template),
	}

	// Initialize IP block template
	ipBlockTemplateStr := `SecRule REMOTE_ADDR "@ipMatch {{.ipAddress}}" "id:{{.ruleId}},phase:1,{{.action}},status:403,log,msg:'IP blocked: {{.ipAddress}}',tag:'CUSTOM-RULE',tag:'IP-BLOCK'"`
	ipBlockTmpl, err := template.New("ip_block").Parse(ipBlockTemplateStr)
	if err != nil {
		logs.Error("Failed to parse IP block template: %v", err)
	} else {
		rg.RegisterTemplate(models.IPBlockRule, "ip_block", ipBlockTmpl)
	}

	// Initialize rate limiting template
	rateLimitTemplateStr := `SecRule REMOTE_ADDR "." "id:{{.ruleId}}1,phase:1,pass,nolog,setvar:tx.{{.ruleId}}_counter=+1,expirevar:tx.{{.ruleId}}_counter={{.timeWindow}}"
	SecRule TX:{{.ruleId}}_counter "@gt {{.requestLimit}}" "id:{{.ruleId}}2,phase:1,{{.action}},status:429,log,msg:'Rate limit exceeded: {{.requestLimit}} requests in {{.timeWindow}} seconds',tag:'CUSTOM-RULE',tag:'RATE-LIMIT'"`
	rateLimitTmpl, err := template.New("rate_limit").Parse(rateLimitTemplateStr)
	if err != nil {
		logs.Error("Failed to parse rate limit template: %v", err)
	} else {
		rg.RegisterTemplate(models.RateLimitRule, "rate_limit", rateLimitTmpl)
	}

	// Initialize SQLi detection template
	sqliTemplateStr := `SecRule {{.target}} "@rx {{.pattern}}" "id:{{.ruleId}},phase:2,{{.action}},status:403,log,msg:'SQL injection attempt detected',tag:'CUSTOM-RULE',tag:'SQLI'"`
	sqliTmpl, err := template.New("sqli").Parse(sqliTemplateStr)
	if err != nil {
		logs.Error("Failed to parse SQLi template: %v", err)
	} else {
		rg.RegisterTemplate(models.SQLiRule, "sqli", sqliTmpl)
	}

	// Initialize XSS detection template
	xssTemplateStr := `SecRule {{.target}} "@rx {{.pattern}}" "id:{{.ruleId}},phase:2,{{.action}},status:403,log,msg:'XSS attempt detected',tag:'CUSTOM-RULE',tag:'XSS'"`
	xssTmpl, err := template.New("xss").Parse(xssTemplateStr)
	if err != nil {
		logs.Error("Failed to parse XSS template: %v", err)
	} else {
		rg.RegisterTemplate(models.XSSRule, "xss", xssTmpl)
	}

	// Initialize path traversal template
	pathTraversalTemplateStr := `SecRule {{.target}} "@rx {{.pattern}}" "id:{{.ruleId}},phase:1,{{.action}},status:403,log,msg:'Path traversal attempt detected',tag:'CUSTOM-RULE',tag:'PATH-TRAVERSAL'"`
	pathTraversalTmpl, err := template.New("path_traversal").Parse(pathTraversalTemplateStr)
	if err != nil {
		logs.Error("Failed to parse path traversal template: %v", err)
	} else {
		rg.RegisterTemplate(models.PathTraversalRule, "path_traversal", pathTraversalTmpl)
	}

	return rg
}

// RegisterTemplate registers a template for a rule type
func (rg *RuleGenerator) RegisterTemplate(ruleType models.WAFRuleType, name string, tmpl *template.Template) {
	if _, exists := rg.templates[ruleType]; !exists {
		rg.templates[ruleType] = make(map[string]*template.Template)
	}
	rg.templates[ruleType][name] = tmpl
}

// GenerateRule generates a ModSecurity rule from a WAF rule
func (rg *RuleGenerator) GenerateRule(rule *models.WAFRule) (string, error) {
	// Handle custom rules first, before checking for templates
	if rule.Type == models.CustomRule {
		// If RuleText is empty but exists in Parameters, extract it from Parameters
		if rule.RuleText == "" && rule.Parameters != "" {
			var params map[string]interface{}
			if err := json.Unmarshal([]byte(rule.Parameters), &params); err == nil {
				if ruleText, ok := params["ruleText"].(string); ok {
					return ruleText, nil
				}
			}
		}

		// Check if RuleText is empty
		if rule.RuleText == "" {
			return "", fmt.Errorf("custom rule has no rule text")
		}

		return rule.RuleText, nil
	}

	// For non-custom rules, check for templates
	templates, exists := rg.templates[rule.Type]
	if !exists {
		return "", fmt.Errorf("no templates found for rule type: %s", rule.Type)
	}

	var params map[string]interface{}

	if rule.Parameters != "" {
		err := json.Unmarshal([]byte(rule.Parameters), &params)
		if err != nil {
			// Try nested unmarshal if stringified JSON
			var quoted string
			if err := json.Unmarshal([]byte(rule.Parameters), &quoted); err == nil {
				if err := json.Unmarshal([]byte(quoted), &params); err != nil {
					return "", fmt.Errorf("invalid rule parameters: %v", err)
				}
			} else {
				return "", fmt.Errorf("invalid rule parameters: %v", err)
			}
		}
	} else {
		params = make(map[string]interface{})
	}

	// Add common parameters
	params["ruleId"] = rule.ID + 100000
	params["action"] = rule.Action

	var tmpl *template.Template
	switch rule.Type {
	case models.IPBlockRule:
		tmpl = templates["ip_block"]
	case models.RateLimitRule:
		tmpl = templates["rate_limit"]
	case models.SQLiRule:
		tmpl = templates["sqli"]
	case models.XSSRule:
		tmpl = templates["xss"]
	case models.PathTraversalRule:
		tmpl = templates["path_traversal"]
	default:
		return "", fmt.Errorf("unknown rule type: %s", rule.Type)
	}

	if tmpl == nil {
		return "", fmt.Errorf("template not found for rule type: %s", rule.Type)
	}

	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, params); err != nil {
		return "", fmt.Errorf("failed to generate rule: %v", err)
	}

	return buf.String(), nil
}

// ValidateRuleParameters validates rule parameters
func (rg *RuleGenerator) ValidateRuleParameters(rule *models.WAFRule) error {
	// Custom rule check
	fmt.Println("Validating rule parameters for rule type:", rule.Type)
	fmt.Println("Rule:", rule)
	fmt.Println("RuleText:", rule.RuleText)
	fmt.Println("Parameters:", rule.Parameters)

	if rule.Type == models.CustomRule {
		// Check for rule text directly or in parameters
		if rule.RuleText == "" {
			// Try to extract rule text from Parameters
			var params map[string]interface{}
			if rule.Parameters != "" {
				if err := json.Unmarshal([]byte(rule.Parameters), &params); err == nil {
					if ruleText, ok := params["ruleText"].(string); ok && ruleText != "" {
						// If found in parameters, copy it to RuleText for consistency
						rule.RuleText = ruleText
						fmt.Println("Extracted rule text from parameters:", ruleText)
						fmt.Println("RuleText after extraction:", rule.RuleText)
						return nil
					}
				}
			}
			return fmt.Errorf("custom rule requires rule text")
		}
		return nil
	}

	// Check Parameters string
	if rule.Parameters == "" {
		return fmt.Errorf("missing parameters for rule type: %s", rule.Type)
	}

	var params map[string]interface{}

	// Handle rule.Params
	if rule.Params != nil {
		switch v := rule.Params.(type) {
		case map[string]interface{}:
			params = v
		case map[string]string:
			converted := make(map[string]interface{}, len(v))
			for k, val := range v {
				converted[k] = val
			}
			params = converted
		case string:
			if err := json.Unmarshal([]byte(v), &params); err != nil {
				return fmt.Errorf("invalid rule parameters: %v", err)
			}
		default:
			data, err := json.Marshal(v)
			if err != nil {
				return fmt.Errorf("invalid rule parameters: cannot marshal: %v", err)
			}
			if err := json.Unmarshal(data, &params); err != nil {
				return fmt.Errorf("invalid rule parameters: cannot unmarshal: %v", err)
			}
		}
	} else {
		// Try to parse Parameters directly
		if err := json.Unmarshal([]byte(rule.Parameters), &params); err != nil {
			// Try to unmarshal as quoted string
			var quoted string
			if e := json.Unmarshal([]byte(rule.Parameters), &quoted); e == nil {
				if e := json.Unmarshal([]byte(quoted), &params); e != nil {
					return fmt.Errorf("invalid rule parameters: nested JSON parse failed: %v", e)
				}
			} else {
				return fmt.Errorf("invalid rule parameters: %v", err)
			}
		}
	}

	// Rule type specific validation
	switch rule.Type {
	case models.IPBlockRule:
		if _, ok := params["ipAddress"]; !ok {
			return fmt.Errorf("IP block rule requires an ipAddress parameter")
		}
	case models.RateLimitRule:
		if _, ok := params["requestLimit"]; !ok {
			return fmt.Errorf("rate limit rule requires a requestLimit parameter")
		}
		if _, ok := params["timeWindow"]; !ok {
			return fmt.Errorf("rate limit rule requires a timeWindow parameter")
		}
	case models.SQLiRule, models.XSSRule, models.PathTraversalRule:
		if _, ok := params["target"]; !ok {
			return fmt.Errorf("%s rule requires a target parameter", rule.Type)
		}
		if _, ok := params["pattern"]; !ok {
			return fmt.Errorf("%s rule requires a pattern parameter", rule.Type)
		}
	default:
		return fmt.Errorf("unknown rule type: %s", rule.Type)
	}

	return nil
}
