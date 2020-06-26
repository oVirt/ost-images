%-provision-engine.sh:
	cp $(PROVISION_ENGINE_SCRIPT) $@

%-engine-installed.qcow2: %-engine-deps-installed.qcow2 %-provision-engine.sh
	qemu-img create -f qcow2 -F qcow2 -b $*-engine-deps-installed.qcow2 $@.tmp
#	See the remark above about chmod.
	chmod 666 $@.tmp
	virt-customize \
		-a $@.tmp \
		$(foreach repo, $(EXTRA_REPOS), --run-command "dnf config-manager --add-repo $(repo)") \
		--run "$*-provision-engine.sh" \
		--run-command "rpm -qa | sort > $(_PKGLIST_PATH)/$(@:.qcow2=-pkglist.txt)" \
		--selinux-relabel
	mv $@.tmp $@
