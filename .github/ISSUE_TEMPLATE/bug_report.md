---
name: Bug Report
about: Something is broken in the scheduler or control panel
title: "[BUG] "
labels: bug
assignees: sanchez314c
---

## What happened?

<!-- Describe what went wrong. -->

## What did you expect to happen?

## Steps to Reproduce

1.
2.
3.

## Environment

- macOS version:
- Plex Media Server version:
- Shell (`echo $SHELL`):

## Relevant Log Output

Paste the relevant lines from `~/Desktop/plex-scheduler.log`:

```
```

## Schedule Configuration

What do you have set in `scripts/plex-scheduler.sh`?

```bash
SCHEDULE_START_TIME=""
SCHEDULE_END_TIME=""
```

## launchd Agent Status

Output of:
```bash
launchctl list | grep plexscheduler
```

```
```
