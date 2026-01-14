#!/bin/bash

MEMORY_OPTS="-Xms${MEMORY:-4G} -Xmx${MEMORY:-4G}"

if [ ! -f "Assets.zip" ]; then
    echo "ERROR: Assets.zip not found in /data. Please copy it from your game client."
    exit 1
fi

if [ ! -f ".authenticated" ]; then
    echo "--- FIRST TIME SETUP: AUTHENTICATION REQUIRED ---"
    echo "Please check the logs for the /auth login code."
    touch .authenticated
fi

exec java $MEMORY_OPTS -jar HytaleServer.jar \
    --assets Assets.zip \
    --bind 0.0.0.0:${PORT:-5520} \
    --nogui