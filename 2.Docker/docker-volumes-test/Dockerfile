FROM gcc:11 AS builder

WORKDIR /app
COPY hello.c .
RUN gcc -o myapp hello.c -static

FROM alpine:latest
COPY --from=builder /app/myapp /usr/local/bin/myapp
RUN ls -al /usr/local/bin
ENTRYPOINT ["myapp",""]
