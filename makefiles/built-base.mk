# If the INSTALL_URL is an iso image then download it
# (or make a symlink to it if it's a local path) first.
%.iso:
	$(if $(findstring http,$(INSTALL_URL)),curl -L -o $@ $(INSTALL_URL),ln -s $(INSTALL_URL) $@)

%_id_rsa:
	cp id_rsa $@

%_id_rsa.pub:
	cp id_rsa.pub $@

%.ks: %.ks.in %_id_rsa.pub
	sed \
		-e "s|%REPO_ROOT%|$(REPO_ROOT)|" \
		-e "s|%SSH_PUB_KEY%|${shell cat $*_id_rsa.pub}|" \
		$*.ks.in > $@

%-base.qcow2: CONSOLE_LOG=$*-base-console.log

%-base.qcow2: $(if $(_USING_ISO), %.iso) %.ks
	qemu-img create -f qcow2 $@.tmp $(DISK_SIZE)
#	Qemu runs with lowered privileges so if the build
#	is done by root, the image is created with 664
#	permissions and qemu is unable to write to it.
#	This is fixed on RPM level.
	chmod 666 $@.tmp
	# node image build with the engine appliance needs lots of memory,
	# also because we put dnf cache on tmpfs. 3072 MiB failed, 6144 worked.
	# Didn't check what the minimum is currently.
	virt-install \
		--name $(@:.qcow2=) \
		--memory 6144 \
		--vcpus 2 \
		--disk path=$@.tmp \
		--location=$(_LOCATION) \
		--os-variant rhel8-unknown \
		--hvm \
		--graphics=vnc \
		--initrd-inject=$*.ks \
		--extra-args inst.ks=file:/$*.ks \
		--extra-args fips=1 \
		--extra-args console=ttyS0,115200 \
		--serial=pty,log.file=$(shell realpath ${CONSOLE_LOG}) \
		--noautoconsole \
		--wait 60 \
		--noreboot || \
			{ \
				echo "ERROR: virt-install $(@:.qcow2=) failed:"; \
				tail -20 ${CONSOLE_LOG}; \
				exit 1; \
			}
	virt-customize \
		-a $@.tmp \
		--copy-in ${NM_STABLE_IPV6_CONF}:${NM_CONF_DIR} \
#		Download the oscap xml for RHEL8 so the report can run in "offline" mode
		--run-command "curl -L -o /root/$(RHEL8_SECURITY_XML_NAME) $(RHEL8_SECURITY_XML_URL)" \
		--run-command "rpm -qa | sort > $(_PKGLIST_PATH)/$(@:.qcow2=-pkglist.txt)" \
		--run-command "setfiles -F -m -v $(SE_CONTEXT) $(PARTITIONS)" \
		--selinux-relabel
	if [[ $(SPARSIFY_BASE) == yes ]]; then \
		virt-sparsify --machine-readable --format qcow2 $@.tmp $@; \
		rm $@.tmp; \
	else \
		mv $@.tmp $@; \
	fi
