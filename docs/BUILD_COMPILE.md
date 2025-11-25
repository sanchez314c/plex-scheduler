# Build and Compile

## No Build Step

Plex Scheduler is pure bash. There is nothing to compile, transpile, bundle, or build. The scripts run directly.

```bash
# Make executable and run
chmod +x scripts/plex-scheduler.sh
./scripts/plex-scheduler.sh status
```

## run-source-linux.sh

A generic run-source script is included at the repo root but it does not apply to this project. It contains detection logic for Node, Python, Go, and Rust projects. Since none of those apply here, running it will exit without doing anything.

```bash
# This does nothing for this project, which is correct behavior
./run-source-linux.sh
```

## run-source-mac.sh

Same situation as the Linux script. Not used.

## run-source-windows.bat

Same situation. Not used. This project is macOS-only.

## Checking Script Syntax

To validate bash syntax without running a script:

```bash
bash -n scripts/plex-scheduler.sh
bash -n scripts/plex-control-panel.sh
bash -n scripts/install-plex-scheduler.sh
```

Exit code 0 means no syntax errors.

## ShellCheck (Optional)

For deeper static analysis, install ShellCheck:

```bash
brew install shellcheck
shellcheck scripts/plex-scheduler.sh
shellcheck scripts/plex-control-panel.sh
shellcheck scripts/install-plex-scheduler.sh
```

ShellCheck may flag some style issues with the existing code. Not all suggestions are required to fix.
