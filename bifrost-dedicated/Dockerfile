ARG BUILD_FROM
FROM $BUILD_FROM

RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        iproute2 \
        python3 \
        slirp4netns \
        util-linux \
        yq \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=0755 run.sh /usr/local/bin/bifrost-addon-run

# we need to start in /config/bifrost, so we have access to configuration,
# state, certificate, etc

WORKDIR /config/bifrost

CMD ["/usr/local/bin/bifrost-addon-run"]
