#!/bin/bash
set -e

echo "=== Plex Scheduler ==="
echo ""
echo "This project is macOS-only. It uses launchd for scheduling,"
echo "which is not available on Linux."
echo ""
echo "For Linux, you would need a systemd timer equivalent."
echo "See docs/TODO.md for planned Linux support."
echo ""
echo "To run on macOS: ./run-source-mac.sh"
exit 1
