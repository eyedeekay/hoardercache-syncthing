FROM alpine:edge
RUN apk update
RUN apk add syncthing make
RUN adduser -h /home/st/ -S -D st st
COPY . /home/st/
WORKDIR /home/st/
USER st
RUN syncthing -generate /home/st/.config/syncthing
RUN mkdir -p /home/st/cache /home/st/import && chown st /home/st/cache /home/st/import
RUN mkdir -p /home/st/import/.stfolder
RUN make syncthing-emitconf
CMD syncthing -gui-address=0.0.0.0:43842 -no-browser
