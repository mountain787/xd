#!/bin/bash
# MUD Server Restart Script with graceful shutdown
# Usage: ./restart.sh

IP="127.0.0.1"
PORT="13800"
PROJECT="gamelib"

echo "==== Restarting MUD server ===="

# Build Vue frontend
echo ""
echo "========================================"
echo "  Building Vue Frontend..."
echo "========================================"
cd vue_source && npm run build && cd ..
if [ $? -eq 0 ]; then
    echo "✓ Frontend built successfully"
else
    echo "✗ Frontend build failed"
fi
echo ""

# Graceful shutdown via telnet
echo "Sending shutdown command..."
SHUTDOWN_RESULT=$(echo -e "login_fee $PROJECT fhwl111\nshutdown\nquit\n" | nc "$IP" "$PORT" 2>&1)

if [ $? -eq 0 ]; then
    echo "✓ Shutdown successful"
else
    echo "✗ Shutdown failed (server may not be running)"
fi

# Wait for shutdown to complete
echo "Waiting for shutdown..."
sleep 3

# Start server
echo "Starting server..."
./startup.sh

if [ $? -eq 0 ]; then
    echo "✓ Server started successfully"
else
    echo "✗ Server start failed"
fi

echo "==== MUD server restarted ===="
