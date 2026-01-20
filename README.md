<!-- LOGO -->
<h1>
<p align="center">
  <img src="https://github.com/zacheri04/docker-hytale-server/blob/main/assets/project_icon.png?raw=true" alt="Logo" width="512">
  <br>Docker Hytale Server
</p>
</h1>

Docker image that provides a Hytale Server.

## Features

- Automatically downloads server files
- Extensive configuration of config.json via environment variables
- More to come!

---

## 📖 Quick Start Guide

### Quick Start with Docker Compose

This example `docker-compose.yml` will create a server on the default port 5520 with 8GB of RAM.

1. Create a new folder and open it
2. Paste the following into new file named `docker-compose.yml`:

```yml:docker-compose.yml
services:
  hytale:
    network_mode: "host"
    image: zacheri/hytale-server
    tty: true
    stdin_open: true
    ports:
      - "5520:5520"
    environment:
      - MEMORY=8G
      - PORT=5520
    volumes:
      - ./:/data
      - /etc/machine-id:/etc/machine-id:ro  # Required for Encrypted authentication
    restart: unless-stopped
```

3. First time setup requires some configuration. Run with `docker compose up`
4. Click the link in the terminal to authenticate via the Hytale website to complete the server file download <img src="https://github.com/zacheri04/docker-hytale-server/blob/main/assets/authentication_message_download_2.png?raw=true" alt="Auth Confirmation" width="1024">
5. When the server is started as shown below, press `Ctrl + C` to stop it <img src="https://github.com/zacheri04/docker-hytale-server/blob/main/assets/server_started.png?raw=true" alt="Server Started" width="1024">
6. Run `docker compose up -d`
7. Run `docker ps` and find the container ID
8. Run `docker attach [container-id]` as shown below
9. You're now in the server console. Run `/auth login device` and follow the authentication prompt similar to step 4. <img src="https://github.com/zacheri04/docker-hytale-server/blob/main/assets/server_auth.png?raw=true" alt="Server Started" width="1024">
10. OPTIONAL (but recommended): Run `/auth persistence Encrypted`. This will save your authentication so you don't have to run it every time the server starts. **Note: For Encrypted authentication to work properly, the volume mount `/etc/machine-id:/etc/machine-id:ro` is required in your docker-compose.yml.**
11. You can now run `Ctrl P, Q` to detach from the Docker container.
12. You're done. Connect with your server's IP address on port 5520. You can stop the server with `docker stop [container-id]` and start it with `docker compose up -d`.

### Environment Variable Options

| Argument          | Default Value    | Description                                                                                                                 |
| ----------------- | ---------------- | --------------------------------------------------------------------------------------------------------------------------- |
| MEMORY            | 8G               | How much RAM to dedicate to the server. (Recommended: Half of system RAM available)                                         |
| PORT              | 5520             | Port the server is hosted on                                                                                                |
| SERVER_NAME       | Hytale Server    | Name of server                                                                                                              |
| MOTD              |                  | Message of the day                                                                                                          |
| PASSWORD          |                  | Password required to join the server                                                                                        |
| MAX_PLAYERS       | 100              | Maximum players allowed in server                                                                                           |
| MAX_RADIUS        | 32               | Maximum view distance. Higher values = higher view distance at cost of performance                                          |
| WORLD_NAME        | default          | Which world folder to host                                                                                                  |
| GAME_MODE         | Adventure        | Which game mode to host the world in                                                                                        |
| JARFILE           | HytaleServer.jar | If your server jarfile is named anything other than the default                                                             |
| ASSETS_ZIP        | Assets.zip       | If your Assets.zip file is named anything other than the default                                                            |
| CHECK_FOR_UPDATES | false            | Check if the latest version of the game is being used on startup. Also checks and updates the downloader tool automatically |
| AUTO_UPDATE       | false            | Automatically delete old server files and redownload if outdated (requires CHECK_FOR_UPDATES=true)                          |

---

## 🔄 Update System & Backup Behavior

### Automatic Updates

The container includes an intelligent update system to keep your server current:

- **CHECK_FOR_UPDATES=true**: Checks for server updates on startup and compares with your currently installed version
- **AUTO_UPDATE=true**: Automatically downloads new versions when available (requires CHECK_FOR_UPDATES=true)

### Update Process

1. **Downloader Update**: The Hytale downloader tool is automatically checked and updated first
2. **Version Detection**: Current and latest versions are compared
3. **Backup Creation**: If an update is needed, your `universe` folder is automatically backed up
4. **Server Update**: Old server files are removed and the latest version is downloaded

### Backup System

Before any server update, the container automatically backs up your world data:

- **Backup Location**: Created in the same directory as your server files
- **Backup Format**: `universe_backup_YYYYMMDD_HHMMSS_vX.X.X/`
  - Example: `universe_backup_20260120_143022_v2026.01.17-4b0f30090/`
- **Backup Method**: Uses `rsync` for reliable, incremental backups
- **Safety**: Updates are aborted if backup fails, preventing data loss

### Manual Backup

Backups are created automatically during updates, but you can also:

- Stop your container: `docker compose down`
- Manually copy the `universe/` folder to a safe location
- Restart your container: `docker compose up -d`

---

## 🛠️ Troubleshooting

| Problem                                                          | Solution                                                               |
| ---------------------------------------------------------------- | ---------------------------------------------------------------------- |
| I'm getting an error message about JWT tokens being out of date? | Update your system's clock. Time must be synced for the server to run. |

---

## ⚠️ Disclaimer

Hytale is still in early access. Expect bugs and changes. This project is in no way affiliated with the Hytale team or Hypixel Studios Canada Inc.
