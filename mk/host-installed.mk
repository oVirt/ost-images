%-provision-host.sh:
	cp $(PROVISION_HOST_SCRIPT) $@

%-host-installed.qcow2: %-upgrade.qcow2 %-provision-host.sh
	qemu-img create -f qcow2 -F qcow2 -b $*-upgrade.qcow2 $@.tmp
#	See the remark above about chmod.
	chmod 666 $@.tmp
	virt-customize \
		-a $@.tmp \
		--memsize $(_MEMSIZE) \
		$(foreach repo, $(EXTRA_REPOS), --run-command "dnf config-manager --add-repo $(repo)") \
		$(_CHANGE_DNF_CACHE_TO_DEV_SHM) \
		--run "$*-provision-host.sh" \
		$(_RESTORE_REGULAR_DNF_CACHE) \
		--run-command "rpm -qa | sort > $(_PKGLIST_PATH)/$(@:.qcow2=-pkglist.txt)" \
		--selinux-relabel
	mv $@.tmp $@
	virt-cat -a $@ /tmp/builder.log | tail -20
