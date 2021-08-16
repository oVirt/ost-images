%-provision-he.sh:
	cp $(PROVISION_HE_SCRIPT) $@

%-he-installed.qcow2: %-host-installed.qcow2 %-provision-he.sh
	qemu-img create -f qcow2 -F qcow2 -b $*-host-installed.qcow2 $@.tmp
#	See the remark above about chmod.
	chmod 666 $@.tmp
	virt-customize \
		-a $@.tmp \
		--memsize $(_MEMSIZE) \
		$(_CHANGE_DNF_CACHE_TO_DEV_SHM) \
		--run "$*-provision-he.sh" \
		$(_RESTORE_REGULAR_DNF_CACHE) \
		--run-command "curl -L -o /var/tmp/cirros.img $(CIRROS_URL)" \
		--run-command "rpm -qa | sort > $(_PKGLIST_PATH)/$(@:.qcow2=-pkglist.txt)" \
		--selinux-relabel
	mv $@.tmp $@
	virt-cat -a $@ /tmp/builder.log | tail -20
