WORKDIR := $(shell pwd)

KERNEL_BRANCH ?= linux-5.4.y
KERNEL_QUBES_BRANCH ?= stable-5.4

all:
	@true

clean:
	@$(MAKE) -C $(WORKDIR)/linux clean || true
	@rm -rf $(WORKDIR)/*.tar.gz $(WORKDIR)/build

install-deps:
	@sudo dnf install -y coreutils module-init-tools sparse dracut busybox bc openssl openssl-devel python3-devel gcc-plugin-devel elfutils-libelf-devel bison flex e2fsprogs dwarves

get-sources:
	@git clone -b $(KERNEL_BRANCH) https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
	@git clone -b $(KERNEL_QUBES_BRANCH) https://github.com/QubesOS/qubes-linux-kernel

gen-config:
	@cd $(WORKDIR)/qubes-linux-kernel && cp -r gen-config config-base config-qubes $(WORKDIR)/linux
	@cd $(WORKDIR)/linux && ./gen-config config-base config-qubes && rm -rf gen-config config-base config-qubes

prepare: gen-config

.PHONY: build
build:
	$(MAKE) -C $(WORKDIR)/linux

install: RELEASE=$(shell make -C $(WORKDIR)/linux -s kernelrelease)
install:
	@rm -rf $(WORKDIR)/build
	@mkdir -p $(WORKDIR)/build
	@echo $(RELEASE) > $(WORKDIR)/build/release
	@cp $(WORKDIR)/linux/arch/x86/boot/bzImage $(WORKDIR)/build/vmlinuz-$(RELEASE)
	@cp $(WORKDIR)/linux/.config $(WORKDIR)/build/config-$(RELEASE)
	@$(MAKE) -C $(WORKDIR)/linux INSTALL_MOD_PATH=$(WORKDIR)/build INSTALL_MOD_STRIP=1 modules_install
	@cp $(WORKDIR)/install-kernel.sh $(WORKDIR)/build/

archive: RELEASE=$(shell cat $(WORKDIR)/build/release)
archive:
	@cd $(WORKDIR)/build/ && tar cvf kernel-$(RELEASE).tar.gz --exclude kernel-$(RELEASE).tar.gz --xform="s%^\./%kernel-$(RELEASE)/%" .
	@mv $(WORKDIR)/build/kernel-$(RELEASE).tar.gz $(WORKDIR)
