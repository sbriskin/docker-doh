FROM alpine:latest

RUN set -e; \
    apk add --no-cache ca-certificates git go gcc musl-dev; \
    GOPATH=/tmp/go GOBIN=/bin go get -v -ldflags '-s' blitiri.com.ar/go/dnss; \
    apk del git go gcc musl-dev; \
    rm -rf /tmp/go

EXPOSE 443

ENTRYPOINT ["/bin/dnss", "-enable_https_to_dns", "-testing__insecure_http"]

