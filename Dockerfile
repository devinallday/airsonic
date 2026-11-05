FROM eclipse-temurin:8-jre

LABEL description="Airsonic media streamer, Azure-ready build" \
      url="https://github.com/airsonic/airsonic"

ENV AIRSONIC_PORT=8080 \
    AIRSONIC_DIR=/airsonic \
    CONTEXT_PATH=/ \
    JVM_HEAP=512m

WORKDIR $AIRSONIC_DIR

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ffmpeg \
        lame \
        tini \
        curl \
    && rm -rf /var/lib/apt/lists/*

COPY install/docker/run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

COPY airsonic-main/target/airsonic.war airsonic.war

EXPOSE $AIRSONIC_PORT

VOLUME $AIRSONIC_DIR/data $AIRSONIC_DIR/music $AIRSONIC_DIR/playlists $AIRSONIC_DIR/podcasts

HEALTHCHECK --interval=15s --timeout=3s --start-period=300s \
    CMD curl -fsS http://localhost:"$AIRSONIC_PORT""$CONTEXT_PATH"rest/ping || exit 1

ENTRYPOINT ["tini", "--", "run.sh"]
