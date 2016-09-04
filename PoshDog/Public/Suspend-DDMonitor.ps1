function Suspend-DDMonitor {
<#
    .SYNOPSIS
        Mutes Datadog monitors. Either all of them with -All or a specific one with -MonitorID
    
    .DESCRIPTION
            
    .EXAMPLE
        # Mute all monitors
        Suspend-DDMonitor -All
        
    .EXAMPLE
        # Mute a single monitor
        Suspend-DDMonitor -MonitorID 123456
        
    .EXAMPLE
        # Mute a single monitor and specify and end date in 2 days.
        Suspend-DDMonitor -MonitorID 123456 -EndDate (Get-Date).AddDays(2)
    
    .EXAMPLE
        # Mute a single monitor and specify and end timestamp, also mute only for scope role:frontend
        Suspend-DDMonitor -MonitorID 123456 -EndTimestamp -Scope 'role:frontend'

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
            ParameterSetName="Suspend-DDMonitor:All"
        )]
        [switch]$All,
        
        # Can be part of 3 parameter sets
        [Parameter(
            Position=0,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$false,
            Mandatory=$True,
            HelpMessage="A Datadog Monitor ID",
            ParameterSetName="Default"
        )]
        [Parameter(
            Position=0,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$false,
            Mandatory=$True,
            HelpMessage="A Datadog Monitor ID",
            ParameterSetName="Suspend-DDMonitor:IDAndDate"
        )]
        [Parameter(
            Position=0,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$false,
            Mandatory=$True,
            HelpMessage="A Datadog Monitor ID",
            ParameterSetName="Suspend-DDMonitor:IDAndTimestamp"
        )]
        [Alias('Id')]
        [uint32]$MonitorId,

        # Can be part of 3 parameter sets!
        [Parameter(
            Position=1,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="The scope to apply the mute to, e.g. role:db",
            ParameterSetName="Default"
        )]
        [Parameter(
            Position=1,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="The scope to apply the mute to, e.g. role:db",
            ParameterSetName="Suspend-DDMonitor:IDAndDate"
        )]
        [Parameter(
            Position=1,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="The scope to apply the mute to, e.g. role:db",
            ParameterSetName="Suspend-DDMonitor:IDAndTimestamp"
        )]
        [string[]]$Scope,
    
        [Parameter(
            Position=2,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="A POSIX timestamp for when the mute should end",
            ParameterSetName="Suspend-DDMonitor:IDAndTimestamp"
        )]
        [Double]$EndTimestamp,

        [Parameter(
            Position=2,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="A POSIX timestamp for when the mute should end",
            ParameterSetName="Suspend-DDMonitor:IDAndDate"
        )]
        [DateTime]$EndDate
    )

    process {     
        if ($PSCmdlet.ParameterSetName -eq "Suspend-DDMonitor:All") {
            $Endpoint = '/monitor/mute_all'
            $ConfirmationMessage = 'Muting all monitors'
            $defaultDisplaySet = 'id', 'active', 'disabled', 'start', 'end', 'scope'
        }
        else {
            $Endpoint = "/monitor/$MonitorId/mute"
            $ConfirmationMessage = "Muting monitor $MonitorId" 
            $Body = @{}
            $defaultDisplaySet = 'id', 'name', 'type', 'query', 'overall_state', 'message', 'options', 'creator', 'created', 'modified'
            
             if ($PSCmdlet.ParameterSetName -eq "Suspend-DDMonitor:IDAndDate") {
                $unixEpochStart = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
                $EndTimestamp = [int]($EndDate - $unixEpochStart).TotalSeconds
                $Body.Add('end',$EndTimestamp)
            }
            elseif ($PSCmdlet.ParameterSetName -eq "Suspend-DDMonitor:IDAndTimestamp") { 
                # ParameterSetName is Suspend-DDMonitor:IDAndTimestamp
                $Body.Add('end',$EndTimestamp)
            }
            if ($Scope) {
                $Body.Add('scope',$Scope)
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
           
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $result | Add-Member MemberSet PSStandardMembers $PSStandardMembers
        return $result
    }
}
