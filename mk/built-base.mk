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

%-base.qcow2: $(if $(_USING_ISO), %.iso) %.ks
	qemu-img create -f qcow2 $@.tmp $(DISK_SIZE)
#	Qemu runs with lowered privileges so if the build
#	is done by root, the image is created with 664
#	permissions and qemu is unable to write to it.
#	This is fixed on RPM level.
	chmod 666 $@.tmp
	virt-install \
		--name $(@:.qcow2=) \
		--memory 3072 \
		--vcpus 2 \
		--disk path=$@.tmp \
		--location=$(_LOCATION) \
		--os-variant rhel8-unknown \
		--hvm \
		--graphics=vnc \
		--initrd-inject=$*.ks \
		--extra-args ks=file:/$*.ks \
		--noautoconsole \
		--wait 60 \
		--debug \
		--noreboot
	virt-customize \
		-a $@.tmp \
		--run-command "rpm -qa | sort > $(_PKGLIST_PATH)/$(@:.qcow2=-pkglist.txt)"
	if [[ $(SPARSIFY_BASE) == yes ]]; then \
		virt-sparsify --machine-readable --format qcow2 $@.tmp $@; \
		rm $@.tmp; \
	else \
		mv $@.tmp $@; \
	fi
