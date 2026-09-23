FROM --platform=$BUILDPLATFORM docker.io/library/golang:1.27-trixie@sha256:433790e515d27dc6003e847e644cc0af956985cf315c1c58a3b73ee2dd305183 AS build

WORKDIR /build

COPY vendor go.mod go.sum ./
RUN go mod verify

COPY . .

ARG TARGETOS
ARG TARGETARCH

ENV GOOS=$TARGETOS
ENV GOARCH=$TARGETARCH
ENV CGO_ENABLED=0

RUN go build -o smlToHttp

FROM docker.io/library/alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS final
RUN addgroup -S -g 1000 sml-to-http && \
    adduser -SHD -u 1000 -G sml-to-http sml-to-http && \
    rm /etc/passwd- /etc/shadow- /etc/group-

COPY --from=build /build/smlToHttp /usr/bin/smlToHttp

USER 1000:1000
ENTRYPOINT ["/usr/bin/smlToHttp"]
