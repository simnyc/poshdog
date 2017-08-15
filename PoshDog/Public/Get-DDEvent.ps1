function Get-DDEvent {
<#
    .SYNOPSIS
        Get an event's details.

    .DESCRIPTION

    .PARAMETER EventID
        A Datadog event ID.
#>

  [CmdletBinding()]

    Param (
        [Parameter(
            Position=0,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            Mandatory=$True,
            HelpMessage="A Datadog event ID."
        )]
        # [int]$null is 0, so we can't use [ValidateNullOrEmpty]
        [ValidateScript( {if ($_ -eq 0) {throw 'Cannot bind argument to parameter <<MonitorID>> because it is null or 0.'} else {return $True} } 
        )]
        [Alias('Id')]
        [long]$EventID
    )

    Process {
        $Endpoint = "/events/$EventID"
        $defaultDisplaySet = 'event'
        
        $result = New-DDQuery -EndPoint $Endpoint -Method 'Get' -RequiresApplicationKey -ErrorAction Stop
        
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $result | Add-Member MemberSet PSStandardMembers $PSStandardMembers
        return $result
    }

}