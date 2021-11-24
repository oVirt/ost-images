# This can be overriden by running with 'make DISTRO=...'
DISTRO := el8stream

# How many threads you want to use when xzipping RPMs
XZ_NUM_THREADS := 4

# Accepts both ISOs and repo urls, can be overriden by running with 'make INSTALL_URL=...'
INSTALL_URL := "http://isoredirect.centos.org/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-latest-dvd1.iso"

# The url of root of repos, can be overriden by running with 'make REPO_ROOT=...'
REPO_ROOT := "http://mirror.centos.org/centos/8-stream/"

# Empty string when using repo-based installs, ".iso" otherwise
_USING_ISO := $(findstring .iso,$(INSTALL_URL))
# The virtual size of the disk.
# Since qcows are sparse they only use as much space as was really written to them.
DISK_SIZE := 22G
# Whether or not to run 'virt-sparsify' on the base image.
# This reduces the image size significantly,
# but requires the same amount of free space available as defined by 'DISK_SIZE' variable.
SPARSIFY_BASE := yes
# CirrOS to be included in engine images for later image upload and use as a base for guest VMs
CIRROS_URL := http://glance.ovirt.org:9292/v2/images/6d5ca10c-ffbc-4a7a-91bf-252ce43d9af9/file

# On/off switches for building layers. These options should have
# sensible defaults i.e. if you have 'ost-images-el8-base' package installed,
# then the default is not to build the base package.
# Can be overriden by running with i.e. 'make BUILD_BASE=...'.
# Any non-empty string will be treated as true and an empty string is treated as false.
# Only removing layers from the bottom is supported - you can't i.e.
# build the "base" layer, but skip the "upgrade" layer.
BUILD_BASE := $(if $(_USING_ISO),$(findstring not installed,$(shell rpm -q $(PACKAGE_NAME)-$(DISTRO)-base)),yes)

BUILD_ENGINE_INSTALLED := yes
BUILD_HOST_INSTALLED := yes
BUILD_HE_INSTALLED := yes

# When using preinstalled images these point to prefixes
# of installed RPMs (usually '/usr/share/ost-images'), otherwise
# they're empty strings.
_BASE_IMAGE_PREFIX := $(if $(BUILD_BASE),,$(shell rpm -q --queryformat '%{INSTPREFIXES}' $(PACKAGE_NAME)-$(DISTRO)-base)/$(PACKAGE_NAME)/)

# When using preinstalled images these have the values of the RPM versions,
# otherwise they're empty strings. We need these in the spec to define proper dependencies.
_BASE_IMAGE_VERSION := $(if $(BUILD_BASE),,$(shell rpm -q --queryformat '%{VERSION}-%{RELEASE}' $(PACKAGE_NAME)-$(DISTRO)-base))

# These variables point to scripts that provision "engine-installed"
# and "host-installed" layers. Can be overriden by running with i.e. 'make PROVISION_HOST_SCRIPT=...'
PROVISION_ENGINE_SCRIPT := $(DISTRO)-provision-engine.sh.in
PROVISION_HOST_SCRIPT := $(DISTRO)-provision-host.sh.in
PROVISION_HE_SCRIPT := $(DISTRO)-provision-he.sh.in

# This resolves to either smth like 'el8.iso' for ISOs or url for repository urls
_LOCATION := $(if $(_USING_ISO),$(DISTRO).iso,$(INSTALL_URL))

# Location of SELinux context
SE_CONTEXT := /etc/selinux/targeted/contexts/files/file_contexts
# List of all partitions (excepet for root /, that is handled by
# --selinux-relabel), virt-customize/setfiles? is not able to relabel
# mounted partitions. We need to relabel them explicitly
PARTITIONS := /boot /var /var/log /var/log/audit /var/tmp /home
# OpenSCAP profile to set - example for RHEL 8 DISA STIG:
# %addon org_fedora_oscap
# content-type = scap-security-guide
# profile = xccdf_org.ssgproject.content_profile_stig
# %end
# or xccdf_org.ssgproject.content_profile_rhvh-stig (for RHVH embedded profile)
OPENSCAP_PROFILE := ""
# Name of the RHEL8 XML needed by oscap offline runs
RHEL8_SECURITY_XML_NAME := security-data-oval-com.redhat.rhsa-RHEL8.xml
# Url of the RHEL8 XML needed by oscap offline runs
RHEL8_SECURITY_XML_URL := https://www.redhat.com/security/data/oval/com.redhat.rhsa-RHEL8.xml
