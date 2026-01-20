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
VERSION=${VERSION:-"latest"}
ASSETS_ZIP=${ASSETS_ZIP:-"Assets.zip"}

# Determine the JAR file name based on version
if [ "$VERSION" = "latest" ]; then
    JARFILE=${JARFILE:-"HytaleServer.jar"}
else
    JARFILE=${JARFILE:-"HytaleServer-${VERSION}.jar"}
fi

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


# Check if the server JAR file exists
if [ ! -f "$JARFILE" ]; then
    echo "Server JAR file $JARFILE not found. Downloading version: $VERSION"
    
    # NOTE: The Hytale downloader currently only supports downloading the latest version.
    # The VERSION variable allows you to track which version is installed via the filename,
    # but all downloads will fetch the latest available version from Hytale's servers.
    
    # Download and extract the Hytale downloader if not present
    if [ ! -f "download.zip" ]; then
        echo "Downloading Hytale downloader..."
        curl -L -o download.zip https://downloader.hytale.com/hytale-downloader.zip
    fi

    if [ ! -f "hytale-downloader-linux-amd64" ]; then
        echo "Extracting downloader..."
        unzip -o download.zip
        chmod +x hytale-downloader-linux-amd64
    fi
    
    # Download the server files
    echo "Downloading Hytale server files..."
    ./hytale-downloader-linux-amd64 -download-path game.zip
    
    # Extract the server files
    echo "Extracting server files..."
    unzip -o game.zip
    
    # Move the JAR file to the versioned filename
    if [ -f "Server/HytaleServer.jar" ]; then
        mv Server/HytaleServer.jar "$JARFILE"
        echo "Server JAR saved as: $JARFILE"
    else
        echo "ERROR: Server JAR not found after extraction"
        exit 1
    fi
    
    # Clean up temporary files
    rm -rf Server
    rm -f game.zip
else
    echo "Using existing server JAR: $JARFILE"
fi

if [ ! -f "$ASSETS_ZIP" ]; then
    echo "ERROR: ${ASSETS_ZIP} not found. Please copy it from your game client."
    exit 1
fi

exec java $MEMORY_OPTS -jar "$JARFILE" \
    --assets "$ASSETS_ZIP" \
    --bind 0.0.0.0:${PORT:-5520} \