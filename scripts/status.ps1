# MIT License. Print operational state, never secrets.
[CmdletBinding()]
param([string]$TaskName = 'DesktopCommander-Public-Watchdog')
$ErrorActionPreference = 'Stop'
$base = Join-Path $env:LOCALAPPDATA 'DesktopCommanderAutoReconnect'
$entry = Join-Path $base 'runtime\node_modules\@wonderwhy-er\desktop-commander\dist\index.js'
$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
$info = if ($task) { Get-ScheduledTaskInfo -TaskName $TaskName } else { $null }
$running = @(Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
    Where-Object { $_.CommandLine -and
        ($_.CommandLine -match 'desktop-commander[\\/]dist[\\/]index[.]js.*\bremote\b') })
[pscustomobject]@{
    RuntimeInstalled = Test-Path -LiteralPath $entry
    TaskInstalled = ($null -ne $task)
    TaskState = if ($task) { $task.State.ToString() } else { 'NotInstalled' }
    LastRunTime = if ($info) { $info.LastRunTime } else { $null }
    RemoteProcessCount = $running.Count
    AgentProcessIds = @($running | Select-Object -ExpandProperty ProcessId)
}
$log = Join-Path $base 'watchdog.log'
if (Test-Path -LiteralPath $log) {
    Write-Host 'Last watchdog events:'
    Get-Content -LiteralPath $log -Tail 8
}
Write-Host 'Note: process presence does NOT prove remote cloud connectivity. Verify with a remote tool call.'
