#!/bin/bash

MEMORY_OPTS="-Xms${MEMORY:-4G} -Xmx${MEMORY:-4G}"

# Set defaults for environment variables
SERVER_NAME=${SERVER_NAME:-"Hytale Server"}
MOTD=${MOTD:-""}
PASSWORD=${PASSWORD:-""}
MAX_PLAYERS=${MAX_PLAYERS:-100}
MAX_RADIUS=${MAX_RADIUS:-32}
WORLD_NAME=${WORLD_NAME:-"default"}
GAME_MODE=${GAME_MODE:-"Adventure"}
JARFILE=${JARFILE:-"HytaleServer.jar"}
ASSETS_ZIP=${ASSETS_ZIP:-"Assets.zip"}

# Use jq to build the JSON object
# We use --arg for strings and --argjson for numbers/booleans
jq -n \
  --arg name "$SERVER_NAME" \
  --arg motd "$MOTD" \
  --arg pass "$PASSWORD" \
  --argjson max "$MAX_PLAYERS" \
  --argjson radius "$MAX_RADIUS" \
  --arg world "$WORLD_NAME" \
  --arg mode "$GAME_MODE" \
  '{
    "Version": 3,
    "ServerName": $name,
    "MOTD": $motd,
    "Password": $pass,
    "MaxPlayers": $max,
    "MaxViewRadius": $radius,
    "LocalCompressionEnabled": false,
    "Defaults": {
      "World": $world,
      "GameMode": $mode
    },
    "ConnectionTimeouts": {
      "JoinTimeouts": {}
    },
    "RateLimit": {},
    "Modules": {
      "PathPlugin": {
        "Modules": {}
      }
    },
    "LogLevels": {},
    "Mods": {},
    "DisplayTmpTagsInStrings": false,
    "PlayerStorage": {
      "Type": "Hytale"
    },
    "AuthCredentialStore": {
      "Type": "Encrypted",
      "Path": "auth.enc"
    }
  }' > config.json


if [ ! -f $JARFILE ]; then
    if [ ! -f "download.zip" ]; then
        echo "Downloading Hytale downloader..."
        curl -L -o download.zip https://downloader.hytale.com/hytale-downloader.zip
    fi

    if [ ! -f "hytale-downloader-linux-amd64" ]; then
        echo "Extracting downloader..."
        unzip -o download.zip
        chmod +x hytale-downloader-linux-amd64
        ./hytale-downloader-linux-amd64 -download-path game.zip
        unzip game.zip
        mv Server/HytaleServer.jar .
    fi
fi

if [ ! -f $ASSETS_ZIP ]; then
    echo "ERROR: ${ASSETS_ZIP} not found. Please copy it from your game client."
    exit 1
fi

exec java $MEMORY_OPTS -jar $JARFILE \
    --assets $ASSETS_ZIP \
    --bind 0.0.0.0:${PORT:-5520} \