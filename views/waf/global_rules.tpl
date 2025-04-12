<div class="flex flex-wrap mb-4">
    <div class="md:w-1/2">
        <h1 class="text-2xl font-bold">Global WAF Rules</h1>
        <p class="text-gray-600 mt-1">Manage security rules across all your sites</p>
    </div>
    <div class="md:w-1/2 text-right">
        <a href="/waf/sites" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded inline-flex items-center">
            <i class="bi bi-globe mr-2"></i> View All Sites
        </a>
    </div>
</div>

<div class="flex flex-wrap mb-4">
    <div class="md:w-full">
        <div class="bg-white rounded-lg shadow">
            <div class="px-4 py-3 border-b">
                <h5 class="text-lg font-medium mb-0">
                    <i class="bi bi-shield-lock text-blue-600 mr-2"></i>Sites with Custom WAF Rules
                </h5>
            </div>
            <div class="p-0">
                {{if not .Sites}}
                <div class="text-center py-8">
                    <i class="bi bi-shield text-4xl text-gray-500"></i>
                    <p class="mt-2">No sites with custom WAF rules found.</p>
                    <a href="/waf/sites" class="mt-4 inline-block px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded">
                        Configure Sites
                    </a>
                </div>
                {{else}}
                <div class="overflow-x-auto">
                    <table class="w-full mb-0">
                        <thead>
                            <tr class="bg-gray-50">
                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Site</th>
                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Domain</th>
                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Rules</th>
                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y">
                            {{range .Sites}}
                            <tr class="hover:bg-gray-50">
                                <td class="px-4 py-2 font-medium">{{.Name}}</td>
                                <td class="px-4 py-2">{{.Domain}}</td>
                                <td class="px-4 py-2">
                                    <span class="px-2 py-1 text-xs font-medium rounded-full bg-blue-500 text-white">
                                        {{index $.RuleCounts .ID}} Rules
                                    </span>
                                </td>
                                <td class="px-4 py-2">
                                    {{if eq .Status "active"}}
                                    <span class="px-2 py-1 text-xs font-medium rounded-full bg-green-500 text-white">Active</span>
                                    {{else}}
                                    <span class="px-2 py-1 text-xs font-medium rounded-full bg-gray-500 text-white">{{.Status}}</span>
                                    {{end}}
                                </td>
                                <td class="px-4 py-2">
                                    <a href="/waf/sites/{{.ID}}/rules" class="px-3 py-1 bg-blue-600 hover:bg-blue-700 text-white rounded inline-flex items-center">
                                        <i class="bi bi-shield-lock mr-1"></i> Manage Rules
                                    </a>
                                </td>
                            </tr>
                            {{end}}
                        </tbody>
                    </table>
                </div>
                {{end}}
            </div>
        </div>
    </div>
</div>