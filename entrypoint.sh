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

# Global variable for version info
LATEST_VERSION=""

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

# Helper function to backup universe folder
backup_universe_folder() {
    if [ -d "universe" ]; then
        BACKUP_TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        BACKUP_DIR="universe_backup_${BACKUP_TIMESTAMP}"
        echo "Backing up universe folder to ${BACKUP_DIR}..."
        
        # Create backup with rsync
        echo "Backing up universe folder..."
        rsync -av universe/ "${BACKUP_DIR}/"
        
        if [ $? -eq 0 ]; then
            echo "Universe folder backed up to: ${BACKUP_DIR}"
        else
            echo "ERROR: Failed to backup universe folder!"
            echo "Aborting update to prevent data loss."
            exit 1
        fi
    else
        echo "No universe folder found to backup."
    fi
}

# Helper function to download and extract downloader
download_and_extract_downloader() {
    echo "Downloading Hytale downloader..."
    curl -L -o download.zip https://downloader.hytale.com/hytale-downloader.zip
    echo "Extracting downloader..."
    unzip -o download.zip
    chmod +x hytale-downloader-linux-amd64
}

# Helper function to get server version from downloader
get_server_version() {
    ./hytale-downloader-linux-amd64 -print-version 2>&1 | head -n1 | tr -d '\n\r' || echo ""
}

# Function to check and update the downloader itself
check_and_update_downloader() {
    echo "Checking for Hytale downloader updates..."
    
    # Ensure downloader exists
    if [ ! -f "download.zip" ]; then
        download_and_extract_downloader
    fi
    
    if [ ! -f "hytale-downloader-linux-amd64" ]; then
        echo "Extracting downloader..."
        unzip -o download.zip
        chmod +x hytale-downloader-linux-amd64
    fi
    
    # Check if downloader needs update
    UPDATE_CHECK_OUTPUT=$(./hytale-downloader-linux-amd64 -check-update 2>&1)
    UPDATE_CHECK_STATUS=$?
    
    # Check if command succeeded
    if [ $UPDATE_CHECK_STATUS -ne 0 ]; then
        echo "Warning: Failed to check for downloader updates (exit code: $UPDATE_CHECK_STATUS)"
        echo "Continuing with existing downloader version..."
        return
    fi
    
    if ! echo "$UPDATE_CHECK_OUTPUT" | grep -q "up to date"; then
        echo "Downloader update available. Updating..."
        rm -f download.zip
        rm -f hytale-downloader-linux-amd64
        download_and_extract_downloader
        echo "Downloader updated successfully."
    else
        echo "Downloader is up to date."
    fi
}

# Function to check and update server version
check_and_update_version() {
    if [ "$CHECK_FOR_UPDATES" = "true" ]; then
        # Always check and update downloader first
        check_and_update_downloader
        
        echo "Checking for server updates..."
        
        # Get the latest version available
        LATEST_VERSION=$(get_server_version)
        
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
                    echo "AUTO_UPDATE is enabled. Backing up universe folder before update..."
                    
                    # Backup universe folder before removing server files
                    backup_universe_folder
                    
                    echo "Removing old server files and downloading latest version..."
                    
                    # Remove old server files (quote variables to handle special characters)
                    rm -f "$JARFILE"
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
            echo "No version file found. Assuming current installation is outdated and forcing update to latest version..."
            
            # Backup universe folder before removing server files
            backup_universe_folder
            
            # Remove old server files to force download of latest version
            rm -f "$JARFILE"
            rm -f game.zip
            rm -rf Server
            
            echo "Will download and install version: $LATEST_VERSION"
        fi
    fi
}

# Run version check
check_and_update_version

if [ ! -f "$JARFILE" ]; then
    if [ ! -f "download.zip" ] || [ ! -f "hytale-downloader-linux-amd64" ]; then
        download_and_extract_downloader
    fi

    if [ ! -f "hytale-downloader-linux-amd64" ]; then
        echo "ERROR: Failed to extract downloader"
        exit 1
    fi
    
    echo "Downloading server files..."
    ./hytale-downloader-linux-amd64 -download-path game.zip
    
    if [ ! -f "game.zip" ]; then
        echo "ERROR: Failed to download game.zip"
        exit 1
    fi
    
    echo "Extracting server files..."
    unzip -o game.zip
    
    if [ ! -f "Server/HytaleServer.jar" ]; then
        echo "ERROR: HytaleServer.jar not found in extracted files"
        exit 1
    fi
    
    mv Server/HytaleServer.jar .
    
    # Save version information
    if [ -n "$LATEST_VERSION" ]; then
        VERSION="$LATEST_VERSION"
    else
        # Fallback: get version if not already determined
        VERSION=$(get_server_version)
        if [ -z "$VERSION" ]; then
            VERSION="unknown"
        fi
    fi
    echo "$VERSION" > .server_version
    echo "Downloaded version $VERSION"
fi

if [ ! -f "$ASSETS_ZIP" ]; then
    echo "ERROR: ${ASSETS_ZIP} not found. Please copy it from your game client."
    exit 1
fi

exec java $MEMORY_OPTS -jar "$JARFILE" \
    --assets "$ASSETS_ZIP" \
    --bind 0.0.0.0:${PORT:-5520} \