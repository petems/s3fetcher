# Build Stage
FROM lacion/alpine-golang-buildimage:1.11 AS build-stage

LABEL app="build-s3fetcher"
LABEL REPO="https://github.com/petems/s3fetcher"

ENV PROJPATH=/go/src/github.com/petems/s3fetcher

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/petems/s3fetcher
WORKDIR /go/src/github.com/petems/s3fetcher

RUN make build-alpine

# Final Stage
FROM lacion/alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/petems/s3fetcher"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/s3fetcher/bin

WORKDIR /opt/s3fetcher/bin

COPY --from=build-stage /go/src/github.com/petems/s3fetcher/bin/s3fetcher /opt/s3fetcher/bin/
RUN chmod +x /opt/s3fetcher/bin/s3fetcher

# Create appuser
RUN adduser -D -g '' s3fetcher
USER s3fetcher

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/s3fetcher/bin/s3fetcher"]
