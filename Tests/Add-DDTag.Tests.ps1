$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

Import-Module $PSScriptRoot\..\PoshDog -Force
# 
InModuleScope PoshDog {
    Describe 'Parameter handling for Add-DDTag' {
        Mock New-DDQuery {}
        $Tags= @('role:frontent','env:prod')
            It 'Throws if Hostname is empty' {      
                {  Add-DDTag -Hostname $null -Tags $Tags } | Should Throw
            }
            It 'Throws if Tags is empty' {      
                {  Add-DDTag -Hostname 'myhost' -Tags $null } | Should Throw
            }
            It 'Throws if called with an invalid source' {      
                {  Add-DDTag -Hostname 'myhost' -Source 'some source'} | Should Throw
            }
        }
    Describe "'Function's Logic for Add-DDTag" {
        Mock New-DDQuery {}
        $MockTags= @('role:frontent','env:prod')
        $MockBody = @{'tags'=$MockTags}
        It 'Calls New-DDQuery with a /tags/hosts/myhost Endpoint, a Post method and a valid Body' {
            Add-DDTag -Hostname myhost -Tags $MockTags
            Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/tags/hosts/myhost' -and $Method -eq 'Post' -and $Body -eq ($MockBody | ConvertTo-Json)}
        }
        $MockBody = @{'tags'=$MockTags;'source'='nagios'}
        It 'Calls New-DDQuery with a valid Body when Source is specified' {
            Add-DDTag -Hostname myhost -Tags $MockTags -Source 'nagios'
            Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/tags/hosts/myhost' -and $Method -eq 'Post' -and $Body -eq ($MockBody | ConvertTo-Json)}
        }
    } 
}