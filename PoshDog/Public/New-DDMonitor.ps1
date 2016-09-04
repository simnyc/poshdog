function New-DDMonitor {
<#
    .SYNOPSIS
        Create a new Datadog monitor by using parameters or by providing a custom object.

    .DESCRIPTION

    .PARAMETER MonitorObject
        A Datadog Monitor object. Can be created from scratch or retrieved with Get-DDMonitor, edited and fed to New-DDMonitor.
        If it's the later, the commandlet will make sure that only supported properties are supplied by removing others.
        Incompatible with all other parameters.
    
    .PARAMETER Type
        The type of the monitor, chosen from: metric alert, service check, event alert.
        
    .PARAMETER Query
        The monitor query to notify on with syntax varying depending on what type of monitor you are creating. The syntax varies depending on the -Type parameter.

    .PARAMETER Name
        The name of the alert. Default value is dynamic and based on the query.
    
    .PARAMETER Message
        A message to include with notifications for this monitor. 
        Email notifications can be sent to specific users by using the same '@username' notation as events.
    
    .PARAMETER Message
        A message to include with notifications for this monitor. 
        Email notifications can be sent to specific users by using the same '@username' notation as events.
    
    .PARAMETER Tags
        A list of tags to associate with your monitor, as string or array of strings
    
    .PARAMETER Options
        A hashtable of options for the monitor. 
        There are options that are common to all types as well as options that are specific to certain monitor types.
    
    .EXAMPLE
        # Use a simple custom object
        $obj=[PSCustomObject]@{type='metric alert'; query='avg(last_5m):sum:system.net.bytes_rcvd{*} > 10000'}
    
    .EXAMPLE
        # Create a more comple custom object
        $query='avg(last_5m):sum:system.net.bytes_rcvd{*} > 10000'
        $name='Created from scratch'
        $type='metric alert'
        $message = @"
         This is a long message
         You better read it all!
        "@
        $tags=@('frontend','webapp')
        $options=@{'timeout_h'='12';'locked'='True'}
        $obj=[PSCustomObject]@{type=$type;query=$query;name=$name;message=$message;options=$options}
        New-DDMonitor -MonitorObject $obj

    .EXAMPLE
        # Use parameters to create a monitor
        New-DDMonitor -Type 'metric alert' -Query 'avg(last_5m):sum:system.net.bytes_rcvd{*} > 100'
    

    .LINK
        http://docs.datadoghq.com/api/?lang=console#monitor-create

    .FUNCTIONALITY
    
#>
    [CmdletBinding()]
    param (     
        [Parameter(
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$false,
            Mandatory=$True,
            HelpMessage="A Datadog Monitor ID",
            ParameterSetName="New-DDMonitor:ByPipeline"
        )]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$MonitorObject,

        [Parameter(
            Position=0,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$false,
            Mandatory=$True,
            HelpMessage="The type of the monitor, chosen from: metric alert, service check, event alert",
            ParameterSetName="New-DDMonitor:ByCommandLine"
        )]
        [ValidateSet("metric alert", "service check", "event alert")]
        [ValidateNotNullOrEmpty()]
        [System.Object]$Type,
        
        [Parameter(
            Position=1,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$false,
            Mandatory=$True,
            HelpMessage="The monitor query to notify on with syntax varying depending on what type of monitor you are creating.",
            ParameterSetName="New-DDMonitor:ByCommandLine"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Query,

        [Parameter(
            Position=2,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$false,
            Mandatory=$False,
            HelpMessage="The name of the alert. Default value is dynamic and based on the query",
            ParameterSetName="New-DDMonitor:ByCommandLine"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        
        [Parameter(
            Position=3,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$false,
            Mandatory=$False,
            HelpMessage="A message to include with notifications for this monitor",
            ParameterSetName="New-DDMonitor:ByCommandLine"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$false,
            Mandatory=$False,
            HelpMessage="A list of tags to associate with your monitor, as string or array of strings",
            ParameterSetName="New-DDMonitor:ByCommandLine"
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tags,

        [Parameter(
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$false,
            Mandatory=$False,
            HelpMessage="A dictionary of options for the monitor.",
            ParameterSetName="New-DDMonitor:ByCommandLine"
        )]
        [ValidateNotNullOrEmpty()]
        [Hashtable]$Options
     )
    process {

        if ($PSCmdlet.ParameterSetName -eq "New-DDMonitor:ByCommandLine") {
            $Body = @{}

            # From http://stackoverflow.com/questions/21559724/getting-all-named-parameters-from-powershell-including-empty-and-set-ones
            $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
            foreach ($key in $ParameterList.keys) {
                $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var.value)
                {
                    Write-Verbose "New-DDMonitor: Parameter $($var.name) was detected, adding it to the request body"
                    $Body.Add($($var.name).ToLower(),$($var.value))
                }
            }
            $result = New-DDQuery -EndPoint "/monitor" -Method 'Post' -Body $($Body | ConvertTo-Json)  -RequiresApplicationKey -ErrorAction Stop
        }
        else {
            Write-Verbose "New-DDMonitor: An object was passed by pipeline"
            $result = New-DDQuery -EndPoint "/monitor" -Method 'Post' -Body $($MonitorObject | ConvertTo-Json)  -RequiresApplicationKey -ErrorAction Stop
        }
        
        # Build the default property set
        $defaultDisplaySet = 'id', 'name', 'type', 'query', 'message', 'options', 'tags', 'created'  
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $result | Add-Member MemberSet PSStandardMembers $PSStandardMembers

        return $result 
   
    }
}