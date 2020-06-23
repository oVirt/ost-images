# This can be overriden by running with 'make DISTRO=...'
DISTRO := el8

# Accepts both ISOs and repo urls, can be overriden by running with 'make INSTALL_URL=...'
INSTALL_URL := "http://isoredirect.centos.org/centos/8/isos/x86_64/CentOS-8.2.2004-x86_64-dvd1.iso"

# The url of root of repos, can be overriden by running with 'make REPO_ROOT=...'
REPO_ROOT := "http://mirror.centos.org/centos/8/"

# Empty string when using repo-based installs, ".iso" otherwise
_USING_ISO := $(findstring .iso,$(INSTALL_URL))

# Whether to build the base image or not. For repo-based installation always
# set to "yes". For iso-based installations looks for installed base package
# and if finds one, base won't be built. Can be overriden by running
# with 'make BUILD_BASE=...'. Any non-empty string will be treated as true
# and an empty string is treated as false.
BUILD_BASE := $(if $(_USING_ISO),$(findstring not installed,$(shell rpm -q $(PACKAGE_NAME)-$(DISTRO)-base)),yes)

# Use either the base image that's built locally
# or the one that's already installed
_BASE_IMAGE_PREFIX := $(if $(BUILD_BASE),,$(shell rpm -q --queryformat '%{INSTPREFIXES}' $(PACKAGE_NAME)-$(DISTRO)-base)/$(PACKAGE_NAME)/)

# If we're using the already installed base image, we have to pass
# its version to RPM spec to have a proper dependency for the "upgrade" layer
_BASE_IMAGE_VERSION := $(if $(BUILD_BASE),,$(shell rpm -q --queryformat '%{VERSION}-%{RELEASE}' $(PACKAGE_NAME)-$(DISTRO)-base))

# Whether to build a real upgrade layer. Upgrade layer doesn't really make
# sense in scenarios where you build from nightly repos.
# Can be overriden by running with 'make DUMMY_UPGRADE=...'. Any non-empty
# string will be treated as true and an empty string as false.
DUMMY_UPGRADE := $(if $(_USING_ISO),,yes)

# These variables point to scripts that provision "engine-installed"
# and "host-installed" layers. Can be overriden by running with i.e. 'make PROVISION_HOST_SCRIPT=...'
PROVISION_ENGINE_SCRIPT := $(DISTRO)-provision-engine.sh.in
PROVISION_HOST_SCRIPT := $(DISTRO)-provision-host.sh.in

# This resolves to either smth like 'el8.iso' for ISOs or url for repository urls
_LOCATION := $(if $(_USING_ISO),$(DISTRO).iso,$(INSTALL_URL))
