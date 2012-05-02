# vim: ft=make: sw=2:

${call core.show-current-location}
${call core.ensure-defined,sys.PKGTOP}

PN_TPM_TARGETS = package clean clean-packages build-package show-packages
.PHONY: $(PN_TPM_TARGETS)

define tpm.private.make-package
  info::
	@echo Available targets: $(PN_TPM_TARGETS)

  package:: build-package

  clean:: clean-packages

  build-package:: $(sys.PKGTOP) $(core.LAST_LOADED_FILE)
	$(ruby.ENV) distributor --dump-path -v -o $(sys.PKGTOP) $(1) $(2)

  clean-packages::
	rm -f $(sys.PKGTOP)/*.tpm

  show-packages:: $(sys.PKGTOP)
	@for f in $(sys.PKGTOP)/*.tpm; do echo $$$${f}; done
endef

define tpm.make-package
  ${eval ${call if-local,tpm.private.make-package,$(1),$(2)}}
endef

