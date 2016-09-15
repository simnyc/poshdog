$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

Import-Module $PSScriptRoot\..\PoshDog -Force
# 
InModuleScope PoshDog {
    $FakeObject=[PSCustomObject]@{type='metric alert'; query='avg(last_5m):sum:system.net.bytes_rcvd{*} > 10000'}
    Describe 'Parameter handling for New-DDMonitor' {
        Mock New-DDQuery {}
        Context 'Using command line parameters' {
            It "Throws if Type is not one of the approved values" {      
                {  New-DDMonitor -Type 'illegal value' -Query 'some query' } | Should Throw
            }
            It 'Throws if Query is null' {      
                {  New-DDMonitor -Type 'metric alert' -Query $null } | Should Throw
            }
            It 'Throws if Message is null' {      
                {  New-DDMonitor -Type 'metric alert' -Query 'some query' -Message $null } | Should Throw
            }
            It 'Throws if Tags is null' {      
                {  New-DDMonitor -Type 'metric alert' -Query 'some query' -Tags $null } | Should Throw
            }
            It 'Throws if Options is null' {      
                {  New-DDMonitor -Type 'metric alert' -Query 'some query' -Options $null } | Should Throw
            }
            It 'Passes if MonitorObject is a custom object' {
                {  New-DDMonitor -MonitorObject $FakeObject } | Should Not Throw
            }
        }
        Context 'Using the pipiline' {
            It 'Passes if MonitorObject is sent through the  pipeline' {    
                {  $FakeObject | New-DDMonitor } | Should Not Throw
            }
        }
        Context "Function's logic" {
            It 'Calls New-DDQuery with a /monitor endpoint, a Post method and a non null body' {
                $MockBody= @{'type'='metric alert';'query'='some query'}
                New-DDMonitor -Type 'metric alert' -Query 'some query'
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/monitor' -and $Method -eq 'Post' -and (($MockBody | ConvertTo-Json) -eq $Body)}
            }
             It 'Calls New-DDQuery with a valid message' {
                $MockBody= @{'type'='metric alert';'query'='some query';'message'='some message'}
                New-DDMonitor -Type 'metric alert' -Query 'some query' -Message 'some message'
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/monitor' -and $Method -eq 'Post' -and (($MockBody | ConvertTo-Json) -eq $Body)}
            }
            It 'Calls New-DDQuery with a valid Tags when Tags is a string' {
                $MockBody= @{'type'='metric alert';'query'='some query';'tags'='some tag'}
                New-DDMonitor -Type 'metric alert' -Query 'some query' -Tags 'some tag'
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/monitor' -and $Method -eq 'Post' -and (($MockBody | ConvertTo-Json) -eq $Body)}
            }
            It 'Calls New-DDQuery with a valid Tags when Tags is an array of string' {
                $MockTags = @('role:frontent','host:myhostname')
                $MockBody= @{'type'='metric alert';'query'='some query';'tags'=$MockTags}
                New-DDMonitor -Type 'metric alert' -Query 'some query' -Tags $MockTags
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/monitor' -and $Method -eq 'Post' -and (($MockBody | ConvertTo-Json) -eq $Body)}
            }
            It 'Calls New-DDQuery with a valid Options ' {
                $MockOptions=@{'timeout_h'='12';'locked'='True'}
                $MockBody= @{'type'='metric alert';'query'='some query';'options'=$MockOptions}
                New-DDMonitor -Type 'metric alert' -Query 'some query' -Options $MockOptions
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/monitor' -and $Method -eq 'Post' -and (($MockBody | ConvertTo-Json) -eq $Body )}
            }
        }
    }
}