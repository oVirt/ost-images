#!/bin/bash

# This helper script builds ost-images.
# It caches images in current directory, source code is supposed to be in ost-images subdir
# Additional mandatory variables that need to be set:
# DISTRO - which image to build. Defaults to el8stream.
# BUILD_HE_INSTALLED - build appliance image. set to 0 or "" if you do not want it to be build. Not relevant for "node" distros. Defaults to 1.
# NODE_URL_BASE - URL for ovirt-node/rhvh images - defaults to ovirt-node repo
# CENTOS_CACHE_URL - URL we download isos from. If not provided the iso files must exist locally.
# RHEL8 - RHEL 8 compose repo, must have BaseOS/x86_64/os/images subdir with bootable image. Used for rhel8 distro.
# RHEL8_BUILD - RHV build repo. Used for rhel8 distro.
# RHVM_REPO - repo for additional RHV packages like rhvm-appliance. Used only for rhvh distro.
# OPENSCAP_PROFILE - set a profile during installation. Defaults to xccdf_org.ssgproject.content_profile_stig on rhel8.

[[ -d ost-images ]] || { echo "missing ost-images subdir"; exit 1; }

echo Building distro ${DISTRO:=el8stream}
echo "with appliance: ${BUILD_HE_INSTALLED:=1}"
echo "with node image url: ${NODE_URL_BASE:=https://resources.ovirt.org/repos/ovirt/github-ci/ovirt-node-ng-image/}"

# cache CentOS images
declare -A INSTALL_URL
INSTALL_URL[el8]="CentOS.iso"
INSTALL_URL[el8stream]="CentOS-Stream.iso"
INSTALL_URL[el9stream]="CentOS-Stream-9.iso"
IMAGE=${INSTALL_URL[$DISTRO]}
if [[ -n "${CENTOS_CACHE_URL}" && -n "$IMAGE" ]]; then
    echo "cache $IMAGE"
    curl $([[ -f $IMAGE ]] && echo "-z $IMAGE") --fail --limit-rate 100M -O ${CENTOS_CACHE_URL}/$IMAGE || { echo Download of $IMAGE failed; rm -f $IMAGE; exit 1; }
fi

# cache ovirt-node/rhvh image
if [ $DISTRO = "rhvh" ]; then
    NODE_IMG=rhvh.iso
    LATEST=$(curl --fail ${NODE_URL_BASE} | grep 'dvd1.iso<' | sed -n 's;.*>\(.*\)<.*;\1;p')
    curl --fail -L -o $NODE_IMG $([[ -f $NODE_IMG ]] && echo -z $NODE_IMG) "${NODE_URL_BASE}/${LATEST}" || exit 1
elif [ $DISTRO = "node" ]; then
    NODE_IMG=node.iso
    # Latest ovirt-node as built by https://github.com/oVirt/ovirt-node-ng-image/actions/workflows/build.yml
    NODE_URL_DIST=el8
    NODE_URL_LATEST_VERSION=$(curl --fail "${NODE_URL_BASE}" | sed -n 's;.*a href="\(ovirt-node-ng-installer-[0-9.-]*.'$NODE_URL_DIST'.iso\)\".*;\1;p' | grep "\.${NODE_URL_DIST}\." | sort | tail -1)
    echo "latest node ${NODE_URL_BASE}${NODE_URL_LATEST_VERSION}"
    curl --fail -L -o $NODE_IMG $([[ -f $NODE_IMG ]] && echo -z $NODE_IMG) ${NODE_URL_BASE}${NODE_URL_LATEST_VERSION} || exit 1
fi

# validate OpenSCAP profile parameter
# TODO we cannot use the profile on RHVH until we make changes to RHVH
#if [ $DISTRO = "rhel8" -o $DISTRO = "rhvh" ]; then
if [ $DISTRO = "rhel8" ]; then
    echo "With OpenSCAP profile: ${OPENSCAP_PROFILE:-none}"
else
    echo "Distro doesn't work with OpenSCAP profiles properly, ignoring"
    OPENSCAP_PROFILE=
fi


pushd ost-images
rm -rf rpmbuild/RPMS/*
[ -d /var/tmp ] && export TMPDIR=/var/tmp #virt-sparsify

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
    --with-distro=$DISTRO

TRIES=2
while [ $TRIES -gt 0 ]; do #try again once
  make clean
  BUILD_WHAT="BUILD_BASE=1 BUILD_HOST_INSTALLED=1 BUILD_ENGINE_INSTALLED=1 BUILD_HE_INSTALLED=${BUILD_HE_INSTALLED}"
  if [ $DISTRO = "el8" ]; then
    time make \
        INSTALL_URL=../$IMAGE \
        BUILD_BASE=1 \
        BUILD_HOST_INSTALLED=1 \
        BUILD_ENGINE_INSTALLED=1 \
        BUILD_HE_INSTALLED=${BUILD_HE_INSTALLED} \
        OPENSCAP_PROFILE="${OPENSCAP_PROFILE}" \
        rpm
  elif [ $DISTRO = "el8stream" ]; then
    time make \
        REPO_ROOT=http://mirror.centos.org/centos/8-stream \
        INSTALL_URL=../$IMAGE \
        BUILD_BASE=1 \
        BUILD_HOST_INSTALLED=1 \
        BUILD_ENGINE_INSTALLED=1 \
        BUILD_HE_INSTALLED=${BUILD_HE_INSTALLED} \
        OPENSCAP_PROFILE="${OPENSCAP_PROFILE}" \
        rpm
  elif [ $DISTRO = "el9stream" ]; then
    time make \
        REPO_ROOT=https://composes.stream.centos.org/production/latest-CentOS-Stream/compose/ \
        INSTALL_URL=../$IMAGE \
        BUILD_BASE=1 \
        BUILD_HOST_INSTALLED=1 \
        BUILD_ENGINE_INSTALLED= \
        BUILD_HE_INSTALLED= \
        OPENSCAP_PROFILE="${OPENSCAP_PROFILE}" \
        USE_FIPS= \
        rpm
  elif [ $DISTRO = "rhel8" ]; then
    for i in rhel8-provision-engine.sh.in rhel8-provision-host.sh.in; do
        sed "s|%BUILD%|$RHEL8_BUILD|g" $i.in > $i
    done
    time make \
        REPO_ROOT=${RHEL8} \
        INSTALL_URL=${RHEL8}/BaseOS/x86_64/os/ \
        BUILD_BASE=1 \
        BUILD_HOST_INSTALLED=1 \
        BUILD_ENGINE_INSTALLED=1 \
        BUILD_HE_INSTALLED=${BUILD_HE_INSTALLED} \
        OPENSCAP_PROFILE="${OPENSCAP_PROFILE}" \
        rpm
  elif [ $DISTRO = "node" -o $DISTRO = "rhvh" ]; then
    # REPO_ROOT is just where "other stuff" like rhvm-appliance comes from. Used only for rhvh.
    time make \
        REPO_ROOT=${RHVM_REPO} \
        INSTALL_URL=../$NODE_IMG \
        SPARSIFY_BASE=no \
        DISK_SIZE=80G \
        BUILD_BASE=1 \
        BUILD_ENGINE_INSTALLED= \
        BUILD_HOST_INSTALLED= \
        BUILD_HE_INSTALLED= \
        OPENSCAP_PROFILE="${OPENSCAP_PROFILE}" \
        rpm
  fi
  [ $? -eq 0 ] && break
  let TRIES-=1
  sleep 600
done
[ $TRIES -eq 0 ] && exit 1

popd
