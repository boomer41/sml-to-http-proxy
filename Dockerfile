FROM --platform=$BUILDPLATFORM docker.io/library/golang:1.27-trixie@sha256:9baa6b4187bbb98d240372a8a235ac0bb6b5ddd52bba1431dc2f7c0705862728 AS build

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

FROM docker.io/library/alpine:3.24.2@sha256:31b6477333eb8257db9e5d7c3a7264fd0467928756f0bbcc27d35bea5d28cdbd AS final
RUN addgroup -S -g 1000 sml-to-http && \
    adduser -SHD -u 1000 -G sml-to-http sml-to-http && \
    rm /etc/passwd- /etc/shadow- /etc/group-

COPY --from=build /build/smlToHttp /usr/bin/smlToHttp

USER 1000:1000
ENTRYPOINT ["/usr/bin/smlToHttp"]
