function Remove-DDEvent {
<#
    .SYNOPSIS
        Delete an event from the stream.

    .DESCRIPTION

    .PARAMETER EventID
        A Datadog event ID.
#>

  [CmdletBinding(SupportsShouldProcess=$true)]

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
        if ($pscmdlet.ShouldProcess($EventId, "Removing event '$EventId'")) {
            $result = New-DDQuery -EndPoint "/events/$EventId" -Method 'Delete' -Body $Body -RequiresApplicationKey -ErrorAction Stop
        }
        else {
            Write-Verbose "Task aborted by user"
            return
        }
       
        return $result

    }

}