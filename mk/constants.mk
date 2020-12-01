# Where pkglist.txt files are put
_PKGLIST_PATH := /var/tmp

# Command used to make *pkglist-diff.txt files
_DIFF := -diff --new-line-format="" --unchanged-line-format=""

# How much memory virt-customize should get in MB
_MEMSIZE := 5120

# Directives to change/restore dnf config to use RAM as dnf cache in VM
_CHANGE_DNF_CACHE_TO_DEV_SHM := --append-line '/etc/dnf/dnf.conf:cachedir=/dev/shm'
_RESTORE_REGULAR_DNF_CACHE := --edit '/etc/dnf/dnf.conf:s/^cachedir.*$$//'
