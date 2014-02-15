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

ruby.docs.files = ${eval ${call ruby.docs.p.v,FILES,$(1)} += ${call sys.makefile-src,$(2),$(3),///}}

ruby.docs.deploy = ${eval ${call ruby.docs.p.v,DEPLOY,$(1)} = ${call sys.makefile-src,$(2)}}

ruby.docs.make = ${if $(ruby.docs.MAKE_$(1)),,${eval ${call ruby.docs.p.make,$(1),$(2),$(3)}}}

# Private rules
#
ruby.docs.p.v = ruby.docs.$(1)_$(2)_$(core.LAST_LOADED_FROM)

ruby.docs.p.base = $(1)$(${call ruby.docs.p.v,API_VERSION,$(1)}:%=/%)

define ruby.docs.p.make
  ${call ruby.docs.p.make-targets,$(1),$(sys.PKGTOP)/docs,${call ruby.docs.p.base,$(1)},${call ruby.docs.p.v,DEPLOY,$(1)},$(2),$(3)}
endef

ruby.docs.p.split = ${foreach item,${subst ///, ,$(1)},${dir $(item)} ${notdir $(item)}}

define ruby.docs.p.copy-file-ensure-folder
  sh -x -c 'mkdir -p $${0}/$${3} && rm -f $${0}/$${3}/$${4} && cp $${1}/$${2}/$${3}/$${4} $${0}/$${3}/$${4}' $(2) ${call ruby.docs.p.split,$(1)}

endef

define ruby.docs.p.install-locally
  rm -rf $(2)
  mkdir -p $(2)
  cp -r $(1)/. $(2)/.

endef

define ruby.docs.p.clean-locally
  rm -rf $(1)

endef

define ruby.docs.p.deploy-via-make
  + $(MAKE) -C $(4) deploy-$(1) SOURCE=${abspath $(2)/$(3)} OFFSET=$(3)
endef

define ruby.docs.p.figure-deploy
  ${if $(4),${call ruby.docs.p.deploy-via-make,$(1),$(2),$(3),$(4)},${call ruby.docs.p.$(1)-locally,$(2)/$(3),${call core.ensure,LOCATION}/$(3)}}
endef

define ruby.docs.p.make-targets
  ruby.docs.MAKE_$(1) := true
  ${call ruby.docs.include,$(1),$(5),$(6)}

  $(2)/$(3):
	mkdir -p $$(@)

  local-docs:: $(2)/$(3)
	$(ruby.ENV) yard doc -o $$(<) -b $$(<)/.yardoc --yardopts $(ruby.docs.YARDOPTS) $$(${call ruby.docs.p.v,FRONT_PAGE,$(1)}:%=--main '%') $$(${call ruby.docs.p.v,INCLUDE,$(1)}:%='%') - $$(${call ruby.docs.p.v,PAGES,$(1)}:%='%')
	@ $$(foreach item,$${wildcard $$(${call ruby.docs.p.v,FILES,$(1)})},$$(call ruby.docs.p.copy-file-ensure-folder,$$(item),$$(<)/.))

  local-clean-docs::
	rm -rf $(2)/$(3)

  local-install-docs::
	$${call ruby.docs.p.figure-deploy,install,$(2),$(3),$$($(4))}

  local-clean-installed-docs::
	$${call ruby.docs.p.figure-deploy,clean,$(2),$(3),$$($(4))}

endef

info::
	@echo Available targets: $(ruby.docs.TARGETS)
	@echo Available targets: $(ruby.docs.LOCAL_TARGETS)

local-redocs:: local-clean-docs local-docs
local-install-docs local-clean-installed-docs::

# In the following actions we want to avoid processing 'docs' in the current
# folder in find command. This folder is processed by the preceeding make
# invocation, thus always ensuring that we process docs both downstream and
# upstream folder structure. And without duplicate processing no matter
# whether 'docs' is present in the current folder or not.
#
$(ruby.docs.TARGETS)::
	+ $(MAKE) local-$(@)
	+ find */* -name docs -print | while read path; do $(MAKE) -C `dirname $${path}` local-$(@) || exit $${?}; done

$(ruby.docs.LOCAL_TARGETS)::
