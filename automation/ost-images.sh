#!/bin/bash -xe

BUILDS="rpmbuild"
EXPORT_DIR="exported-artifacts"
MAX_RPM_AGE="5" # in days

rm -rf "${EXPORT_DIR}"
mkdir -p "${EXPORT_DIR}"

export LIBGUESTFS_BACKEND=direct
export LIBGUESTFS_DEBUG=1
export LIBGUESTFS_TRACE=1

# Ensure /dev/kvm exists, otherwise it will still use
# direct backend, but without KVM (much slower).
# This is needed only for CI where we use chroot.
! [[ -c "/dev/kvm" ]] && mknod /dev/kvm c 10 232

on_exit() {
    make clean
    rm -rf "${BUILDS}"
}

publish_images() {
    cp -r "${EXPORT_DIR}"/*.rpm "${PUBLISH_DIR}/."
    dnf repomanage --old --keep "${MAX_RPM_AGE}" "${PUBLISH_DIR}" | xargs -r rm
    createrepo_c \
        --update \
        --retain-old-md-by-age "${MAX_RPM_AGE}d" \
        --compatibility \
        "${PUBLISH_DIR}"
}

trap on_exit EXIT

./build.sh

find "${BUILDS}" -iname "*.rpm" -exec mv {} "${EXPORT_DIR}/" \;
find "." -iname "*-pkglist*.txt" -exec mv {} "${EXPORT_DIR}/" \;

if [ -n "${PUBLISH_DIR}" ]; then
    publish_images
fi
