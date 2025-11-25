# Development

## Setup

```bash
git clone https://github.com/sanchez314c/plex-scheduler.git
cd plex-scheduler
chmod +x scripts/*.sh
```

No package manager, no `npm install`, no virtual environment. This is bash.

## Project Structure

```
plex-scheduler/
  scripts/
    plex-scheduler.sh         # Core logic
    plex-control-panel.sh     # Interactive TUI
    install-plex-scheduler.sh # One-time setup
  docs/                       # Documentation
  archive/                    # Old versions, not active
  .gitignore
  .editorconfig
  .gitattributes
  CHANGELOG.md
  README.md
  LICENSE
```

## Making Changes

### Editing the Schedule Logic

The schedule math is in `is_within_schedule()` in `scripts/plex-scheduler.sh`. Before changing it:

1. Understand the midnight crossover detection: `start_total > end_total` means the window spans midnight
2. Test boundary conditions manually (see below)
3. Do not change the algorithm without testing all four cases

### Testing Manually

Since there's no test suite, test by temporarily modifying `SCHEDULE_START_TIME` and `SCHEDULE_END_TIME` in the script and calling the function:

```bash
# Quick function-level test (add temporarily to script)
SCHEDULE_START_TIME="22:00"
SCHEDULE_END_TIME="04:00"
is_within_schedule && echo "IN schedule" || echo "OUT of schedule"
```

Test cases to cover:
- Current time exactly at start (22:00): should be IN
- Current time exactly at end (04:00): should be OUT (end is exclusive)
- One minute before start (21:59): should be OUT
- One minute after start (22:01): should be IN
- Midnight (00:00): should be IN for the 22:00-04:00 window
- One minute before end (03:59): should be IN
- One minute after end (04:01): should be OUT

### Editing the Control Panel

`scripts/plex-control-panel.sh` is a menu loop. It calls `plex-scheduler.sh` for all operations. If you add a new command to `plex-scheduler.sh`, add a menu option here for it.

The menu uses ANSI color codes. Keep new menu items consistent with the existing style (yellow prompts, green success, red errors/stops).

### Adding a New Command to plex-scheduler.sh

1. Write the function
2. Add a case in the `case "${1:-control}" in` block at the bottom
3. Add it to the `help` output
4. Update `docs/API.md`
5. Add a menu option in `plex-control-panel.sh` if it should be interactive
6. Update the function table in `CLAUDE.md`

## Code Style

- `#!/bin/bash` shebang on every script
- Functions: `snake_case`
- Variables: `UPPER_CASE` for config, `lower_case` for locals
- Log everything significant with `log_message`
- Check return codes: `if ! command; then log_message "ERROR: ..."; fi`
- No external tools beyond standard macOS bash builtins + `pgrep`, `pkill`, `launchctl`, `open`

## Branching

Work on feature branches:

```bash
git checkout -b feature/your-feature
# make changes
git add scripts/plex-scheduler.sh
git commit -m "feat: describe what changed"
git push origin feature/your-feature
```

Open a pull request from your branch. See CONTRIBUTING.md for PR guidelines.

## Commit Format

```
<type>: <short description>

Types: feat, fix, docs, refactor, test, chore
```

Examples:
```
feat: add weekday/weekend schedule mode
fix: handle edge case when Plex plist is missing from LaunchAgents
docs: update ARCHITECTURE with new function table
```
