# Inspired from https://github.com/stuartleeks/PesterMatchHashtable
function Compare-Hashtable {
    [CmdletBinding()]
    param (
        [Parameter(
            Position=0,
            Mandatory=$True
        )]
        [hashtable]$value,

        [Parameter(
            Position=1,
            Mandatory=$True
        )]
        [hashtable]$expectedMatch
    )
    process {
        if($value.Count -ne $expectedMatch.Count){
            Write-Verbose 'Count is different'
            return $false;
        }

        foreach($expectedKey in $expectedMatch.Keys) {
            if (-not($value.Keys -contains $expectedKey)){
                write-verbose "key $expectedKey from ExpectedMatch is not in Value"
                return $false;
            }
            if (-not ($value[$expectedKey] -eq $expectedMatch[$expectedKey])){
                write-verbose "different values for $expectedKey"
                return $false;
            }
        }

        return $true;
    }
}