# vim: ft=make: sw=2:

${call core.show-current-location}
${call core.load-from-current,ruby/docs.mk}

define ruby.add-item-to-loadpath
  ${call core.info,ruby,Adding to LOADPATH - $(1)}
  override ruby.EXTRA_LOAD_PATH += $(1)
  export ruby.EXTRA_LOAD_PATH
endef

define ruby.add-cwd-to-loadpath
  ${eval ${call ruby.add-item-to-loadpath,${dir $(core.LAST_LOADED_FILE)}${1}}}
endef

define ruby.add-path-to-loadpath
  ${eval ${call util.set-env-variable,ruby.USE_PATH,true}}
endef

define ruby.tweak-loaded
  ${eval ${call util.set-env-variable,ruby.LOADED_FROM,$(1)}}
endef

define ruby.test.exclude
  ${eval ${if $(DOALL),,${call if-local,util.add-env-variable,ruby.test.EXCLUDED,$(1)}}}
endef

define ruby.test.include-only
  ${eval ${if $(DOALL),,${call if-local,util.add-env-variable,ruby.test.INCLUDED,$(1)}}}
endef

define ruby.use-version
  ${eval ruby.ENV := ruby-env $(1)}
endef

override ruby.test.EXCLUDED =
override ruby.test.INCLUDED =

DOALL =
ITEMS = *

ruby.launch = $(ruby.ENV) ruby -I$(core.PLUGINS_DIR) -r ruby/exec-helper ${if $(1),$(1) || exit $${?},}

local.ruby-exec = env ruby.ITEM=$(1) $(ruby.ENV) ruby -I$(core.PROJECT_CONFIG_DIR) -I$(core.PLUGINS_DIR) -r ruby/test-helper $(1) || exit $${?}
local.rspec-exec = env ruby.ITEM=$(1) $(ruby.ENV) rspec -I$(core.PROJECT_CONFIG_DIR) -I$(core.PLUGINS_DIR) -r ruby/spec-helper $(2) $(1) || exit $${?}

.PHONY: info
info::
	@ echo "Available targets: test(s) local-test(s) spec(s) local-spec(s)"

tests:: test
specs:: spec
local-tests:: local-test
local-specs:: local-spec

define local.find-makefile-and-do
  find . -name '[Mm]akefile' -print | while read path; do $(MAKE) -C `dirname $${path}` local-$(1) || exit $${?}; done
endef

define local.make-one
  make -C ${dir $(1)} ITEMS=${notdir ${basename $(1)}} local-$(2)
endef

test spec::
	@ ${if $(SK_MAKE_ONE),${call local.make-one,$(SK_MAKE_ONE),$(@)},${call local.find-makefile-and-do,$(@)}}

local-test local-spec::
	@ echo Folder: $(CURDIR)

local-test::
	@ for item in *; do case $${item} in ($(ITEMS:%=%[-_]spec.rb|)$(ITEMS:%=%[-_]test.rb|)$(ITEMS:%=%.rb|)'') case $${item} in (*[-_]spec.rb) ${call local.rspec-exec,$${item}};; (*) ${call local.ruby-exec,$${item}};; esac;; esac; done

local-spec::
	@ for item in *; do case $${item} in (*[-_]spec.rb) case $${item} in ($(ITEMS:%=%[-_]spec.rb|)$(ITEMS:%=%.rb|)'') ${call local.rspec-exec,$${item},--color -fs};; esac;; esac; done
