# Architecture

## Overview

Plex Scheduler is three bash scripts coordinated by a macOS launchd agent. There is no server, no daemon process of its own, no compiled binary, and no persistent state beyond log files.

```
macOS launchd
  com.plexscheduler.agent.plist
  (runs every 5 minutes)
         |
         v
scripts/plex-scheduler.sh [control]
         |
         |-- is_within_schedule()
         |        |
         |        |-- YES: start_plex()
         |        |-- NO:  stop_plex()
         |
         v
Plex Media Server.app
(/Applications/Plex Media Server.app)
```

## Components

### scripts/plex-scheduler.sh

The core script. All logic lives here.

**Configuration variables (top of file):**

```bash
LOG_FILE="${HOME}/Desktop/plex-scheduler.log"
SCHEDULE_START_TIME="22:00"
SCHEDULE_END_TIME="04:00"
```

**Functions:**

| Function | Description |
|----------|-------------|
| `log_message(msg)` | Writes `YYYY-MM-DD HH:MM:SS - msg` to `$LOG_FILE` |
| `is_plex_running()` | Returns 0 if Plex process found via `pgrep -f "Plex Media Server"` |
| `start_plex()` | `launchctl load -w` the Plex plist, fallback to `open -a`, waits 5s, verifies |
| `stop_plex()` | `launchctl unload -w` the Plex plist, waits 10s, force `pkill` if still running |
| `is_within_schedule()` | Converts times to minutes-since-midnight, handles overnight crossover |
| `control_plex()` | Calls `is_within_schedule`, then `start_plex` or `stop_plex` |
| `force_start()` | Calls `start_plex` unconditionally |
| `force_stop()` | Calls `stop_plex` unconditionally |
| `show_status()` | Prints run state and schedule alignment to stdout |

**Command dispatch (bottom of file):**

```bash
case "${1:-control}" in
    "start"|"force_start") force_start ;;
    "stop"|"force_stop")   force_stop ;;
    "status")              show_status ;;
    "control"|"check")     control_plex ;;
    "help"|"-h"|"--help")  # prints usage ;;
    *) echo "Unknown command"; exit 1 ;;
esac
```

Default argument when none is passed is `control`.

### scripts/plex-control-panel.sh

An interactive TUI menu wrapping the scheduler script. It does not contain logic; it calls `scripts/plex-scheduler.sh` for all operations.

- Menu options 1-4: status, force start, force stop, manual schedule check
- Option 5: tails last 20 lines of `~/Desktop/plex-scheduler.log`
- Option 6: calls `scripts/install-plex-scheduler.sh`
- Option 7: unloads and removes the launchd plist
- Option 8: exits

### scripts/install-plex-scheduler.sh

One-time setup script. Validates Plex is installed at `/Applications/Plex Media Server.app`, then loads the launchd agent via `launchctl load`.

### com.plexscheduler.agent.plist

Not stored in the repository. Generated and placed at `~/Library/LaunchAgents/com.plexscheduler.agent.plist` by the install script. Configures launchd to run `plex-scheduler.sh control` every 5 minutes (`StartInterval: 300`).

## Schedule Logic

`is_within_schedule()` converts all times to minutes since midnight for integer comparison:

```bash
current_total = current_hour * 60 + current_minute
start_total   = start_hour * 60 + start_minute
end_total     = end_hour * 60 + end_minute
```

For overnight windows where `start_total > end_total` (e.g., 22:00=1320, 04:00=240):

```
in window if: current >= start  OR  current < end
              (current >= 1320) OR  (current < 240)
```

For same-day windows where `start_total <= end_total`:

```
in window if: current >= start  AND  current < end
```

## Log Files

| File | Written by | Contents |
|------|-----------|----------|
| `~/Desktop/plex-scheduler.log` | `log_message()` in `plex-scheduler.sh` | Timestamped events |
| `~/Desktop/plex-scheduler-output.log` | launchd stdout redirect | stdout from launchd-triggered runs |
| `~/Desktop/plex-scheduler-error.log` | launchd stderr redirect | stderr from launchd-triggered runs |

## Process Control Strategy

Start: `launchctl load -w ~/Library/LaunchAgents/com.plexapp.mediaserver.plist` with `open -a "Plex Media Server"` as fallback.

Stop: `launchctl unload -w` first (graceful), waits 10 seconds, then `pkill -f "Plex Media Server"` if the process is still alive.
