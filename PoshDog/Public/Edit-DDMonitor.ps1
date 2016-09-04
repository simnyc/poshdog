function Edit-DDMonitor {
<#
    .SYNOPSIS
        Edit a Datadog monitor

    .DESCRIPTION
        
    .PARAMETER MonitorObject
        # A Datadog Monitor object. Can be created from scratch or retrieved with Get-DDMonitor, edited and fed to Edit-DDMonitor.
        If it's the later, the commandlet will make sure that only supported properties are supplied by removing others.
        The only required property is query.

    .EXAMPLE
        # Edit an existing object
        $m = Get-DDMonitor -All | Select -First 1
        $m += ' - EDITED'
        Edit-DDMonitor -MonitorObject $m
        
    .EXAMPLE
        # Edit an existing object and pass it by the pipeline
        $m = Get-DDMonitor -All | Select -First 1
        $m += ' - EDITED'
        $m | Edit-DDMonitor

    .EXAMPLE
        # Create a custom object and pass it to the commandlet
        $o=[PSCustomObject]@{id = '869861'; query = 'avg(last_5m):sum:system.net.bytes_rcvd{*} > 10000'; name = 'CREATED FROM SCRATCH' }
        $o | Edit-DDMonitor
        
    .LINK
        http://docs.datadoghq.com/api/?lang=console#monitor-edit
        
    .FUNCTIONALITY
    
#>
    [CmdletBinding()]
    param (     
        [Parameter(
            Position=0,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$false,
            Mandatory=$True,
            HelpMessage="A Datadog Monitor ID"
        )]
        [PSCustomObject]$MonitorObject      
    )
    process {
        $MonitorId = $MonitorObject.id
        if (!$MonitorId) {
            Throw "The object does not contain an id property"
        }

        $EditedMonitorObject = @{}
        $ValidProperties = @("name", "options", "message", "query", "tags")
        
        foreach ($property in $MonitorObject.PSObject.Properties) {
            Write-Verbose "Edit-DDMonitor: Looking at property $($property.name)"
            if ($ValidProperties -contains $property.name) {
                Write-Verbose "Edit-DDMonitor: Adding property $($property.name) to the EditedMonitorObject"
                $EditedMonitorObject.add($($property.name),$($property.value))
            }
            else {
                Write-Verbose "Edit-DDMonitor: Property $($property.name) is NOT valid, removing it"
            }            
        }
        
        $result = New-DDQuery -EndPoint "/monitor/$MonitorId" -Method 'Put' -Body $($EditedMonitorObject | ConvertTo-Json)  -RequiresApplicationKey -ErrorAction Stop
        
        #Build the default property set
        $defaultDisplaySet = 'id', 'name', 'type', 'query', 'message', 'options', 'modified'  
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $result | Add-Member MemberSet PSStandardMembers $PSStandardMembers

        return $result 
    
    }
}