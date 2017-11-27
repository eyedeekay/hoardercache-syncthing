
addon-syncthing-build:
	docker build --force-rm -t hoardercache-syncthing .

addon-syncthing-run-daemon:
	docker run -d --rm \
		-h apthoarder-syncthing \
		-p 43842:8384
		--restart=always \
		--volume "$(cache_directory)":/var/cache/apt-cacher-ng \
		--name hoardercache-syncthing \
		-t base-apt-cache

syncthing-web:
	sr W 127.0.0.1:43842
