# Desktop Commander Windows Auto-Reconnect

A small, open-source **Windows user-session** watchdog for the [Desktop Commander Remote MCP](https://desktopcommander.app/mcp/). It starts Remote Device at Windows sign-in, avoids duplicate starts when a Remote process exists, and relaunches it after exit. Includes an optional guide to Windows automatic sign-in. **MIT licensed.**

> Independent community project. Not affiliated with Desktop Commander, Microsoft, or OpenAI. No Windows password or credential collection. Scripts do **not** configure Windows Autologon.

## What we actually verified

On one Windows 10 Pro PC, a real reboot test showed this sequence: Windows booted; its preconfigured Autologon signed into the interactive user session; Windows Task Scheduler started a Remote Device watchdog; the watchdog started the Remote Device; a remote MCP command succeeded. This verifies **one reboot path**, not universal reliability or all outage recovery cases.

## Requirements

- A machine you own/administer, Windows 10/11 with PowerShell 5.1 and Task Scheduler
- Node.js 18+ (with `node.exe`, `npm.cmd` on PATH)
- A [Desktop Commander Remote MCP](https://desktopcommander.app/mcp/) account and configured compatible AI connector
- Internet connection and a signed-in Windows user session
- Permission to create your own per-user scheduled task

## Install

Review every script before running it. Open a normal **PowerShell terminal** (not administrator) in the cloned repository.

1. Install Node.js if not already installed.
2. **First-time authorization:** Run `npx -y @wonderwhy-er/desktop-commander@0.3.1 remote`. Complete the OAuth browser flow, verify the device can be reached, then press `Ctrl+C` to stop that temporary foreground session.
3. Install the watchdog:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

4. Check installation:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\status.ps1
Get-ScheduledTask -TaskName DesktopCommander-Public-Watchdog
```

5. Confirm the device is listed as online in your Remote MCP management dashboard, then **execute a harmless remote command** (e.g., date or hostname) from the connected AI client. Process presence alone does not prove it is connected.
6. At your own discretion, reboot and repeat the remote command after Windows login. Keep a recovery login method available.

The installation stores the pinned Remote Device under `%LOCALAPPDATA%\DesktopCommanderAutoReconnect\runtime` and a copy of `watchdog.ps1` alongside lifecycle logs. It adds the `DesktopCommander-Public-Watchdog` task with an `AtLogOn` trigger using your **interactive account**, without asking for a password or elevating privileges.

## Optional: sign into Windows automatically

A watchdog task with `AtLogOn` cannot run until Windows signs in. If you require an unattended sign-in **and accept the security risks**, use [Microsoft Sysinternals Autologon](https://learn.microsoft.com/en-us/sysinternals/downloads/autologon) **manually** with proper authorization and the existing Windows account credentials. Never supply credentials to this repository or store them in a command, script, shortcut, or GitHub issue. Autologon reduces physical security; its LSA secret can be decrypted by administrators.

**This optional step is outside the repository, is not enabled automatically, and is not recommended for shared, portable or physically accessible machines.** For most people, use normal Windows sign-in and let the watchdog start afterward.

## Operations and troubleshooting

- `scripts\status.ps1`: Shows task state, local process count and recent lifecycle events.
- Task trigger: Windows interactive user **logon**, not system boot before login.
- Reconnect behavior: checks existing Node Remote process; when none exists, starts the pinned Remote entrypoint; after exit waits 15 seconds, then retries.
- Duplicate avoidance: process check plus named mutex prevent most duplicate watchdog instances. It cannot prevent every race with external launchers.
- Logs: `%LOCALAPPDATA%\DesktopCommanderAutoReconnect\watchdog.log`, `remote.stdout.log`, `remote.stderr.log`. Treat logs as private.
- If OAuth expires, interactively rerun the Remote Device and reauthenticate. A watchdog **cannot** bypass authentication.
- Network/service outage: the Remote client may reconnect internally; this watchdog only restarts an exited process. **No end-to-end automatic recovery SLA.**
- The watchdog requires `node.exe` on PATH after login. Fix the user/system PATH if the startup task fails.
- Installation has a `-WhatIf` option to inspect the top-level action; it is not a complete dry run of npm's internal changes.
- This repository does not collect telemetry, open firewall ports, install a Windows service, or enable remote sign-in by itself.

## Uninstall

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\uninstall.ps1
# To also delete its local runtime and watchdog logs:
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\uninstall.ps1 -RemoveLocalData
```

**Uninstall does not disable Microsoft Autologon.** Disable Windows automatic sign-in separately inside the official Autologon tool if you chose to use it.

## Validation and license

Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\smoke.ps1` to parse-check all PowerShell scripts and review critical safety invariants. This is not a full integration test. See [SECURITY.md](SECURITY.md).

MIT © 2026 huseyinozcanasta
