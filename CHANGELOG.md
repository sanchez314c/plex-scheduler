# Changelog

All notable changes to Plex Scheduler are documented here.

## [Unreleased]

## [1.0.2] - 2026-03-27 22:31

### Fixed
- `plex-scheduler.sh`: Removed dead `PLEX_BINARY` variable (defined but never used anywhere in the codebase)
- `plex-scheduler.sh`: Removed stray `export PLEX_LAUNCHCTL_LABEL` (not needed by sub-processes)
- `plex-scheduler.sh`: Log path uses `$HOME/Desktop/` (kept per design decision; was briefly changed to Library/Logs but reverted)
- `plex-scheduler.sh`: `control_plex()` log message hardcoded "10 PM - 4 AM"; now uses `format_time()` on configured times
- `plex-scheduler.sh`: `show_status()` hardcoded "10 PM - 4 AM" in two branches; now uses `format_time()` on configured times
- `plex-scheduler.sh`: `help` output hardcoded "10:00 PM to 4:00 AM"; now reads from `SCHEDULE_START_TIME`/`SCHEDULE_END_TIME`
- `plex-scheduler.sh`: Arithmetic in `is_within_schedule()` missing `10#` base prefix; hours 08 and 09 would be interpreted as invalid octal
- `plex-scheduler.sh`: Unquoted `[ $var -gt $var ]` comparisons replaced with `[ "$var" -gt "$var" ]` throughout `is_within_schedule()`
- `plex-scheduler.sh`: Added missing edge case for same start/end time (now returns OUT/1 instead of falling through to same-day branch)
- `plex-control-panel.sh`: `print_status()` ran the scheduler script twice (once discarded, once captured); now single invocation captures output and checks exit code
- `plex-control-panel.sh`: Log path in "View Recent Logs" now uses `$HOME/Desktop/plex-scheduler.log` (dynamic, not hardcoded username)
- `install-plex-scheduler.sh`: Attempted to `launchctl load` a plist that doesn't exist yet; now creates the plist file first then loads it
- `install-plex-scheduler.sh`: Removed emoji characters from output (portability)
- `install-plex-scheduler.sh`: Installation summary now reads schedule from the scheduler script itself rather than hardcoding times

### Added
- `plex-scheduler.sh`: `format_time()` helper converts HH:MM 24h to human-readable 12h format (e.g. "22:00" -> "10:00 PM")
- `tests/test-schedule-logic.sh`: 15-case test suite for `is_within_schedule()` covering overnight window, same-day window, boundary conditions, and same-start/end edge case - all passing

## [1.0.1] - 2026-03-27 22:23

### Fixed
- `plex-scheduler.sh`: `LOG_FILE` was hardcoded to `/Users/heathen-admin/Desktop/`; changed to `$HOME/Desktop/plex-scheduler.log`
- `plex-scheduler.sh`: `PLEX_LAUNCHCTL_LABEL` and `PLEX_BINARY` were flagged unused by shellcheck; now exported so sub-processes can access them
- `plex-control-panel.sh`: `SCRIPT_DIR` and `SCHEDULER_SCRIPT` were hardcoded to `/Users/heathen-admin/Desktop/`; now use `$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)` pattern
- `plex-control-panel.sh`: Log path in "View Recent Logs" option was hardcoded; changed to `$HOME/Desktop/plex-scheduler.log`
- `plex-control-panel.sh`: Install script call was hardcoded to `/Users/heathen-admin/Desktop/install-plex-scheduler.sh`; changed to `"$SCRIPT_DIR/install-plex-scheduler.sh"`
- `plex-control-panel.sh`: All `read` calls missing `-r` flag (SC2162); added `-r` to all four instances
- `install-plex-scheduler.sh`: `$?` anti-pattern (SC2181) replaced with direct `if launchctl load ...; then` check
- `install-plex-scheduler.sh`: Hardcoded path to `plex-scheduler.sh` replaced with `"$SCRIPT_DIR/plex-scheduler.sh"`
- `install-plex-scheduler.sh`: Log path in completion message changed to `$HOME/Desktop/plex-scheduler.log`
- All five scripts pass `shellcheck` with zero findings and `bash -n` syntax validation

## [1.0.0] - 2026-03-27

### Changed
- Pipeline audit: fixed hardcoded paths, shellcheck compliance, test suite added
- Replaced generic run-source scripts with project-specific versions
- Removed irrelevant Windows batch file (macOS-only project)

### Added
- Full documentation suite (27 files)
- GitHub issue/PR templates
- Automated test script for schedule logic validation

## [0.1.0] - 2026-03-14

### Added
- Full documentation suite: README, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, CLAUDE, AGENTS, VERSION_MAP
- GitHub issue templates for bug reports and feature requests
- GitHub pull request template
- docs/ directory with ARCHITECTURE, INSTALLATION, DEVELOPMENT, API, BUILD_COMPILE, DEPLOYMENT, FAQ, TROUBLESHOOTING, TECHSTACK, WORKFLOW, QUICK_START, LEARNINGS, PRD, TODO

## [0.0.1] - 2024-11-25

### Added
- Initial release
- Automatic scheduling with default 10 PM to 4 AM window
- Manual override commands (start/stop)
- Interactive control panel (`plex-control-panel.sh`)
- macOS launchd integration via `com.plexscheduler.agent.plist`
- Logging to `~/Desktop/plex-scheduler.log`
- Overnight schedule support with midnight crossover handling
- `is_within_schedule()` function with minutes-since-midnight math
- Graceful Plex shutdown via launchctl with pkill fallback
- Installation script that validates Plex is present before proceeding
