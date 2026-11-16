#!/bin/bash

HOST="127.0.0.1"
PORT="9101"

echo "SUNPULSE SOLAR FARM"
echo "RECEIVER AVAILABILITY CHECK"
echo "Checking $HOST:$PORT"

if timeout 3 bash -c "echo >/dev/tcp/$HOST/$PORT" 2>/dev/null
then
    echo "PASS: TCP Receiver is reachable."
    exit 0
else
    echo "FAIL: TCP Receiver is unavailable."
    exit 1
fi
