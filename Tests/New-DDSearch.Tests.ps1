$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

Import-Module $PSScriptRoot\..\PoshDog -Force
# 
InModuleScope PoshDog {
    Describe 'Parameter handling for New-DDSearch' {
        Mock New-DDQuery {}
        It "Throws if Hostname is null" {      
            {  New-DDSearch -Query $null } | Should Throw
        }
        It 'Throws if called with an invalid Facet' {      
            {  New-DDSearch -Query myhost -Facet invalid } | Should Throw
        }
        It 'Passes if called with the "hosts" Facet' {      
            { New-DDSearch -Query myhost -Facet hosts} | Should Not Throw
        }
        It 'Passes if called with the "metrics" Facet' {      
            { New-DDSearch -Query myhost -Facet metrics} | Should Not Throw
        }
        It 'Passes when Hostname is sent through the pipeline by value' {
            $Query = 'myhost'
            {  $Query | New-DDSearch } | Should Not Throw
        }
    }
    Describe "Function's logic for New-DDSearch" {
        Mock New-DDQuery {}
        Context 'No faceting' {
            It 'Calls New-DDQuery with a /search endpoint, a Get method and proper body' {
                $MockBody= @{'q'='myhost'}
                New-DDSearch -Query myhost
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/search' -and $Method -eq 'Get' -and (Compare-HashTable $MockBody $Body)}
            }
        }
        Context 'With hosts faceting' {
            It 'Calls New-DDQuery with a /search endpoint, a Get method and proper body' {
                $MockBody= @{'q'='hosts:myhost'}
                New-DDSearch -Query myhost -Facet hosts
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/search' -and $Method -eq 'Get' -and (Compare-HashTable $MockBody $Body)}
            }
        }
        Context 'With metrics faceting' {
            It 'Calls New-DDQuery with a /search endpoint, a Get method and proper body' {
                $MockBody= @{'q'='metrics:mymetric'}
                New-DDSearch -Query mymetric -Facet metrics
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/search' -and $Method -eq 'Get' -and (Compare-HashTable $MockBody $Body)}
            }
        }
    }
}