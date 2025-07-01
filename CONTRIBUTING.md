# Contributing

Thanks for taking an interest. This is a small bash utility, so contributions are straightforward.

## What's Worth Contributing

- Bug fixes in the schedule logic (`is_within_schedule` in `scripts/plex-scheduler.sh`)
- Linux/systemd equivalents (the project currently only targets macOS launchd)
- Additional schedule modes (weekday vs weekend, multiple windows per day)
- Improvements to the control panel TUI in `scripts/plex-control-panel.sh`
- Better error reporting when Plex fails to start or stop

## Getting Started

1. Fork the repo on GitHub
2. Clone your fork
3. Make your changes on a feature branch (`git checkout -b feature/your-feature`)
4. Test manually on macOS with Plex installed
5. Open a pull request

## Testing

There's no automated test suite. Manual testing steps:

```bash
# Verify status detection works
./scripts/plex-scheduler.sh status

# Verify help output
./scripts/plex-scheduler.sh help

# Verify the schedule check runs without error
./scripts/plex-scheduler.sh control

# Verify the control panel loads
./scripts/plex-control-panel.sh
```

If you're modifying `is_within_schedule`, test these boundary cases:
- Exact start time (22:00)
- Exact end time (04:00)
- One minute before start (21:59)
- One minute after end (04:01)
- Midnight crossover (23:59 and 00:01)
- A normal same-day window that doesn't cross midnight

## Code Style

- Bash with `#!/bin/bash` shebang
- Functions named with underscores: `is_plex_running`, `start_plex`
- Log all significant actions with `log_message`
- Keep error paths explicit (check return codes, log failures)
- No external dependencies beyond what ships with macOS

## Pull Request Guidelines

- One thing per PR
- Update CHANGELOG.md with what changed and why
- If you're adding a new script, update the tables in README.md and CLAUDE.md

## Reporting Bugs

Open a GitHub issue using the bug report template. Include:
- macOS version
- Plex Media Server version
- The relevant lines from `~/Desktop/plex-scheduler.log`
- What you expected vs what happened

## License

By contributing, you agree your changes will be released under the MIT license.
