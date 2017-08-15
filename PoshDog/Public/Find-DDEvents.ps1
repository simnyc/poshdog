function Find-DDEvents {
<#
    .SYNOPSIS
        Query the event stream.

    .DESCRIPTION

    .PARAMETER StartDate
        Date object, not compatible with StartTimestamp
    
    .PARAMETER StartTimestamp
        Unix timestamp, not compatible with StartDate

    .PARAMETER EndDate
        Date object, defaults to current time, not compatible with EndTimestamp
    
    .PARAMETER EndTimestamp
        Unix timestamp, defaults to current time, not compatible with EndDate

    .PARAMETER Priority
        Search for 'low' or 'normal' priority events. Default is none.

    .PARAMETER Sources
        A string or array of strings indicating what source, if any, should be used to filter events.

    .PARAMETER Tags
         A string or array of strings indicating what tags, if any, should be used to filter events.
#>

  [CmdletBinding(DefaultParameterSetName='Find-DDEvent:ByDate')]

    # All parameters belong to 2 sets: Find-DDEvent:ByDate and Find-DDEvent:ByTimestamp
    param (     
         [Parameter(
            Position=0,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$True,
            Mandatory=$True,
            HelpMessage="Start date",
            ParameterSetName="Find-DDEvent:ByDate"
        )]
        [ValidateNotNullOrEmpty()]
        [datetime]$StartDate,

        [Parameter(
            Position=1,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$True,
            Mandatory=$True,
            HelpMessage="End date",
            ParameterSetName="Find-DDEvent:ByDate"
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {if ($_ -lt $StartDate) {throw [System.ArgumentException]::New('EndDate cannot be before StartDate') } else {return $True} } )]
        [datetime]$EndDate,

        [Parameter(
            Position=0,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$True,
            Mandatory=$True,
            HelpMessage="Start timestamp",
            ParameterSetName="Find-DDEvent:ByTimestamp"
        )]
        # [int]$null is 0, so we can't use [ValidateNullOrEmpty]
        [ValidateScript( {if ($_ -eq 0) {throw [System.ArgumentException]::New('Cannot bind argument to parameter <<StartTimestamp>> because it is null or 0.') } else {return $True} } )]
        [Double]$StartTimestamp,

        [Parameter(
            Position=1,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False,
            ValueFromRemainingArguments=$True,
            Mandatory=$True,
            HelpMessage="End timestamp",
            ParameterSetName="Find-DDEvent:ByTimestamp"
        )]
        # [int]$null is 0, so we can't use [ValidateNullOrEmpty]
        [ValidateScript( {if ($_ -eq 0) {throw [System.ArgumentException]::New('Cannot bind argument to parameter <<EndTimestamp>> because it is null or 0.') } else {return $True} } )]
        [ValidateScript( {if ($_ -lt $StartTimestamp) {throw [System.ArgumentException]::New('EndTimestamp cannot be before StartTimestamp') } else {return $True} } )]
        [Double]$EndTimestamp,

        [Parameter(
            Position=2,
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$True,
            Mandatory=$False,
            HelpMessage="Search for 'low' or 'normal' priority events. Default is none.",
            ParameterSetName="Find-DDEvent:ByDate"
        )]
        [Parameter(
            Position=2,
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$True,
            Mandatory=$False,
            HelpMessage="Search for 'low' or 'normal' priority events. Default is none.",
            ParameterSetName="Find-DDEvent:ByTimestamp"
        )]
        [ValidateSet("low","normal")]
        [string[]]$Priority,

        [Parameter(
            Position=3,
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            Mandatory=$False,
            HelpMessage="A string or array of strings indicating what source, if any, should be used to filter events.",
            ParameterSetName="Find-DDEvent:ByDate"
        )]
        [Parameter(
            Position=3,
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            Mandatory=$False,
            HelpMessage="A string or array of strings indicating what source, if any, should be used to filter events.",
            ParameterSetName="Find-DDEvent:ByTimestamp"
        )]
        [string[]]$Sources,

        [Parameter(
            Position=4,
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            Mandatory=$False,
            HelpMessage="A string or array of strings indicating what tags, if any, should be used to filter the list of monitors by scope",
            ParameterSetName="Find-DDEvent:ByDate"
        )]
        [Parameter(
            Position=4,
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            Mandatory=$False,
            HelpMessage="A string or array of strings indicating what tags, if any, should be used to filter the list of monitors by scope",
            ParameterSetName="Find-DDEvent:ByTimestamp"
        )]
        [string[]]$Tags
    )

    process {
        $Body = @{}

        if ($PSCmdlet.ParameterSetName -eq 'Find-DDEvent:ByDate') {
            $StartTimestamp = ConvertFrom-Date -Date $StartDate
            $EndTimestamp = ConvertFrom-Date -Date $EndDate
        }
        $Body.Add('start',$StartTimestamp)
        $Body.Add('end',$EndTimestamp)
        if ($Priority) {
            $Body.Add('priority',$Priority)
        }
        if ($Sources) {
            $Body.Add('sources',$Sources)
        }
        if ($Tags) {
            $Body.Add('tags',$Tags)
        }

        $result = New-DDQuery -EndPoint '/events' -Method 'Get' -Body $Body -RequiresApplicationKey -ErrorAction Stop

        $defaultDisplaySet = 'events'
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $result | Add-Member MemberSet PSStandardMembers $PSStandardMembers

        return $result
    }
}
