function New-DDQuery {
<#
    .SYNOPSIS
        Make a request to the API with the parameters entered by the user

    .DESCRIPTION
        
    .PARAMETER APIVersion
        Version of the API, defaults to v1

    .PARAMETER EndPoint
        The API endpoint, as defined on http://docs.datadoghq.com/api/?lang=console, e.g /monitor  

    .PARAMETER Method
        The HTTP method used, should be one of GET, PUT, PUSH, DELETE

    .PARAMETER Body
        An object used as body for the HTTP request.
        If the request is a GET call, the body must be a Powershell hashtable, it will get added to the query parameters.
        If the request is NOT a GET, the body must be a JSON string.

    .PARAMETER RequiresApplicationKey
        The API call requires an application key to be set

    .EXAMPLE
        # A GET request with no Body:
        New-DDQuery -EndPoint $Endpoint -Method 'Get' -RequiresApplicationKey -ErrorAction Stop
        
    .EXAMPLE
        # A GET request with an array as -Body parameter
        $Body = @{'option1','value1'}
        New-DDQuery -EndPoint $Endpoint -Method 'Get' -Body $Body -RequiresApplicationKey -ErrorAction Stop

    .EXAMPLE
        # A POST request 
        New-DDQuery -EndPoint "/monitor" -Method 'Post' -Body $($MonitorObject | ConvertTo-Json)  -RequiresApplicationKey -ErrorAction Stop

    .LINK
        

    .FUNCTIONALITY
        
#>
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$APIVersion = "v1",
        
        [Parameter(
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Endpoint,

        [Parameter(
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false
        )]
        [ValidateSet("Get","Post","Put","Push","Delete")]
        [ValidateNotNullOrEmpty()]
        [string]$Method,

        [Parameter(
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false
        )]
        [AllowNull()]
        [object]$Body,
        
        [Parameter(
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            ValueFromRemainingArguments=$false
        )]
        [switch]$RequiresApplicationKey
    )
    process {
        $key_string = "?api_key="
        $key_string += (Get-DDKey -ErrorAction Stop)

        if ($RequiresApplicationKey) {
            Write-Verbose ""
            write-verbose "This API call also requires an APP KEY, adding it."
            $key_string += "&application_key="
            $key_string += (Get-DDKey -ApplicationKey -ErrorAction Stop)
        }

        $dd_url = "https://app.datadoghq.com/api/" + $APIVersion + $Endpoint + $key_string
        
        Try {
            $result = Invoke-RestMethod -Method $Method -Uri $dd_url -ContentType "application/json" -Body $Body
        }
        Catch {
            Throw "Request to Datadog API backend was NOT successful; It returned this: $_"
        }

        return $result
    }
}
