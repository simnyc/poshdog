function New-DDSearch {
<#
    .SYNOPSIS
        Search for entities from the last 24 hours in Datadog.

    .DESCRIPTION

    .PARAMETER Query
        The query string. 
        
    .PARAMETER Facet
        Limits results to an object type, chosen from: hosts, metrics. 

    .EXAMPLE
        # Search for metric or host object that match 'windows'
        New-DDSearch -Query 'windows'

    .EXAMPLE
        # Search for hosts that match 'db01'
        New-DDSearch -Query 'db01' -Facet hosts

    .EXAMPLE
        # Search for metrics that match 'replication'
        New-DDSearch -Query 'replication' -Facet metrics

    .LINK
        http://docs.datadoghq.com/api/?lang=console#search

    .FUNCTIONALITY
    
#>
    [CmdletBinding()]
    param (     
        [Parameter(
            Position=0,
            Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Query,
        
        [Parameter(
            Position=1,
            Mandatory=$False,
            ValueFromPipeline=$False,
            ValueFromPipelineByPropertyName=$False)]
        [ValidateSet("hosts", "metrics")]
        [ValidateNotNullOrEmpty()]
        [string]$Facet
    )

    process {
        $Body = @{}
        if ($Facet) {
            $Query = "${Facet}:${Query}"
        }
    
        $Body.Add('q',$Query)

        $result = New-DDQuery -EndPoint '/search' -Method 'Get' -Body $Body -RequiresApplicationKey -ErrorAction Stop 

        # Build the default property set
        $defaultDisplaySet = 'results'  
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $result | Add-Member MemberSet PSStandardMembers $PSStandardMembers

        return $result
    }
}
