# Workflow

## Normal Operation Flow

Once installed, this is what happens automatically:

```
User logs into macOS
       |
       v
launchd loads com.plexscheduler.agent.plist
       |
       v (every 5 minutes)
plex-scheduler.sh control
       |
       |-- is_within_schedule()?
       |        |
       |        YES (e.g., 10:30 PM)
       |        |-- is_plex_running()?
       |        |        NO: start_plex()  --> launchctl load com.plexapp.mediaserver
       |        |        YES: log "already running"
       |        |
       |        NO (e.g., 6:00 AM)
       |        |-- is_plex_running()?
       |                 YES: stop_plex()  --> launchctl unload, then pkill if needed
       |                 NO: log "already stopped"
       |
       v
log_message() writes to ~/Desktop/plex-scheduler.log
```

## Development Workflow

When making changes to the scripts:

1. Edit the script
2. Validate syntax: `bash -n scripts/plex-scheduler.sh`
3. Test manually:
   ```bash
   ./scripts/plex-scheduler.sh status
   ./scripts/plex-scheduler.sh control
   ```
4. For schedule logic changes, test boundary cases (see DEVELOPMENT.md)
5. Update CHANGELOG.md
6. Commit on a feature branch
7. Open a pull request

## Checking Scheduler Health

Quick health check:

```bash
# Is the agent loaded?
launchctl list | grep plexscheduler

# What happened in the last hour?
tail -20 ~/Desktop/plex-scheduler.log

# What is the current state?
./scripts/plex-scheduler.sh status
```

## Manual Override Workflow

To temporarily disable scheduling while using Plex outside normal hours:

```bash
# Unload the agent (stops automatic checking)
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist

# Start Plex manually
./scripts/plex-scheduler.sh start

# ... use Plex ...

# When done, reload the agent
launchctl load ~/Library/LaunchAgents/com.plexscheduler.agent.plist
```

Or use the control panel (option 7 to unload, option 6 to reload).

## Changing the Schedule

```bash
# Edit the script
nano scripts/plex-scheduler.sh
# Change SCHEDULE_START_TIME and SCHEDULE_END_TIME

# Reload the agent to pick up the change
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist
launchctl load ~/Library/LaunchAgents/com.plexscheduler.agent.plist

# Verify
./scripts/plex-scheduler.sh status
```

## Viewing Logs

```bash
# Last 20 entries
tail -20 ~/Desktop/plex-scheduler.log

# Live tail (useful while testing)
tail -f ~/Desktop/plex-scheduler.log

# Errors from launchd runs
tail ~/Desktop/plex-scheduler-error.log
```
