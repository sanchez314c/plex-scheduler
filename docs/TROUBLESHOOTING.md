# Troubleshooting

## Plex Is Not Starting Automatically

**Check the launchd agent is loaded:**
```bash
launchctl list | grep plexscheduler
```

If no output: the agent is not loaded. Run `./scripts/install-plex-scheduler.sh`.

If you see a negative exit code (like `-1` or `-9`), the script is crashing. Check the error log:
```bash
cat ~/Desktop/plex-scheduler-error.log
```

**Check the schedule is correct:**
```bash
# Should print something like "Within allowed window" if it's the right time
./scripts/plex-scheduler.sh status
```

**Run a manual check:**
```bash
./scripts/plex-scheduler.sh control
```

Then check the log:
```bash
tail ~/Desktop/plex-scheduler.log
```

---

## Plex Is Not Stopping Automatically

Same first step: verify the launchd agent is loaded.

Then check that the current time is actually outside your schedule window. `show_status` can mislead if you recently changed times. Run:

```bash
date  # what time does the system think it is?
./scripts/plex-scheduler.sh status
```

If status says "Within allowed window" and you disagree, double-check `SCHEDULE_START_TIME` and `SCHEDULE_END_TIME` in `scripts/plex-scheduler.sh`. Remember times are in 24-hour format.

---

## launchd Agent Fails to Load

```bash
launchctl load ~/Library/LaunchAgents/com.plexscheduler.agent.plist
```

If this errors, check:

1. The plist file exists:
```bash
ls ~/Library/LaunchAgents/com.plexscheduler.agent.plist
```

2. The plist is valid XML:
```bash
plutil -lint ~/Library/LaunchAgents/com.plexscheduler.agent.plist
```

3. The path in the plist points to where `plex-scheduler.sh` actually lives:
```bash
cat ~/Library/LaunchAgents/com.plexscheduler.agent.plist | grep ProgramArguments -A5
```

If the path is wrong (e.g., you moved the repository), reinstall:
```bash
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist 2>/dev/null
rm ~/Library/LaunchAgents/com.plexscheduler.agent.plist
./scripts/install-plex-scheduler.sh
```

---

## Plex Fails to Start Even When Manually Triggered

```bash
./scripts/plex-scheduler.sh start
```

Check the log:
```bash
tail -20 ~/Desktop/plex-scheduler.log
```

If you see `ERROR: Failed to start Plex Media Server`:

1. Check Plex is installed:
```bash
ls /Applications/Plex\ Media\ Server.app
```

2. Try starting Plex manually:
```bash
open -a "Plex Media Server"
```

3. Check if Plex's own launchd agent is present:
```bash
ls ~/Library/LaunchAgents/com.plexapp.mediaserver.plist
```

If that plist is missing, Plex may need to be launched once manually to create it.

---

## Force Stop Does Not Kill Plex

If `pkill -f "Plex Media Server"` is not working, the process may be running under a different name. Check:

```bash
pgrep -la plex
ps aux | grep -i plex
```

Kill the process by PID if needed:
```bash
kill -9 <PID>
```

---

## Log File Shows Nothing Recent

Verify the agent is running and the log path is correct:

```bash
grep LOG_FILE scripts/plex-scheduler.sh
```

The default is `~/Desktop/plex-scheduler.log` (resolved via `$HOME`). It should work on any macOS user account.

---

## `plex-control-panel.sh` Shows Errors

The control panel resolves its own location at startup using `BASH_SOURCE[0]` and finds `plex-scheduler.sh` relative to itself. If you see errors about the scheduler script not being found:

1. Verify both scripts are in the same directory:
```bash
ls scripts/plex-scheduler.sh scripts/plex-control-panel.sh
```

2. Make sure both are executable:
```bash
chmod +x scripts/*.sh
```

---

## How to Reset Everything

```bash
# Unload and remove the agent
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist 2>/dev/null
rm -f ~/Library/LaunchAgents/com.plexscheduler.agent.plist

# Clear logs
rm -f ~/Desktop/plex-scheduler*.log

# Reinstall
./scripts/install-plex-scheduler.sh
```
