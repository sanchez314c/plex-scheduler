# Learnings

Notes from building and operating this tool.

## Midnight Crossover Math

The first attempt at `is_within_schedule()` used a simple range check: `current >= start && current < end`. That broke for overnight windows because at midnight, current (0) is less than start (1320 for 22:00), so the check incorrectly returned false.

The fix: detect overnight windows by checking if `start_total > end_total`. When it is, the window wraps, and the check becomes `current >= start OR current < end`. The OR is the key change.

## launchd vs cron

Started with cron as the obvious choice. Switched to launchd after finding that macOS deprecated cron-style periodic jobs in favor of launchd agents. launchd also handles:

- Automatic log file creation (stdout/stderr redirect in the plist)
- Surviving login/logout cleanly
- `launchctl list` for easy status checking

The plist configuration is more verbose than a cron expression, but it integrates better with macOS.

## Graceful Stop with Force Kill Fallback

A simple `pkill` on the first stop attempt sometimes left Plex in a half-stopped state. The fix was to try the graceful `launchctl unload` path first, wait 10 seconds, then fall back to `pkill` only if the process is still alive. The 10-second wait is necessary because Plex has media indexing and session teardown to do on shutdown.

## Log File on Desktop

Putting the log on the Desktop was a deliberate choice after considering `~/Library/Logs/`. Most users running this tool are not sysadmins and would never think to look in `~/Library/Logs/`. The Desktop is immediately visible and findable.

## Control Panel Architecture

The control panel is purely a menu wrapper, not a second implementation of scheduler logic. All operations go through `plex-scheduler.sh`. This prevents the two scripts from diverging on behavior.

## Installer Validates First

The installer checks for Plex before doing anything. Early versions just loaded the plist and left users confused when nothing worked because Plex was not installed. The explicit check with an error message makes the problem immediately obvious.

## Start Verification

`start_plex()` waits 5 seconds after triggering the start, then calls `is_plex_running()` to verify. Without this, the function would return success before Plex had actually started, making logs misleading and status checks unreliable.
