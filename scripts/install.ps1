# MIT License. Install only for the current interactive Windows user.
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$PackageVersion = '0.3.1',
    [string]$TaskName = 'DesktopCommander-Public-Watchdog'
)
$ErrorActionPreference = 'Stop'
if ($env:OS -ne 'Windows_NT') { throw 'Windows only.' }
$node = Get-Command node.exe -ErrorAction Stop
$npm = Get-Command npm.cmd -ErrorAction Stop
$base = Join-Path $env:LOCALAPPDATA 'DesktopCommanderAutoReconnect'
$runtime = Join-Path $base 'runtime'
$script = Join-Path $base 'watchdog.ps1'
$source = Join-Path $PSScriptRoot 'watchdog.ps1'
if (-not (Test-Path -LiteralPath $source)) { throw 'watchdog.ps1 missing' }
if (-not $PSCmdlet.ShouldProcess($env:USERNAME, 'Install Desktop Commander Remote watchdog and scheduled task')) { return }

New-Item -ItemType Directory -Force -Path $runtime | Out-Null
Write-Host "Installing pinned Remote Device version $PackageVersion..."
& $npm.Source install --prefix $runtime --no-fund --no-audit --ignore-scripts "@wonderwhy-er/desktop-commander@$PackageVersion"
if ($LASTEXITCODE -ne 0) { throw "npm failed: $LASTEXITCODE" }
$entry = Join-Path $runtime 'node_modules\@wonderwhy-er\desktop-commander\dist\index.js'
if (-not (Test-Path -LiteralPath $entry)) { throw 'Remote Device entrypoint missing after npm install.' }
Copy-Item -LiteralPath $source -Destination $script -Force

$userId = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$action = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument ('-NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $script + '"')
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $userId
$principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable `
    -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew `
    -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger `
    -Principal $principal -Settings $settings `
    -Description 'Starts Desktop Commander Remote after logon and recovers from agent exits.' -Force | Out-Null
Start-ScheduledTask -TaskName $TaskName
Write-Host "Installed. Task: $TaskName"
Write-Warning 'Logon task requires a signed-in Windows user session. Windows Autologon is NOT installed or enabled by this project.'
Write-Warning 'If first-run OAuth is needed, complete it interactively using: npx @wonderwhy-er/desktop-commander@0.3.1 remote'
