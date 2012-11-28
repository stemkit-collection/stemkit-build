# vim: ft=make: sw=2:

ruby.docs.YARDOPTS := ${dir $(core.LAST_LOADED_FILE)}docs/yard-defaults
ruby.docs.TARGETS := docs redocs install-docs serve-docs clean-docs
.PHONY: $(ruby.docs.TARGETS)

define ruby.docs.include
  ${eval ruby.docs.INCLUDE_$(1) += $(2)}
endef

define ruby.docs.front-page
  ${eval ruby.docs.FRONT_PAGE_$(1) := ${call util.join-path,$(2),$(3)}}
endef

define ruby.docs.pages
  ${eval ruby.docs.PAGES_$(1) += ${call util.join-path,$(2),$(3)}}
endef

define ruby.docs.p.join
  $$(ruby.docs.$(2)_$(3):%=$(1:%=% )'$(sys.SRCTOP)/%')
endef

define ruby.docs.p.top
  $(sys.PKGTOP)/docs$(1:%=/%)$(2:%=/%)
endef

define ruby.docs.p.make
  ${call ruby.docs.include,$(1),$(2)}

  ${call ruby.docs.p.top,$(1)}:
	mkdir -p $$(@)

  docs:: ${call ruby.docs.p.top,$(1)}
	yard doc -c -o $$(<) -b $$(<)/.yardoc --yardopts $(ruby.docs.YARDOPTS) ${call ruby.docs.p.join,--main,FRONT_PAGE,$(1)} ${call ruby.docs.p.join,,INCLUDE,$(1)} - ${call ruby.docs.p.join,,PAGES,$(1)}

  install-docs:: ${call ruby.docs.p.top,$(1)}
	rm -rf $$(LOCATION)/$${notdir $$(<)}
	cp -r $$(<) $$(LOCATION)/.

  clean-docs::
	rm -rf ${call ruby.docs.p.top,$(1)}
endef

define ruby.docs.make
  ${eval ${call ruby.docs.p.make,$(1),$(2),$(3),$(4)}}
endef

info::
	@echo Available targets: $(ruby.docs.TARGETS)

redocs:: clean-docs docs
install-docs:: sys-ensure-LOCATION

$(ruby.docs.TARGETS)::

serve-docs::
