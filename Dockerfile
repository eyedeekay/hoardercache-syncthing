FROM alpine:edge
VOLUME ["/home/st/cache"]
VOLUME ["/home/st/import"]
#VOLUME ["/home/st/.config/syncthing"]
RUN apk update
RUN apk add syncthing make ca-certificates
RUN adduser -h /home/st/ -S -D st st
COPY . /home/st/
WORKDIR /home/st/
RUN mkdir -p /home/st/cache /home/st/import/.stfolder
RUN chown -R st /home/st/
RUN chmod a+w /home/st/
USER st
CMD syncthing -generate /home/st/.config/syncthing && \
        make syncthing-emitconf && \
        syncthing -gui-address=0.0.0.0:43842 -no-browser
