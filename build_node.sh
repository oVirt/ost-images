#!/bin/bash -xe

autoreconf -if

prefix=/usr
libdir=$prefix/lib64
sysconfdir=/etc
localstatedir=/var
./configure --prefix=$prefix --libdir=$libdir --sysconfdir=$sysconfdir --localstatedir=$localstatedir

export DISTRO=node
export SPARSIFY_BASE=no
export DISK_SIZE=80G
export BUILD_UPGRADE=
export BUILD_ENGINE_INSTALLED=
export BUILD_HOST_INSTALLED=
export BUILD_HE_INSTALLED=
export INSTALL_URL=https://resources.ovirt.org/pub/ovirt-4.4/iso/ovirt-node-ng-installer/4.4.3-2020112920/el8/ovirt-node-ng-installer-4.4.3-2020112920.el8.iso

make -e rpm
