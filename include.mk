
export syncthing-device-id = $(shell docker exec hoardercache-syncthing syncthing -device-id)

define ST_CACHE_CONF
'\t<folder id=\"hoarder-syncthing-cached\" label=\"Syncthing Cache Folder\" path=\"/home/st/cache/\" type=\"readonly\" rescanIntervalS=\"60\" fsWatcherEnabled=\"false\" fsWatcherDelayS=\"10\" ignorePerms=\"false\" autoNormalize=\"true\">\n \
\t\t<device id=\"$(syncthing-device-id)\"></device>\n \
\t\t<filesystemType>basic</filesystemType>\n \
\t\t<minDiskFree unit=\"%\">1</minDiskFree>\n \
\t\t<versioning></versioning>\n \
\t\t<copiers>0</copiers>\n \
\t\t<pullers>0</pullers>\n \
\t\t<hashers>0</hashers>\n \
\t\t<order>random</order>\n \
\t\t<ignoreDelete>false</ignoreDelete>\n \
\t\t<scanProgressIntervalS>0</scanProgressIntervalS>\n \
\t\t<pullerPauseS>0</pullerPauseS>\n \
\t\t<maxConflicts>-1</maxConflicts>\n \
\t\t<disableSparseFiles>false</disableSparseFiles>\n \
\t\t<disableTempIndexes>false</disableTempIndexes>\n \
\t\t<paused>false</paused>\n \
\t\t<weakHashThresholdPct>25</weakHashThresholdPct>\n \
\t\t<markerName>/home/st/.stfolder.cache</markerName>\n \
\t</folder>'
endef

export ST_CACHE_CONF

define ST_IMPORT_CONF
\t<folder id=\"hoarder-syncthing-import\" label=\"Syncthing import Folder\" path=\"/home/st/import/\" type=\"readwrite\" rescanIntervalS=\"1800\" fsWatcherEnabled=\"false\" fsWatcherDelayS=\"10\" ignorePerms=\"false\" autoNormalize=\"true\">\n \
\t\t<device id=\"$(syncthing-device-id)\"></device>\n \
\t\t<filesystemType>basic</filesystemType>\n \
\t\t<minDiskFree unit=\"%\">1</minDiskFree>\n \
\t\t<versioning></versioning>\n \
\t\t<copiers>0</copiers>\n \
\t\t<pullers>0</pullers>\n \
\t\t<hashers>0</hashers>\n \
\t\t<order>random</order>\n \
\t\t<ignoreDelete>false</ignoreDelete>\n \
\t\t<scanProgressIntervalS>0</scanProgressIntervalS>\n \
\t\t<pullerPauseS>0</pullerPauseS>\n \
\t\t<maxConflicts>-1</maxConflicts>\n \
\t\t<disableSparseFiles>false</disableSparseFiles>\n \
\t\t<disableTempIndexes>false</disableTempIndexes>\n \
\t\t<paused>false</paused>\n \
\t\t<weakHashThresholdPct>25</weakHashThresholdPct>\n \
\t\t<markerName>/home/st/.stfolder.import</markerName>\n \
\t</folder>
endef

export ST_IMPORT_CONF

addon-syncthing-build:
	docker build --force-rm -t hoardercache-syncthing -f hoardercache-syncthing/Dockerfile .

addon-syncthing-run-daemon:
	docker run -d \
		-h apthoarder-syncthing \
		-p 43842:43842 \
		--restart=always \
		--volume "$(cache_directory)/import":/home/st/import \
		--volume "$(cache_directory)/cache":/home/st/cache \
		--name hoardercache-syncthing \
		-t hoardercache-syncthing

addon-syncthing-restart:
	docker rm -f hoardercache-syncthing; \
	make addon-syncthing-run-daemon

addon-syncthing-clobber:
	docker rm -f hoardercache-syncthing; \
	docker rmi -f hoardercache-syncthing; \
	docker system prune -f

addon-syncthing-pull:
	cd hoardercache-syncthing; git pull

addon-syncthing-update: addon-syncthing-pull addon-syncthing-build addon-syncthing-restart

syncthing-cacheconf:
	@echo "$(ST_CACHE_CONF)"

syncthing-importconf:
	@echo "$(ST_IMPORT_CONF)"

syncthing-device-id:
	@echo $(syncthing-device-id)

syncthing-web:
	sr W http://127.0.0.1:43842/ &
