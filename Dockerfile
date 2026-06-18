FROM golang:1.26-alpine AS builder

# Get sql_exporter
COPY .   /go/src/github.com/sql_exporter
WORKDIR /go/src/github.com/sql_exporter

# Install build tools and dependencies
RUN apk add git make &&\
    go install github.com/prometheus/promu@latest

# Do makefile
RUN go mod vendor &&\
    sed 's|//go:build ignore|//go:build go1.8\n// +build go1.8|' clickhouse/conn_go18.go > vendor/github.com/mailru/go-clickhouse/conn_go18.go
RUN make build

# Make image and copy build sql_exporter
FROM        quay.io/prometheus/busybox:glibc
LABEL maintainer="The Prometheus Authors <prometheus-developers@googlegroups.com>"
COPY        --from=builder /go/src/github.com/sql_exporter/sql_exporter  /bin/sql_exporter

EXPOSE      9399
ENTRYPOINT  [ "/bin/sql_exporter" ]
