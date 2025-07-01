# Security

## Scope

Plex Scheduler is a local macOS utility. It runs entirely on the user's machine and does not expose any network services or accept remote input. The attack surface is limited to:

- The shell scripts themselves (`scripts/plex-scheduler.sh`, `scripts/plex-control-panel.sh`, `scripts/install-plex-scheduler.sh`)
- The launchd plist at `~/Library/LaunchAgents/com.plexscheduler.agent.plist`
- Log files written to `~/Desktop/`

## Known Considerations

**Script permissions:** The scripts in `scripts/` should be owned by the user and not world-writable. After cloning, verify:

```bash
ls -la scripts/
# should show -rwxr-xr-x or similar, owned by your user
```

**Log file location:** Logs go to `~/Desktop/plex-scheduler.log`. This is a plain-text file. It does not contain credentials or sensitive data, only timestamps and Plex start/stop events.

**launchd agent:** The plist runs `plex-scheduler.sh` every 5 minutes as the current user. It does not run as root. It does not use `sudo`.

**No external network calls:** The scheduler does not call any external APIs. All actions are local process management via `launchctl`, `pgrep`, `pkill`, and `open`.

## Reporting a Vulnerability

If you find a security issue in the scripts (e.g., a shell injection via an environment variable, a log file that could be hijacked), open a GitHub issue labeled `security` or contact [@sanchez314c](https://github.com/sanchez314c) directly.

Given the local-only nature of this tool, most findings will be informational, but all reports are read.
