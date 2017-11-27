FROM alpine:3.6
RUN apk update
RUN apk add syncthing
RUN adduser -h /home/sync/ -S -D sync sync
USER sync
CMD syncthing
