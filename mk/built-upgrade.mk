%-upgrade.qcow2: %-base.qcow2
	qemu-img create -f qcow2 -F qcow2 -b $(*)-base.qcow2 $@.tmp
#	See the remark above about chmod.
	chmod 666 $@.tmp
	virt-customize \
		-a $@.tmp \
		$(if $(DUMMY_UPGRADE),, --run-command "dnf upgrade -y") \
		--run-command "dnf clean all" \
		--run-command "rpm -qa | sort > $(_PKGLIST_PATH)/$(@:.qcow2=-pkglist.txt)" \
		--selinux-relabel
	mv $@.tmp $@
