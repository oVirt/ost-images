#!/bin/bash -xe

CHROME_CONTAINER_IMAGE='quay.io/ovirt/node-chrome-debug:4.0.0'
FIREFOX_CONTAINER_IMAGE='quay.io/ovirt/node-firefox-debug:4.0.0'
HUB_CONTAINER_IMAGE='quay.io/ovirt/hub:4.0.0'
FFMPEG_CONTAINER_IMAGE='quay.io/ovirt/video:ffmpeg-4.3.1-20211025'

IMAGES=( \
    ${CHROME_CONTAINER_IMAGE} \
    ${FIREFOX_CONTAINER_IMAGE} \
    ${HUB_CONTAINER_IMAGE} \
    ${FFMPEG_CONTAINER_IMAGE} \
)

ARTIFACTS_PATH="/var/tmp/selenium"
SYSTEMD_UNITS_PATH="/usr/lib/systemd/system"

dnf install -y podman

# redirect container storage to /var/tmp/
sed -i 's|/var/lib/containers/storage|/var/tmp/containers/storage|g' /etc/containers/storage.conf

for image in ${IMAGES[@]}; do
    podman pull ${image}
done

# relabel redirected storage
semanage fcontext -a -e /var/lib/containers /var/tmp/containers
restorecon -R -v /var/tmp/containers

mkdir -p ${ARTIFACTS_PATH}
chmod 777 ${ARTIFACTS_PATH}

# firewall-cmd is not working under virt-customize
sed -i 's|</zone>|<port port="4444" protocol="udp"/><port port="4444" protocol="tcp"/></zone>|' "/etc/firewalld/zones/public.xml"


# Selenium pod unit
cat << EOF > ${SYSTEMD_UNITS_PATH}/selenium-pod.service
[Unit]
Description=Podman selenium-pod.service
Wants=network-online.target
After=network-online.target
RequiresMountsFor=

Requires=selenium-hub.service \
    selenium-node-firefox-debug.service \
    selenium-node-chrome-debug.service

Wants=selenium-video-firefox.service \
    selenium-video-chrome.service

Before=selenium-hub.service \
    selenium-node-firefox-debug.service \
    selenium-node-chrome-debug.service \
    selenium-video-firefox.service \
    selenium-video-chrome.service

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=no
TimeoutStopSec=70

ExecStartPre=/usr/bin/podman pod create \
    --name selenium-pod \
    --replace=true \
    --network=slirp4netns:enable_ipv6=true \
    -p 4444:4444 \
    -p 5900:5900 \
    -p 7900:7900 \
    -p 5901:5901 \
    -p 7901:7901

ExecStart=/usr/bin/podman pod start \
    selenium-pod

ExecStop=/usr/bin/podman pod stop \
    --ignore \
    selenium-pod \
    -t 10

Type=forking

[Install]
WantedBy=multi-user.target default.target
EOF


# Selenium hub unit
cat << EOF > ${SYSTEMD_UNITS_PATH}/selenium-hub.service
[Unit]
Description=Podman selenium-hub.service
Wants=network-online.target
After=network-online.target
BindsTo=selenium-pod.service
After=selenium-pod.service

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=no
TimeoutStopSec=70
SuccessExitStatus=143

ExecStart=/usr/bin/podman run \
    --cgroups=no-conmon \
    --sdnotify=conmon \
    --replace \
    -d \
    -v /dev/shm:/dev/shm \
    --name selenium-hub \
    --pod selenium-pod \
    quay.io/ovirt/hub:4.0.0

ExecStop=/usr/bin/podman stop \
    --ignore \
    selenium-hub

Type=notify
NotifyAccess=all

[Install]
WantedBy=multi-user.target default.target
EOF


# Selenium chrome node unit
cat << EOF > ${SYSTEMD_UNITS_PATH}/selenium-node-chrome-debug.service
[Unit]
Description=Podman selenium-node-chrome-debug.service
Wants=network-online.target
After=network-online.target
BindsTo=selenium-pod.service
After=selenium-pod.service

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=no
TimeoutStopSec=70
SuccessExitStatus=143

