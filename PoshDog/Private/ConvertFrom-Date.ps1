function ConvertFrom-Date {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$True)]
        [datetime]$Date
    )
    process{
        $unixEpochStart = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
        return ([uint32]($Date - $unixEpochStart).TotalSeconds)
    }
}