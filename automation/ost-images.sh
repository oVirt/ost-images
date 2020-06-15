#!/bin/bash -xe

BUILDS="rpmbuild"
EXPORT_DIR="exported-artifacts"
PUBLISH_DIR="/var/www/html/yum"

rm -rf "${EXPORT_DIR}"
mkdir -p "${EXPORT_DIR}"

export LIBGUESTFS_BACKEND=direct

# Ensure /dev/kvm exists, otherwise it will still use
# direct backend, but without KVM (much slower).
# This is needed only for CI where we use chroot.
! [[ -c "/dev/kvm" ]] && mknod /dev/kvm c 10 232

on_exit() {
    make clean
    rm -rf "${BUILDS}"
}

trap on_exit EXIT

./build.sh

find "${BUILDS}" -iname "*.rpm" -exec mv {} "${EXPORT_DIR}/" \;
find "." -iname "*-pkglist*.txt" -exec mv {} "${EXPORT_DIR}/" \;
cp -r "${EXPORT_DIR}"/*.rpm "${PUBLISH_DIR}/."
createrepo_c \
    --update \
    --retain-old-md-by-age "5d" \
    --compatibility \
    "${PUBLISH_DIR}"
