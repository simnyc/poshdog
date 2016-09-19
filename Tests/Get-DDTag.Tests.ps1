$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

Import-Module $PSScriptRoot\..\PoshDog -Force
# 
InModuleScope PoshDog {
    Describe 'Parameter handling for Get-DDTag' {
        Mock New-DDQuery {}
        Context 'Parameter set "Get-DDTag:All"' {
            It 'Throws if called with Hostname' {      
                {  Get-DDTag -All -Hostname } | Should Throw
            }
            It 'Throws if called with an invalid source' {      
                {  Get-DDTag -All -Source 'some source'} | Should Throw
            }
        }
        Context 'Parameter set "Get-DDTag:ByHostname"' {
            It "Throws if Hostname is null" {      
                {  Get-DDTag -Hostname $null } | Should Throw
            }
            It 'Throws if called with an invalid source' {      
                {  Get-DDTag -Hostname myhost -Source 'some source'} | Should Throw
            }
            It 'Passes if called with a valid source' {      
                {  Get-DDTag -Hostname myhost -Source 'nagios'} | Should Not Throw
            }
            It 'Passes when Hostname is sent through the pipeline by value' {
                $HostName = 'myhost'
                {  $HostName | Get-DDTag} | Should Not Throw
            }
        }
    }
    Describe "Function's logic for Get-DDTag" {
        Mock New-DDQuery {}
        Context 'Parameter set "Get-DDTag:All"' {
            It 'Calls New-DDQuery with a /tags/hosts endpoint, a Get method and an empty body' {
                Get-DDTag -All
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/tags/hosts' -and $Method -eq 'Get' -and $Body -eq $null}
            }
            It 'Calls New-DDQuery with a valid Source when Source is set' {
                $MockBody= @{'source'='nagios'}
                Get-DDTag -All -Source 'nagios'
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/tags/hosts' -and $Method -eq 'Get' -and (Compare-HashTable $MockBody $Body)}
            }
        }
        Context 'Parameter set "Get-DDTag:ByHostname"' {
            It 'Calls New-DDQuery with a /tags/hosts/myhost endpoint, a Get method and an empty body' {
                Get-DDTag -Hostname 'myhost'
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/tags/hosts/myhost' -and $Method -eq 'Get' -and $Body -eq $null}
            }
            It 'Calls New-DDQuery with a valid Source when Source is set' {
                $MockBody= @{'source'='nagios'}
                Get-DDTag -Hostname 'myhost' -Source 'nagios'
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/tags/hosts/myhost' -and $Method -eq 'Get' -and (Compare-HashTable $MockBody $Body)}
            }
            It 'Calls New-DDQuery with a valid Endpoint when Hostname is sent through the Pipeline' {
                $Hostname = 'myhost'
                $Hostname | Get-DDTag
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/tags/hosts/myhost' -and $Method -eq 'Get' -and $Body -eq $null}
            }
        }
    }
}