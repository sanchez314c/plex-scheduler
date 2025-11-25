# Quick Start

Get Plex Scheduler running in under 5 minutes.

## Step 1: Verify Plex is Installed

```bash
ls /Applications/Plex\ Media\ Server.app
```

If the directory does not exist, install Plex from https://www.plex.tv/media-server-downloads/ first.

## Step 2: Clone and Set Up

```bash
git clone https://github.com/sanchez314c/plex-scheduler.git
cd plex-scheduler
chmod +x scripts/plex-scheduler.sh scripts/plex-control-panel.sh scripts/install-plex-scheduler.sh
```

## Step 3: Install

```bash
./scripts/install-plex-scheduler.sh
```

Expected output ends with:
```
Installation complete!
Schedule: Plex will automatically run from 10:00 PM to 4:00 AM
```

## Step 4: Verify

```bash
./scripts/plex-scheduler.sh status
```

## Step 5 (Optional): Change the Schedule

Edit `scripts/plex-scheduler.sh` and change the top two variables:

```bash
SCHEDULE_START_TIME="22:00"   # 10 PM
SCHEDULE_END_TIME="04:00"     # 4 AM
```

Then reload:
```bash
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist
launchctl load ~/Library/LaunchAgents/com.plexscheduler.agent.plist
```

## That's It

Plex will now start automatically when the window opens and stop when it closes. The check runs every 5 minutes.

To monitor what's happening:
```bash
tail -f ~/Desktop/plex-scheduler.log
```

To use the interactive control panel:
```bash
./scripts/plex-control-panel.sh
```
