function Resume-DDMonitor {
<#
    .SYNOPSIS
        Unmutes Datadog monitors. Either all of them with -All or a specific one with -MonitorID
    .DESCRIPTION
            
    .PARAMETER All
        A switch to resume all monitors. Incompatible with all other parameters.
    
    .PARAMETER MonitorID
        A Datadog monitor ID.
        
    .PARAMETER Scope
        A string or array of strings representing the scope to apply the unmuting to.
        
    .PARAMETER AllScopes
        A switch to clear muting for a monitor across all scopes.

    .EXAMPLE
        # Unmute all monitors
        Resume-DDMonitor -All
        
    .EXAMPLE
        # Mute a single monitor
        Resume-DDMonitor -MonitorID 123456
        
    .EXAMPLE
        # Unmute a single monitor for scope role:frontend
        Resume-DDMonitor -MonitorID 123456 -Scope role:frontend
    
    .EXAMPLE
        # Unmute a single monitor across all scopes
        Resume-DDMonitor -MonitorID 123456 -AllScopes

    .LINK
        http://docs.datadoghq.com/api/?lang=console#monitor-mute
        http://docs.datadoghq.com/api/?lang=console#monitor-mute-all

    .FUNCTIONALITY
    
#>
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High',DefaultParameterSetName="Default")]
    param (     
         [Parameter(
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false,
            HelpMessage="Unmute all monitors",
            ParameterSetName="Resume-DDMonitor:All"
        )]
        [switch]$All,
        
        [Parameter(
            Position=0,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$false,
            Mandatory=$True,
            HelpMessage="A Datadog Monitor ID",
            ParameterSetName="Resume-DDMonitor:ByID"
        )]
        [Alias('Id')]
        [uint32]$MonitorId,

        [Parameter(
            Position=1,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="The scope to apply the unmute to, e.g. role:db",
            ParameterSetName="Resume-DDMonitor:ByID"
        )]
        [string[]]$Scope,
    
        [Parameter(
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false,
            HelpMessage="Unmute the monitor across all scopes",
            ParameterSetName="Resume-DDMonitor:ByID"
        )]
        [switch]$AllScopes
    )

    process {     
        if ($PSCmdlet.ParameterSetName -eq "Resume-DDMonitor:All") {
            $Endpoint = '/monitor/unmute_all'
            $ConfirmationMessage = 'Unmuting all monitors'
        }
        else {
            $Endpoint = "/monitor/$MonitorId/unmute"
            $ConfirmationMessage = "Unmuting monitor $MonitorId" 
            $Body = @{}
            $defaultDisplaySet = 'id', 'name', 'type', 'query', 'overall_state', 'message', 'options', 'creator', 'created', 'modified'
            $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet) -ErrorAction SilentlyContinue
            $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
            
            if ($Scope) {
                $Body.Add('scope',$Scope)
            }
            if ($AllScopes) {
                $Body.Add('all_scopes','True')
            }
            $Body = $Body | ConvertTo-Json
        }

        if ($pscmdlet.ShouldProcess($ConfirmationMessage)) {
            $result = New-DDQuery -EndPoint $Endpoint -Method 'Post' -Body $Body -RequiresApplicationKey -ErrorAction Stop
        }
        else {
            Write-Verbose "Task aborted by user"
            return
        }
           
        $result | Add-Member MemberSet PSStandardMembers $PSStandardMembers -ErrorAction SilentlyContinue
        return $result
    }
}