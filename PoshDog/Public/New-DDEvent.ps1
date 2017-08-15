function New-DDEvent {
<#
    .SYNOPSIS
        Post an event to the stream.

    .DESCRIPTION

    .PARAMETER Title
        The event title, limited to 100 characters.
    
    .PARAMETER Text
        The body of the event, limited to 4000 characters.
        
    .PARAMETER DateHappened
        Date object representing the date of the event, default is now. Not compatible with TimestampHappened.
    
    .PARAMETER TimestampHappened
        Posix timestamp of the event, default is now. Not compatible with DateHappened.
   
    .PARAMETER Priority
        The priority of the event, can be 'normal' or 'low'. Default is 'normal'.
    
    .PARAMETER Host
        Hostname to associate with the event, default is None.
    
    .PARAMETER Tags
        A list of tags to associate with the event, as string or array of strings
    
    .PARAMETER AlertType
        Severity of the event. Can be 'error', 'warning', or 'success'. Default is 'info'.

    .PARAMETER AggregationKey
        An arbitrary string to use for aggregation, max length of 100 characters. Default is None.
        If you specify a key, all events using that key will be grouped together in the Event Stream.
    
    .PARAMETER SourceTypeName
        The type of event being posted. Can be 'nagios', 'hudson', 'jenkins', 'user', 'my_apps', 'feed',
        'chef', 'puppet', 'git', 'bitbucket', 'fabric', 'capistrano'. Default is None.
       
    .EXAMPLE
       # Send an event with default options
       New-DDEvent -Title 'A new event' -Text 'Something happened!'

    .EXAMPLE
       # Send an event with custom options
       New-DDEvent -Title 'A new event' -Text 'Something happened!' -Tags 'deploy' -AlertType 'Success'
   

    .LINK
        http://docs.datadoghq.com/api/?lang=console#events-post

    .FUNCTIONALITY
    
#>
    [CmdletBinding(DefaultParameterSetName='Default')]

    # most parameters belong to Default, New-DDEvent:ByDate and New-DDEvent:ByTimestamp parameter sets
    param (     
         [Parameter(
            Position=0,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            Mandatory=$True,
            HelpMessage=" The event title",
            ParameterSetName="Default"
        )]
        [Parameter(
            Position=0,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            Mandatory=$True,
            HelpMessage=" The event title",
            ParameterSetName="New-DDEvent:ByDate"
        )]
        [Parameter(
            Position=0,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            Mandatory=$True,
            HelpMessage=" The event title",
            ParameterSetName="New-DDEvent:ByTimestamp"
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 100)]
        [String]$Title,

        [Parameter(
            Position=1,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            Mandatory=$True,
            HelpMessage="The body of the event.",
            ParameterSetName="Default"
        )]
        [Parameter(
            Position=1,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            Mandatory=$True,
            HelpMessage="The body of the event.",
            ParameterSetName="New-DDEvent:ByDate"
        )]
        [Parameter(
            Position=1,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            Mandatory=$True,
            HelpMessage="The body of the event.",
            ParameterSetName="New-DDEvent:ByTimestamp"
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 4000)]
        [String]$Text,

        [Parameter(
            Position=2,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="Date of the event",
            ParameterSetName="New-DDEvent:ByDate"
        )]
        [ValidateNotNullOrEmpty()]
        [datetime]$DateHappened,

        [Parameter(
            Position=2,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="POSIX timestamp of the event",
            ParameterSetName="New-DDEvent:ByTimestamp"
        )]
        # [int]$null is 0, so we can't use [ValidateNullOrEmpty]
        [ValidateScript( {if ($_ -eq 0) {throw 'Cannot bind argument to parameter <<MonitorID>> because it is null or 0.'} else {return $True} } 
        )]
        [Double]$TimestampHappened,
        
       [Parameter(
            Position=3,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="The priority of the event chosen from 'normal' or 'low'",
            ParameterSetName="Default"
        )]
       [Parameter(
            Position=3,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="The priority of the event chosen from 'normal' or 'low'",
            ParameterSetName="New-DDEvent:ByDate"
        )]
        [Parameter(
            Position=3,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="The priority of the event chosen from 'normal' or 'low'",
            ParameterSetName="New-DDEvent:ByTimestamp"
        )]
        [ValidateSet('normal', 'low')]
        [ValidateNotNullOrEmpty()]
        [String]$Priority, # No need to set a default value here, the API does that for us

        [Parameter(
            Position=4,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="Host name to associate with the event.",
            ParameterSetName="Default"
        )]
        [Parameter(
            Position=4,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="Host name to associate with the event.",
            ParameterSetName="New-DDEvent:ByDate"
        )]
        [Parameter(
            Position=4,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="Host name to associate with the event.",
            ParameterSetName="New-DDEvent:ByTimestamp"
        )]
        [ValidateNotNullOrEmpty()]
        [String]$Hostname,

         [Parameter(
            Position=5,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$false,
            Mandatory=$False,
            HelpMessage="A list of tags to associate with the event, as string or array of strings",
            ParameterSetName="Default"
        )]
         [Parameter(
            Position=5,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$false,
            Mandatory=$False,
            HelpMessage="A list of tags to associate with the event, as string or array of strings",
            ParameterSetName="New-DDEvent:ByDate"
        )]
        [Parameter(
            Position=5,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$false,
            Mandatory=$False,
            HelpMessage="A list of tags to associate with the event, as string or array of strings",
            ParameterSetName="New-DDEvent:ByTimestamp"
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tags,

        [Parameter(
            Position=6,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="Severity of the event. Can be 'error', 'warning', 'info' or 'success'. Default is 'info'.",
            ParameterSetName="Default"
        )]
        [Parameter(
            Position=6,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="Severity of the event. Can be 'error', 'warning', 'info' or 'success'. Default is 'info'.",
            ParameterSetName="New-DDEvent:ByTimestamp"
        )]
        [Parameter(
            Position=6,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="Severity of the event. Can be 'error', 'warning' or 'success'. Default is 'info'.",
            ParameterSetName="New-DDEvent:ByDate"
        )]
        [ValidateSet('error', 'warning', 'success')]
        [ValidateNotNullOrEmpty()]
        [String]$AlertType,

        [Parameter(
            Position=7,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="An arbitrary string to use for aggregation, max length of 100 characters.",
            ParameterSetName="Default"
        )]
        [Parameter(
            Position=7,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="An arbitrary string to use for aggregation, max length of 100 characters.",
            ParameterSetName="New-DDEvent:ByDate"
        )]
         [Parameter(
            Position=7,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="An arbitrary string to use for aggregation, max length of 100 characters.",
            ParameterSetName="New-DDEvent:ByTimestamp"
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 100)]
        [String]$AggregationKey,

        [Parameter(
            Position=8,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="The type of event being posted.",
            ParameterSetName="Default"
        )]
        [Parameter(
            Position=8,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="The type of event being posted.",
            ParameterSetName="New-DDEvent:ByDate"
        )]
        [Parameter(
            Position=8,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$False,
            Mandatory=$False,
            HelpMessage="The type of event being posted.",
            ParameterSetName="New-DDEvent:ByTimestamp"
        )]
        [ValidateSet('nagios', 'hudson', 'jenkins', 'user', 'my_apps', 'feed',
        'chef', 'puppet', 'git', 'bitbucket', 'fabric', 'capistrano')]
        [ValidateNotNullOrEmpty()]
        [String]$SourceTypeName
     )
    process {

        $Body = @{}

        $Body.Add('title', $Title)
        $Body.Add('text', $Text)
        if ($PSCmdlet.ParameterSetName -eq "New-DDEvent:ByDate") {
            $unixEpochStart = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
            $Timestamp = [int]($DateHappened - $unixEpochStart).TotalSeconds
            $Body.Add('date_happened',$Timestamp)
        }
        if ($PSCmdlet.ParameterSetName -eq "New-DDEvent:ByTimestamp") {
            $Body.Add('date_happened',$TimestampHappened)
        }
        if ($Priority) {
            $Body.Add('priority', $Priority)
        }
        if ($Hostname) {
            $Body.Add('host', $Hostname)
        }
        if ($Tags) {
            $Body.Add("tags",($Tags -join ','))
        }
        if ($AlertType) {
            $Body.Add('alert_type', $AlertType)
        }
        if ($AggregationKey) {
            $Body.Add('aggregation_key', $AggregationKey)
        }
        if ($SourceTypeName) {
            $Body.Add('source_type_name', $SourceTypeName)
        }

        $result = New-DDQuery -EndPoint "/events" -Method 'Post' -Body $($Body | ConvertTo-Json)  -RequiresApplicationKey -ErrorAction Stop
       
        # Build the default property set
        $defaultDisplaySet = 'event', 'status'
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $result | Add-Member MemberSet PSStandardMembers $PSStandardMembers

        return $result 
   
    }
}
