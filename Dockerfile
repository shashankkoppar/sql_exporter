FROM golang:1.16-alpine AS builder

# Get sql_exporter
ADD .   /go/src/github.com/sql_exporter
WORKDIR /go/src/github.com/sql_exporter

# Do makefile
RUN apk add git make &&\
    go mod vendor &&\
    mv clickhouse/conn_go18.go vendor/github.com/mailru/go-clickhouse/conn_go18.go
RUN make build

# Make image and copy build sql_exporter
FROM        quay.io/prometheus/busybox:glibc
MAINTAINER  The Prometheus Authors <prometheus-developers@googlegroups.com>
COPY        --from=builder /go/src/github.com/sql_exporter/sql_exporter  /bin/sql_exporter

EXPOSE      9399
ENTRYPOINT  [ "/bin/sql_exporter" ]
