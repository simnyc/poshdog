# PoshDog

PoshDog is a Powershell module that makes it easy to interact with [Datadog's REST API](http://docs.datadoghq.com/api/?lang=console).

## Instructions

### Install the module

Manual install:

* [Download](https://github.com/RamblingCookieMonster/PSStackExchange/archive/master.zip) the repository from Github
* [Unblock](https://technet.microsoft.com/en-us/library/hh849924.aspx) the zip file: `unblock-file master.zip`
* Extract the Poshdog folder to a module path (e.g. `$env:USERPROFILE\Documents\WindowsPowerShell\Modules\)`

If you're running a modern version of Powershell you can get it from the [Powershell Galery](https://www.powershellgallery.com/packages/poshdog/):

 ```
 # Install the module for your user only 
 Install-Module poshdog -force -Scope CurrentUser
 
 # and import it into your session
 Import-Module poshdog

 ```

### Get started!

First, take a look at the commands exported by this module:

```
PS C: simon> Get-Command -Module poshdog

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Edit-DDMonitor                                     0.0.2      poshdog
Function        Get-DDMonitor                                      0.0.2      poshdog
Function        New-DDMonitor                                      0.0.2      poshdog
Function        Remove-DDMonitor                                   0.0.2      poshdog
Function        Resume-DDHost                                      0.0.2      poshdog
Function        Resume-DDMonitor                                   0.0.2      poshdog
Function        Set-DDConfiguration                                0.0.2      poshdog
Function        Suspend-DDHost                                     0.0.2      poshdog
Function        Suspend-DDMonitor                                  0.0.2      poshdog
...
```

To find out what a command is doing, simply type:

```
Get-Help Get-DDMonitor -Full

NOM
    Get-DDMonitor

SUMMARY
    Retrieves a list of all existing Datadog monitors with -All or a specific one with -MonitorID.


SYNTAXE
    Get-DDMonitor [-All] [-GroupStates <String[]>] [-Tags <String[]>] [<CommonParameters>]

    Get-DDMonitor [-MonitorId] <UInt32> [-GroupStates <String[]>] [<CommonParameters>]

...
```

The next thing you'll want to do is to set the required credentials to query Datadog's API. Go on to the [Integrations / API](https://app.datadoghq.com/account/settings#api) page, record your API key and an Application key (create one if needed).

Now in Powershell type in:

```
Set-DDConfiguration -DDApiKey YOUR_API_KEY_GOES_HERE -DDAppKey YOUR_APP_KEY_GOES_HERE 
```

This will create a file in `Env:APPDATA\PoshDog\` which will be used by the module later on.


## Examples

Now let's see what you can do with Poshdog.

### List all existing monitors

```
PS C: > Get-DDMonitor -All

name                                           id query
----                                           -- -----
Process ntp                                167104 "process.up".over("host:vagrant-ubuntu-trusty-64","process:ntp").last(4).count_by_status()
Host is missing                            521296 "datadog.agent.up".over("host:vagrant-ubuntu-14-04").by("host").last(2).count_by_status()
CPU usage is high on container             168971 avg(last_5m):avg:system.cpu.idle{container} by {host} < 20
CPU usage on Windows box                   258201 avg(last_5m):avg:system.cpu.system{host:vagrant-w2k12r2} > 40
My new monitor #4                          869838 avg(last_5m):sum:system.net.bytes_rcvd{*} > 100
...

```

### It's all objects!

Poshdog follows Powershell best practice to always return objects. This means you can feed these objects to other commandlets, just like you're used to.  
To list only those monitors that talk about Windows, try:

```
PS C: simon> Get-DDMonitor -All | where Name -Match windows

name                         id query
----                         -- -----
CPU usage on Windows box 258201 avg(last_5m):avg:system.cpu.system{host:vagrant-w2k12r2} > 40

```

### Default properties

The other recommendation we follow is to give these objects a [Default Display Property Set](http://powershell.com/cs/blogs/tips/archive/2013/01/24/using-propertysets.aspx) so that by default the output only shows properties that are thought useful most of the time.  
To display all properties you can pipe the command to `| Select -Property *`.


### Do more faster!

Now let's say you must mute that monitor. There is a commandlet called `Suspend-DDMonitor` that does just that.  
Now, you _could_ record the monitor ID and run `Suspend -MonitorID 258201`, but why bother? Let Powershell do the work for you:

```
PS C: simon> Get-DDMonitor -All | where Name -Match windows | Suspend-DDMonitor

Confirmation
Are you sure you want to perform this action ?
Performing the operation « Suspend-DDMonitor » on target « Muting monitor 258201 ».
[Y] YES  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is  « Y ») : Y


id            : 258201
name          : CPU usage on Windows box
type          : metric alert
query         : avg(last_5m):avg:system.cpu.system{host:vagrant-w2k12r2} > 40
overall_state : No Data
message       : {{#is_alert}}cpu is hight{{/is_alert}}

                {{#is_no_data}}No cpu data received!{{/is_no_data}}

                {{#is_recovery}}cpu is ok{{/is_recovery}}

                @simon.morand@datadoghq.com
options       : @{notify_audit=False; timeout_h=0; silenced=; no_data_timeframe=2; notify_no_data=True; renotify_interval=0}
creator       :
created       : 2015-08-24T19:29:17.785620+00:00
modified      : 2015-08-24T21:04:43.202252+00:00

```

How does it work? The `Suspend-DDMonitor` command recognizes the `ID` property in the object sent by `Get-DDMonitor` an automatically uses it.

### Edit a monitor

Let's say you need to edit a monitor's definition. You can do that with the `Edit-DDMonitor` commandlet:

```
# Retrieve the monitor
PS C: simon> $m=Get-DDMonitor -MonitorId 258201
PS C: simon> $m.query
avg(last_5m):avg:system.cpu.system{host:vagrant-w2k12r2} > 40

# Edit the query property
PS C: simon> $m.query = 'avg(last_5m):avg:system.cpu.system{host:vagrant-w2k12r2} > 400'
PS C: simon> $m.query
avg(last_5m):avg:system.cpu.system{host:vagrant-w2k12r2} > 400

# Send back the edited object
PS C: simon> $m | Edit-DDMonitor


id       : 258201
name     : CPU usage on Windows box
type     : metric alert
query    : avg(last_5m):avg:system.cpu.system{host:vagrant-w2k12r2} > 400
message  : {{#is_alert}}cpu is hight{{/is_alert}}

           {{#is_no_data}}No cpu data received!{{/is_no_data}}

           {{#is_recovery}}cpu is ok{{/is_recovery}}

           @simon.morand@datadoghq.com
options  : @{notify_audit=False; locked=False; timeout_h=0; silenced=; no_data_timeframe=2; notify_no_data=True; renotify_interval=0}
modified : 2016-09-08T20:58:10.793850+00:00

```

### Mute a host

Yes, you've guessed it, there's a commandlet for that:

```
PS C: simon> Suspend-DDHost -Hostname myhost -Message 'Down for a short maintenance window' -EndDate (Get-DAte).AddHours(1) -Override -Confirm:$False

hostname action message
-------- ------ -------
myhost   Muted  Down for a short maintenance window

```

## Contribute

Poshdog only covers a small portion of the API right now. If you'd like to help, simply [fork](https://help.github.com/articles/fork-a-repo/) the project and [submit](https://help.github.com/articles/creating-a-pull-request-from-a-fork/) a Pull Request.

You can also [open issues](https://help.github.com/articles/creating-a-pull-request-from-a-fork/).

### Test test test

Poshdogs uses [Pester](https://github.com/pester/Pester) to run unit and integration tests. So far only a [handful](https://github.com/simnyc/poshdog/tree/master/Tests) of tests have been written, but the goal is to get a near complete coverage.
If you do contribute, please write tests if possible. You could also just submit new tests :-)

