# Installation

## Prerequisites

- macOS (any version with launchd, which is all modern macOS)
- Plex Media Server installed at `/Applications/Plex Media Server.app`
- Bash (ships with macOS)

Verify Plex is installed:
```bash
ls /Applications/Plex\ Media\ Server.app
```

If that path does not exist, install Plex Media Server from https://www.plex.tv/media-server-downloads/ before continuing.

## Clone the Repository

```bash
git clone https://github.com/sanchez314c/plex-scheduler.git
cd plex-scheduler
```

## Make Scripts Executable

```bash
chmod +x scripts/plex-scheduler.sh
chmod +x scripts/plex-control-panel.sh
chmod +x scripts/install-plex-scheduler.sh
```

## Run the Installer

```bash
./scripts/install-plex-scheduler.sh
```

The installer will:
1. Check that Plex is installed at `/Applications/Plex Media Server.app`
2. Load the launchd agent: `launchctl load ~/Library/LaunchAgents/com.plexscheduler.agent.plist`
3. Run `plex-scheduler.sh status` to confirm everything is working

Expected output:
```
Plex Media Server Scheduler Installation
==========================================
Plex Media Server found
Installing launchd agent...
Launchd agent installed successfully
Testing Plex scheduler...
Plex Media Server: RUNNING (or STOPPED)
Schedule: ...

Installation complete!

Schedule: Plex will automatically run from 10:00 PM to 4:00 AM
```

## Verify Installation

```bash
# Confirm the launchd agent is loaded
launchctl list | grep plexscheduler

# Run a manual schedule check
./scripts/plex-scheduler.sh status
```

## Customize the Schedule

Edit `scripts/plex-scheduler.sh` and change the two variables at the top:

```bash
SCHEDULE_START_TIME="22:00"   # change to your desired start time
SCHEDULE_END_TIME="04:00"     # change to your desired end time
```

Times are in 24-hour format. Overnight windows (where start is after end numerically) are handled automatically.

Reload the agent after changing the schedule:

```bash
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist
launchctl load ~/Library/LaunchAgents/com.plexscheduler.agent.plist
```

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist
rm ~/Library/LaunchAgents/com.plexscheduler.agent.plist
```

Plex Media Server itself is not affected.