ExecStart=/usr/bin/podman run \
    --cgroups=no-conmon \
    --sdnotify=conmon \
    -d \
    -v /dev/shm:/dev/shm \
    -v /var/tmp/selenium/:/export:Z \
    -e SE_EVENT_BUS_HOST=localhost \
    -e SE_EVENT_BUS_PUBLISH_PORT=4442 \
    -e SE_EVENT_BUS_SUBSCRIBE_PORT=4443 \
    -e "SE_OPTS=--port 5600" \
    -e DISPLAY_NUM=100 \
    -e DISPLAY=:100 \
    -e VNC_PORT=5900 \
    -e NO_VNC_PORT=7900 \
    -e VNC_NO_PASSWORD=1 \
    -e SCREEN_WIDTH=1600 \
    -e SCREEN_HEIGHT=900 \
    --name selenium-node-chrome-debug \
    --pod selenium-pod \
    quay.io/ovirt/node-chrome-debug:4.0.0

ExecStop=/usr/bin/podman stop \
    --ignore \
    selenium-node-chrome-debug

Type=notify
NotifyAccess=all

[Install]
WantedBy=multi-user.target default.target
EOF


# Selenium firefox node unit
cat << EOF > ${SYSTEMD_UNITS_PATH}/selenium-node-firefox-debug.service
[Unit]
Description=Podman selenium-node-firefox-debug.service
Wants=network-online.target
After=network-online.target
BindsTo=selenium-pod.service
After=selenium-pod.service

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=no
TimeoutStopSec=70
SuccessExitStatus=143

ExecStart=/usr/bin/podman run \
    --cgroups=no-conmon \
    --sdnotify=conmon \
    -d \
    -v /dev/shm:/dev/shm \
    -v /var/tmp/selenium/:/export:Z \
    -e SE_EVENT_BUS_HOST=localhost \
    -e SE_EVENT_BUS_PUBLISH_PORT=4442 \
    -e SE_EVENT_BUS_SUBSCRIBE_PORT=4443 \
    -e "SE_OPTS=--port 5601" \
    -e DISPLAY_NUM=101 \
    -e DISPLAY=:101 \
    -e VNC_PORT=5901 \
    -e NO_VNC_PORT=7901 \
    -e VNC_NO_PASSWORD=1 \
    -e SCREEN_WIDTH=1600 \
    -e SCREEN_HEIGHT=900 \
    --name selenium-node-firefox-debug \
    --pod selenium-pod \
    quay.io/ovirt/node-firefox-debug:4.0.0

ExecStop=/usr/bin/podman stop \
    --ignore \
    selenium-node-firefox-debug

Type=notify
NotifyAccess=all

[Install]
WantedBy=multi-user.target default.target
EOF


# Selenium chrome video unit
cat << EOF > ${SYSTEMD_UNITS_PATH}/selenium-video-chrome.service
[Unit]
Description=Podman selenium-video-chrome.service
Documentation=man:podman-generate-systemd(1)
Wants=network-online.target
After=network-online.target
BindsTo=selenium-pod.service
After=selenium-pod.service

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=no
TimeoutStopSec=70
SuccessExitStatus=143

ExecStart=/usr/bin/podman run \
    --cgroups=no-conmon \
    --sdnotify=conmon \
    -d \
    -v /var/tmp/selenium/:/videos:Z \
    -e "DISPLAY_CONTAINER_NAME= " \
    -e DISPLAY=100 \
    -e FILE_NAME=video-chrome.mp4 \
    -e VIDEO_SIZE=1600x900 \
    --name selenium-video-chrome \
    --pod selenium-pod \
    quay.io/ovirt/video:ffmpeg-4.3.1-20211025

ExecStop=/usr/bin/podman stop \
    --ignore \
    selenium-video-chrome

Type=notify
NotifyAccess=all

[Install]
WantedBy=multi-user.target default.target
EOF


# Selenium firefox video unit
cat << EOF > ${SYSTEMD_UNITS_PATH}/selenium-video-firefox.service
[Unit]
Description=Podman selenium-video-firefox.service
Documentation=man:podman-generate-systemd(1)
Wants=network-online.target
After=network-online.target
BindsTo=selenium-pod.service
After=selenium-pod.service

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=no
TimeoutStopSec=70
SuccessExitStatus=143

ExecStart=/usr/bin/podman run \
    --cgroups=no-conmon \
    --sdnotify=conmon \
    -d \
    -v /var/tmp/selenium/:/videos:Z \
    -e "DISPLAY_CONTAINER_NAME= " \
    -e DISPLAY=101 \
    -e FILE_NAME=video-firefox.mp4 \
    -e VIDEO_SIZE=1600x900 \
    --name selenium-video-firefox \
    --pod selenium-pod \
    quay.io/ovirt/video:ffmpeg-4.3.1-20211025

ExecStop=/usr/bin/podman stop \
    --ignore \
    selenium-video-firefox

Type=notify
NotifyAccess=all

[Install]
WantedBy=multi-user.target default.target
EOF
