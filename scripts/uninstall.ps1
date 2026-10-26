# MIT License. This does NOT remove Windows Autologon settings or credentials.
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$TaskName = 'DesktopCommander-Public-Watchdog',
    [switch]$RemoveLocalData
)
$ErrorActionPreference = 'Stop'
$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($task -and $PSCmdlet.ShouldProcess($TaskName, 'Remove scheduled task')) {
    Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host 'Removed scheduled task.'
}
if ($RemoveLocalData) {
    $base = Join-Path $env:LOCALAPPDATA 'DesktopCommanderAutoReconnect'
    if ((Test-Path $base) -and $PSCmdlet.ShouldProcess($base, 'Remove watchdog/runtime files and logs')) {
        Remove-Item -LiteralPath $base -Force -Recurse
        Write-Host 'Removed local runtime and logs.'
    }
}
Write-Host 'Windows sign-in/Autologon settings were not changed.'
