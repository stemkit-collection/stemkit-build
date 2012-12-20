# vim: ft=make: sw=2:

ruby.docs.YARDOPTS := $(core.LAST_LOADED_FROM)/docs/yard-defaults
ruby.docs.TARGETS := docs redocs install-docs clean-docs

.PHONY: $(ruby.docs.TARGETS)

# Public rules
#
ruby.docs.setup-api-version = ${eval ${call ruby.docs.p.v,API_VERSION,$(1)} := $(2)}

ruby.docs.include = ${eval ${call ruby.docs.p.v,INCLUDE,$(1)} += ${call sys.makefile-src,$(2),$(3)}}

ruby.docs.front-page = ${eval ${call ruby.docs.p.v,FRONT_PAGE,$(1)} := ${call sys.makefile-src,$(2),$(3)}}

ruby.docs.pages = ${eval ${call ruby.docs.p.v,PAGES,$(1)} += ${call sys.makefile-src,$(2),$(3)}}

ruby.docs.make = ${if $(ruby.docs.MAKE_$(1)),,${eval ${call ruby.docs.p.make,$(1),${call ruby.docs.p.target,$(1)},$(2),$(3),$(4)}}}

# Private rules
#
ruby.docs.p.v = ruby.docs.$(1)_$(2)_$(core.LAST_LOADED_FROM)

ruby.docs.p.target = $(sys.PKGTOP)/docs/$(1)$(${call ruby.docs.p.v,API_VERSION,$(1)}:%=-%)

define ruby.docs.p.make
  ruby.docs.MAKE_$(1) := true
  ${call ruby.docs.include,$(1),$(3),$(4)}

  $(2):
	mkdir -p $$(@)

  docs:: $(2)
	$(ruby.ENV) yard doc -o $$(<) -b $$(<)/.yardoc --yardopts $(ruby.docs.YARDOPTS) $$(${call ruby.docs.p.v,FRONT_PAGE,$(1)}:%=--main '%') $$(${call ruby.docs.p.v,INCLUDE,$(1)}:%='%') - $$(${call ruby.docs.p.v,PAGES,$(1)}:%='%')

  install-docs:: $(2)
	mkdir -p $${dir $$(LOCATION)/$(1)}
	cp -r $$(<) $${dir $$(LOCATION)/$(1)}

  clean-docs::
	rm -rf $(2)
endef

info::
	@echo Available targets: $(ruby.docs.TARGETS)

redocs:: clean-docs docs
install-docs:: sys-ensure-LOCATION

$(ruby.docs.TARGETS)::
