# MIT License. Read-only source validation; no system mutation.
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$names = @('watchdog.ps1', 'install.ps1', 'status.ps1', 'uninstall.ps1')
foreach ($name in $names) {
    $file = Join-Path (Join-Path $root 'scripts') $name
    if (-not (Test-Path -LiteralPath $file)) { throw "Missing $name" }
    $tokens = $null
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$errors)
    if ($errors.Count -gt 0) {
        foreach ($error in $errors) { Write-Host ('ERROR ' + $name + ': ' + $error.Message) }
        throw "PowerShell syntax failure: $name"
    }
    Write-Host "PASS parser: $name"
}
$watchdog = Get-Content -Raw -LiteralPath (Join-Path $root 'scripts\watchdog.ps1')
$installer = Get-Content -Raw -LiteralPath (Join-Path $root 'scripts\install.ps1')
if ($installer -notmatch 'New-ScheduledTaskTrigger -AtLogOn') { throw 'Missing at-logon trigger' }
if ($installer -notmatch 'LogonType Interactive') { throw 'Missing interactive user principal' }
if ($installer -match 'AutoAdminLogon|DefaultPassword|Set-ItemProperty.*Winlogon') { throw 'Installer must not configure Windows Autologon' }
if ($watchdog -notmatch 'System.Threading.Mutex') { throw 'Missing duplicate watchdog guard' }
if ($watchdog -notmatch 'Test-RemoteProcess') { throw 'Missing existing process check' }
if ($watchdog -match 'Invoke-Expression|iex\s') { throw 'Forbidden dynamic command execution' }
if (-not (Test-Path (Join-Path $root 'LICENSE'))) { throw 'LICENSE missing' }
if (-not (Test-Path (Join-Path $root 'SECURITY.md'))) { throw 'Security documentation missing' }
Write-Host 'PASS guardrails and documentation'
