#!/bin/bash

URL="https://omniutil.onrender.com/health"

while true; do
    echo "Pinging $URL at $(date)"
    curl -s $URL > /dev/null
    sleep 300 # 5 minutes
done
