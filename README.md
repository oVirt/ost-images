# The oVirt System Test Images

The oVirt System Test projects relies on the existence of a few QCOW images packaged as RPMS
and made avaliable in a yum repository.

This project provides the scripts used to build those images.

## Preparing your system for building the images

Please note that building multiple QCOW images will require a lot of resources.
Be sure to have at least 100Gb of free disk space, at least 16Gb of RAM and 4 cores.

1. Ensure you have `git` and required tools for building the image:

   ```console
   dnf install -y git
   dnf install -y make autoconf automake rpm-build guestfs-tools libvirt-client libvirt-daemon-config-network qemu-img virt-install
   ```

2. As a normal user, clone ost-image repository

   ```console
   git clone https://github.com/oVirt/ost-images.git
   ```

3. Set environment variables for configuring the build script:

   ```console
   export DISTRO=el9stream
   ```

   Relevant environment variable you can use to configure the build script are:
   - `DISTRO` - which image to build. Defaults to el9stream.
   - `BUILD_HE_INSTALLED` - build appliance image. set to `0` or `""` if you do not want it to be build. Not relevant for "node" distros. Defaults to `1`.
   - `NODE_URL_BASE` - URL for ovirt-node/rhvh images - defaults to ovirt-node repo
   - `CENTOS_CACHE_URL` - URL we download ISOs from. If not provided the iso files must exist locally.
   - `OPENSCAP_PROFILE` - set a profile during installation. Defaults to xccdf_org.ssgproject.content_profile_stig on rhel8.

   If you don't set `CENTOS_CACHE_URL` the full installation ISO of the operating system (not the boot image, the full DVD iso)
   must be added within `./ost-images` directory and named `${DISTRO}.iso`.

4. Run the build script:

   ```console
   $ ./ost-images/build.sh 
   Building distro el9stream
   with appliance: 1
   with node image url: https://resources.ovirt.org/repos/ovirt/github-ci/ovirt-node-ng-image/
   Distro doesn't work with OpenSCAP profiles properly, ignoring
   ```

5. At the end of the build you'll have the built RPMs in `./ost-images/rpmbuild/RPMS/x86_64`
