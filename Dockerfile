FROM alpine:3.23.2@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62 AS buildenv

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

FROM alpine:3.23.2@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62

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
