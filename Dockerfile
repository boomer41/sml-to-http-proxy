FROM --platform=$BUILDPLATFORM docker.io/library/golang:1.27-trixie@sha256:af1bfc2614ebb1dbd31af514b78740fd678850e76498762b425ecee4c5c6ea80 AS build

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

FROM docker.io/library/alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf AS final
RUN addgroup -S -g 1000 sml-to-http && \
    adduser -SHD -u 1000 -G sml-to-http sml-to-http && \
    rm /etc/passwd- /etc/shadow- /etc/group-

COPY --from=build /build/smlToHttp /usr/bin/smlToHttp

USER 1000:1000
ENTRYPOINT ["/usr/bin/smlToHttp"]
