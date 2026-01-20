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
CHECK_FOR_UPDATES=${CHECK_FOR_UPDATES:-false}
AUTO_UPDATE=${AUTO_UPDATE:-false}

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

# Function to check and update server version
check_and_update_version() {
    if [ "$CHECK_FOR_UPDATES" = "true" ]; then
        echo "Checking for server updates..."
        
        # Ensure downloader exists
        if [ ! -f "download.zip" ]; then
            echo "Downloading Hytale downloader..."
            curl -L -o download.zip https://downloader.hytale.com/hytale-downloader.zip
        fi
        
        if [ ! -f "hytale-downloader-linux-amd64" ]; then
            echo "Extracting downloader..."
            unzip -o download.zip
            chmod +x hytale-downloader-linux-amd64
        fi
        
        # Get the latest version available
        LATEST_VERSION=$(./hytale-downloader-linux-amd64 -print-version 2>&1 | grep -oP '(?<=Version: ).*' || echo "")
        
        if [ -z "$LATEST_VERSION" ]; then
            echo "Warning: Could not determine latest version. Skipping version check."
            return
        fi
        
        echo "Latest version available: $LATEST_VERSION"
        
        # Check if we have a version file from previous installation
        if [ -f ".server_version" ]; then
            CURRENT_VERSION=$(cat .server_version)
            echo "Current installed version: $CURRENT_VERSION"
            
            if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
                echo "Server is outdated!"
                
                if [ "$AUTO_UPDATE" = "true" ]; then
                    echo "AUTO_UPDATE is enabled. Removing old server files and downloading latest version..."
                    
                    # Remove old server files
                    rm -f $JARFILE
                    rm -f game.zip
                    rm -rf Server
                    
                    echo "Old server files removed. New version will be downloaded."
                else
                    echo "AUTO_UPDATE is disabled. To update, set AUTO_UPDATE=true or manually delete the server files."
                fi
            else
                echo "Server is up to date!"
            fi
        else
            echo "No version file found. This may be a first-time installation or an upgrade from a previous version."
        fi
    fi
}

# Run version check
check_and_update_version

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
        
        # Save version information
        VERSION=$(./hytale-downloader-linux-amd64 -print-version 2>&1 | grep -oP '(?<=Version: ).*' || echo "unknown")
        echo "$VERSION" > .server_version
        echo "Downloaded version $VERSION"
    fi
fi

if [ ! -f $ASSETS_ZIP ]; then
    echo "ERROR: ${ASSETS_ZIP} not found. Please copy it from your game client."
    exit 1
fi

exec java $MEMORY_OPTS -jar $JARFILE \
    --assets $ASSETS_ZIP \
    --bind 0.0.0.0:${PORT:-5520} \