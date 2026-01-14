FROM eclipse-temurin:25-jre-jammy

RUN apt-get update && apt-get install -y curl jq unzip && rm -rf /var/lib/apt/lists/*

WORKDIR /data

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5580

ENTRYPOINT [ "/entrypoint.sh" ]