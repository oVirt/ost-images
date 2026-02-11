#!/bin/bash

# This helper script builds ost-images.
# Source code is supposed to be in ost-images subdir
# Additional mandatory variables that need to be set:
# DISTRO - which image to build. Defaults to centos9.
# BUILD_HE_INSTALLED - build appliance image. set to 0 or "" if you do not want it to be build. Not relevant for "node" distros. Defaults to 1.

[[ -d ost-images ]] || { echo "missing ost-images subdir"; exit 1; }

echo Building distro ${DISTRO:=centos}
echo "distro version: ${DISTRO_VERSION:=9}"
echo "with appliance: ${BUILD_HE_INSTALLED:=1}"

pushd ost-images

rm -rf rpmbuild/RPMS/*

autoreconf -if

prefix=/usr
libdir=$prefix/lib64
sysconfdir=/etc
localstatedir=/var
./configure \
    --prefix=$prefix \
    --libdir=$libdir \
    --sysconfdir=$sysconfdir \
    --localstatedir=$localstatedir \
    --with-distro=$DISTRO \
    --with-distro-version=$DISTRO_VERSION

make clean
time make -e rpm

MAKE_EXIT=$?

popd

exit $MAKE_EXIT