#!/bin/bash -xe

DISTRO=$1

[[ -z $DISTRO ]] && { echo "Please enter distro version!"; exit 1; }

# Build ansible execution environment
ansible-builder build -t $DISTRO-ansible-executor -f ./build-ansible-ee/execution-environment.yml

# Publish ansible execution environment to the quay
podman login quay.io -u $QUAY_USERNAME --password $QUAY_TOKEN
podman push $DISTRO-ansible-executor quay.io/ovirt/$DISTRO-ansible-executor
