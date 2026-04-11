#!/bin/bash

# Plex Media Server Scheduler
# Controls Plex based on time windows (10 PM - 4 AM default)

# Configuration
LOG_FILE="${HOME}/Desktop/plex-scheduler.log"
SCHEDULE_START_TIME="22:00"  # 10 PM
SCHEDULE_END_TIME="04:00"    # 4 AM

# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check if Plex is currently running
is_plex_running() {
    if pgrep -f "Plex Media Server" > /dev/null 2>&1; then
        return 0  # True - running
    else
        return 1  # False - not running
    fi
}

# Start Plex Media Server
start_plex() {
    if ! is_plex_running; then
        log_message "Starting Plex Media Server"
        # Use launchctl to start the service
        launchctl load -w "$HOME/Library/LaunchAgents/com.plexapp.mediaserver.plist" 2>/dev/null || {
            # Fallback to direct launch if launchctl fails
            open -a "Plex Media Server"
        }

        # Wait and verify it started
        sleep 5
        if is_plex_running; then
            log_message "Plex Media Server started successfully"
            return 0
        else
            log_message "ERROR: Failed to start Plex Media Server"
            return 1
        fi
    else
        log_message "Plex Media Server is already running"
        return 0
    fi
}

# Stop Plex Media Server
stop_plex() {
    if is_plex_running; then
        log_message "Stopping Plex Media Server"

        # Try graceful shutdown first
        launchctl unload -w "$HOME/Library/LaunchAgents/com.plexapp.mediaserver.plist" 2>/dev/null

        # Give it time to shut down gracefully
        sleep 10

        # If still running, force quit
        if is_plex_running; then
            log_message "Force quitting Plex Media Server"
            pkill -f "Plex Media Server"
            sleep 3
        fi

        # Final check
        if ! is_plex_running; then
            log_message "Plex Media Server stopped successfully"
            return 0
        else
            log_message "ERROR: Failed to stop Plex Media Server"
            return 1
        fi
    else
        log_message "Plex Media Server is already stopped"
        return 0
    fi
}

# Check if current time is within scheduled window
is_within_schedule() {
    current_hour=$(date '+%H')
    current_minute=$(date '+%M')

    # Parse schedule times
    start_hour=$(echo "$SCHEDULE_START_TIME" | cut -d: -f1)
    start_minute=$(echo "$SCHEDULE_START_TIME" | cut -d: -f2)
    end_hour=$(echo "$SCHEDULE_END_TIME" | cut -d: -f1)
    end_minute=$(echo "$SCHEDULE_END_TIME" | cut -d: -f2)

    # Convert to minutes since midnight for easier comparison
    # Use 10# prefix to force base-10 parsing (prevents octal on hours 08/09)
    current_total=$((10#$current_hour * 60 + 10#$current_minute))
    start_total=$((10#$start_hour * 60 + 10#$start_minute))
    end_total=$((10#$end_hour * 60 + 10#$end_minute))

    # Handle overnight schedule (like 22:00 to 04:00)
    if [ "$start_total" -gt "$end_total" ]; then
        # Schedule crosses midnight
        if [ "$current_total" -ge "$start_total" ] || [ "$current_total" -lt "$end_total" ]; then
            return 0  # Within schedule
        fi
    elif [ "$start_total" -eq "$end_total" ]; then
        # Same start and end time: window is undefined, never within schedule
        return 1
    else
        # Normal schedule (same day)
        if [ "$current_total" -ge "$start_total" ] && [ "$current_total" -lt "$end_total" ]; then
            return 0  # Within schedule
        fi
    fi

    return 1  # Outside schedule
}

# Format a HH:MM 24-hour time string for human-readable display (e.g. "22:00" -> "10:00 PM")
format_time() {
    local time_str="$1"
    local hour minute suffix
    hour=$(echo "$time_str" | cut -d: -f1)
    minute=$(echo "$time_str" | cut -d: -f2)
    hour=$((10#$hour))
    if [ "$hour" -eq 0 ]; then
        suffix="AM"
        hour=12
    elif [ "$hour" -lt 12 ]; then
        suffix="AM"
    elif [ "$hour" -eq 12 ]; then
        suffix="PM"
    else
        suffix="PM"
        hour=$((hour - 12))
    fi
    printf "%d:%s %s" "$hour" "$minute" "$suffix"
}

# Main control function
control_plex() {
    log_message "Running Plex scheduler check"

    local start_display end_display
    start_display=$(format_time "$SCHEDULE_START_TIME")
    end_display=$(format_time "$SCHEDULE_END_TIME")

    if is_within_schedule; then
        log_message "Current time is within scheduled window (${start_display} - ${end_display})"
        start_plex
    else
        log_message "Current time is outside scheduled window"
        stop_plex
    fi
}

# Override functions for manual control
force_start() {
    log_message "Manual override: Force starting Plex"
    start_plex
}

force_stop() {
    log_message "Manual override: Force stopping Plex"
    stop_plex
}

show_status() {
    local start_display end_display
    start_display=$(format_time "$SCHEDULE_START_TIME")
    end_display=$(format_time "$SCHEDULE_END_TIME")

    if is_plex_running; then
        echo "Plex Media Server: RUNNING"
        if is_within_schedule; then
            echo "Schedule: Within allowed window (${start_display} - ${end_display})"
        else
            echo "Schedule: Outside allowed window (running due to manual override)"
        fi
    else
        echo "Plex Media Server: STOPPED"
        if is_within_schedule; then
            echo "Schedule: Within allowed window (should be running - may need manual start)"
        else
            echo "Schedule: Outside allowed window (correctly stopped)"
        fi
    fi
}

# Parse command line arguments
case "${1:-control}" in
    "start"|"force_start")
        force_start
        ;;
    "stop"|"force_stop")
        force_stop
        ;;
    "status")
        show_status
        ;;
    "control"|"check")
        control_plex
        ;;
    "help"|"-h"|"--help")
        start_display=$(format_time "$SCHEDULE_START_TIME")
        end_display=$(format_time "$SCHEDULE_END_TIME")
        echo "Plex Media Server Scheduler"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  control     - Check schedule and start/stop accordingly (default)"
        echo "  start       - Force start Plex Media Server"
        echo "  stop        - Force stop Plex Media Server"
        echo "  status      - Show current status and schedule info"
        echo "  help        - Show this help message"
        echo ""
        echo "Schedule: Plex runs from ${start_display} to ${end_display} automatically"
        echo "Log file: $LOG_FILE"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac