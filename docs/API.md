# API Reference

All user-facing interface is through bash scripts. This document covers every command, argument, return code, and log output.

---

## scripts/plex-scheduler.sh

**Usage:** `./scripts/plex-scheduler.sh [command]`

Default command when none is provided: `control`

### Commands

#### `status`

Prints current Plex run state and schedule alignment to stdout.

```bash
./scripts/plex-scheduler.sh status
```

**Output examples:**

When running and in schedule:
```
Plex Media Server: RUNNING
Schedule: Within allowed window (10 PM - 4 AM)
```

When stopped and outside schedule:
```
Plex Media Server: STOPPED
Schedule: Outside allowed window (correctly stopped)
```

When running outside schedule (manual override):
```
Plex Media Server: RUNNING
Schedule: Outside allowed window (running due to manual override)
```

**Return code:** 0 always (status is informational)

---

#### `start` / `force_start`

Forces Plex to start regardless of current schedule.

```bash
./scripts/plex-scheduler.sh start
```

**Process:**
1. Checks `is_plex_running()`. If already running, logs and returns 0.
2. Runs `launchctl load -w ~/Library/LaunchAgents/com.plexapp.mediaserver.plist`
3. If launchctl fails, falls back to `open -a "Plex Media Server"`
4. Waits 5 seconds
5. Verifies process is running

**Return codes:**
- `0`: Plex started successfully (or was already running)
- `1`: Failed to start after 5-second wait

**Log output:**
```
2026-03-14 22:01:00 - Manual override: Force starting Plex
2026-03-14 22:01:00 - Starting Plex Media Server
2026-03-14 22:01:05 - Plex Media Server started successfully
```

---

#### `stop` / `force_stop`

Forces Plex to stop regardless of current schedule.

```bash
./scripts/plex-scheduler.sh stop
```

**Process:**
1. Checks `is_plex_running()`. If not running, logs and returns 0.
2. Runs `launchctl unload -w ~/Library/LaunchAgents/com.plexapp.mediaserver.plist`
3. Waits 10 seconds for graceful shutdown
4. If still running, runs `pkill -f "Plex Media Server"`
5. Waits 3 more seconds, verifies

**Return codes:**
- `0`: Plex stopped successfully (or was already stopped)
- `1`: Failed to stop after graceful + force attempts

**Log output:**
```
2026-03-14 04:00:00 - Manual override: Force stopping Plex
2026-03-14 04:00:00 - Stopping Plex Media Server
2026-03-14 04:00:10 - Plex Media Server stopped successfully
```

---

#### `control` / `check`

Runs one schedule check. Starts or stops Plex based on whether the current time is inside the configured window.

```bash
./scripts/plex-scheduler.sh control
```

This is the command launchd runs every 5 minutes.

**Return codes:** Same as `start_plex` or `stop_plex`, depending on which is called.

**Log output:**
```
2026-03-14 22:05:00 - Running Plex scheduler check
2026-03-14 22:05:00 - Current time is within scheduled window (10 PM - 4 AM)
2026-03-14 22:05:00 - Plex Media Server is already running
```

---

#### `help` / `-h` / `--help`

Prints usage information to stdout.

```bash
./scripts/plex-scheduler.sh help
```

**Return code:** 0

---

#### Unknown command

```bash
./scripts/plex-scheduler.sh badcommand
```

**Output:** `Unknown command: badcommand` and `Use './scripts/plex-scheduler.sh help' for usage information`

**Return code:** 1

---

## scripts/plex-control-panel.sh

**Usage:** `./scripts/plex-control-panel.sh`

Interactive menu. No arguments accepted.

### Menu Options

| Option | Action |
|--------|--------|
| 1 | Print current status (calls `plex-scheduler.sh status`) |
| 2 | Force start Plex (calls `plex-scheduler.sh start`) |
| 3 | Force stop Plex (calls `plex-scheduler.sh stop`) |
| 4 | Run schedule check manually (calls `plex-scheduler.sh control`) |
| 5 | Show last 20 lines of `~/Desktop/plex-scheduler.log` |
| 6 | Run installer (`scripts/install-plex-scheduler.sh`) |
| 7 | Uninstall (prompts for confirmation, removes launchd plist) |
| 8 | Exit |

---

## scripts/install-plex-scheduler.sh

**Usage:** `./scripts/install-plex-scheduler.sh`

One-time setup script.

**What it does:**
1. Checks for `/Applications/Plex Media Server.app`
2. Runs `launchctl load ~/Library/LaunchAgents/com.plexscheduler.agent.plist`
3. Runs `plex-scheduler.sh status` as a smoke test

**Return codes:**
- `0`: Installed successfully
- `1`: Plex not found, or launchctl load failed

---

## Configuration Variables

All configuration is in `scripts/plex-scheduler.sh` at the top of the file:

| Variable | Default | Description |
|----------|---------|-------------|
| `PLEX_LAUNCHCTL_LABEL` | `com.plexapp.mediaserver` | Label used by Plex's own launchd agent |
| `PLEX_BINARY` | `/Applications/Plex Media Server.app/Contents/MacOS/Plex Media Server` | Path to Plex binary (used for reference, not direct execution) |
| `LOG_FILE` | `${HOME}/Desktop/plex-scheduler.log` | Path to main log file |
| `SCHEDULE_START_TIME` | `22:00` | Window open time in 24-hour HH:MM format |
| `SCHEDULE_END_TIME` | `04:00` | Window close time in 24-hour HH:MM format |

---

## Log Format

All log entries from `log_message()` follow this format:

```
YYYY-MM-DD HH:MM:SS - message
```

Example entries:
```
2026-03-14 22:00:05 - Running Plex scheduler check
2026-03-14 22:00:05 - Current time is within scheduled window (10 PM - 4 AM)
2026-03-14 22:00:05 - Starting Plex Media Server
2026-03-14 22:00:10 - Plex Media Server started successfully
```
