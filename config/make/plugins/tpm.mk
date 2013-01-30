# vim: ft=make: sw=2:

${call core.show-current-location}
${call core.ensure-defined,sys.PKGTOP}

tpm.TARGETS := package clean clean-packages build-package show-packages
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
  $(2)-tpm:: $(sys.PKGTOP) $(core.LAST_LOADED_FILE)
	ruby-env 1.8 distributor --dump-path -v $(3:%=-V%) $(4:%=-B%) --source $(sys.SRCTOP) --binary $(sys.BINTOP) -o $(sys.PKGTOP) prodinfo-$(1) ${if $(5),$(5),$(2)}
endef

define tpm.p.make-rpm
  ${call tpm.p.make,$(1),$(2),$(4),$(5),$(6)}

  .PHONY: $(2)-rpm $(2)-rpm-only
  $(2)-rpm:: $(2)-tpm $(2)-rpm-only
  $(2)-rpm-only::
	tpm-to-rpm --dump-path $(4:%=-V%) $(5:%=-B%) $(7:%=-t %) -N $(1)$(3:%=-%) -s $(1).rpm-spec -f $(sys.PKGTOP)/${if $(6),$(6),$(2)}.tpm-path -r $(1)-responses.yaml
endef

# ${call tpm.make, <product> [<package>], <version>, <build>, [<package>]}
#                  $(1)                   $(2)       $(3)     $(4)
#
# $(1)[last] is used for constructing a target, hence when <product> is to be
# used for that, omit <package> in $(1), specifying it in $(4). Othewise, if
# the target must be based on <package>, specify both <product> and <package>
# in $(1), omitting $(4) altogether.
#
tpm.make = ${eval ${call if-local,tpm.p.make,${firstword $(1)},${lastword $(1)},$(2),$(3),$(4)}}

# ${call tpm.make-rpm, <product> [<package>], <version>, <build>, [<package>], <top>}
#                      $(1)                   $(2)       $(3)     $(4)         $(5)
#
# Same consideration for specifying <package> either in $(1) or in $(4). When
# $(4) must be empty and <top> specified, make sure to explicitly use empty
# value (,,). Additional consideration is that when both <product> and
# <package> is specified in $(1), the RPM product name (-N) will be set to
# <product>-<package>. Otherwise, to just <package>.
#
tpm.make-rpm = ${eval ${call if-local,tpm.p.make-rpm,${firstword $(1)},${lastword $(1)},${word 2,$(1)},$(2),$(3),$(4),$(5)}}

info::
	@echo Available targets: $(tpm.TARGETS)

$(tpm.TARGETS)::

package:: build-package
clean:: clean-packages

clean-packages::
	rm -f $(sys.PKGTOP)/*.tpm

show-packages:: $(sys.PKGTOP)
	@for f in $(sys.PKGTOP)/*.tpm; do echo $${f}; done
