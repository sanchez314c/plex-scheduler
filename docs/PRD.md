# Product Requirements Document - Plex Scheduler

**Version**: 1.0.0
**Last Updated**: 2026-03-27
**Stack**: Bash / macOS launchd
**Status**: Production-ready

## Problem

Plex Media Server runs continuously even when no one is using it. On a home server or Mac Pro, this consumes CPU and memory 24/7. The typical use pattern is nighttime viewing, not all-day streaming. There is no built-in scheduling feature in Plex.

## Goal

Stop Plex automatically when no one needs it and start it again before the viewing window begins. Do this without requiring the user to think about it after initial setup.

## Target User

A Plex user running Plex Media Server on a Mac who:
- Has a predictable viewing schedule (e.g., evenings only)
- Wants to reduce resource usage during off-hours
- Is comfortable running a shell script once to set it up
- Does not want to manage a persistent background service of their own

## Requirements

### Must Have

- Automatically start Plex at a configured start time
- Automatically stop Plex at a configured end time
- Handle schedules that cross midnight (e.g., 10 PM to 4 AM)
- Check on a regular interval (not just once at start/end time)
- Survive reboots and user login/logout
- Provide a way to check current state
- Provide a way to manually override (start/stop regardless of schedule)
- Log all actions with timestamps

### Should Have

- Interactive control panel for users who prefer a menu over CLI flags
- Clear error messages when Plex is not installed or fails to start
- Graceful stop before force kill

### Nice to Have

- Multiple schedule windows per day
- Different schedules on weekdays vs weekends
- Linux/systemd support

### Out of Scope

- Web UI
- Remote management
- Integration with Plex API or user activity detection
- Auto-start on media playback events
- Any network functionality

## Design Decisions

**launchd over cron:** macOS discourages cron for periodic tasks. launchd is the supported mechanism and integrates better with user sessions.

**5-minute check interval:** A tighter interval (1 minute) would feel more responsive but adds unnecessary launchd overhead. 5 minutes is acceptable for a start/stop scheduler with a 6-hour window.

**Script-based, no compiled binary:** The target user can read and modify bash scripts. A compiled binary would create a maintenance and trust barrier.

**Log to Desktop:** Visibility over convention. The target user is not a sysadmin.

**Single schedule window:** Covers the primary use case without added complexity. Multiple windows are a future enhancement.

## Success Criteria

- Plex starts within 5 minutes of the schedule window opening
- Plex stops within 5 minutes of the schedule window closing
- No false starts/stops during the configured window
- Correct behavior across midnight (22:00 to 04:00 window)
- Manual override works immediately
- All actions visible in `~/Desktop/plex-scheduler.log`
