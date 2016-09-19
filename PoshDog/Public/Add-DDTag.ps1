function Add-DDTag {
<#
    .SYNOPSIS
        Add tags to a host.

    .DESCRIPTION

    .PARAMETER Hostname
        A hostname as shown on Datadog's Infrastructure List page.

    .Parameter Tags
        String or array of strings representing the tags to apply to the host.

    .PARAMETER Source
        Specify a source for the tags. Valid sources are: nagios, hudson, jenkins, users, feed, chef, puppet, git, bitbucket, fabric, capistrano. 

    .EXAMPLE
        # Add a tag 'role:frontend' coming from Nagios to host 'myhost'
        Add-DDTag -Hostname 'myhost' -Tags 'role:frontend' -Source 'nagios'

    .LINK
        http://docs.datadoghq.com/api/?lang=console#tags-add
        
    .FUNCTIONALITY
    
#>
    [CmdletBinding()]
    param (     
        [Parameter(
            Position=0,
            Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True
        )]
        [Alias('Computername')]
        [ValidateNotNullOrEmpty()]
        [string]$Hostname,

        [Parameter(
            Position=1,
            Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tags,
        
        [Parameter(
            Position=2,
            Mandatory=$False,
            ValueFromPipeline=$False,
            ValueFromRemainingArguments=$True
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('nagios', 'hudson', 'jenkins', 'users',
         'feed', 'chef', 'puppet', 'git', 'bitbucket', 'fabric', 'capistrano' )]
        [string]$Source
    )   

    process {
        $Body = @{} 
        $Body.Add('tags',$Tags)
        if ($Source) {
            $Body.Add('source',$Source)
        }
        
        $result = New-DDQuery -EndPoint "/tags/hosts/$Hostname" -Method 'Post' -Body ($Body | ConvertTo-Json) -RequiresApplicationKey -ErrorAction Stop 
        
        $defaultDisplaySet = 'tags'   
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $result | Add-Member MemberSet PSStandardMembers $PSStandardMembers
        
        return $result
        
    }
}
