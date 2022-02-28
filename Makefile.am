include makefiles/constants.mk
include makefiles/vars.mk
include makefiles/pkglist.mk

include makefiles/cirros.mk
include makefiles/base.mk
include makefiles/engine-installed.mk
include makefiles/host-installed.mk
include makefiles/he-installed.mk

ost-images.spec: ost-images.spec.in
	sed 's/[@]PACKAGE_RELEASE[@]/$(PACKAGE_RELEASE)/g' $< >$@

ks: $(DISTRO).ks

.INTERMEDIATE: $(DISTRO).iso

iso: $(DISTRO).iso

ssh-keys: $(DISTRO)_id_rsa

base: $(DISTRO)-base.qcow2 $(DISTRO)-base-pkglist.txt

engine: $(DISTRO)-engine-installed.qcow2 $(DISTRO)-engine-installed-pkglist.txt $(DISTRO)-engine-installed-pkglist-diff.txt

host: $(DISTRO)-host-installed.qcow2 $(DISTRO)-host-installed-pkglist.txt $(DISTRO)-host-installed-pkglist-diff.txt

he: $(DISTRO)-he-installed.qcow2 $(DISTRO)-he-installed-pkglist.txt $(DISTRO)-he-installed-pkglist-diff.txt

spec: ost-images.spec

all: base engine host he spec

gen-VERSION:
	if test -d ../.git; then                                             \
		$(top_srcdir)/build-aux/pkg-version --full > $(distdir)/VERSION; \
	fi

dist-hook: gen-VERSION

clean-local:
	virsh list --name | grep -q "^$(DISTRO)-base$$" && virsh destroy $(DISTRO)-base || :
	virsh list --name --inactive | grep -q "^$(DISTRO)-base$$" && virsh undefine $(DISTRO)-base || :

dist_image_DATA = \
	$(DISTRO)-base-pkglist.txt \
	$(DISTRO)-base.qcow2 \
	$(DISTRO).ks \
	$(DISTRO)_id_rsa \
	$(DISTRO)_id_rsa.pub \
	$(if $(BUILD_ENGINE_INSTALLED),$(DISTRO)-engine-installed-pkglist-diff.txt) \
	$(if $(BUILD_ENGINE_INSTALLED),$(DISTRO)-engine-installed-pkglist.txt) \
	$(if $(BUILD_ENGINE_INSTALLED),$(DISTRO)-engine-installed.qcow2) \
	$(if $(BUILD_HOST_INSTALLED),$(DISTRO)-host-installed-pkglist-diff.txt) \
	$(if $(BUILD_HOST_INSTALLED),$(DISTRO)-host-installed-pkglist.txt) \
	$(if $(BUILD_HOST_INSTALLED),$(DISTRO)-host-installed.qcow2) \
	$(if $(BUILD_HE_INSTALLED),$(DISTRO)-he-installed-pkglist-diff.txt) \
	$(if $(BUILD_HE_INSTALLED),$(DISTRO)-he-installed-pkglist.txt) \
	$(if $(BUILD_HE_INSTALLED),$(DISTRO)-he-installed.qcow2) \
	$(NULL)

dist_image_SCRIPTS = \
	$(if $(BUILD_ENGINE_INSTALLED),$(DISTRO)-provision-engine.sh) \
	$(if $(BUILD_HOST_INSTALLED),$(DISTRO)-provision-host.sh) \
	$(if $(BUILD_HE_INSTALLED),$(DISTRO)-provision-he.sh) \
	$(NULL)

CLEANFILES = \
	cirros.img \
	*-console.log \
	*-pkglist*.txt \
	*.ks \
	*.qcow2 \
	*.qcow2.tmp \
	*.spec \
	*_id_rsa* \
	$(DISTRO)-provision-engine.sh \
	$(DISTRO)-provision-host.sh \
	$(DISTRO)-provision-he.sh \
	$(DIST_ARCHIVES) \
	$(NULL)

EXTRA_DIST = \
	ost-images.spec \
	ost-images.spec.in \
	template.ks.in \
	$(NULL)

rpm: spec
	rpmbuild -bb \
		--define "_topdir $(shell realpath $(builddir))/rpmbuild" \
		--define "distro $(DISTRO)" \
		--define "release $(PACKAGE_RELEASE)" \
		--define "xz_num_threads $(XZ_NUM_THREADS)" \
		--define "with_engine_installed $(if $(BUILD_ENGINE_INSTALLED),1,0)" \
		--define "with_host_installed $(if $(BUILD_HOST_INSTALLED),1,0)" \
		--define "with_he_installed $(if $(BUILD_HE_INSTALLED),1,0)" \
		--build-in-place \
		ost-images.spec
