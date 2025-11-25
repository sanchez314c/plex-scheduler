# Deployment

## Fresh Machine Setup

1. Install Plex Media Server from https://www.plex.tv/media-server-downloads/
2. Verify it is at `/Applications/Plex Media Server.app`
3. Clone the repository:

```bash
git clone https://github.com/sanchez314c/plex-scheduler.git
cd plex-scheduler
```

4. Make scripts executable:

```bash
chmod +x scripts/plex-scheduler.sh
chmod +x scripts/plex-control-panel.sh
chmod +x scripts/install-plex-scheduler.sh
```

5. Run the installer:

```bash
./scripts/install-plex-scheduler.sh
```

6. Verify:

```bash
launchctl list | grep plexscheduler
./scripts/plex-scheduler.sh status
```

## Updating to a New Version

```bash
cd /path/to/plex-scheduler
git pull origin main
```

No restart required. The launchd agent calls the script directly from the repository path, so it picks up changes on the next 5-minute trigger.

If you changed `plex-scheduler.sh` config variables (schedule times), reload the agent:

```bash
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist
launchctl load ~/Library/LaunchAgents/com.plexscheduler.agent.plist
```

## Moving to a Different Machine

1. On the new machine: follow the fresh machine setup above
2. Copy your custom `SCHEDULE_START_TIME` and `SCHEDULE_END_TIME` values from the old machine's `scripts/plex-scheduler.sh` to the new one
3. The launchd plist is generated fresh by the installer, so no need to copy it

## Reinstalling

If the launchd agent is not working correctly:

```bash
# Unload current agent
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist 2>/dev/null

# Remove existing plist
rm -f ~/Library/LaunchAgents/com.plexscheduler.agent.plist

# Reinstall
./scripts/install-plex-scheduler.sh
```

Or use menu option 6 in the control panel.

## Uninstalling

```bash
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist
rm ~/Library/LaunchAgents/com.plexscheduler.agent.plist
```

Log files at `~/Desktop/plex-scheduler*.log` can be removed manually if desired. Plex Media Server is not affected.

## Verifying the Scheduler Is Active

```bash
# Should show the agent with a PID or - (waiting for next trigger)
launchctl list | grep plexscheduler

# Should show recent entries from auto-runs
tail ~/Desktop/plex-scheduler.log
```
