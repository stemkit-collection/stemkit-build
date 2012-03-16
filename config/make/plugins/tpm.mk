# vim: ft=make: sw=2:

${call core.show-current-location}
${call core.ensure-defined,SK_MAKE_PKGTOP}

PN_TPM_TARGETS = package clean clean-packages build-package show-packages
.PHONY: $(PN_TPM_TARGETS)

$(SK_MAKE_PKGTOP):
	mkdir -p $@

define tpm.private.make-package
  info::
	@echo Available targets: $(PN_TPM_TARGETS)

  package:: build-package show-packages

  clean:: clean-packages

  build-package:: $(SK_MAKE_PKGTOP) $(core.LAST_LOADED_FILE)
	$(ruby.ENV) $(2) distributor -v -o $(SK_MAKE_PKGTOP) $(1)

  clean-packages::
	rm -f $(SK_MAKE_PKGTOP)/*.tpm

  show-packages:: $(SK_MAKE_PKGTOP)
	@echo PACKAGES:
	@ for f in $(SK_MAKE_PKGTOP)/*; do echo $$$${f}; done | sed -n 's/^.*[.]tpm$$$$/  &/p'
endef

define tpm.make-package
  ${call core.eval-if-local,tpm.private.make-package,$(1),$(2)}
endef

