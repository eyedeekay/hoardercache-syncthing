FROM alpine:edge
RUN apk update
RUN apk add syncthing
RUN adduser -h /home/st/ -S -D st st
RUN mkdir -p /home/st/cache /home/st/import
RUN echo "_import" /home/st/cache/.stignore
COPY . /home/st/
WORKDIR /home/st/
USER st
CMD syncthing -gui-address=127.0.0.1:43842 -no-browser
