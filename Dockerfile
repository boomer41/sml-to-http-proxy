FROM --platform=$BUILDPLATFORM docker.io/library/golang:1.27-trixie@sha256:6fa523b3b5f87910a5712ae234ff8b94d80fb99c7b4f94754b135553d8c5588f AS build

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

COPY --from=build /build/smlToHttp /usr/bin/smlToHttp
ENTRYPOINT ["/usr/bin/smlToHttp"]
