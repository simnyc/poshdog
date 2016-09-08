function Get-DDMonitor {
<#
    .SYNOPSIS
        Retrieves a list of all existing Datadog monitors with -All or a specific one with -MonitorID.

    .DESCRIPTION

    .PARAMETER All
        Retrieves all monitors. Incompatible with -MonitorID.

    .PARAMETER MonitorId
        A Datadog Monitor ID. Incompatible with -All.

    .PARAMETER GroupStates
        A string or array of strings indicating what, if any, group states to include. Choose from one or more from 'all', 'alert', 'warn', or 'no data'.
        The argument `group_states` will in fact not render all the monitors that have an alert / warning state. Rather, they give more details on different groups within a monitor that has the multi-alert feature activated.
    
    .Parameter Tags
        A string or array of strings indicating what tags, if any, should be used to filter the list of monitors by scope. 
        Incompatible with -MonitorID

    .EXAMPLE
        # Get a list of all monitors
        Get-DDMonitor -All

    .EXAMPLE
        # Get a list of all monitors and filter with a tags
        Get-DDMonitor -All -Tags host:myhostname

    .EXAMPLE
        # Get a list of all monitors and request the alert and warn group states
        Get-DDMonitor -All -GroupStates @('alert', 'warn')

    .EXAMPLE
        # Get a specific monitor
        Get-DDMonitor -MonitorID 123456

    .LINK
        
    .FUNCTIONALITY
    
#>
    [CmdletBinding()]
    param (     
        [Parameter(
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false,
            ParameterSetName="Get-DDMonitor:All"
        )]
        [switch]$All,
        
        [Parameter(
            Position=0,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$false,
            Mandatory=$True,
            HelpMessage="A Datadog Monitor ID",
            ParameterSetName="Get-DDMonitor:ByID"
        )]
        # [int]$null is 0, so we can't use [ValidateNullOrEmpty]
        [ValidateScript( {if ($_ -eq 0) {throw 'Cannot bind argument to parameter <<MonitorID>> because it is null or 0.'} else {return $True} } 
        )]
        [Alias('Id')]
        [uint32]$MonitorId,
        
        # Can be part of both Parameter Sets
        [Parameter(
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false,
            Mandatory=$False,
            HelpMessage="A string or array of strings indicating what, if any, group states to include. Choose from one or more from 'all', 'alert', 'warn', or 'no data'. Example: 'alert,warn'",
            ParameterSetName="Get-DDMonitor:All"
        )]
        [Parameter(
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false,
            Mandatory=$False,
            HelpMessage="A string or array of strings indicating what, if any, group states to include. Choose from one or more from 'all', 'alert', 'warn', or 'no data'. Example: 'alert,warn'",
            ParameterSetName="Get-DDMonitor:ByID"
        )]
        [ValidateSet("all","alert","warn","no data")]
        [string[]]$GroupStates,

        [Parameter(
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false,
            Mandatory=$False,
            HelpMessage="A string or array of strings indicating what tags, if any, should be used to filter the list of monitors by scope",
            ParameterSetName="Get-DDMonitor:All"
        )]
        [string[]]$Tags
    )
    process {
        if ($GroupStates -or $Tags) {
            $Body = @{}
        }
        
        # GroupStates can be a member of both parameter sets
        if ($GroupStates){
            $Body.Add("group_states",($GroupStates -join ','))
        }
        
        if ($PSCmdlet.ParameterSetName -eq "Get-DDMonitor:All") {
            $Endpoint = '/monitor'
            if ($Tags) {
                $Body.Add("tags",($Tags -join ','))
            }
            # Build the default property set
            $defaultDisplaySet = 'name','id','query'
        }
        else {
            # otherwise ($PSCmdlet.ParameterSetName -eq "Get-DDMonitor:ByID") {
            $Endpoint = "/monitor/$MonitorId"
            # Build the default property set
            $defaultDisplaySet = 'id', 'name', 'type', 'query', 'overall_state', 'message', 'options', 'created', 'creator'  
        }
        $result = New-DDQuery -EndPoint $Endpoint -Method 'Get' -Body $Body -RequiresApplicationKey -ErrorAction Stop
        
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $result | Add-Member MemberSet PSStandardMembers $PSStandardMembers
        return $result
    }
}