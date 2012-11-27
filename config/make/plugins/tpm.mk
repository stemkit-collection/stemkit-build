# vim: ft=make: sw=2:

${call core.show-current-location}
${call core.ensure-defined,sys.PKGTOP}

tpm.TARGETS := package clean clean-packages build-package show-packages
.PHONY: $(tpm.TARGETS)

define tpm.p.make-package
  build-package:: $(sys.PKGTOP) $(core.LAST_LOADED_FILE)
	$(ruby.ENV) distributor --source $(sys.SRCTOP) --binary $(sys.BINTOP) --dump-path -v -o $(sys.PKGTOP) $(1) $(2)
endef

define tpm.make-package
  ${eval ${call if-local,tpm.p.make-package,$(1),$(2)}}
endef

info::
	@echo Available targets: $(tpm.TARGETS)

$(tmp.TARGETS)::

package:: build-package
clean:: clean-packages

clean-packages::
	rm -f $(sys.PKGTOP)/*.tpm

show-packages:: $(sys.PKGTOP)
	@for f in $(sys.PKGTOP)/*.tpm; do echo $${f}; done
