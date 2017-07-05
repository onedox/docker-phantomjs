FROM debian:jessie

# Install runtime dependencies
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        ca-certificates \
        unzip \
        libfontconfig \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN set -x  \
    # Install PhantomJS pre-release: https://github.com/Vitallium/phantomjs/releases/tag/2.0.1
 && apt-get update \
 && apt-get install -y --no-install-recommends \
        curl \
 && mkdir /tmp/phantomjs \
 && curl -L https://github.com/Vitallium/phantomjs/releases/download/2.0.1/phantomjs-2.0.1-linux-x86_64.zip > /tmp/phantomjs.zip \
 && unzip /tmp/phantomjs.zip -d /tmp \
 && mv /tmp/phantomjs-2.0.1-linux-x86_64/bin/phantomjs /usr/local/bin \
 && chmod a+x /usr/local/bin/phantomjs \
    # Install dumb-init (to handle PID 1 correctly).
    # https://github.com/Yelp/dumb-init
 && curl -Lo /tmp/dumb-init.deb https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64.deb \
 && dpkg -i /tmp/dumb-init.deb \
    # Clean up
 && apt-get purge --auto-remove -y \
        curl \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* \
    \
    # Run as non-root user.
 && useradd --system --uid 72379 -m --shell /usr/sbin/nologin phantomjs \
 && su phantomjs -s /bin/sh -c "phantomjs --version"

USER phantomjs

EXPOSE 8910

ENTRYPOINT ["dumb-init"]
CMD ["phantomjs"]
