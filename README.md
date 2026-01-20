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
    restart: unless-stopped
```

3. First time setup requires some configuration. Run with `docker compose up`
4. Click the link in the terminal to authenticate via the Hytale website to complete the server file download <img src="https://github.com/zacheri04/docker-hytale-server/blob/main/assets/authentication_message_download_2.png?raw=true" alt="Auth Confirmation" width="1024">
5. When the server is started as shown below, press `Ctrl + C` to stop it <img src="https://github.com/zacheri04/docker-hytale-server/blob/main/assets/server_started.png?raw=true" alt="Server Started" width="1024">
6. Run `docker compose up -d`
7. Run `docker ps` and find the container ID
8. Run `docker attach [container-id]` as shown below
9. You're now in the server console. Run `/auth login device` and follow the authentication prompt similar to step 4. <img src="https://github.com/zacheri04/docker-hytale-server/blob/main/assets/server_auth.png?raw=true" alt="Server Started" width="1024">
10. OPTIONAL (but recommended): Run `/auth persistence Encrypted`. This will save your authentication so you don't have to run it every time the server starts.
11. You can now run `Ctrl P, Q` to detach from the Docker container.
12. You're done. Connect with your server's IP address on port 5520. You can stop the server with `docker stop [container-id]` and start it with `docker compose up -d`.

### Environment Variable Options

| Argument    | Default Value    | Description                                                                         |
| ----------- | ---------------- | ----------------------------------------------------------------------------------- |
| MEMORY      | 8G               | How much RAM to dedicate to the server. (Recommended: Half of system RAM available) |
| PORT        | 5520             | Port the server is hosted on                                                        |
| VERSION     | latest           | Version of the Hytale server to use. When set, server JAR will be named HytaleServer-{VERSION}.jar. Default is "latest" which uses HytaleServer.jar |
| SERVER_NAME | Hytale Server    | Name of server                                                                      |
| MOTD        |                  | Message of the day                                                                  |
| PASSWORD    |                  | Password required to join the server                                                |
| MAX_PLAYERS | 100              | Maximum players allowed in server                                                   |
| MAX_RADIUS  | 32               | Maximum view distance. Higher values = higher view distance at cost of performance  |
| WORLD_NAME  | default          | Which world folder to host                                                          |
| GAME_MODE   | Adventure        | Which game mode to host the world in                                                |
| JARFILE     | HytaleServer.jar | If your server jarfile is named anything other than the default                     |
| ASSETS_ZIP  | Assets.zip       | If your Assets.zip file is named anything other than the default                    |

---

## 🛠️ Troubleshooting
| Problem                                                          | Solution                                                               |
| ---------------------------------------------------------------- | ---------------------------------------------------------------------- |
| I'm getting an error message about JWT tokens being out of date? | Update your system's clock. Time must be synced for the server to run. |


---

## ⚠️ Disclaimer

Hytale is still in early access. Expect bugs and changes. This project is in no way affiliated with the Hytale team or Hypixel Studios Canada Inc.
