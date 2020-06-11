#!/bin/bash -xe

BUILDS="rpmbuild"
EXPORT_DIR="exported-artifacts"

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
