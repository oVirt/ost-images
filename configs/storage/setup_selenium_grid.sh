#!/bin/bash -xe

CHROME_CONTAINER_IMAGE='quay.io/ovirt/selenium-standalone-chrome:latest'
FIREFOX_CONTAINER_IMAGE='quay.io/ovirt/selenium-standalone-firefox:latest'
FFMPEG_CONTAINER_IMAGE='quay.io/ovirt/selenium-video:latest'

IMAGES=( \
    ${CHROME_CONTAINER_IMAGE} \
    ${FIREFOX_CONTAINER_IMAGE} \
    ${FFMPEG_CONTAINER_IMAGE} \
)

ARTIFACTS_PATH="/var/tmp/selenium"

dnf install -y podman

# redirect container storage to /var/tmp/
sed -i 's|/var/lib/containers/storage|/var/tmp/containers/storage|g' /etc/containers/storage.conf

# relabel redirected storage
semanage fcontext -a -e /var/lib/containers /var/tmp/containers
restorecon -R -v /var/tmp/containers

for image in ${IMAGES[@]}; do
    podman pull ${image}
done

mkdir -p ${ARTIFACTS_PATH}
chmod 777 ${ARTIFACTS_PATH}

# firewall-cmd is not working under virt-customize
sed -i 's|</zone>|<port port="4444" protocol="udp"/><port port="4444" protocol="tcp"/></zone>|' "/etc/firewalld/zones/public.xml"
