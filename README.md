# Docker Hytale Server

Docker image that provides a Hytale Server.

---

## Quick Start Guide

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
4. Follow the prompts to authenticate downloads

### Environment Variable Options

| Argument    | Default Value    | Description                                                                         |
| ----------- | ---------------- | ----------------------------------------------------------------------------------- |
| MEMORY      | 8G               | How much RAM to dedicate to the server. (Recommended: Half of system RAM available) |
| SERVER_NAME | Hytale Server    | The name of your server                                                             |
| MOTD        |                  | Message of the day                                                                  |
| PASSWORD    |                  | Password required to join the server                                                |
| MAX_PLAYERS | 100              | Maximum players allowed in server                                                   |
| MAX_RADIUS  | 32               | Maximum view distance. Higher values = higher view distance at cost of performance. |
| WORLD_NAME  | default          | Which world folder to host                                                          |
| GAME_MODE   | Adventure        | Which game mode to host the world in                                                |
| JARFILE     | HytaleServer.jar | If your server jarfile is named anything other than the default                     |
| ASSETS_ZIP  | Assets.zip       | If your Assets.zip file is named anything other than the default                    |

---

## Disclaimer

Hytale is still in early access. Expect bugs and changes. This project is in no way affiliated with the Hytale team or Hypixel Studios Canada Inc.
