$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

Import-Module $PSScriptRoot\..\PoshDog -Force

InModuleScope PoshDog {
    Describe "Running test for Get-DDMonitor" {
        $env:dd_api_key = 'foofromenv'
        $env:dd_app_key = 'barfromenv'
        Context "Unit tests" {
            It "Should throw if the Monitor ID is not an int" {      
                {  Get-DDMonitor -MonitorID 'illegal value' } | Should Throw "Input string was not in a correct format"
            }
        }
    }
}