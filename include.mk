
addon-syncthing-build:
	docker build --force-rm -t hoardercache-syncthing -f hoardercache-syncthing/Dockerfile .

addon-syncthing-run-daemon:
	docker run -d \
		-h apthoarder-syncthing \
		-p 43842:8384 \
		--restart=always \
		--volume "$(cache_directory)":/var/cache/apt-cacher-ng \
		--name hoardercache-syncthing \
		-t hoardercache-syncthing

syncthing-web:
	sr W 127.0.0.1:43842
