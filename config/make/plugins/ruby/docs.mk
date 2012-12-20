# vim: ft=make: sw=2:

ruby.docs.YARDOPTS := $(core.LAST_LOADED_FROM)/docs/yard-defaults
ruby.docs.TARGETS := docs redocs install-docs clean-docs
.PHONY: $(ruby.docs.TARGETS)

ruby.docs.include = ${eval ruby.docs.INCLUDE_$(1) += ${call sys.makefile-src,$(2),$(3)}}

ruby.docs.front-page = ${eval ruby.docs.FRONT_PAGE_$(1) := ${call sys.makefile-src,$(2),$(3)}}

ruby.docs.pages = ${eval ruby.docs.PAGES_$(1) += ${call sys.makefile-src,$(2),$(3)}}

ruby.docs.make = ${eval ${call ruby.docs.p.make,$(1),$(sys.PKGTOP)/docs/$(1),$(2),$(3),$(4)}}

define ruby.docs.p.make
  ${call ruby.docs.include,$(1),$(3),$(4)}

  $(2):
	mkdir -p $$(@)

  docs:: $(2)
	$(ruby.ENV) yard doc -o $$(<) -b $$(<)/.yardoc --yardopts $(ruby.docs.YARDOPTS) $$(ruby.docs.FRONT_PAGE_$(1):%=--main '%') $$(ruby.docs.INCLUDE_$(1):%='%') - $$(ruby.docs.PAGES_$(1):%='%')

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
