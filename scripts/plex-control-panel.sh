#!/bin/bash

# Plex Control Panel - User-friendly interface for Plex scheduler

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEDULER_SCRIPT="$SCRIPT_DIR/plex-scheduler.sh"

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    clear
    echo -e "${BLUE}🎬 Plex Media Server Control Panel${NC}"
    echo "====================================="
    echo ""
}

print_status() {
    local status_output
    if status_output=$("$SCHEDULER_SCRIPT" status 2>&1) && [ -n "$status_output" ]; then
        echo -e "${GREEN}Current Status:${NC}"
        echo "$status_output" | while read -r line; do
            if [[ $line == *"RUNNING"* ]]; then
                echo -e "  ${GREEN}✅ $line${NC}"
            elif [[ $line == *"STOPPED"* ]]; then
                echo -e "  ${RED}❌ $line${NC}"
            else
                echo "  ℹ️  $line"
            fi
        done
    fi
    echo ""
}

show_menu() {
    echo -e "${YELLOW}Choose an option:${NC}"
    echo "1) Check Status & Schedule"
    echo "2) Force Start Plex Now"
    echo "3) Force Stop Plex Now"
    echo "4) Run Schedule Check (Manual)"
    echo "5) View Recent Logs"
    echo "6) Install/Reinstall Scheduler"
    echo "7) Uninstall Scheduler"
    echo "8) Exit"
    echo ""
    read -r -p "Enter your choice (1-8): " choice
}

handle_choice() {
    case $choice in
        1)
            print_status
            ;;
        2)
            echo -e "${YELLOW}Starting Plex Media Server...${NC}"
            "$SCHEDULER_SCRIPT" start
            echo ""
            echo -e "${GREEN}Action completed. Checking status...${NC}"
            print_status
            ;;
        3)
            echo -e "${YELLOW}Stopping Plex Media Server...${NC}"
            "$SCHEDULER_SCRIPT" stop
            echo ""
            echo -e "${GREEN}Action completed. Checking status...${NC}"
            print_status
            ;;
        4)
            echo -e "${YELLOW}Running manual schedule check...${NC}"
            "$SCHEDULER_SCRIPT" control
            echo ""
            echo -e "${GREEN}Schedule check completed. Checking status...${NC}"
            print_status
            ;;
        5)
            echo -e "${YELLOW}Recent Plex Scheduler Logs:${NC}"
            echo "-----------------------------------"
            local log_file="${HOME}/Desktop/plex-scheduler.log"
            if [ -f "$log_file" ]; then
                tail -n 20 "$log_file"
            else
                echo "No log file found yet."
            fi
            ;;
        6)
            echo -e "${YELLOW}Installing/Reinstalling Plex Scheduler...${NC}"
            "$SCRIPT_DIR/install-plex-scheduler.sh"
            ;;
        7)
            echo -e "${RED}Uninstalling Plex Scheduler...${NC}"
            echo "This will remove the automatic scheduling but keep Plex installed."
            read -r -p "Are you sure? (y/N): " confirm
            if [[ $confirm == [yY] ]]; then
                launchctl unload "$HOME/Library/LaunchAgents/com.plexscheduler.agent.plist" 2>/dev/null
                rm -f "$HOME/Library/LaunchAgents/com.plexscheduler.agent.plist"
                echo -e "${GREEN}✅ Scheduler uninstalled successfully${NC}"
            else
                echo -e "${YELLOW}❌ Uninstall cancelled${NC}"
            fi
            ;;
        8)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please select 1-8.${NC}"
            ;;
    esac
}

# Main loop
while true; do
    print_header
    print_status
    show_menu
    handle_choice
    echo ""
    read -r -p "Press Enter to continue..."
done