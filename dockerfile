FROM quay.io/projectquay/golang:1.21 as builder

WORKDIR /go/src/app
COPY . .
ARG OS
RUN make $OS


FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot", "start"]