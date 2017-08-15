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
        Context 'Parameter set "New-DDEvent:ByDate"' {
            It "Throws if DateHappened is null" {      
                { New-DDEvent -Title 'some title' -Text 'some text' -DateHappened $null } | Should Throw 
            }
            It "Throws if DateHappened is not a datetime" {      
                { [int]$d; New-DDEvent -Title 'some title' -Text 'some text' -DateHappened $d } | Should Throw 
            }
            It "Passes if DateHappened is a datetime" {      
                { New-DDEvent -Title 'some title' -Text 'some text' -DateHappened (Get-Date) } | Should Not Throw 
            }
        }
        Context 'Parameter set "New-DDEvent:ByTimestamp"' {
            It "Throws if TimestampHappened is null" {      
                {  New-DDEvent -Title 'some title' -Text 'some text' -TimestampHappened $null } | Should Throw 
            }
            It "Throws if TimestampHappened is not a digit" {      
                { New-DDEvent -Title 'some title' -Text 'some text' -TimestampHappened 'some value' } | Should Throw 
            }
            It "Passes if TimestampHappened is a double" {      
                { [double]$d=1489795234; New-DDEvent -Title 'some title' -Text 'some text' -TimestampHappened $d } | Should Not Throw 
            }
        }
        Context 'Parameter set "Default"' {
            It "Throws if Title is null" {      
                {  New-DDEvent -Title $null -Text 'some text' -DateHappened (Get-Date) } | Should Throw 
            }
            It "Throws if Text is null" {      
                {  New-DDEvent -Title 'some title' -Text $null -DateHappened (Get-Date) } | Should Throw 
            }
            It "Passes with just a Title and Text" {
                {  New-DDEvent -Title 'some title' -Text 'some text' } | Should Not Throw 
            }
            It "Throws if Priority is not an approved value" {      
                {  New-DDEvent -Title 'some title' -Text $null -DateHappened (Get-Date) -Priority 'some illegal value' } | Should Throw 
            }
            It "Throws if AlertType is not an approved value" {      
                {  New-DDEvent -Title 'some title' -Text $null -DateHappened (Get-Date) -AlertType 'some illegal value' } | Should Throw 
            }
            It "Throws if SourceTypeName is not an approved value" {      
                {  New-DDEvent -Title 'some title' -Text $null -DateHappened (Get-Date) -SourceTypeName 'some illegal value' } | Should Throw 
            }
           
        }
    }
    Describe "Funtion's logic for New-DDEvent" {
        $env:dd_api_key = 'foofromenv'
        $env:dd_app_key = 'barfromenv'
        Mock New-DDQuery {}
        Context 'Parameter set "Default"' {
            It 'Calls New-DDQuery with a /events endpoint, a POST method and a valid body' {                
                $MockBody= @{'title'='some title';'text'='some text'}
                New-DDEvent -Title 'some title' -Text 'some text'
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/events' -and $Method -eq 'Post' -and (($MockBody | ConvertTo-Json) -eq $Body)}
            }
        }
        Context 'Parameter set "New-DDEvent:ByTimestamp"' {
            It 'Calls New-DDQuery with a /events endpoint, a POST method and a valid body' {
                $MockBody= @{'title'='some title';'text'='some text';'date_happened'=1494560224}
                New-DDEvent -Title 'some title' -Text 'some text' -TimestampHappened 1494560224
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/events' -and $Method -eq 'Post' -and (($MockBody | ConvertTo-Json) -eq $Body)}
            }       
        }
        Context 'Parameter set "New-DDEvent:ByDate"' {
            It 'Calls New-DDQuery with a /events endpoint, a POST method and a valid body' {
                $unixEpochStart = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
                $MockBody= @{'title'='some title';'text'='some text';'date_happened'=0}
                New-DDEvent -Title 'some title' -Text 'some text' -DateHappened $unixEpochStart
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/events' -and $Method -eq 'Post' -and (($MockBody | ConvertTo-Json) -eq $Body)}
            }
            
        }
    }
}