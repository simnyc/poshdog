function Get-DDKey {
<#
    .SYNOPSIS
        Search for API or App keys in different places

    .DESCRIPTION
        Get-DDKey will search for keys in different places:
            - in a standard JSON file within the user directory by default
            - in environment variables
            - in a specific JSON file when used with the -ConfigFilePath parameter. 

    .PARAMETER ApplicationKey
        Retrieves the Application Key instead of the default API Key.

    .EXAMPLE
        # Retrieves the API Key
        Get-DDKey -ErrorAction Stop
        
    .EXAMPLE
        # Retrieves the API Key from a file
        Get-DDKey -ErrorAction Stop -ConfigFilePath 'c:\file.json'

    .EXAMPLE
        # Retrieves the Application Key
        Get-DDKey -ApplicationKey -ErrorAction Stop
        
    .LINK
        

    .FUNCTIONALITY
        
#>
    [CmdletBinding()] 
    param (
        [Parameter (
            Position = 0,
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false
        )]
        [switch]$ApplicationKey,

        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigFilePath
    )  
    process {   
        if ($ApplicationKey) {
            $KeyType = "dd_app_key"
        }
        else {
            $KeyType = "dd_api_key"
        }

        Try {
            if (-not $ConfigFilePath) {
                Write-Verbose 'Looking for the configuration file at default location of %APPDATA%\PoshDog\keys.json'
                $ConfigFilePath = (Get-Item Env:APPDATA).value
                $ConfigFilePath += '\PoshDog\keys.json'
            }
            else {
                Write-Verbose "Path specified with value $ConfigFilePath, searching there"
            }
            Get-item $ConfigFilePath -ErrorAction Stop | Out-Null
            Write-Verbose "Found the file $ConfigFilePath"
            Try {
                Write-Verbose "Looking for the $KeyType key in the configuration file"
                $key= (Get-Content  $ConfigFilePath | ConvertFrom-Json).$KeyType
                if ($key) {
                    Write-Verbose "Key found!"
                    return $key
                }
                else {
                    Throw
                }
            }
            Catch {
                Write-Verbose "Could not find the $KeyType key in the file, continuing the search process"
            }
        }
        Catch {
            Write-Verbose "Unable to find the file, got this instead: $_"
            Continue
        }
        
        Try {
            Write-Verbose "Looking for an environment variable"
            $key = (Get-item Env:$KeyType -ErrorAction stop).value
            if ($key) {
                Write-Verbose "$KeyType found!"
                return $key
            }
            else {
                Throw
            }
            
        }
        Catch {
            Write-Verbose "Could not find the $KeyType key in Env, got this instead: $_"
        }
        Write-Error "Could not find the required key, try running Set-DDConfiguration"
    }
}