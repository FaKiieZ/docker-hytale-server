# Docker Hytale Server

Docker image that provides a Hytale Server.

---

## Quick Start Guide

### Quick Start with Docker Compose

1. Add a `docker-compose.yml` file to your directory
2. Paste the following:

```yml
services:
  hytale:
    network_mode: "host"
    build: .
    container_name: hytale-dedicated
    tty: true
    stdin_open: true
    ports:
      - "5520:5520/udp"
    environment:
      - MEMORY=8G
      - PORT=5520
    volumes:
      - ./hytale_data:/data
    restart: unless-stopped
```

3. Run with `docker compose up -d`

---

## Disclaimer

Hytale is still in early access. Expect bugs and changes. This project is in no way affiliated with the Hytale team or Hypixel Studios Canada Inc.
