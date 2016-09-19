function Get-DDTag {
<#
    .SYNOPSIS
        Retrieves a mapping of tags to hosts for your whole infrastructure when called with -All, or the list of tags that apply to a given host when called with -Hostname.

    .DESCRIPTION

    .PARAMETER All
        Returns a mapping of tags to hosts for your whole infrastructure. Incompatible with -Hostname.

    .PARAMETER Hostname
        A hostname as shown on Datadog's Infrastructure List. Incompatible with -All.

    .PARAMETER Source
        Only shows tags from a particular source. Valid sources are: nagios, hudson, jenkins, users, feed, chef, puppet, git, bitbucket, fabric, capistrano. 
    
    .Parameter BySource
        Returns tags grouped by source. Incompatible with -All.

    .EXAMPLE
        # Get a list of all tags
        Get-DDTag -All

    .EXAMPLE
        # Get a list of all tags coming from nagios
        Get-DDTag -All -Source nagios

    .EXAMPLE
        # Get a list of all tags for host myhost, grouped by source
        Get-DDTag -Hostname myhost -BySource

    .LINK
        http://docs.datadoghq.com/api/?lang=console#tags-get
        http://docs.datadoghq.com/api/?lang=console#tags-get-host
        
    .FUNCTIONALITY
    
#>
    [CmdletBinding()]
    param (     
        [Parameter(
            Mandatory=$True,
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false,
            ParameterSetName="Get-DDTag:All"
        )]
        [switch]$All,

        [Parameter(
            Position=0,
            Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            ParameterSetName="Get-DDTag:ByHostname"
        )]
        [Alias('Computername')]
        [ValidateNotNullOrEmpty()]
        [string]$Hostname,

        # Can be part of both Parameter Sets
        [Parameter(
            Position=1,
            ValueFromPipeline=$False,
            ValueFromRemainingArguments=$True,
            ParameterSetName="Get-DDTag:All"
        )]
        [Parameter(
            Position=1,
            ValueFromPipeline=$False,
            ValueFromRemainingArguments=$True,
            ParameterSetName="Get-DDTag:ByHostname"
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('nagios', 'hudson', 'jenkins', 'users',
         'feed', 'chef', 'puppet', 'git', 'bitbucket', 'fabric', 'capistrano' )]
        [string]$Source,
        
        [Parameter(
            Position=2,
            ValueFromPipeline=$False,
            ParameterSetName="Get-DDTag:ByHostname"
        )]
        [switch]$BySource
        )

    process {
        if ($Source -or $BySource) {
            $Body = @{} 
        }
        if ($Source) {
            $Body.Add('source',$Source)
        }
        if ($BySource) {
            $Body.Add('by_source','True')
        }
        if ($PSCmdlet.ParameterSetName -eq "Get-DDTag:All") {
            $Endpoint = '/tags/hosts'
        }
        else {
            # Parameter Set is Get-DDTag:ByHostname
            $Endpoint = "/tags/hosts/$Hostname"
            $defaultDisplaySet = 'tags'
        }
        
        $result = New-DDQuery -EndPoint $Endpoint -Method 'Get' -Body $Body -RequiresApplicationKey -ErrorAction SilentlyContinue -ErrorVariable err 

        if ($result -eq $null) {
            Write-Verbose "Get-DDTag: The query returned nothing. The server returned $err"
        }
        
        $defaultDisplaySet = 'tags'   
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $result | Add-Member MemberSet PSStandardMembers $PSStandardMembers

        return $result
        
    }
}
