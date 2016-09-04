function Remove-DDMonitor {
<#
    .SYNOPSIS
        Remove a Datadog monitor.

    .DESCRIPTION

    .PARAMETER MonitorObject
        A Datadog Monitor object. Can be created from scratch or passed from the pipeline
                
    .EXAMPLE
        # Enter confirmation when asked
        Remove-DDMonitor -MonitorID 123456
        
    .EXAMPLE
        # Pass the value by pipeline and bypass confirmation
        $m.id | Remove-DDMonitor -Confirm:$False

    .LINK
        http://docs.datadoghq.com/api/?lang=console#monitor-delete
        
    .FUNCTIONALITY
    
#>
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param (     
        [Parameter(
            Position=0,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$false,
            Mandatory=$True,
            HelpMessage="A Datadog Monitor ID"
        )]
        [Alias('Id')]
        [uint32]$MonitorId
    )
    process {           
        if ($pscmdlet.ShouldProcess($MonitorId, "Removing monitor '$MonitorId'")) {
            $result = New-DDQuery -EndPoint "/monitor/$MonitorId" -Method 'Delete' -Body $Body -RequiresApplicationKey -ErrorAction Stop
        }
        else {
            Write-Verbose "Task aborted by user"
            return
        }
       
        return $result
    }
}