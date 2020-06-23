include mk/constants.mk
include mk/vars.mk

BASE_MAKEFILE := $(if $(BUILD_BASE),mk/built-base.mk,mk/preinstalled-base.mk)

include $(BASE_MAKEFILE)

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

%-provision-engine.sh:
	cp $(PROVISION_ENGINE_SCRIPT) $@

%-engine-installed.qcow2: %-upgrade.qcow2 %-provision-engine.sh
	qemu-img create -f qcow2 -F qcow2 -b $*-upgrade.qcow2 $@.tmp
#	See the remark above about chmod.
	chmod 666 $@.tmp
	virt-customize \
		-a $@.tmp \
		--run "$*-provision-engine.sh" \
		--run-command "rpm -qa | sort > $(_PKGLIST_PATH)/$(@:.qcow2=-pkglist.txt)" \
		--selinux-relabel
	mv $@.tmp $@

%-provision-host.sh:
	cp $(PROVISION_HOST_SCRIPT) $@

%-host-installed.qcow2: %-upgrade.qcow2 %-provision-host.sh
	qemu-img create -f qcow2 -F qcow2 -b $*-upgrade.qcow2 $@.tmp
#	See the remark above aboud chmod.
	chmod 666 $@.tmp
	virt-customize \
		-a $@.tmp \
		--run "$*-provision-host.sh" \
		--run-command "rpm -qa | sort > $(_PKGLIST_PATH)/$(@:.qcow2=-pkglist.txt)" \
		--selinux-relabel
	mv $@.tmp $@

%-pkglist.txt: %.qcow2
	virt-copy-out -a $*.qcow2 $(_PKGLIST_PATH)/$@ .

%-upgrade-pkglist-diff.txt: %-upgrade-pkglist.txt %-base-pkglist.txt
	$(_DIFF) $*-upgrade-pkglist.txt $*-base-pkglist.txt > $@

%-host-installed-pkglist-diff.txt: %-host-installed-pkglist.txt %-upgrade-pkglist.txt
	$(_DIFF) $*-host-installed-pkglist.txt $*-upgrade-pkglist.txt > $@

%-engine-installed-pkglist-diff.txt: %-engine-installed-pkglist.txt %-upgrade-pkglist.txt
	$(_DIFF) $*-engine-installed-pkglist.txt $*-upgrade-pkglist.txt > $@

ost-images.spec: ost-images.spec.in
	sed 's/[@]PACKAGE_RELEASE[@]/$(PACKAGE_RELEASE)/g' $< >$@

ks: $(DISTRO).ks

.INTERMEDIATE: $(DISTRO).iso

iso: $(DISTRO).iso

base: $(DISTRO)-base.qcow2 $(DISTRO)-base-pkglist.txt

upgrade: $(DISTRO)-upgrade.qcow2 $(DISTRO)-upgrade-pkglist.txt $(DISTRO)-upgrade-pkglist-diff.txt

engine: $(DISTRO)-engine-installed.qcow2 $(DISTRO)-engine-installed-pkglist.txt $(DISTRO)-engine-installed-pkglist-diff.txt

host: $(DISTRO)-host-installed.qcow2 $(DISTRO)-host-installed-pkglist.txt $(DISTRO)-host-installed-pkglist-diff.txt

spec: ost-images.spec

all: $(if $(BUILD_BASE),base) upgrade engine host spec

gen-VERSION:
	if test -d ../.git; then                                             \
		$(top_srcdir)/build-aux/pkg-version --full > $(distdir)/VERSION; \
	fi

dist-hook: gen-VERSION

clean-local:
	-virsh destroy $(DISTRO)-base
	-virsh undefine $(DISTRO)-base

dist_image_DATA = \
	$(if $(BUILD_BASE),$(DISTRO)-base-pkglist.txt) \
	$(if $(BUILD_BASE),$(DISTRO)-base.qcow2) \
	$(if $(BUILD_BASE),$(DISTRO).ks) \
	$(DISTRO)-engine-installed-pkglist-diff.txt \
	$(DISTRO)-engine-installed-pkglist.txt \
	$(DISTRO)-engine-installed.qcow2 \
	$(DISTRO)-host-installed-pkglist-diff.txt \
	$(DISTRO)-host-installed-pkglist.txt \
	$(DISTRO)-host-installed.qcow2 \
	$(DISTRO)-upgrade-pkglist-diff.txt \
	$(DISTRO)-upgrade-pkglist.txt \
	$(DISTRO)-upgrade.qcow2 \
	$(NULL)

dist_image_SCRIPTS = \
	$(DISTRO)-provision-engine.sh \
	$(DISTRO)-provision-host.sh \
	$(NULL)

CLEANFILES = \
	*-pkglist*.txt \
	*.ks \
	*.qcow2 \
	*.qcow2.tmp \
	*.spec \
	$(DISTRO)-provision-engine.sh \
	$(DISTRO)-provision-host.sh \
	$(DIST_ARCHIVES) \
	$(NULL)

EXTRA_DIST = \
	ost-images.spec \
	ost-images.spec.in \
	template.ks.in \
	$(NULL)

rpm: spec
	rpmbuild -bb \
		--define "distro $(DISTRO)" \
		--define "release $(PACKAGE_RELEASE)" \
		--define "with_base $(if $(BUILD_BASE),1,0)" \
		$(if $(_BASE_IMAGE_VERSION),--define "base_version $(_BASE_IMAGE_VERSION)") \
		--build-in-place \
		ost-images.spec
