$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

Import-Module $PSScriptRoot\..\PoshDog -Force
# 
InModuleScope PoshDog {
    Describe 'Running unit tests on Remove-DDMonitor' {
        Mock New-DDQuery {}
        Context 'Parameter handling' {
            It "Throws if the Monitor ID is not an int" {      
                {  Remove-DDMonitor -MonitorID 'illegal value' -Confirm:$False} | Should Throw 'Input string was not in a correct format'
            }
            It "Throws if the Monitor ID is null or 0" {      
                {  Remove-DDMonitor -MonitorID 0 -Confirm:$False} | Should Throw 
            }
             It 'Throws if the Monitor ID is null or 0' {      
                {  Remove-DDMonitor -MonitorID $null -Confirm:$False} | Should Throw 'it is null or 0'
            }
        }
        Context "Function's logic" {
            It 'Calls New-DDQuery with a /monitor/123456 endpoint, a Delete method and a null body' {
                Remove-DDMonitor -MonitorId 123456 -Confirm:$False
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/monitor/123456' -and $Method -eq 'Delete' -and $Body -eq $null}
            }
        }
    }
}