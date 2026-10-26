FROM --platform=$BUILDPLATFORM docker.io/library/golang:1.27-trixie@sha256:fbb7ae40b62ff8afe31662df570d39b4f5052ac32b90dae8e60d7657a20a74f4 AS build

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
