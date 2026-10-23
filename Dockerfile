FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a AS buildenv

ENV SOURCE_URL=https://github.com/esnet/iperf/releases/download/3.19.1/iperf-3.19.1.tar.gz \
    SOURCE_SHA256SUM_URL=https://github.com/esnet/iperf/releases/download/3.19.1/iperf-3.19.1.tar.gz.sha256

# Download source file, extract and compile
WORKDIR /iperf3
RUN apk --no-cache add tar build-base \
    && wget ${SOURCE_URL} \
    && wget ${SOURCE_SHA256SUM_URL} \
    && sha256sum -c *.sha256 \
    && for tarfile in *.tar.gz; do tar -xz --strip-components=1 --file="$tarfile"; done \
    && ./configure \
    && make \
    && make install

FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

# Copy relevant compiled files to distribution image
RUN adduser --system iperf3 \
    && ldconfig -n /usr/local/lib
COPY --from=buildenv /usr/local/lib/ /usr/local/lib/
COPY --from=buildenv /usr/local/bin/ /usr/local/bin/
COPY --from=buildenv /usr/local/include/ /usr/local/include/
COPY --from=buildenv /usr/local/share/man/ /usr/local/share/man/

# Switch to non-root user
USER iperf3

# Set expose port and entrypoint
EXPOSE 5201
ENTRYPOINT ["iperf3"]

LABEL org.opencontainers.image.authors="MattKobayashi <matthew@kobayashi.au>"
