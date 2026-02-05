#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Plex Scheduler (macOS) ==="

# Make scripts executable
chmod +x "$SCRIPT_DIR/scripts/"*.sh 2>/dev/null

# Launch the interactive control panel
exec "$SCRIPT_DIR/scripts/plex-control-panel.sh"
