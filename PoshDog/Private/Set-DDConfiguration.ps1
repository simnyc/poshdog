function Set-DDConfiguration {
<#
    .SYNOPSIS
        Creates a configuration file with Datadog keys to be used in subsequent requests

    .DESCRIPTION
        
    .EXAMPLE
        # Write keys in the standard  Env:APPDATA\PoshDog\keys.json file
        Set-DDConfiguration -DDAPIKey somekey -DDAppKey somekey
        
    .EXAMPLE
        # Write keys in an alternate file
        Set-DDConfiguration -DDAPIKey somekey -DDAppKey somekey -ConfigFilePath 'c:\file.json'
        
    .LINK
        
    .FUNCTIONALITY
        
#>
    [CmdletBinding()]
    Param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$DDAPIKey,
        
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$DDAppKey,

        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigFilePath
    )
    Process {
        $content = @{dd_api_key=$DDAPIKey;dd_app_key=$DDAppKey}| ConvertTo-Json -ErrorAction stop
        Try {
            if ($ConfigFilePath) {  
                Write-Verbose "The path $ConfigFilePath was specified, writting there"
                Set-Content -Path $ConfigFilePath -value $content -ErrorAction Stop | Out-Null   
            }
            else {
                Write-Verbose "Trying to create the configuration file at default location"
                $ConfigFilePath = (Get-Item Env:APPDATA).value
                $ConfigFilePath += "\PoshDog\keys.json"

                New-Item -ItemType Directory -Path (Split-Path $ConfigFilePath) -Force -ErrorAction Stop | Out-Null
                Set-Content -Path $ConfigFilePath -Value $Content -ErrorAction Stop | Out-Null
            }
            Write-Verbose "File $ConfigFilePath was successfully written to  disk"
            Write-Output "Configuration file successfully written at $ConfigFilePath"
        }
        Catch {        
            Throw "Could not write to file, got this instead: $_"
        }
    }
}
