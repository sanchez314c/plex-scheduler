# Plex Scheduler

Automatically starts and stops Plex Media Server based on a configured time window. Default schedule is 10:00 PM to 4:00 AM. Outside that window, Plex is stopped to free CPU and memory.

Built for macOS using launchd. Three scripts handle everything: the core scheduler, an installer, and an interactive control panel.

**Author:** J. Michaels ([@sanchez314c](https://github.com/sanchez314c))
**GitHub:** https://github.com/sanchez314c

---

## Quick Start

```bash
# Install the launchd agent (run once)
./scripts/install-plex-scheduler.sh

# Launch the interactive control panel
./scripts/plex-control-panel.sh

# Or use direct commands
./scripts/plex-scheduler.sh status
./scripts/plex-scheduler.sh start
./scripts/plex-scheduler.sh stop
```

## How It Works

A launchd agent (`com.plexscheduler.agent.plist`) triggers `plex-scheduler.sh` every 5 minutes. The script checks whether the current time falls inside the configured window. If it does and Plex is not running, it starts Plex. If it does not and Plex is running, it stops Plex.

Overnight schedules (like 10 PM to 4 AM) work correctly. The script converts times to minutes-since-midnight and handles the midnight crossover with dedicated comparison logic.

## Configuration

Edit the two variables at the top of `scripts/plex-scheduler.sh`:

```bash
SCHEDULE_START_TIME="22:00"  # 24-hour format
SCHEDULE_END_TIME="04:00"
```

After changing the schedule, reload the launchd agent:

```bash
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist
launchctl load ~/Library/LaunchAgents/com.plexscheduler.agent.plist
```

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/plex-scheduler.sh` | Core logic: time check, start/stop Plex |
| `scripts/plex-control-panel.sh` | Interactive menu for all operations |
| `scripts/install-plex-scheduler.sh` | Installs the launchd agent |

## Commands

```bash
./scripts/plex-scheduler.sh status    # Show Plex state and schedule info
./scripts/plex-scheduler.sh start     # Force start (ignores schedule)
./scripts/plex-scheduler.sh stop      # Force stop (ignores schedule)
./scripts/plex-scheduler.sh control   # Run one schedule check manually
./scripts/plex-scheduler.sh help      # Usage info
```

## Requirements

- macOS (any modern version with launchd)
- Plex Media Server installed at `/Applications/Plex Media Server.app`
- Bash

## Logs

All activity is written to `~/Desktop/plex-scheduler.log` with timestamps. Use control panel option 5 to tail recent entries, or run:

```bash
tail -f ~/Desktop/plex-scheduler.log
```

Three log files are generated:

| File | Contents |
|------|----------|
| `~/Desktop/plex-scheduler.log` | Main activity log with timestamps |
| `~/Desktop/plex-scheduler-output.log` | stdout from launchd runs |
| `~/Desktop/plex-scheduler-error.log` | stderr from launchd runs |

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist
rm ~/Library/LaunchAgents/com.plexscheduler.agent.plist
```

Plex itself stays installed and untouched.

## License

MIT. See [LICENSE](LICENSE).
