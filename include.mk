
addon-syncthing-build:
	docker build --force-rm -t hoardercache-syncthing -f hoardercache-syncthing/Dockerfile .

addon-syncthing-run-daemon:
	docker run -d \
		-h apthoarder-syncthing \
		-p 43842:43842 \
		--restart=always \
		--volume "$(cache_directory)":/var/cache/apt-cacher-ng \
		--name hoardercache-syncthing \
		-t hoardercache-syncthing

addon-syncthing-restart:
	docker rm -f hoardercache-syncthing; \
	make addon-syncthing-run-daemon

syncthing-web:
	surf http://127.0.0.1:43842/
