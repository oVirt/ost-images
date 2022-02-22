# Where pkglist.txt files are put
_PKGLIST_PATH := /var/tmp

# Command used to make *pkglist-diff.txt files
_DIFF := diff --new-line-format="" --unchanged-line-format=""

# How much memory virt-customize should get in MB
_MEMSIZE := 7168

# Directives to change/restore dnf config to use RAM as dnf cache in VM
_CHANGE_DNF_CACHE_TO_DEV_SHM := --append-line '/etc/dnf/dnf.conf:cachedir=/dev/shm'
_RESTORE_REGULAR_DNF_CACHE := --edit '/etc/dnf/dnf.conf:s/^cachedir.*$$//'

# Where to cache libvirt and libguestfs runtime, use per-build directory cache rather than the default ~/.cache
XDG_CACHE_HOME := $(abs_builddir)/.cache
export XDG_CACHE_HOME

# Command used to make substitutions in provisioning scripts
PROVISION_SUBST_CMD := sed "s|%RHEL8_BUILD%|$$RHEL8_BUILD|g"
