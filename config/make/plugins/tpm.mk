# vim: ft=make: sw=2:

${call core.show-current-location}
${call core.ensure-defined,sys.PKGTOP}

tpm.TARGETS := package clean clean-packages clean-tpm clean-rpm build-package show-packages
.PHONY: $(tpm.TARGETS)

define tpm.p.make-package
  build-package:: $(sys.PKGTOP) $(core.LAST_LOADED_FILE)
	ruby-env 1.8 distributor --source $(sys.SRCTOP) --binary $(sys.BINTOP) --dump-path -v -o $(sys.PKGTOP) $(1) $(2)
endef

define tpm.make-package
  ${eval ${call if-local,tpm.p.make-package,$(1),$(2)}}
endef

define tpm.p.make
  .PHONY: $(2)-tpm
  info::
	@ echo Available targets: $(2)-tpm

  $(2)-tpm:: $(sys.PKGTOP) $(core.LAST_LOADED_FILE)
	ruby-env 1.8 distributor -v --dump-path $(3:%=-V%) $(4:%=-B%) --source $(sys.SRCTOP) --binary $(sys.BINTOP) -o $(sys.PKGTOP) prodinfo-$(1) $(2)
endef

define tpm.p.make-rpm
  ${call tpm.p.make,$(1),$(2),$(3),$(4)}

  .PHONY: $(2)-rpm $(2)-rpm-only
  info::
	@ echo Available targets: $(2)-rpm $(2)-rpm-only

  $(2)-rpm:: $(2)-tpm $(2)-rpm-only
  $(2)-rpm-only::
	tpm-to-rpm -v --dump-path $(3:%=-V%) $(4:%=-B%) $(6:%=-t%) -N $(5:%=%-)$(2) -c rpm/$(1).conf -f $(sys.PKGTOP)/$(2).tpm-path
endef

# ${call tpm.make, <product>, <package>, <version>, <build>
#                  $(1)       $(2)       $(3)       $(4)
tpm.make = ${eval ${call if-local,tpm.p.make,$(1:%=%),$(2:%=%),$(3),$(4)}}

# ${call tpm.make-rpm, <product>, <package>, <version>, <build>, <prefix>, <top>}
#                      $(1)       $(2)       $(3)       $(4)     $(5)      $(6)
tpm.make-rpm = ${eval ${call if-local,tpm.p.make-rpm,$(1:%=%),$(2:%=%),$(3),$(4),$(5:%=%),$(6)}}

info::
	@echo Available targets: $(tpm.TARGETS)

$(tpm.TARGETS)::

package:: build-package
clean:: clean-packages

clean-packages:: clean-tpm clean-rpm

clean-tpm::
	rm -f $(sys.PKGTOP)/*.tpm $(sys.PKGTOP)/*.tpm-path

clean-rpm::
	rm -f $(sys.PKGTOP)/*.rpm $(sys.PKGTOP)/*.rpm-path

show-packages:: $(sys.PKGTOP)
	@for f in $(sys.PKGTOP)/*.tpm; do echo $${f}; done
