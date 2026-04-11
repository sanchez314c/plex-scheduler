#!/bin/bash

# Plex Scheduler Installation Script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEDULER_SCRIPT="$SCRIPT_DIR/plex-scheduler.sh"
PLIST_LABEL="com.plexscheduler.agent"
PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_LABEL}.plist"
LOG_FILE="${HOME}/Desktop/plex-scheduler.log"

echo "Plex Media Server Scheduler Installation"
echo "========================================="

# Check if Plex is installed
if [ ! -d "/Applications/Plex Media Server.app" ]; then
    echo "ERROR: Plex Media Server is not installed in /Applications/"
    echo "Please install Plex Media Server first, then run this script again."
    exit 1
fi

echo "Plex Media Server found"

# Verify the scheduler script exists
if [ ! -f "$SCHEDULER_SCRIPT" ]; then
    echo "ERROR: Scheduler script not found at $SCHEDULER_SCRIPT"
    exit 1
fi

# Create LaunchAgents directory if needed
mkdir -p "$HOME/Library/LaunchAgents"

# Unload any existing agent before reinstalling
if launchctl list "$PLIST_LABEL" > /dev/null 2>&1; then
    echo "Removing existing launchd agent..."
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
fi

# Create the plist file
echo "Creating launchd agent plist..."
cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${PLIST_LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>${SCHEDULER_SCRIPT}</string>
        <string>control</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>RunAtLoad</key>
    <false/>
    <key>StandardOutPath</key>
    <string>${HOME}/Desktop/plex-scheduler-output.log</string>
    <key>StandardErrorPath</key>
    <string>${HOME}/Desktop/plex-scheduler-error.log</string>
</dict>
</plist>
EOF

echo "Plist created at $PLIST_PATH"

# Load the launchd agent
echo "Loading launchd agent..."
if launchctl load "$PLIST_PATH"; then
    echo "Launchd agent loaded successfully"
else
    echo "ERROR: Failed to load launchd agent"
    exit 1
fi

# Test the script
echo "Testing Plex scheduler..."
"$SCHEDULER_SCRIPT" status

echo ""
echo "Installation complete!"
echo ""
SCHEDULE_INFO=$("$SCHEDULER_SCRIPT" help 2>/dev/null | grep 'Schedule:' | sed 's/^Schedule: //')
echo "Schedule: ${SCHEDULE_INFO:-Plex runs on configured schedule}"
echo "Control Script: $SCHEDULER_SCRIPT"
echo "Plist: $PLIST_PATH"
echo "Logs: $LOG_FILE"
echo ""
echo "Manual Commands:"
echo "  Check status:    $SCHEDULER_SCRIPT status"
echo "  Force start:     $SCHEDULER_SCRIPT start"
echo "  Force stop:      $SCHEDULER_SCRIPT stop"
echo "  Manual check:    $SCHEDULER_SCRIPT control"
echo ""
echo "Note: The scheduler checks every 5 minutes and will automatically"
echo "    start/stop Plex based on the configured schedule."
