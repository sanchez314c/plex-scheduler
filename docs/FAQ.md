# FAQ

## Why isn't Plex starting at the right time?

The scheduler checks every 5 minutes via launchd. If you start it at 10:00 PM, Plex may not start until 10:05 PM at the latest. This is by design.

Verify the launchd agent is running:
```bash
launchctl list | grep plexscheduler
```

If there is no output, the agent is not loaded. Run `./scripts/install-plex-scheduler.sh` to reinstall it.

## Plex stopped when I was using it. Why?

Your current time is outside the configured schedule window. The scheduler runs every 5 minutes, so if you are using Plex outside the window, it will stop it.

To prevent this during a session, force-start Plex manually:
```bash
./scripts/plex-scheduler.sh start
```

This does not disable the schedule permanently. On the next 5-minute check, the scheduler will see you are outside the window and stop Plex again. For a longer manual session, temporarily unload the agent:

```bash
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist
```

Reload it when done:
```bash
launchctl load ~/Library/LaunchAgents/com.plexscheduler.agent.plist
```

## How do I change the schedule?

Edit the two variables at the top of `scripts/plex-scheduler.sh`:

```bash
SCHEDULE_START_TIME="22:00"
SCHEDULE_END_TIME="04:00"
```

Times are in 24-hour format. After saving, reload the launchd agent:

```bash
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist
launchctl load ~/Library/LaunchAgents/com.plexscheduler.agent.plist
```

## Can I run multiple schedule windows? (e.g., noon to 2 PM AND 10 PM to 4 AM)

Not currently. The scheduler supports one window. This is a known limitation. See `docs/TODO.md`.

## Does this work on Linux?

Not yet. The scheduler uses macOS launchd. A Linux/systemd equivalent is a potential contribution. See CONTRIBUTING.md.

## Where are the log files?

Three files, all on your Desktop:

- `~/Desktop/plex-scheduler.log` — Main activity log (timestamped events from the scheduler)
- `~/Desktop/plex-scheduler-output.log` — stdout from launchd-triggered runs
- `~/Desktop/plex-scheduler-error.log` — stderr from launchd-triggered runs

## The log file is not being created. Why?

The log file is created on the first scheduler run. If you just installed, run a manual check:

```bash
./scripts/plex-scheduler.sh control
```

The file should appear at `~/Desktop/plex-scheduler.log` after that.

## How do I completely remove this?

```bash
launchctl unload ~/Library/LaunchAgents/com.plexscheduler.agent.plist
rm ~/Library/LaunchAgents/com.plexscheduler.agent.plist
```

Optionally clean up logs:
```bash
rm ~/Desktop/plex-scheduler*.log
```

Plex Media Server is not touched by either command.

## Can I use this without installing the launchd agent?

Yes. You can call `./scripts/plex-scheduler.sh control` manually whenever you want a schedule check. Without the launchd agent, there is no automatic 5-minute check.

## What happens if the script path changes?

The launchd plist contains the hardcoded path to `plex-scheduler.sh`. If you move the repository, you will need to edit the plist or reinstall. Run `./scripts/install-plex-scheduler.sh` from the new location to regenerate it.
