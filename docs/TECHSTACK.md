# Tech Stack

## Core Technologies

| Component | Technology | Version | Why |
|-----------|-----------|---------|-----|
| Shell | Bash | Ships with macOS | Standard shell, no dependencies, runs everywhere macOS does |
| Scheduler | macOS launchd | OS-provided | Built into macOS, starts at login, survives reboots, handles stdout/stderr logging |
| Platform | macOS | Modern (10.15+) | Target environment where Plex Media Server runs |

## No External Dependencies

This project has zero external dependencies. Everything it uses ships with macOS:

- `bash` - shell runtime
- `launchctl` - launchd agent management
- `pgrep` / `pkill` - process detection and termination
- `open` - application launcher (fallback for start)
- `date` - time reading for schedule checks
- `cut` - string parsing for HH:MM time format

## Why launchd Instead of cron

launchd is the correct tool for this on macOS:

- cron on macOS is legacy and discouraged since macOS Monterey
- launchd agents start with the user session and run reliably in the background
- launchd handles stdout/stderr redirection to files natively via the plist
- launchd can be controlled with `launchctl` load/unload without restarts

## Why Bash Instead of Python or Swift

- No install step, no virtual environments, no package managers
- Runs immediately after `chmod +x`
- The task (process detection + launchctl calls + time math) is 5-10 lines of shell, not a reason to bring in a runtime
- The user audience is comfortable running shell scripts

## Architecture Decision: No Daemon

The scheduler does not run as a persistent daemon. It runs as a 5-minute cron-like job via launchd. This means:

- No background process to manage or crash
- No memory footprint between checks
- Easy to debug: just read the log file or run the script manually
- The launchd agent itself is managed by the OS

## Architecture Decision: Log to Desktop

Logs go to `~/Desktop/plex-scheduler.log` instead of `~/Library/Logs/` or `/var/log/`. This is intentional: the target user is not a sysadmin. Desktop visibility makes the log file easy to find without knowing macOS log conventions.
