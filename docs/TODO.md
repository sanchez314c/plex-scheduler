# TODO

Work items for future releases.

## High Priority

All previous high-priority items (hardcoded paths) were fixed in v1.0.0 pipeline audit.

## Medium Priority

- [ ] Add weekday/weekend schedule mode (run schedule only on weekdays, or different times on weekends)
- [ ] Linux/systemd support (equivalent to the launchd agent using a systemd user unit)
- [ ] Configurable check interval (currently hardcoded to 300 seconds in the launchd plist)
- [ ] Configurable log location (currently `~/Desktop/` by design, but some users may prefer elsewhere)

## Low Priority

- [ ] Multiple schedule windows per day (e.g., noon to 2 PM AND 10 PM to 4 AM)
- [ ] Add ShellCheck to CI/CD (GitHub Action)
- [ ] Quiet mode: suppress log entries when Plex is already in the correct state (reduces log noise from "already running/stopped" messages)
- [ ] `plex-scheduler.sh install` subcommand (so install logic can be called from within the main script)

## Completed

- [x] Fix hardcoded paths in `plex-control-panel.sh` (was `/Users/heathen-admin/Desktop/`)
- [x] Fix hardcoded paths in `install-plex-scheduler.sh` (was `/Users/heathen-admin/Desktop/`)
- [x] Fix `LOG_FILE` to use `$HOME` instead of hardcoded username path
- [x] Add automated test script for `is_within_schedule()` boundary cases
- [x] Create plist in installer instead of assuming it exists
- [x] Remove unused `PLEX_BINARY` variable
- [x] Fix hardcoded "10 PM - 4 AM" in status/control/help output
- [x] Add `10#` base prefix for octal-safe hour parsing
