#!/bin/bash -xe

CHROME_CONTAINER_IMAGE='quay.io/ovirt/selenium-standalone-chrome:4.0.0'
FIREFOX_CONTAINER_IMAGE='quay.io/ovirt/selenium-standalone-firefox:4.0.0'
FFMPEG_CONTAINER_IMAGE='quay.io/ovirt/video:latest'

IMAGES=( \
    ${CHROME_CONTAINER_IMAGE} \
    ${FIREFOX_CONTAINER_IMAGE} \
    ${FFMPEG_CONTAINER_IMAGE} \
)

ARTIFACTS_PATH="/var/tmp/selenium"
DOCKER_CONFIG_PATH="/etc/docker"

# redirect container storage to /var/tmp/
mkdir -p ${DOCKER_CONFIG_PATH}
echo "{\"data-root\":\"/var/tmp/docker\"}" > "${DOCKER_CONFIG_PATH}/daemon.json"

dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce
systemctl enable docker

# TODO: figure out a way to pull images here if docker works for us
#for image in ${IMAGES[@]}; do
#    docker pull ${image}
#done

mkdir -p ${ARTIFACTS_PATH}
chmod 777 ${ARTIFACTS_PATH}

# firewall-cmd is not working under virt-customize
sed -i 's|</zone>|<port port="4444" protocol="udp"/><port port="4444" protocol="tcp"/></zone>|' "/etc/firewalld/zones/public.xml"
