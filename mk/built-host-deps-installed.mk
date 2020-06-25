# Go through all package names in '*-packages.txt' file and sed
# the contents line by line to change to 'rm' commands, i.e.:
#
#  ovirt-engine
#
# gets replaced with:
#
#  rm -f ovirt-engine-[0-9]*.rpm;
#
# The '$(shell)' construct in the makefile replaces newlines with
# spaces, so the value of the variable below will be a single, long
# line - that's why we need those semicolons. Also note, that for the above
# command to work, the bash script needs to have extended globbing
# enabled with:
#
#  setopt -s extglob
#
_REMOVE_HOST_RPMS_COMMAND := $(shell sed 's/.*/rm -f \0-[0-9]*.rpm;/g' tested-host-packages.txt)

%-provision-host-deps.sh:
	sed 's/REMOVE_RPMS_COMMAND/$(_REMOVE_HOST_RPMS_COMMAND)/g' $(PROVISION_HOST_DEPS_SCRIPT) > $@

%-host-deps-installed.qcow2: %-upgrade.qcow2 %-provision-host-deps.sh
	qemu-img create -f qcow2 -F qcow2 -b $*-upgrade.qcow2 $@.tmp
	chmod 666 $@.tmp # needed for CI jobs
	virt-customize \
		-a $@.tmp \
		$(foreach repo, $(EXTRA_REPOS), --run-command "dnf config-manager --add-repo $(repo)") \
		--run "$*-provision-host-deps.sh" \
		--run-command "rpm -qa | sort > $(_PKGLIST_PATH)/$(@:.qcow2=-pkglist.txt)" \
		--selinux-relabel
	mv $@.tmp $@
