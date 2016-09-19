#Get public and private function definition files.
    $Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
    $Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
    Foreach($import in @($Public + $Private))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import file $($import.fullname): $_"
        }
    }
Set-Alias -Name Mute-DDMonitor -Value Suspend-DDMonitor -Description 'Mutes Datadog monitors.' -Force
Set-Alias -Name Unmute-DDMonitor -Value Resume-DDMonitor -Description 'Unmutes Datadog monitors.' -Force
Set-Alias -Name Mute-DDHost -Value Suspend-DDHost -Description 'Mutes Datadog hosts.' -Force
Set-Alias -Name Unmute-DDHost -Value Resume-DDHost -Description 'Unmutes Datadog hosts.' -Force

# Here I might...
    # Read in or create an initial config file and variable
    # Export Public functions ($Public.BaseName) for WIP modules
    # Set variables visible to the module and its functions only

Export-ModuleMember -Function $Public.Basename -Alias *