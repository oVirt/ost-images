#!/bin/bash -xe

# NetworkManager drop-in config for stable ipv6 addresses
cat << EOF > /etc/NetworkManager/conf.d/10-stable-ipv6-addr.conf
[connection]
ipv6.addr-gen-mode=0
ipv6.dhcp-duid=ll
ipv6.dhcp-iaid=mac
EOF

# Download RHEL8 oscap XML needed by offline runs
curl -L -o /root/security-data-oval-com.redhat.rhsa-RHEL8.xml https://www.redhat.com/security/data/oval/com.redhat.rhsa-RHEL8.xml
