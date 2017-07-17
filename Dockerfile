FROM ubuntu:xenial

# Install runtime dependencies
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        ca-certificates \
        libfontconfig \
        libpng-dev \
        libjpeg-dev \
        libwebp-dev \
        openssl \
        zlibc \
        libfreetype6 \
        libicu-dev \
        libxml2 \
        libxslt1-dev \
        libhyphen0 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN set -x  \
    # Install official PhantomJS release
 && apt-get update \
 && apt-get install -y --no-install-recommends \
        curl \
 && mkdir /tmp/phantomjs \
 && curl -L https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.5.0-beta-linux-ubuntu-xenial-x86_64.tar.gz \
        | tar -xz --strip-components=1 -C /tmp/phantomjs \
 && mv /tmp/phantomjs/bin/phantomjs /usr/local/bin \
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
 && chmod a+x /usr/local/bin/phantomjs \
 && chown phantomjs.phantomjs /usr/local/bin/phantomjs

USER phantomjs

EXPOSE 8910

ENTRYPOINT ["dumb-init"]
CMD ["phantomjs"]
