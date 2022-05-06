#!/bin/bash -xe

# synchronize changes with https://github.com/oVirt/ovirt-system-tests/blob/master/ost_utils/pytest/fixtures/selenium.py
CHROME_CONTAINER_IMAGE='quay.io/ovirt/selenium-standalone-chrome:4.0.0'
FIREFOX_CONTAINER_IMAGE='quay.io/ovirt/selenium-standalone-firefox:4.0.0'
FFMPEG_CONTAINER_IMAGE='quay.io/ovirt/video:latest'

IMAGES=( \
    ${CHROME_CONTAINER_IMAGE} \
    ${FIREFOX_CONTAINER_IMAGE} \
    ${FFMPEG_CONTAINER_IMAGE} \
)

ARTIFACTS_PATH="/var/tmp/selenium"

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
