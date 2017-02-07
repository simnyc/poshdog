$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

Import-Module $PSScriptRoot\..\PoshDog -Force
# 
InModuleScope PoshDog {
    Describe 'Running unit tests on Get-DDMonitor' {
        $env:dd_api_key = 'foofromenv'
        $env:dd_app_key = 'barfromenv'
        Context 'Parameter handling' {
            It "Throws if the Monitor ID is not an int" {      
                {  Get-DDMonitor -MonitorID 'illegal value' } | Should Throw
            }
             It 'Throws if the Monitor ID is null or 0' {      
                {  Get-DDMonitor -MonitorID $null } | Should Throw 'it is null or 0'
            }
        }

        Context 'Parameter set "Get-DDMonitor:All"' {
            Mock New-DDQuery {}
            It 'Calls New-DDQuery with a /monitor endpoint' {
                Get-DDMonitor -All
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/monitor'}
            }

            $MockBody= @{'group_states'='alert'}
            Mock New-DDQuery {}
            It 'Calls New-DDQuery with a valid GroupStates when GroupStates is a string' {
                Get-DDMonitor -All -GroupStates 'alert'
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/monitor' -and (Compare-HashTable $MockBody $Body)}
            }

            $MockGroupStates = @('alert','warn')
            $MockBody=@{'group_states'=($MockGroupStates -join ',')}
            Mock New-DDQuery {}
            It 'Calls New-DDQuery with a valid GroupStates when GroupStates is an array of strings' {
                Get-DDMonitor -All -GroupStates $MockGroupStates
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/monitor' -and (Compare-HashTable $MockBody $Body)}
            }
            
            $MockBody=@{'tags'='role:frontend'}
            Mock New-DDQuery {}
            It 'Calls New-DDQuery with a valid Tags when Tags is a string' {
                Get-DDMonitor -All -Tags 'role:frontend'
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/monitor' -and (Compare-HashTable $MockBody $Body)}
            }

            $MockTags = @('role:frontent','host:myhostname')
            $MockBody=@{'tags'=($MockTags -join ',')}
            Mock New-DDQuery {}
            It 'Calls New-DDQuery with a valid Tags when Tags is an array of strings' {
                Get-DDMonitor -All -Tags $MockTags
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/monitor' -and (Compare-HashTable $MockBody $Body)}
            }

            $MockTags = @('role:frontent','host:myhostname')
            $MockGroupStates = @('alert','warn')
            $MockBody=@{}
            $MockBody.Add('tags',($MockTags -join ','))
            $MockBody.Add('group_states',($MockGroupStates -join ','))
            Mock New-DDQuery {}
            It 'Calls New-DDQuery with a valid Tags and GroupStates' {
                Get-DDMonitor -All -Tags $MockTags -GroupStates $MockGroupStates
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/monitor' -and (Compare-HashTable $MockBody $Body)}
            }    
        }

        Context 'Parameter set "Get-DDMonitor:ByID"' {
            Mock New-DDQuery {}
            It 'Calls New-DDQuery with a /monitor/123456 endpoint' {
                Get-DDMonitor -MonitorId 123456
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/monitor/123456'}
            }
            
            $MockBody= @{'group_states'='alert'}
            Mock New-DDQuery {}
            It 'Calls New-DDQuery with a valid GroupStates when GroupStates is a string' {
                Get-DDMonitor -MonitorId 123456 -GroupStates 'alert'
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/monitor/123456' -and (Compare-HashTable $MockBody $Body)}
            }
          
            $MockGroupStates = @('alert','warn')
            $MockBody=@{'group_states'=($MockGroupStates -join ',')}
            Mock New-DDQuery {}
            It 'Calls New-DDQuery with a valid GroupStates when GroupStates is an array of strings' {
                Get-DDMonitor -MonitorId 123456 -GroupStates $MockGroupStates
                Assert-MockCalled New-DDQuery -Scope It -ParameterFilter {$Endpoint -eq '/monitor/123456' -and (Compare-HashTable $MockBody $Body)}
            }
        }
    }
}