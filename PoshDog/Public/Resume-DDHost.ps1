function Resume-DDHost {
<#
    .SYNOPSIS
        Unmutes Datadog hosts.
    .DESCRIPTION
            
    .PARAMETER Hostname
        A hostname as shown on Datadog's Infrastructure List
    
    .EXAMPLE
        # Unmute a host called myhost
        Resume-DDHost -Hostname myhost
        
    .LINK
        http://docs.datadoghq.com/api/?lang=console#hosts-unmute

    .FUNCTIONALITY   
#>

[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High',DefaultParameterSetName="Default")]
    param (        
        # Can be part of 3 parameter sets
        [Parameter(
            Position=0,
            Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            ValueFromRemainingArguments=$True,
            ParameterSetName="Default"
        )]
        [Alias('Computername')]
        [ValidateNotNullOrEmpty()]
        [string]$Hostname
    )

    process {
        if ($pscmdlet.ShouldProcess($ConfirmationMessage)) {
            $result = New-DDQuery -EndPoint "/host/$Hostname/unmute" -Method 'Post' -RequiresApplicationKey -ErrorAction Stop
        }
        else {
            Write-Verbose 'Task aborted by user'
            return
        }   

        $defaultDisplaySet = 'hostname', 'action'
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $result | Add-Member MemberSet PSStandardMembers $PSStandardMembers
        return $result
    }
}