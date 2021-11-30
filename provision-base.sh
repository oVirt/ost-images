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

# create a dummy repo - dnf is grumpy when it has no repos to work with
mkdir -p /etc/yum.repos.d/ost-dummy-repo/repodata
echo '<metadata packages="0"/>' > /etc/yum.repos.d/ost-dummy-repo/repodata/primary.xml
cat << EOF > /etc/yum.repos.d/ost-dummy-repo/repodata/repomd.xml
<repomd>
    <data type="primary">
        <location href="repodata/primary.xml"/>
    </data>
</repomd>
EOF
cat << EOF > /etc/yum.repos.d/dummy.repo
[dummy]
name=dummy
gpgcheck=0
baseurl=/etc/yum.repos.d/ost-dummy-repo
EOF

# Cause journal logs to persist after reboot.
mkdir -p /var/log/journal
