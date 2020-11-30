%-provision-he.sh:
	cp $(PROVISION_HE_SCRIPT) $@

%-he-installed.qcow2: %-host-installed.qcow2 %-provision-he.sh
	qemu-img create -f qcow2 -F qcow2 -b $*-host-installed.qcow2 $@.tmp
#	See the remark above about chmod.
	chmod 666 $@.tmp
	virt-customize \
		-a $@.tmp \
		--run "$*-provision-he.sh" \
		--run-command "rpm -qa | sort > $(_PKGLIST_PATH)/$(@:.qcow2=-pkglist.txt)" \
		--selinux-relabel
	mv $@.tmp $@
