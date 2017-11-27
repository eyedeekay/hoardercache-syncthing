
export syncthing-device-id = $(shell docker exec hoardercache-syncthing syncthing -device-id)
export syncthing-apikey = $(shell docker exec hoardercache-syncthing grep apikey /home/st/.config/syncthing/config.xml | sed 's|apikey||g' | tr -d '</>' )

syncthing-api:
	@echo "$(syncthing-apikey)"

define ST_CACHE_CONF
'\t<folder id=\"hoarder-syncthing-cached\" label=\"Syncthing Cache Folder\" path=\"/home/st/cache/\" type=\"readonly\" rescanIntervalS=\"60\" fsWatcherEnabled=\"false\" fsWatcherDelayS=\"10\" ignorePerms=\"false\" autoNormalize=\"true\">\n \
\t<device id=\"$(syncthing-device-id)\"></device>\n \
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

syncthing-deviceconf:
	@echo "    <device id=\"$(syncthing-device-id)\" name=\"apthoarder-syncthing\" compression=\"metadata\" introducer=\"false\" skipIntroductionRemovals=\"false\" introducedBy=\"\">"
	@echo "        <address>dynamic</address>"
	@echo "        <paused>false</paused>"
	@echo "    </device>"

syncthing-guiconf:
	@echo "    <gui enabled=\"true\" tls=\"false\" debugging=\"false\">"
	@echo "        <address>127.0.0.1:8384</address>"
	@echo "        <apikey>$(syncthing-apikey)</apikey>"
	@echo "        <theme>default</theme>"
	@echo "    </gui>"

syncthing-optconf:
	@echo "    <options>"
	@echo "        <listenAddress>default</listenAddress>"
	@echo "        <globalAnnounceServer>default</globalAnnounceServer>"
	@echo "        <globalAnnounceEnabled>true</globalAnnounceEnabled>"
	@echo "        <localAnnounceEnabled>true</localAnnounceEnabled>"
	@echo "        <localAnnouncePort>21027</localAnnouncePort>"
	@echo "        <localAnnounceMCAddr>[ff12::8384]:21027</localAnnounceMCAddr>"
	@echo "        <maxSendKbps>0</maxSendKbps>"
	@echo "        <maxRecvKbps>0</maxRecvKbps>"
	@echo "        <reconnectionIntervalS>60</reconnectionIntervalS>"
	@echo "        <relaysEnabled>true</relaysEnabled>"
	@echo "        <relayReconnectIntervalM>10</relayReconnectIntervalM>"
	@echo "        <startBrowser>true</startBrowser>"
	@echo "        <natEnabled>true</natEnabled>"
	@echo "        <natLeaseMinutes>60</natLeaseMinutes>"
	@echo "        <natRenewalMinutes>30</natRenewalMinutes>"
	@echo "        <natTimeoutSeconds>10</natTimeoutSeconds>"
	@echo "        <urAccepted>0</urAccepted>"
	@echo "        <urUniqueID></urUniqueID>"
	@echo "        <urURL>https://data.syncthing.net/newdata</urURL>"
	@echo "        <urPostInsecurely>false</urPostInsecurely>"
	@echo "        <urInitialDelayS>1800</urInitialDelayS>"
	@echo "        <restartOnWakeup>true</restartOnWakeup>"
	@echo "        <autoUpgradeIntervalH>12</autoUpgradeIntervalH>"
	@echo "        <upgradeToPreReleases>false</upgradeToPreReleases>"
	@echo "        <keepTemporariesH>24</keepTemporariesH>"
	@echo "        <cacheIgnoredFiles>false</cacheIgnoredFiles>"
	@echo "        <progressUpdateIntervalS>5</progressUpdateIntervalS>"
	@echo "        <limitBandwidthInLan>false</limitBandwidthInLan>"
	@echo "        <minHomeDiskFree unit=\"%\">1</minHomeDiskFree>"
	@echo "        <releasesURL>https://upgrades.syncthing.net/meta.json</releasesURL>"
	@echo "        <overwriteRemoteDeviceNamesOnConnect>false</overwriteRemoteDeviceNamesOnConnect>"
	@echo "        <tempIndexMinBlocks>10</tempIndexMinBlocks>"
	@echo "        <trafficClass>0</trafficClass>"
	@echo "        <weakHashSelectionMethod>auto</weakHashSelectionMethod>"
	@echo "        <stunServer>default</stunServer>"
	@echo "        <stunKeepaliveSeconds>24</stunKeepaliveSeconds>"
	@echo "        <defaultKCPEnabled>false</defaultKCPEnabled>"
	@echo "        <kcpNoDelay>false</kcpNoDelay>"
	@echo "        <kcpUpdateIntervalMs>25</kcpUpdateIntervalMs>"
	@echo "        <kcpFastResend>false</kcpFastResend>"
	@echo "        <kcpCongestionControl>true</kcpCongestionControl>"
	@echo "        <kcpSendWindowSize>128</kcpSendWindowSize>"
	@echo "        <kcpReceiveWindowSize>128</kcpReceiveWindowSize>"
	@echo "        <defaultFolderPath>~</defaultFolderPath>"
	@echo "        <minHomeDiskFreePct>0</minHomeDiskFreePct>"
	@echo "    </options>"

syncthing-emitconf:
	@echo "<configuration version=\"23\">"
	make syncthing-cacheconf
	make syncthing-importconf
	make syncthing-deviceconf
	make syncthing-guiconf
	make syncthing-optconf
	@echo "</configuration>"

syncthing-device-id:
	@echo $(syncthing-device-id)

syncthing-web:
	sr W http://127.0.0.1:43842/ &
