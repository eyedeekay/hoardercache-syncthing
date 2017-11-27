
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
	@echo "$(ST_CACHE_CONF)" | tee -a config.xml

syncthing-importconf:
	@echo "$(ST_IMPORT_CONF)" | tee -a config.xml

syncthing-deviceconf:
	@echo "    <device id=\"$(syncthing-device-id)\" name=\"apthoarder-syncthing\" compression=\"metadata\" introducer=\"false\" skipIntroductionRemovals=\"false\" introducedBy=\"\">" | tee -a config.xml
	@echo "        <address>dynamic</address>" | tee -a config.xml
	@echo "        <paused>false</paused>" | tee -a config.xml
	@echo "    </device>" | tee -a config.xml

syncthing-guiconf:
	@echo "    <gui enabled=\"true\" tls=\"false\" debugging=\"false\">" | tee -a config.xml
	@echo "        <address>127.0.0.1:8384</address>" | tee -a config.xml
	@echo "        <apikey>$(syncthing-apikey)</apikey>" | tee -a config.xml
	@echo "        <theme>default</theme>" | tee -a config.xml
	@echo "    </gui>" | tee -a config.xml

syncthing-optconf:
	@echo "    <options>" | tee -a config.xml
	@echo "        <listenAddress>default</listenAddress>" | tee -a config.xml
	@echo "        <globalAnnounceServer>default</globalAnnounceServer>" | tee -a config.xml
	@echo "        <globalAnnounceEnabled>true</globalAnnounceEnabled>" | tee -a config.xml
	@echo "        <localAnnounceEnabled>true</localAnnounceEnabled>" | tee -a config.xml
	@echo "        <localAnnouncePort>21027</localAnnouncePort>" | tee -a config.xml
	@echo "        <localAnnounceMCAddr>[ff12::8384]:21027</localAnnounceMCAddr>" | tee -a config.xml
	@echo "        <maxSendKbps>0</maxSendKbps>" | tee -a config.xml
	@echo "        <maxRecvKbps>0</maxRecvKbps>" | tee -a config.xml
	@echo "        <reconnectionIntervalS>60</reconnectionIntervalS>" | tee -a config.xml
	@echo "        <relaysEnabled>true</relaysEnabled>" | tee -a config.xml
	@echo "        <relayReconnectIntervalM>10</relayReconnectIntervalM>" | tee -a config.xml
	@echo "        <startBrowser>true</startBrowser>" | tee -a config.xml
	@echo "        <natEnabled>true</natEnabled>" | tee -a config.xml
	@echo "        <natLeaseMinutes>60</natLeaseMinutes>" | tee -a config.xml
	@echo "        <natRenewalMinutes>30</natRenewalMinutes>" | tee -a config.xml
	@echo "        <natTimeoutSeconds>10</natTimeoutSeconds>" | tee -a config.xml
	@echo "        <urAccepted>0</urAccepted>" | tee -a config.xml
	@echo "        <urUniqueID></urUniqueID>" | tee -a config.xml
	@echo "        <urURL>https://data.syncthing.net/newdata</urURL>" | tee -a config.xml
	@echo "        <urPostInsecurely>false</urPostInsecurely>" | tee -a config.xml
	@echo "        <urInitialDelayS>1800</urInitialDelayS>" | tee -a config.xml
	@echo "        <restartOnWakeup>true</restartOnWakeup>" | tee -a config.xml
	@echo "        <autoUpgradeIntervalH>12</autoUpgradeIntervalH>" | tee -a config.xml
	@echo "        <upgradeToPreReleases>false</upgradeToPreReleases>" | tee -a config.xml
	@echo "        <keepTemporariesH>24</keepTemporariesH>" | tee -a config.xml
	@echo "        <cacheIgnoredFiles>false</cacheIgnoredFiles>" | tee -a config.xml
	@echo "        <progressUpdateIntervalS>5</progressUpdateIntervalS>" | tee -a config.xml
	@echo "        <limitBandwidthInLan>false</limitBandwidthInLan>" | tee -a config.xml
	@echo "        <minHomeDiskFree unit=\"%\">1</minHomeDiskFree>" | tee -a config.xml
	@echo "        <releasesURL>https://upgrades.syncthing.net/meta.json</releasesURL>" | tee -a config.xml
	@echo "        <overwriteRemoteDeviceNamesOnConnect>false</overwriteRemoteDeviceNamesOnConnect>" | tee -a config.xml
	@echo "        <tempIndexMinBlocks>10</tempIndexMinBlocks>" | tee -a config.xml
	@echo "        <trafficClass>0</trafficClass>" | tee -a config.xml
	@echo "        <weakHashSelectionMethod>auto</weakHashSelectionMethod>" | tee -a config.xml
	@echo "        <stunServer>default</stunServer>" | tee -a config.xml
	@echo "        <stunKeepaliveSeconds>24</stunKeepaliveSeconds>" | tee -a config.xml
	@echo "        <defaultKCPEnabled>false</defaultKCPEnabled>" | tee -a config.xml
	@echo "        <kcpNoDelay>false</kcpNoDelay>" | tee -a config.xml
	@echo "        <kcpUpdateIntervalMs>25</kcpUpdateIntervalMs>" | tee -a config.xml
	@echo "        <kcpFastResend>false</kcpFastResend>" | tee -a config.xml
	@echo "        <kcpCongestionControl>true</kcpCongestionControl>" | tee -a config.xml
	@echo "        <kcpSendWindowSize>128</kcpSendWindowSize>" | tee -a config.xml
	@echo "        <kcpReceiveWindowSize>128</kcpReceiveWindowSize>" | tee -a config.xml
	@echo "        <defaultFolderPath>~</defaultFolderPath>" | tee -a config.xml
	@echo "        <minHomeDiskFreePct>0</minHomeDiskFreePct>" | tee -a config.xml
	@echo "    </options>" | tee -a config.xml

syncthing-emitconf:
	@echo "<configuration version=\"23\">" | tee config.xml
	make syncthing-cacheconf
	make syncthing-importconf
	make syncthing-deviceconf
	make syncthing-guiconf
	make syncthing-optconf
	@echo "</configuration>" | tee -a config.xml

syncthing-device-id:
	@echo $(syncthing-device-id)

syncthing-web:
	sr W http://127.0.0.1:43842/ &
