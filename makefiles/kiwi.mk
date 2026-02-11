# Base
BASEDIR := build/base
$(BASEDIR)/%-base.qcow2 $(BASEDIR)/%-base.packages: configs/$(DISTRO)$(DISTRO_VERSION).xml configs/default.xml configs/packages.xml configs/config.sh
	kiwi-ng --profile=$(DISTRO) --kiwi-file=$(DISTRO)$(DISTRO_VERSION).xml system build --description=configs/ --target-dir=$(BASEDIR)
	mv $(BASEDIR)/ost-images*.qcow2 $(BASEDIR)/$*-base.qcow2
	mv $(BASEDIR)/ost-images*.packages $(BASEDIR)/$*-base.packages

# Storage
STORAGEDIR := build/storage
$(STORAGEDIR)/%-storage.qcow2 $(STORAGEDIR)/%-storage.packages: configs/$(DISTRO)$(DISTRO_VERSION).xml configs/default.xml configs/packages.xml configs/config.sh
	kiwi-ng --profile=$(DISTRO) --profile=storage --kiwi-file=$(DISTRO)$(DISTRO_VERSION).xml system build --description=configs/ --target-dir=$(STORAGEDIR)
	mv $(STORAGEDIR)/ost-images*.qcow2 $(STORAGEDIR)/$*-storage.qcow2
	mv $(STORAGEDIR)/ost-images*.packages $(STORAGEDIR)/$*-storage.packages

# Hosted Engine
HEDIR := build/he
$(HEDIR)/%-he-installed.qcow2 $(HEDIR)/%-he-installed.packages: configs/$(DISTRO)$(DISTRO_VERSION).xml configs/default.xml configs/packages.xml configs/config.sh
	kiwi-ng --profile=$(DISTRO) --profile=provision-he --kiwi-file=$(DISTRO)$(DISTRO_VERSION).xml system build --description=configs/ --target-dir=$(HEDIR)
	mv $(HEDIR)/ost-images*.qcow2 $(HEDIR)/$*-he-installed.qcow2
	mv $(HEDIR)/ost-images*.packages $(HEDIR)/$*-he-installed.packages

# Engine
ENGINEDIR := build/engine
$(ENGINEDIR)/%-engine-installed.qcow2 $(ENGINEDIR)/%-engine-installed.packages: configs/$(DISTRO)$(DISTRO_VERSION).xml configs/default.xml configs/packages.xml configs/config.sh
	kiwi-ng --profile=$(DISTRO) --profile=provision-engine --kiwi-file=$(DISTRO)$(DISTRO_VERSION).xml system build --description=configs/ --target-dir=$(ENGINEDIR)
	mv $(ENGINEDIR)/ost-images*.qcow2 $(ENGINEDIR)/$*-engine-installed.qcow2
	mv $(ENGINEDIR)/ost-images*.packages $(ENGINEDIR)/$*-engine-installed.packages

# Host
HOSTDIR := build/host
$(HOSTDIR)/%-host-installed.qcow2 $(HOSTDIR)/%-host-installed.packages: configs/$(DISTRO)$(DISTRO_VERSION).xml configs/default.xml configs/packages.xml configs/config.sh
	kiwi-ng --profile=$(DISTRO) --profile=provision-host --kiwi-file=$(DISTRO)$(DISTRO_VERSION).xml system build --description=configs/ --target-dir=$(HOSTDIR)
	mv $(HOSTDIR)/ost-images*.qcow2 $(HOSTDIR)/$*-host-installed.qcow2
	mv $(HOSTDIR)/ost-images*.packages $(HOSTDIR)/$*-host-installed.packages

