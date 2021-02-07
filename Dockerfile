FROM golang:1.15-alpine as builder
ENV VERSION "1.3.3"

RUN apk update && apk add --no-cache git ca-certificates && update-ca-certificates

WORKDIR /app
COPY . .

RUN GOARCH=amd64 \
	GOOS=linux \
	CGO_ENABLED=0 \
	go build -o /cortex-tenant \
    -ldflags "-s -w -extldflags \"-static\" -X main.version=${VERSION}"

# executable image
FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /cortex-tenant /
COPY --from=builder /app/config.yml /etc/cortex/cortex-tenant.yml

USER 1000:1000

ENTRYPOINT ["/cortex-tenant"]
CMD ["-config", "/etc/cortex/cortex-tenant.yml"]
