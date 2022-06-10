%-provision-he.sh: configs/$(DISTRO)/%-provision-he.sh.in
	$(PROVISION_SUBST_CMD) configs/$(DISTRO)/$*-provision-he.sh.in > $@

%-he-installed.qcow2: %-host-installed.qcow2 %-provision-he.sh cirros.img
	qemu-img create -f qcow2 -F qcow2 -b $*-host-installed.qcow2 $@.tmp
#	See the remark above about chmod.
	chmod 666 $@.tmp
# TODO download el8 version of sysstat/lm_sensors until we have el9 engine
	virt-customize \
		-a $@.tmp \
		--memsize $(_MEMSIZE) \
		$(_CHANGE_DNF_CACHE_TO_DEV_SHM) \
		--run "$*-provision-he.sh" \
		--run-command "dnf download --releasever=8 --downloaddir /var/tmp sysstat lm_sensors-libs.x86_64" \
		$(_RESTORE_REGULAR_DNF_CACHE) \
		--upload cirros.img:/var/tmp \
		--run-command "chown root:root /var/tmp/cirros.img" \
		--run-command "rpm -qa | sort > $(_PKGLIST_PATH)/$(@:.qcow2=-pkglist.txt)" \
		--run-command "setfiles -F -m -v $(SE_CONTEXT) $(PARTITIONS)" \
		--selinux-relabel
	mv $@.tmp $@
	virt-cat -a $@ /tmp/builder.log | tail -20
