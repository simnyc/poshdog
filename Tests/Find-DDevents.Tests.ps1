$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

Import-Module $PSScriptRoot\..\PoshDog -Force
InModuleScope PoshDog {
    Describe 'Parameter Handling' {
        $env:dd_api_key = 'foofromenv'
        $env:dd_app_key = 'barfromenv'
        Mock New-DDQuery {}
        Context 'Parameter set "Find-DDEvents:ByDate"' {
            It 'Throws if StartDate is null' {
                { Find-DDEvents -StartDate $nnull -EndDate (Get-date)  } | Should Throw 
            }
            It 'Throws if EndDate is null' {
                { Find-DDEvents -StartDate (Get-Date) -EndDate $null  } | Should Throw 
            }
            It 'Throws if StartDate is newer then EndDate' {
                #{ Find-DDEvents -StartDate (Get-Date).AddDays(1) -EndDate (Get-Date)  } | Should Throw 
                { Find-DDEvents -StartDate (get-date) -EndDate (get-date).AddDays(-1) } | Should Throw
            }
            It 'Passes if both dates are date objects' {
                { Find-DDEvents -StartDate (Get-Date) -EndDate (Get-date).AddDays(1)  } | Should Not Throw 
            }
        }
         Context 'Parameter set "Find-DDEvents:ByTimestamp"' {
            It 'Throws if StartDate is null' {
                { Find-DDEvents -StartTimestamp $null -EndTimestamp 1346273496 } | Should Throw 
            }
            It 'Throws if EndDate is null' {
                { Find-DDEvents -StartTimestamp 1346273496 -EndTimestamp $null } | Should Throw 
            }
            It 'Throws if StartDate is newer then EndDate' {
                { Find-DDEvents -StartTimestamp 1346273496 -EndTimestamp 1346273396 } | Should Throw 
            }
             It 'Passes if StartDate is older then EndDate' {
                { Find-DDEvents -StartTimestamp 1346274496 -EndTimestamp 1346275396 } | Should not Throw 
            }
            It 'Throws if Priority is not low or nomal' {
                {Find-DDEvents -StartTimestamp 1346274496 -EndTimestamp 1346275396 -Priority 'something' } | Should Throw 
            }
        }
    }
    Describe 'Function logic for Find-DDevents' {
        $env:dd_api_key = 'foofromenv'
        $env:dd_app_key = 'barfromenv'
        Mock New-DDQuery {}
        Context 'Parameter set "Find-DDEvents:ByTimestamp"' {
            It 'Calls New-DDQuery with a /events endpoint and proper timestamps' {
                $MockBody= @{'start'=1496715749;'end'=1496716749}
                Find-DDEvents -StartTimestamp 1496715749 -EndTimestamp 1496716749
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/events' -and $Method -eq 'Get' -and (Compare-HashTable $MockBody $Body)}
            }
            It 'Calls New-DDQuery with a /events endpoint, proper timestamps and low priority' {
                $MockBody= @{'start'=1496715749;'end'=1496716749; 'priority'='low'}
                Find-DDEvents -StartTimestamp 1496715749 -EndTimestamp 1496716749 -Priority low
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/events' -and $Method -eq 'Get' -and (Compare-HashTable $MockBody $Body)}
            }
            It 'Calls New-DDQuery with a /events endpoint, proper timestamps and normal priority' {
                $MockBody= @{'start'=1496715749;'end'=1496716749; 'priority'='normal'}
                Find-DDEvents -StartTimestamp 1496715749 -EndTimestamp 1496716749 -Priority normal
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/events' -and $Method -eq 'Get' -and (Compare-HashTable $MockBody $Body)}
            }
        }
        Context 'Parameter set "Find-DDEvents:ByDate"' {
            It 'Calls New-DDQuery with a /events endpoint and proper timestamps' {
                $MockBody= @{'start'=1;'end'=60}
                Find-DDEvents -StartDate (Get-Date -Date "1970-01-01 00:00:01Z").ToUniversalTime() -EndDate  (Get-Date -Date "1970-01-01 00:01:00Z").ToUniversalTime()
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/events' -and $Method -eq 'Get' -and (Compare-HashTable $MockBody $Body)}
            }
        }
    }
}
    