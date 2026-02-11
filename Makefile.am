include makefiles/kiwi.mk

%_id_rsa:
	cp id_rsa $@

%_id_rsa.pub:
	cp id_rsa.pub $@

configs/config.sh: configs/config.sh.in $(DISTRO)$(DISTRO_VERSION)_id_rsa.pub
	sed \
		-e "s|%SSH_PUB_KEY%|${shell cat $(DISTRO)$(DISTRO_VERSION)_id_rsa.pub}|" \
		-e "s|%OPENSCAP_PROFILE%|${OPENSCAP_PROFILE}|" \
		configs/config.sh.in > $@

ost-images.spec: ost-images.spec.in
	sed 's/[@]PACKAGE_RELEASE[@]/$(PACKAGE_RELEASE)/g' $< >$@

base: $(BASEDIR)/$(DISTRO)$(DISTRO_VERSION)-base.qcow2 $(BASEDIR)/$(DISTRO)$(DISTRO_VERSION)-base.packages

storage: $(STORAGEDIR)/$(DISTRO)$(DISTRO_VERSION)-storage.qcow2 $(STORAGEDIR)/$(DISTRO)$(DISTRO_VERSION)-storage.packages

he: $(HEDIR)/$(DISTRO)$(DISTRO_VERSION)-he-installed.qcow2 $(HEDIR)/$(DISTRO)$(DISTRO_VERSION)-he-installed.packages

engine: $(ENGINEDIR)/$(DISTRO)$(DISTRO_VERSION)-engine-installed.qcow2 $(ENGINEDIR)/$(DISTRO)$(DISTRO_VERSION)-engine-installed.packages

host: $(HOSTDIR)/$(DISTRO)$(DISTRO_VERSION)-host-installed.qcow2 $(HOSTDIR)/$(DISTRO)$(DISTRO_VERSION)-host-installed.packages

spec: ost-images.spec

all: base storage engine host he spec

gen-VERSION:
	if test -d ../.git; then                                             \
		$(top_srcdir)/build-aux/pkg-version --full > $(distdir)/VERSION; \
	fi

dist-hook: gen-VERSION

dist_image_DATA = \
	$(DISTRO)$(DISTRO_VERSION)_id_rsa \
	$(DISTRO)$(DISTRO_VERSION)_id_rsa.pub \
	$(BASEDIR)/$(DISTRO)$(DISTRO_VERSION)-base.packages \
	$(BASEDIR)/$(DISTRO)$(DISTRO_VERSION)-base.qcow2 \
	$(if $(BUILD_STORAGE),$(STORAGEDIR)/$(DISTRO)$(DISTRO_VERSION)-storage.packages) \
	$(if $(BUILD_STORAGE),$(STORAGEDIR)/$(DISTRO)$(DISTRO_VERSION)-storage.qcow2) \
	$(if $(BUILD_ENGINE_INSTALLED),$(ENGINEDIR)/$(DISTRO)$(DISTRO_VERSION)-engine-installed.packages) \
	$(if $(BUILD_ENGINE_INSTALLED),$(ENGINEDIR)/$(DISTRO)$(DISTRO_VERSION)-engine-installed.qcow2) \
	$(if $(BUILD_HOST_INSTALLED),$(HOSTDIR)/$(DISTRO)$(DISTRO_VERSION)-host-installed.packages) \
	$(if $(BUILD_HOST_INSTALLED),$(HOSTDIR)/$(DISTRO)$(DISTRO_VERSION)-host-installed.qcow2) \
	$(if $(BUILD_HE_INSTALLED),$(HEDIR)/$(DISTRO)$(DISTRO_VERSION)-he-installed.packages) \
	$(if $(BUILD_HE_INSTALLED),$(HEDIR)/$(DISTRO)$(DISTRO_VERSION)-he-installed.qcow2) \
	$(NULL)

clean-local:
	rm -vf $(DISTRO)$(DISTRO_VERSION)_id_rsa $(DISTRO)$(DISTRO_VERSION)_id_rsa.pub
	rm -vf *.spec $(DIST_ARCHIVES)
	rm -vf configs/config.sh
	rm -rf build

EXTRA_DIST = \
	ost-images.spec \
	ost-images.spec.in \
	$(NULL)

rpm: spec
	rpmbuild -bb \
		--define "_topdir $(shell realpath $(builddir))/rpmbuild" \
		--define "distro $(DISTRO)" \
		--define "distro_version $(DISTRO_VERSION)" \
		--define "release $(PACKAGE_RELEASE)" \
		--define "xz_num_threads 2" \
		--define "with_storage $(if $(BUILD_STORAGE),1,0)" \
		--define "with_engine_installed $(if $(BUILD_ENGINE_INSTALLED),1,0)" \
		--define "with_host_installed $(if $(BUILD_HOST_INSTALLED),1,0)" \
		--define "with_he_installed $(if $(BUILD_HE_INSTALLED),1,0)" \
		--build-in-place \
		ost-images.spec
