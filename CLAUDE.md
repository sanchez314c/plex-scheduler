# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Plex Media Server Scheduler** is a bash-based macOS utility that automatically controls Plex Media Server to run only during specified hours (default: 10 PM to 4 AM). It uses macOS launchd for background scheduling and includes an interactive control panel.

**Platform:** macOS (launchd-based)
**Language:** Bash

## Commands

```bash
# Control Panel (interactive menu)
./scripts/plex-control-panel.sh

# Direct Commands
./scripts/plex-scheduler.sh status      # Check Plex status and schedule
./scripts/plex-scheduler.sh start       # Force start Plex (override schedule)
./scripts/plex-scheduler.sh stop        # Force stop Plex (override schedule)
./scripts/plex-scheduler.sh control     # Run schedule check (auto start/stop)
./scripts/plex-scheduler.sh help        # Show usage information

# Installation
./scripts/install-plex-scheduler.sh     # Install launchd agent

# Service Management
launchctl load ~/Library/LaunchAgents/com.plexscheduler.agent.plist
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist
launchctl list | grep plexscheduler
```

## Architecture

### Script Components

| Script | Purpose |
|--------|---------|
| `scripts/plex-scheduler.sh` | Core control logic: process detection, start/stop, schedule checking |
| `scripts/plex-control-panel.sh` | Interactive TUI menu wrapping scheduler commands |
| `scripts/install-plex-scheduler.sh` | Installs launchd agent, validates Plex installation |

### plex-scheduler.sh Functions

| Function | Purpose |
|----------|---------|
| `is_plex_running()` | Process detection via `pgrep -f "Plex Media Server"` |
| `start_plex()` | Starts via launchctl, falls back to `open -a` |
| `stop_plex()` | Graceful shutdown via launchctl, force kill via pkill |
| `is_within_schedule()` | Time window calculation with overnight handling |
| `control_plex()` | Main logic: checks schedule, starts/stops accordingly |
| `force_start()` | Manual override: start regardless of schedule |
| `force_stop()` | Manual override: stop regardless of schedule |
| `show_status()` | Prints current run state and schedule alignment |

### Schedule Configuration

Variables at the top of `scripts/plex-scheduler.sh`:

```bash
LOG_FILE="${HOME}/Desktop/plex-scheduler.log"
SCHEDULE_START_TIME="22:00"  # 10 PM (24-hour format)
SCHEDULE_END_TIME="04:00"    # 4 AM
```

### Overnight Schedule Logic

`is_within_schedule()` handles schedules that cross midnight:
1. Converts `SCHEDULE_START_TIME` and `SCHEDULE_END_TIME` to minutes since midnight
2. If `start_total > end_total`, the window crosses midnight
3. For overnight windows: `current >= start OR current < end`
4. For same-day windows: `current >= start AND current < end`

### Generated Files

| File | Location |
|------|----------|
| `com.plexscheduler.agent.plist` | `~/Library/LaunchAgents/` |
| `plex-scheduler.log` | `~/Desktop/` |
| `plex-scheduler-output.log` | `~/Desktop/` |
| `plex-scheduler-error.log` | `~/Desktop/` |

## System Integration

- **launchd:** Runs schedule check every 5 minutes via plist agent
- **Process Control:** Uses `launchctl load/unload` for Plex's own agent (`com.plexapp.mediaserver`)
- **Fallback:** Direct `open -a "Plex Media Server"` / `pkill -f "Plex Media Server"` if launchctl fails

## Dependencies

- macOS with launchd
- Plex Media Server installed at `/Applications/Plex Media Server.app`
- Bash (ships with macOS)

## What Not to Break

- The overnight schedule logic in `is_within_schedule()` is correct as-is. The midnight crossover detection (`start_total > end_total`) is intentional.
- The 10-second grace period in `stop_plex()` before force-killing is intentional to allow graceful shutdown.
- Log paths are hardcoded to `~/Desktop/` by design for easy user access.

## Adding New Scripts

If you add a new script to `scripts/`, update:
1. The script tables in this file (above)
2. The script tables in `README.md`
3. The relevant section in `docs/API.md`
