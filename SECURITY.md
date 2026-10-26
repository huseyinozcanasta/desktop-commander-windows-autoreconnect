# Security policy

This is a community helper, **not** an official Desktop Commander or Microsoft utility.

## Threat model
Remote Desktop Commander gives an authenticated remote client the ability to run commands under your local Windows user account. Keeping it online at login extends the time it can be reached. Protect the account at the provider, revoke unneeded devices, and stop this task when you no longer want remote access.

- Windows Autologon is **optional** and is NOT configured by the scripts in this repository.
- If you choose Windows Autologon, use Microsoft's official Sysinternals Autologon GUI, only on your own authorized personal computer. It stores an LSA secret that an administrator can recover, and physical access to the computer becomes far more dangerous.
- Never put account credentials in command-line arguments, task definitions, your Git history, or copied support logs.
- The log only records process lifecycle events (never passwords or OAuth tokens). The Remote Device's stdout/stderr may contain sensitive troubleshooting information; **do not upload these logs publicly**.
- Keep BitLocker/device encryption, account protection and screen lock enabled; avoid unattended automatic login on shared machines.
- Updating third-party packages is a deliberate action: inspect the chosen version and npm dependency advisories.
- Do not run install scripts from unknown forks without reviewing them first. Their permissions match the Windows user.
- The process check detects a local process only. It cannot guarantee remote service connectivity or account authorization.
- Installation is per interactive user. This is not a Windows service or pre-login remote-access backdoor.

## Reporting a vulnerability
Use GitHub's private vulnerability reporting if enabled; otherwise contact the repository owner without disclosing credentials, paths containing usernames, tokens or complete logs.
