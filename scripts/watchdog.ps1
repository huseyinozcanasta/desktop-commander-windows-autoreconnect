# MIT License. Local per-user watchdog for Desktop Commander Remote.
param([switch]$Probe)
$ErrorActionPreference = 'Stop'
$base = Join-Path $env:LOCALAPPDATA 'DesktopCommanderAutoReconnect'
$node = (Get-Command node.exe -ErrorAction Stop).Source
$entry = Join-Path $base 'runtime\node_modules\@wonderwhy-er\desktop-commander\dist\index.js'
$log = Join-Path $base 'watchdog.log'
New-Item -ItemType Directory -Path $base -Force | Out-Null

function Write-Status([string]$message) {
    $line = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ' ' + $message
    Add-Content -LiteralPath $log -Value $line -Encoding UTF8
}

function Test-RemoteProcess {
    # An existing Remote Device should be reused, not duplicated.
    $processes = @(Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
        Where-Object { $_.CommandLine -and
            ($_.CommandLine -match 'desktop-commander[\\/]dist[\\/]index[.]js.*\bremote\b') })
    return $processes.Count -gt 0
}

if (-not (Test-Path -LiteralPath $entry)) {
    Write-Status 'RUNTIME_MISSING'
    throw 'Install the runtime first (scripts/install.ps1).'
}
if ($Probe) {
    $found = Test-RemoteProcess
    Write-Output "Runtime=OK RemoteProcessExists=$found"
    exit 0
}

$mutexName = 'Local\DCRemoteWatchdog_' + ($env:USERNAME -replace '[^a-zA-Z0-9]', '_')
$mutex = New-Object System.Threading.Mutex($false, $mutexName)
$lockHeld = $false
try {
    $lockHeld = $mutex.WaitOne(0)
    if (-not $lockHeld) { exit 0 }
    Write-Status 'WATCHDOG_STARTED'
    while ($true) {
        if (Test-RemoteProcess) {
            Start-Sleep -Seconds 30
            continue
        }
        try {
            Write-Status 'START_REMOTE'
            $stdout = Join-Path $base 'remote.stdout.log'
            $stderr = Join-Path $base 'remote.stderr.log'
            $proc = Start-Process -FilePath $node `
                -ArgumentList ('"' + $entry + '" remote') `
                -WorkingDirectory $env:USERPROFILE -WindowStyle Hidden `
                -RedirectStandardOutput $stdout -RedirectStandardError $stderr `
                -PassThru
            Write-Status ('AGENT_STARTED_PID=' + $proc.Id)
            $proc.WaitForExit()
            Write-Status ('AGENT_EXIT_CODE=' + $proc.ExitCode)
        } catch {
            Write-Status ('AGENT_START_FAILED=' + $_.Exception.GetType().Name)
        }
        Start-Sleep -Seconds 15
    }
} finally {
    if ($lockHeld) { $mutex.ReleaseMutex() }
    $mutex.Dispose()
}
