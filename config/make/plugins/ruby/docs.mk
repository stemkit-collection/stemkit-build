# vim: ft=make: sw=2:

ruby.docs.YARDOPTS := $(core.LAST_LOADED_FROM)/docs/yard-defaults
ruby.docs.TARGETS := docs redocs install-docs clean-docs clean-installed-docs
ruby.docs.LOCAL_TARGETS := $(ruby.docs.TARGETS:%=local-%)

.PHONY: $(ruby.docs.TARGETS) $(ruby.docs.LOCAL_TARGETS)

# Public rules
#
ruby.docs.setup-api-version = ${eval ${call ruby.docs.p.v,API_VERSION,$(1)} := $(2)}

ruby.docs.include = ${eval ${call ruby.docs.p.v,INCLUDE,$(1)} += ${call sys.makefile-src,$(2),$(3)}}

ruby.docs.front-page = ${eval ${call ruby.docs.p.v,FRONT_PAGE,$(1)} := ${call sys.makefile-src,$(2),$(3)}}

ruby.docs.pages = ${eval ${call ruby.docs.p.v,PAGES,$(1)} += ${call sys.makefile-src,$(2),$(3)}}

ruby.docs.make = ${if $(ruby.docs.MAKE_$(1)),,${eval ${call ruby.docs.p.make,$(1),$(2),$(3)}}}

# Private rules
#
ruby.docs.p.v = ruby.docs.$(1)_$(2)_$(core.LAST_LOADED_FROM)

ruby.docs.p.target = $(sys.PKGTOP)/docs/$(1)$(${call ruby.docs.p.v,API_VERSION,$(1)}:%=-%)

ruby.docs.p.install-target = $$(LOCATION)/$(1)$(${call ruby.docs.p.v,API_VERSION,$(1)}:%=/api-%)

define ruby.docs.p.make
  ${call ruby.docs.p.make-targets,$(1),${call ruby.docs.p.target,$(1)},${call ruby.docs.p.install-target,$(1)},$(2),$(3)}
endef

define ruby.docs.p.make-targets
  ruby.docs.MAKE_$(1) := true
  ${call ruby.docs.include,$(1),$(4),$(5)}

  $(2):
	mkdir -p $$(@)

  local-docs:: $(2)
	$(ruby.ENV) yard doc -o $$(<) -b $$(<)/.yardoc --yardopts $(ruby.docs.YARDOPTS) $$(${call ruby.docs.p.v,FRONT_PAGE,$(1)}:%=--main '%') $$(${call ruby.docs.p.v,INCLUDE,$(1)}:%='%') - $$(${call ruby.docs.p.v,PAGES,$(1)}:%='%')

  local-install-docs:: $(2)
	mkdir -p $(3)
	cp -r $$(<)/. $(3)/.

  local-clean-docs::
	rm -rf $(2)

  local-clean-installed-docs::
	rm -rf $(3)
endef

info::
	@echo Available targets: $(ruby.docs.TARGETS)
	@echo Available targets: $(ruby.docs.LOCAL_TARGETS)

local-redocs:: local-clean-docs local-docs
local-install-docs local-clean-installed-docs:: sys-ensure-LOCATION

$(ruby.docs.TARGETS)::
	@ $(MAKE) local-$(@)
	@ find . -depth +1 -name docs -print | while read path; do $(MAKE) -C `dirname $${path}` local-$(@) || exit $${?}; done

$(ruby.docs.LOCAL_TARGETS)::
