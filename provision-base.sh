#!/bin/bash -xe

# NetworkManager drop-in config for stable ipv6 addresses
cat << EOF > /etc/NetworkManager/conf.d/10-stable-ipv6-addr.conf
[connection]
ipv6.addr-gen-mode=0
ipv6.dhcp-duid=ll
ipv6.dhcp-iaid=mac
EOF

# Create connection files for interfaces
# All connections will have never-default=True except eth0
for i in {0..5}; do
  iface="eth$i"
  cat << EOF > /etc/NetworkManager/system-connections/$iface
[connection]
id=$iface
uuid=$(uuid)
type=ethernet
autoconnect=true
interface-name=$iface

[ipv6]
method=auto
never-default=$([ $i -gt 0 ] && echo "true" || echo "false")

[ipv4]
method=auto
never-default=$([ $i -gt 0 ] && echo "true" || echo "false")
EOF
  chmod 600 /etc/NetworkManager/system-connections/$iface
done

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

# Add grub user(ost) and password(123456)
sed -i 's/\(set superusers=\).*/\1"ost"/g' /etc/grub.d/01_users
cat << EOF > /boot/grub2/user.cfg
GRUB2_PASSWORD=grub.pbkdf2.sha512.10000.91CD67730990F56A67373FAD6DFECCD03C582AE1FF28BB6953FE58497F631976DD4D20DFB9F0F5B196600F0C9ACF98CFDCBCEE1B5C73BB488BF65B08E6C36F2A.A063A2376D1DA0C3E5799F91EF30E1523A02AAADB3276F1756B58A77629437842ABC35F72155A362FD009C86455645D5335B74C5DC74F950AAC43C400915A9B3
EOF
grub2-mkconfig -o /boot/grub2/grub.cfg

# Fix root password lastchange date
head -1 /etc/shadow
sed -i  "/^root:/ s/::/:$((`date --utc --date "$1" +%s`/86400)):/" /etc/shadow
