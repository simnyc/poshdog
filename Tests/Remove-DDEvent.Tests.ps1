$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

Import-Module $PSScriptRoot\..\PoshDog -Force
# 
InModuleScope PoshDog {
    Describe 'Running unit tests on Remove-DDEvent' {
        $env:dd_api_key = 'foofromenv'
        $env:dd_app_key = 'barfromenv'
        Mock New-DDQuery {}
        $FakeObject=[PSCustomObject]@{EventID=1234567890}
        Context 'Parameter handling' {
            It "Throws if the Event ID is not an int" {      
                {  Remove-DDEvent -EventID 'illegal value' } | Should Throw
            }
             It 'Throws if the Event ID is null or 0' {      
                {  Remove-DDEvent -EventID $null } | Should Throw 'it is null or 0'
            }
            It 'Passes if EventID is sent from the pipeline' {
                {$FakeObject | Remove-DDEvent } | Should Not Throw
            }
        }
        Context "Function's logic for Remove-DDEvent" {
            
            It 'Calls New-DDQuery with a /events/1234567890 endpoint, a Delete method and a null body' {
                Remove-DDEvent -EventID 1234567890 -Confirm:$False
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/events/1234567890'-and $Method -eq 'Delete' -and $Body -eq $null}
            }
            
        }
    }
}