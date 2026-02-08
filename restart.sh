#!/bin/bash
# MUD Server Restart Script
# Usage: ./restart.sh

echo "Restarting MUD server..."

# Kill existing processes
pkill -f "pike.*driver.pike" 2>/dev/null
sleep 2

# Start server
./startup.sh

echo "MUD server restarted."
