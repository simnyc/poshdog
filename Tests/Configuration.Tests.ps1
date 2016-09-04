$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

Import-Module $PSScriptRoot\..\PoshDog -Force

InModuleScope PoshDog {
    Describe "Running test for Set-DDConfiguration" {
        $testPath = "TestDrive:\test.txt"
        Context "Unit tests" {
            It "Should throw if the keys are not set" {      
                {  Set-DDConfiguration -DDAPIKey $null -DDAppKey $null -ErrorAction Stop } | Should Throw
            }
            It "Should not throw if correct parameters are passed" {
                { Set-DDConfiguration -DDAPIKey fooooo -DDAppKey barrr -ConfigFilePath $testPath } | Should Not Throw
            }
        }
        Context "Integration tests" {
            Set-DDConfiguration -DDAPIKey foo -DDAppKey bar -ConfigFilePath $testPath | Out-Null
            It "Writes the proper API Key to file" {
                Select-String -Pattern '"foo"' -Path $testPath | Should Not BeNullOrEmpty 
            }
            It "Writes the proper APP Key to file" {
                Select-String -Pattern '"bar"' -Path $testPath | Should Not BeNullOrEmpty 
            }   
        }
    }
}

InModuleScope PoshDog {
    Describe "Running test for Get-DDKey" {
        $testPath = "TestDrive:\test.txt"
        Context "Integration tests" {
            Set-DDConfiguration -DDAPIKey foo -DDAppKey bar -ConfigFilePath $testPath | Out-Null
            It "Returns the proper API Key from file" {
                Get-DDKey -ConfigFilePath $testPath | Should Be 'foo' 
            }
            It "Returns the proper APP Key from file" {
                Get-DDKey -ApplicationKey -ConfigFilePath $testPath | Should Be 'bar' 
            }
            Remove-Item $testPath -Force -ErrorAction Stop
            $env:dd_api_key = 'foofromenv'
            $env:dd_app_key = 'barfromenv'
            Mock Get-Item { Throw }
            It "Returns the proper API Key from Env" {
                Get-DDKey | Should Be 'foofromenv' 
            }
            It "Returns the proper APP Key from Env" {
                Get-DDKey -ApplicationKey | Should Be 'barfromenv' 
            }
        }
    }
}