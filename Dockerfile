FROM alpine:edge
RUN apk update
RUN apk add syncthing make
RUN adduser -h /home/st/ -S -D st st
RUN mkdir -p /home/st/cache /home/st/import
RUN echo "_import" /home/st/cache/.stignore
COPY . /home/st/
WORKDIR /home/st/
USER st
RUN syncthing -generate /home/st/.config/syncthing
RUN make syncthing-emitconf
CMD syncthing -gui-address=0.0.0.0:43842 -no-browser
