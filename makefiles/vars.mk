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
CIRROS_URL := https://templates.ovirt.org/yum/cirros.img

# Whether to use FIPS or not. To disable FIPS set this to an empty string
USE_FIPS := yes

# On/off switches for building layers. These options should have
# sensible defaults i.e. if you have 'ost-images-el8-base' package installed,
# then the default is not to build the base package.
# Can be overriden by running with i.e. 'make BUILD_HE_INSTALLED=...'.
# Any non-empty string will be treated as true and an empty string is treated as false.
# Only removing layers from the bottom is supported - you can't i.e.
# build the "base" layer, but skip the "upgrade" layer.
BUILD_BASE := yes
BUILD_ENGINE_INSTALLED := yes
BUILD_HOST_INSTALLED := yes
BUILD_HE_INSTALLED := yes

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
OPENSCAP_PROFILE_SNIPPET := $(if $(OPENSCAP_PROFILE),%addon org_fedora_oscap\ncontent-type = scap-security-guide\nprofile = $(OPENSCAP_PROFILE)\n%end,)
