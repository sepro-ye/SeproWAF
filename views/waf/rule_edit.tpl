<div class="flex flex-wrap mb-4">
    <div class="md:w-1/2">
        <h1 class="text-2xl font-bold">{{if .IsEdit}}Edit{{else}}Create{{end}} WAF Rule</h1>
        <p class="text-gray-600 mt-1">{{if .IsEdit}}Modify existing rule{{else}}Configure a new security rule{{end}} for {{.Site.Domain}}</p>
    </div>
    <div class="md:w-1/2 text-right">
        <a href="/waf/sites/{{.SiteID}}/rules" class="px-4 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded inline-flex items-center">
            <i class="bi bi-arrow-left mr-2"></i> Back to Rules
        </a>
    </div>
</div>

<div class="flex flex-wrap">
    <div class="w-full">
        <div class="bg-white rounded-lg shadow mb-6">
            <div class="px-4 py-3 border-b">
                <h5 class="text-lg font-medium mb-0">
                    {{if .IsEdit}}Edit Rule: {{.Rule.Name}}{{else}}New Rule Definition{{end}}
                </h5>
            </div>
            <div id="rule-form-loading" class="text-center py-8">
                <div class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-blue-600 border-t-transparent" role="status">
                    <span class="sr-only">Loading...</span>
                </div>
                <p class="mt-2">Loading form...</p>
            </div>
            <div id="rule-form-content" class="p-4 hidden">
                <form id="ruleForm" class="space-y-6">
                    <input type="hidden" id="siteId" name="siteId" value="{{.SiteID}}">
                    {{if .IsEdit}}<input type="hidden" id="ruleId" name="id" value="{{.RuleID}}">{{end}}
                    
                    <div class="grid gap-6 md:grid-cols-2">
                        <!-- Rule Name -->
                        <div class="col-span-2">
                            <label for="ruleName" class="block text-sm font-medium text-gray-700 mb-1">
                                Rule Name <span class="text-red-500">*</span>
                            </label>
                            <div class="relative rounded-md shadow-sm">
                                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                    <i class="bi bi-tag text-gray-400"></i>
                                </div>
                                <input type="text" 
                                    class="block w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 transition" 
                                    id="ruleName" name="name" placeholder="Enter a descriptive name" required>
                            </div>
                            <p class="mt-1 text-sm text-gray-500">Use a clear name that describes what this rule protects against</p>
                        </div>

                        <!-- Rule Type -->
                        <div class="col-span-2 md:col-span-1">
                            <label for="ruleType" class="block text-sm font-medium text-gray-700 mb-1">
                                Rule Type <span class="text-red-500">*</span>
                            </label>
                            <div class="relative rounded-md shadow-sm">
                                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                    <i class="bi bi-shield text-gray-400"></i>
                                </div>
                                <select class="block w-full pl-10 pr-9 py-2.5 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 appearance-none transition" 
                                    id="ruleType" name="type" {{if .IsEdit}}disabled{{end}} required>
                                    <option value="">Select a rule type...</option>
                                    <!-- Rule types will be loaded here via JavaScript -->
                                </select>
                                <div class="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
                                    <i class="bi bi-chevron-down text-gray-400"></i>
                                </div>
                            </div>
                            <p id="typeDescription" class="mt-1 text-sm text-gray-500">Select the type of protection you want to implement</p>
                        </div>
                        
                        <!-- Rule Action -->
                        <div class="col-span-2 md:col-span-1">
                            <label for="ruleAction" class="block text-sm font-medium text-gray-700 mb-1">
                                Action <span class="text-red-500">*</span>
                            </label>
                            <div class="relative rounded-md shadow-sm">
                                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                    <i class="bi bi-lightning text-gray-400"></i>
                                </div>
                                <select class="block w-full pl-10 pr-9 py-2.5 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 appearance-none transition" 
                                    id="ruleAction" name="action">
                                    <option value="deny">Block Request (403 Forbidden)</option>
                                    <option value="pass">Allow but Log (Monitor Mode)</option>
                                </select>
                                <div class="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
                                    <i class="bi bi-chevron-down text-gray-400"></i>
                                </div>
                            </div>
                            <p class="mt-1 text-sm text-gray-500">Define what happens when this rule is triggered</p>
                        </div>
                    </div>
                    
                    <!-- Dynamic Parameters -->
                    <div id="parameters-container" class="space-y-4">
                        <!-- Dynamic parameters will be loaded here based on rule type -->
                        <h6 class="block text-sm font-medium text-gray-700 mb-3">Rule Parameters</h6>
                    </div>
                    
                    <!-- Rule Preview Section -->
                    <div class="mt-6">
                        <div class="bg-gray-50 border rounded-md overflow-hidden">
                            <div class="px-4 py-3 bg-gray-100 border-b flex justify-between items-center">
                                <h6 class="font-medium flex items-center">
                                    <i class="bi bi-code-slash mr-2 text-blue-600"></i>
                                    Rule Preview
                                </h6>
                                <div class="flex space-x-2">
                                    <button type="button" id="copyRuleBtn" class="text-xs bg-gray-200 hover:bg-gray-300 px-2 py-1 rounded inline-flex items-center transition">
                                        <i class="bi bi-clipboard mr-1"></i> Copy
                                    </button>
                                    <button type="button" id="refreshPreviewBtn" class="text-xs bg-blue-50 hover:bg-blue-100 text-blue-700 px-2 py-1 rounded inline-flex items-center transition">
                                        <i class="bi bi-arrow-repeat mr-1"></i> Refresh
                                    </button>
                                </div>
                            </div>
                            <div class="p-4">
                                <pre id="rulePreview" class="bg-gray-100 text-gray-800 p-3 rounded text-sm overflow-x-auto max-h-60 font-mono">// Select a rule type to generate a preview</pre>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Form Actions -->
                    <div class="flex justify-between pt-4 border-t">
                        <button type="button" id="testRuleBtn" class="px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-md inline-flex items-center transition shadow-sm">
                            <i class="bi bi-lightning mr-2"></i> Test Rule
                        </button>
                        <div class="space-x-2">
                            <a href="/waf/sites/{{.SiteID}}/rules" class="px-4 py-2.5 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-md inline-flex items-center transition">
                                <i class="bi bi-x-circle mr-2"></i> Cancel
                            </a>
                            <button type="submit" class="px-4 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-md inline-flex items-center transition shadow-sm">
                                <i class="bi bi-check-circle mr-2"></i> {{if .IsEdit}}Update{{else}}Create{{end}} Rule
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Test Result Modal -->
<div id="testResultModal" class="fixed inset-0 z-50 hidden overflow-y-auto" aria-hidden="true">
    <div class="flex items-center justify-center min-h-screen p-4">
        <div class="fixed inset-0 bg-black bg-opacity-50 transition-opacity" id="test-modal-backdrop"></div>
        <div class="bg-white rounded-lg shadow-xl max-w-xl w-full z-10">
            <div class="px-4 py-3 border-b flex justify-between items-center">
                <h5 class="text-lg font-medium">Rule Test Result</h5>
                <button type="button" class="text-gray-500 hover:text-gray-700" id="close-test-modal">
                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>
            <div class="px-4 py-4">
                <div id="test-success" class="hidden">
                    <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
                        <div class="flex items-center">
                            <i class="bi bi-check-circle text-xl mr-2"></i>
                            <span>Rule validation successful!</span>
                        </div>
                    </div>
                    <div>
                        <h6 class="font-medium mb-2">Rule Text:</h6>
                        <pre id="validated-rule-text" class="bg-gray-100 text-gray-800 p-3 rounded text-sm overflow-x-auto max-h-40"></pre>
                    </div>
                </div>
                <div id="test-error" class="hidden">
                    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                        <div class="flex items-center">
                            <i class="bi bi-exclamation-triangle text-xl mr-2"></i>
                            <span>Rule validation failed!</span>
                        </div>
                    </div>
                    <div>
                        <h6 class="font-medium mb-2">Error:</h6>
                        <pre id="validation-error" class="bg-gray-100 text-red-600 p-3 rounded text-sm overflow-x-auto max-h-40"></pre>
                    </div>
                </div>
            </div>
            <div class="px-4 py-3 border-t flex justify-end">
                <button type="button" class="px-4 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded" id="close-test-result">
                    Close
                </button>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const isEdit = {{if .IsEdit}}true{{else}}false{{end}};
    let ruleTemplates = [];
    let currentRule = null;
    
    // Load templates first
    loadTemplates();
    
    // For edit mode, load the existing rule
    if (isEdit) {
        loadRule({{.RuleID}});
    }
    
    // Handle form submission
    document.getElementById('ruleForm').addEventListener('submit', function(e) {
        e.preventDefault();
        saveRule();
    });
    
    // Handle test button
    document.getElementById('testRuleBtn').addEventListener('click', testRule);
    
    // Handle rule type change
    document.getElementById('ruleType').addEventListener('change', function() {
        const selectedType = this.value;
        if (selectedType) {
            updateParameterForm(selectedType);
        }
    });
    
    // Modal close buttons
    document.getElementById('close-test-modal').addEventListener('click', closeTestModal);
    document.getElementById('close-test-result').addEventListener('click', closeTestModal);
    document.getElementById('test-modal-backdrop').addEventListener('click', closeTestModal);
    
    function closeTestModal() {
        document.getElementById('testResultModal').classList.add('hidden');
    }
    
    // Load rule templates
    async function loadTemplates() {
        try {
            const response = await axios.get('/api/waf/templates', {
                headers: {
                    'Authorization': 'Bearer ' + localStorage.getItem('sepro_waf_token')
                }
            });
            
            ruleTemplates = response.data;
            
            // Populate rule type dropdown
            const typeSelect = document.getElementById('ruleType');
            ruleTemplates.forEach(template => {
                const option = document.createElement('option');
                option.value = template.type;
                option.textContent = template.name;
                typeSelect.appendChild(option);
            });
            
            // Show form after templates are loaded
            document.getElementById('rule-form-loading').classList.add('hidden');
            document.getElementById('rule-form-content').classList.remove('hidden');
            
            // If not in edit mode, handle any initial selection
            if (!isEdit && typeSelect.value) {
                updateParameterForm(typeSelect.value);
            }
        } catch (error) {
            console.error('Error loading templates:', error);
            showToast('Failed to load rule templates', 'danger');
        }
    }
    
    // Load existing rule for editing
    async function loadRule(ruleId) {
        try {
            const response = await axios.get(`/api/waf/rules/${ruleId}`, {
                headers: {
                    'Authorization': 'Bearer ' + localStorage.getItem('sepro_waf_token')
                }
            });
            
            currentRule = response.data;
            
            // Populate form with rule data
            document.getElementById('ruleName').value = currentRule.name;
            document.getElementById('ruleType').value = currentRule.type;
            document.getElementById('ruleAction').value = currentRule.action || 'deny';
            
            // Update parameters based on rule type
            updateParameterForm(currentRule.type, true);
            
            // Update rule preview
            document.getElementById('rulePreview').textContent = currentRule.rule_text || '// Rule text not available';
        } catch (error) {
            console.error('Error loading rule:', error);
            showToast('Failed to load rule data', 'danger');
        }
    }
    
    // Update parameter form based on selected rule type
    function updateParameterForm(ruleType, isLoadingExisting = false) {
        const container = document.getElementById('parameters-container');
        container.innerHTML = '<h6 class="block text-sm font-medium text-gray-700 mb-3">Rule Parameters</h6>';
        
        // Find the selected template
        const template = ruleTemplates.find(t => t.type === ruleType);
        if (!template) return;
        
        // Update type description
        document.getElementById('typeDescription').textContent = template.description;
        
        // Parse parameters from current rule if editing
        let currentParams = {};
        if (isEdit && currentRule && currentRule.parameters) {
            try {
                currentParams = JSON.parse(currentRule.parameters);
            } catch (e) {
                console.error('Error parsing rule parameters:', e);
            }
        }
        
        // Special handling for custom rules
        if (ruleType === 'custom') {
            // Clear container and set a more descriptive title
            container.innerHTML = '<h6 class="text-base font-medium text-gray-700 mb-3">Custom Rule Definition</h6>';
            
            // Create a fieldset for the custom rule
            const fieldset = document.createElement('fieldset');
            fieldset.className = 'border border-gray-200 rounded-md p-4 bg-gray-50';
            
            // Create legend
            const legend = document.createElement('legend');
            legend.className = 'text-sm font-medium px-2 text-blue-600';
            legend.textContent = 'ModSecurity Rule Syntax';
            fieldset.appendChild(legend);
            
            // Add description
            const description = document.createElement('p');
            description.className = 'text-sm text-gray-600 mb-4';
            description.innerHTML = 'Enter your custom ModSecurity rule using correct syntax. <a href="https://github.com/corazawaf/coraza/wiki/Rules-Introduction" target="_blank" class="text-blue-600 hover:underline">View rule documentation</a>';
            fieldset.appendChild(description);
            
            // Create textarea for rule text
            const ruleTextDiv = document.createElement('div');
            ruleTextDiv.className = 'mb-2';
            
            const ruleTextLabel = document.createElement('label');
            ruleTextLabel.className = 'block text-sm font-medium text-gray-700 mb-1';
            ruleTextLabel.htmlFor = 'customRuleText';
            ruleTextLabel.innerHTML = 'Rule Text <span class="text-red-500">*</span>';
            
            const ruleTextWrapper = document.createElement('div');
            ruleTextWrapper.className = 'relative rounded-md shadow-sm';
            
            const iconDiv = document.createElement('div');
            iconDiv.className = 'absolute top-3 left-3 flex items-start pointer-events-none';
            const icon = document.createElement('i');
            icon.className = 'bi bi-code-slash text-gray-400';
            iconDiv.appendChild(icon);
            
            const textarea = document.createElement('textarea');
            textarea.id = 'customRuleText';
            textarea.name = 'customRuleText';
            textarea.className = 'block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md font-mono text-sm focus:ring-blue-500 focus:border-blue-500 transition';
            textarea.rows = 8;
            textarea.required = true;
            textarea.placeholder = 'SecRule REQUEST_HEADERS:User-Agent "@contains BadBot" "id:10001,phase:1,deny,status:403,log,msg:\'Blocked bad user agent\'"';
            
            // Set value from current rule if editing
            if (isLoadingExisting && currentRule && currentRule.rule_text) {
                textarea.value = currentRule.rule_text;
            }
            
            ruleTextWrapper.appendChild(iconDiv);
            ruleTextWrapper.appendChild(textarea);
            
            const helpText = document.createElement('p');
            helpText.className = 'mt-1 text-xs text-gray-500';
            helpText.textContent = 'Enter your ModSecurity compatible rule using the correct syntax';
            
            ruleTextDiv.appendChild(ruleTextLabel);
            ruleTextDiv.appendChild(ruleTextWrapper);
            ruleTextDiv.appendChild(helpText);
            
            fieldset.appendChild(ruleTextDiv);
            container.appendChild(fieldset);
            
            // Add these example buttons at the bottom of the custom rule fieldset
            const exampleButtonsDiv = document.createElement('div');
            exampleButtonsDiv.className = 'mt-3 flex flex-wrap gap-2';
            exampleButtonsDiv.innerHTML = `
                <span class="text-xs text-gray-600">Examples:</span>
                <button type="button" class="text-xs bg-gray-200 hover:bg-gray-300 px-2 py-1 rounded inline-flex items-center transition example-rule-btn" 
                    data-example="block-admin">
                    Block Admin Path
                </button>
                <button type="button" class="text-xs bg-gray-200 hover:bg-gray-300 px-2 py-1 rounded inline-flex items-center transition example-rule-btn"
                    data-example="block-user-agent">
                    Block Bad User Agent
                </button>
                <button type="button" class="text-xs bg-gray-200 hover:bg-gray-300 px-2 py-1 rounded inline-flex items-center transition example-rule-btn"
                    data-example="rate-limit">
                    API Rate Limiting
                </button>
            `;
            fieldset.appendChild(exampleButtonsDiv);
            
            // Define rule examples in a configuration object
            const ruleExamples = {
                'block-admin': {
                    text: `SecRule REQUEST_URI "@beginsWith /admin" "id:10002,phase:1,deny,status:403,log,msg:'Admin access blocked'"`
                },
                'block-user-agent': {
                    text: `SecRule REQUEST_HEADERS:User-Agent "@contains BadBot" "id:10001,phase:1,deny,status:403,log,msg:'Blocked bad user agent'"`
                },
                'rate-limit': {
                    text: `SecRule REQUEST_URI "@beginsWith /api/login" "id:10003,phase:1,pass,nolog,setvar:ip.login_counter=+1,expirevar:ip.login_counter=60"
SecRule IP:login_counter "@gt 5" "id:10004,phase:1,deny,status:429,log,msg:'Login rate limit exceeded'"`
                }
            };
            
            // Add event listeners for example buttons
            fieldset.querySelectorAll('.example-rule-btn').forEach(btn => {
                btn.addEventListener('click', function() {
                    const example = this.getAttribute('data-example');
                    if (ruleExamples[example]) {
                        textarea.value = ruleExamples[example].text;
                        // Update preview
                        document.getElementById('rulePreview').textContent = textarea.value;
                    }
                });
            });
            
            // Add event listeners
            textarea.addEventListener('input', function() {
                document.getElementById('rulePreview').textContent = this.value;
            });
            
            // Set initial preview
            if (textarea.value) {
                document.getElementById('rulePreview').textContent = textarea.value;
            } else {
                document.getElementById('rulePreview').textContent = '// Enter your custom rule above';
            }
            
            return; // Skip the rest of the function
        }
        
        // Create form fields for each parameter
        template.parameters.forEach(param => {
            const fieldDiv = document.createElement('div');
            fieldDiv.className = 'mb-6 p-4 border border-gray-200 rounded-md bg-gray-50';
            
            const labelWrapper = document.createElement('div');
            labelWrapper.className = 'flex justify-between items-center mb-2';
            
            const label = document.createElement('label');
            label.className = 'text-sm font-medium text-gray-700';
            label.htmlFor = `param-${param.name}`;
            label.textContent = param.description || param.name;
            
            // Add parameter type badge
            const typeBadge = document.createElement('span');
            typeBadge.className = 'text-xs px-2 py-1 rounded-full bg-blue-100 text-blue-800';
            typeBadge.textContent = param.type || 'text';
            
            labelWrapper.appendChild(label);
            labelWrapper.appendChild(typeBadge);
            
            let input;
            
            if (param.type === 'text' || param.type === 'code') {
                // Create improved textarea with line numbers and syntax highlighting
                input = document.createElement('textarea');
                input.className = 'w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring focus:ring-blue-500 focus:ring-opacity-50 font-mono';
                input.rows = 4;
                
                if (param.type === 'code') {
                    input.classList.add('font-mono', 'text-sm');
                }
            } else if (param.type === 'select' && param.options) {
                input = document.createElement('select');
                input.className = 'w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring focus:ring-blue-500 focus:ring-opacity-50';
                
                // Add options from parameter definition
                param.options.forEach(option => {
                    const optionEl = document.createElement('option');
                    optionEl.value = option.value;
                    optionEl.textContent = option.label || option.value;
                    input.appendChild(optionEl);
                });
            } else {
                input = document.createElement('input');
                input.className = 'w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring focus:ring-blue-500 focus:ring-opacity-50';
                
                // Set appropriate input type based on parameter type
                if (param.type === 'number') {
                    input.type = 'number';
                    if (param.min !== undefined) input.min = param.min;
                    if (param.max !== undefined) input.max = param.max;
                    if (param.step !== undefined) input.step = param.step;
                } else if (param.type === 'boolean') {
                    // Create a toggle switch for boolean parameters
                    const toggleWrapper = document.createElement('div');
                    toggleWrapper.className = 'relative inline-block w-10 mr-2 align-middle select-none transition duration-200 ease-in';
                    
                    const toggleCheckbox = document.createElement('input');
                    toggleCheckbox.type = 'checkbox';
                    toggleCheckbox.id = `param-${param.name}`;
                    toggleCheckbox.name = `param-${param.name}`;
                    toggleCheckbox.className = 'toggle-checkbox absolute block w-6 h-6 rounded-full bg-white border-4 appearance-none cursor-pointer';
                    
                    const toggleLabel = document.createElement('label');
                    toggleLabel.htmlFor = `param-${param.name}`;
                    toggleLabel.className = 'toggle-label block overflow-hidden h-6 rounded-full bg-gray-300 cursor-pointer';
                    
                    toggleWrapper.appendChild(toggleCheckbox);
                    toggleWrapper.appendChild(toggleLabel);
                    
                    // Replace our input with the toggle switch
                    input = toggleCheckbox;
                    
                    // Add the toggle wrapper to the field div later
                    fieldDiv.appendChild(labelWrapper);
                    fieldDiv.appendChild(toggleWrapper);
                    
                    // Add custom CSS for the toggle
                    const style = document.createElement('style');
                    style.textContent = `
                        .toggle-checkbox:checked {
                            right: 0;
                            border-color: #3b82f6;
                        }
                        .toggle-checkbox:checked + .toggle-label {
                            background-color: #3b82f6;
                        }
                    `;
                    document.head.appendChild(style);
                    
                    // Skip the rest of the regular input setup
                    input.required = param.required !== false;
                    
                    // Set value from current rule if editing, or use default
                    if (isLoadingExisting && currentParams[param.name] !== undefined) {
                        input.checked = currentParams[param.name] === true || currentParams[param.name] === 'true';
                    } else if (param.default !== undefined) {
                        input.checked = param.default === true || param.default === 'true';
                    }
                    
                    // Add event listeners to update preview on input change
                    input.addEventListener('change', generateRulePreview);
                    
                    // Add description if available
                    const description = document.createElement('p');
                    description.className = 'text-sm text-gray-500 mt-2';
                    description.textContent = param.help || `Toggle to ${param.name.replace(/([A-Z])/g, ' $1').toLowerCase()}`;
                    
                    fieldDiv.appendChild(description);
                    container.appendChild(fieldDiv);
                    
                    return;
                } else {
                    input.type = 'text';
                    if (param.pattern) input.pattern = param.pattern;
                }
            }
            
            input.id = `param-${param.name}`;
            input.name = `param-${param.name}`;
            input.required = param.required !== false;
            
            if (param.placeholder) {
                input.placeholder = param.placeholder;
            }
            
            // Set value from current rule if editing, or use default
            if (isLoadingExisting && currentParams[param.name] !== undefined) {
                input.value = currentParams[param.name];
            } else if (param.default !== undefined) {
                input.value = param.default;
            }
            
            // Add description if available
            const description = document.createElement('p');
            description.className = 'text-sm text-gray-500 mt-2';
            description.textContent = param.help || `Enter the ${param.name.replace(/([A-Z])/g, ' $1').toLowerCase()}`;
            
            fieldDiv.appendChild(labelWrapper);
            fieldDiv.appendChild(input);
            fieldDiv.appendChild(description);
            container.appendChild(fieldDiv);
            
            // Add event listeners to update preview on input change
            input.addEventListener('input', generateRulePreview);
            input.addEventListener('change', generateRulePreview);
        });
        
        // Generate initial preview
        generateRulePreview();
    }
    
    // Generate rule preview
    async function generateRulePreview() {
        try {
            const ruleData = collectFormData();
            
            // Don't try to preview if required fields are missing
            if (!ruleData.type || !ruleData.name) {
                document.getElementById('rulePreview').textContent = '// Please complete required fields';
                return;
            }
            
            const response = await axios.post('/api/waf/test-rule', ruleData, {
                headers: {
                    'Authorization': 'Bearer ' + localStorage.getItem('sepro_waf_token'),
                    'Content-Type': 'application/json'
                }
            });
            
            if (response.data.success) {
                document.getElementById('rulePreview').textContent = response.data.ruleText;
            } else {
                document.getElementById('rulePreview').textContent = `// Error: ${response.data.error}`;
            }
        } catch (error) {
            console.error('Error generating preview:', error);
            document.getElementById('rulePreview').textContent = '// Error generating preview';
        }
    }
    
    // Test rule validation
    async function testRule() {
        try {
            const ruleData = collectFormData();
            
            // Show loading state
            document.getElementById('testRuleBtn').innerHTML = '<i class="bi bi-hourglass-split animate-spin mr-2"></i> Testing...';
            document.getElementById('testRuleBtn').disabled = true;
            
            const response = await axios.post('/api/waf/test-rule', ruleData, {
                headers: {
                    'Authorization': 'Bearer ' + localStorage.getItem('sepro_waf_token'),
                    'Content-Type': 'application/json'
                }
            });
            
            // Reset button
            document.getElementById('testRuleBtn').innerHTML = '<i class="bi bi-lightning mr-2"></i> Test Rule';
            document.getElementById('testRuleBtn').disabled = false;
            
            // Show test result modal
            const successDiv = document.getElementById('test-success');
            const errorDiv = document.getElementById('test-error');
            
            if (response.data.success) {
                successDiv.classList.remove('hidden');
                errorDiv.classList.add('hidden');
                document.getElementById('validated-rule-text').textContent = response.data.ruleText;
            } else {
                successDiv.classList.add('hidden');
                errorDiv.classList.remove('hidden');
                document.getElementById('validation-error').textContent = response.data.error;
            }
            
            document.getElementById('testResultModal').classList.remove('hidden');
        } catch (error) {
            console.error('Error testing rule:', error);
            showToast('Failed to test rule', 'danger');
            
            // Reset button
            document.getElementById('testRuleBtn').innerHTML = '<i class="bi bi-lightning mr-2"></i> Test Rule';
            document.getElementById('testRuleBtn').disabled = false;
        }
    }
    
    // Save rule
    async function saveRule() {
        try {
            const ruleData = collectFormData();
            
            let url = isEdit ? `/api/waf/rules/${ruleData.id}` : `/api/sites/${ruleData.siteId}/waf/rules`;
            let method = isEdit ? 'put' : 'post';
            const response = await axios({
                method: method,
                url: url,
                data: ruleData,
                headers: {
                    'Authorization': 'Bearer ' + localStorage.getItem('sepro_waf_token'),
                    'Content-Type': 'application/json'
                }
            });
            
            showToast(`Rule ${isEdit ? 'updated' : 'created'} successfully`, 'success');
            
            // Redirect to rule list
            window.location.href = `/waf/sites/${ruleData.siteId}/rules`;
        } catch (error) {
            console.error('Error saving rule:', error);
            showToast(`Failed to ${isEdit ? 'update' : 'create'} rule`, 'danger');
        }
    }
    
    // Collect form data with improved JSON handling
    function collectFormData() {
        const formData = {
            name: document.getElementById('ruleName').value,
            type: document.getElementById('ruleType').value,
            action: document.getElementById('ruleAction').value,
            siteId: parseInt(document.getElementById('siteId').value),
            status: 'enabled'
        };
        
        if (isEdit) {
            formData.id = parseInt(document.getElementById('ruleId').value);
        }
        
        // Special handling for custom rules first
        if (formData.type === 'custom') {
            const customRuleText = document.getElementById('customRuleText');
            if (customRuleText) {
                formData.rule_text = customRuleText.value;
                // Use empty object for parameters instead of string
                formData.parameters = {};
            } else {
                formData.rule_text = document.getElementById('rulePreview').textContent;
                formData.parameters = {};
            }
            return formData;
        }
        
        // For other rule types
        const template = ruleTemplates.find(t => t.type === formData.type);
        if (template) {
            // Collect parameter values
            const params = {};
            template.parameters.forEach(param => {
                const input = document.getElementById(`param-${param.name}`);
                if (!input) return;
                
                // Handle different input types appropriately
                if (param.type === 'boolean') {
                    params[param.name] = input.checked;
                } else if (param.type === 'number') {
                    params[param.name] = input.value !== '' ? Number(input.value) : null;
                } else {
                    params[param.name] = input.value;
                }
            });
            
            // Set parameters as object, not string
            formData.parameters = params;
        } else {
            // If template not found, provide empty object for parameters
            formData.parameters = {};
        }
        
        return formData;
    }
    
    // Add copy rule button functionality
    document.getElementById('copyRuleBtn').addEventListener('click', function() {
        const ruleText = document.getElementById('rulePreview').textContent;
        navigator.clipboard.writeText(ruleText).then(() => {
            this.innerHTML = '<i class="bi bi-check mr-1"></i> Copied!';
            setTimeout(() => {
                this.innerHTML = '<i class="bi bi-clipboard mr-1"></i> Copy';
            }, 2000);
        }).catch(err => {
            console.error('Failed to copy: ', err);
            showToast('Failed to copy rule text', 'danger');
        });
    });
    
    // Refresh preview button
    document.getElementById('refreshPreviewBtn').addEventListener('click', generateRulePreview);
});
</script>