function Suspend-DDHost {
<#
    .SYNOPSIS
        Mutes Datadog hosts.

    .PARAMETER Hostname
        A hostname as shown on Datadog's Infrastructure List

    .PARAMETER Message
        A message to associate with the muting of this host

    .PARAMETER EndDate
        A Datetime object representing when the mute should end. If omitted, the host will remain muted until explicitly unmuted.

    .PARAMETER EndTimestamp
        POSIX timestamp when the host will be unmuted. If omitted, the host will remain muted until explicitly unmuted.

    .PARAMETER override
        If true and the host is already muted, will replace existing host mute settings.
    
    .DESCRIPTION
            
    .EXAMPLE
        # Mute a host called myhost, undefinitely
        Suspend-DDHost -Hostname myhost
        
    .EXAMPLE
        # Mute a host for 1h using a Datetime object
        Suspend-DDMonitor -Hostname myhost -EndDate (get-date).AddHours(1)

    .EXAMPLE
        # Mute a host for 1h using a Unix timestamp
        Suspend-DDMonitor -Hostname myhost -EndTimestamp 1473358000    

    .EXAMPLE
        # Mute a host, provide an informationnal message and override an existing muting
        Suspend-DDMonitor -Hostname myhost -Message 'Shutting down this server' -Override    
    .LINK
        http://docs.datadoghq.com/api/?lang=console#hosts-mute

    .FUNCTIONALITY
    
#>

    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High',DefaultParameterSetName="Default")]
    param (     
        
        # Can be part of 3 parameter sets
        [Parameter(
            Position=0,
            Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            ParameterSetName="Default"
        )]
        [Parameter(
            Position=0,
            Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            ParameterSetName="Suspend-DDHost:ByDate"
        )]
        [Parameter(
            Position=0,
            Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            ParameterSetName="Suspend-DDHost:ByTimestamp"
        )]
        [Alias('Computername')]
        [ValidateNotNullOrEmpty()]
        [string]$Hostname,

        # Can be part of 3 parameter sets
        [Parameter(
            Position=1,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            ParameterSetName="Default"
        )]
        [Parameter(
            Position=1,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            ParameterSetName="Suspend-DDHost:ByDate"
        )]
        [Parameter(
            Position=1,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            ParameterSetName="Suspend-DDHost:ByTimestamp"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(
            Position=2,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            HelpMessage="A POSIX timestamp for when the mute should end",
            ParameterSetName="Suspend-DDHost:ByTimestamp"
        )]
        [ValidateNotNullOrEmpty()]
        [Double]$EndTimestamp,

        [Parameter(
            Position=2,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            HelpMessage="A Datetime object representing when the mute should end",
            ParameterSetName="Suspend-DDHost:ByDate"
        )]
        [DateTime]$EndDate,


         # Can be part of 3 parameter sets
        [Parameter(
            Position=3,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            ParameterSetName="Default"
        )]
        [Parameter(
            Position=3,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            ParameterSetName="Suspend-DDHost:ByDate"
        )]
        [Parameter(
            Position=3,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            ParameterSetName="Suspend-DDHost:ByTimestamp"
        )]
        [switch]$Override
    )

    process {
        $Body = @{}

        if ($Message) {
            $Body.Add('message',$Message)
        }
        if ($Override) {
            $Body.Add('override','true')
        }
        
        if ($PSCmdlet.ParameterSetName -eq "Suspend-DDHost:ByDate") {
            $unixEpochStart = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
            $EndTimestamp = [int]($EndDate - $unixEpochStart).TotalSeconds
            $Body.Add('end',$EndTimestamp)
        }
        elseif ($PSCmdlet.ParameterSetName -eq "Suspend-DDHost:ByTimestamp") {
            $Body.Add('end',$EndTimestamp)
        }

        if ($pscmdlet.ShouldProcess($ConfirmationMessage)) {
            $result = New-DDQuery -EndPoint "/host/$Hostname/mute" -Method 'Post' -Body ($Body | ConvertTo-Json) -RequiresApplicationKey -ErrorAction Stop
        }
        else {
            Write-Verbose 'Task aborted by user'
            return
        }

        $defaultDisplaySet = 'hostname', 'action', 'message'
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $result | Add-Member MemberSet PSStandardMembers $PSStandardMembers
        return $result
    }
    
}