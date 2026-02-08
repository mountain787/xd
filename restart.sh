#!/bin/bash
# MUD Server Restart Script with graceful shutdown
# Usage: ./restart.sh

IP="127.0.0.1"
PORT="13800"
PROJECT="gamelib"

echo "==== Restarting MUD server ===="

# Graceful shutdown via telnet
echo "Sending shutdown command..."
{
    sleep 0.5
    echo "login_fee $PROJECT fhwl111"
    sleep 0.5
    echo "shutdown"
    sleep 0.5
    echo "quit"
} | nc "$IP" "$PORT" 2>/dev/null

# Wait for shutdown to complete
echo "Waiting for shutdown..."
sleep 3

# Start server
echo "Starting server..."
./startup.sh

echo "==== MUD server restarted ===="
