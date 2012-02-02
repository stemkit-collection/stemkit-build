# vim: ft=make: sw=2:

${call core.show-current-location}

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

define ruby.exclude-items
  ${eval ${call util.set-env-variable,ruby.EXCLUDED,$(1)}}
endef

ITEMS ?= *

local.ruby-exec = env ruby.ITEM=$(1) ruby -I$(core.GLOBAL_CONFIG_DIR) -r ruby-test-helper $(1) || exit $${?}
local.rspec-exec = env ruby.ITEM=$(1) rspec -I$(core.GLOBAL_CONFIG_DIR) -r ruby-spec-helper $(2) $(1) || exit $${?}

.PHONY: info
info::
	@ echo "Available targets: test(s) local-test(s) spec(s) local-spec(s)"

tests:: test
specs:: spec
local-tests:: local-test
local-specs:: local-spec

test spec::
	@ find . -name '[Mm]akefile' -print | while read path; do $(MAKE) -C `dirname $${path}` local-$(@) || exit $${?}; done

local-test local-spec::
	@ echo Folder: $(CURDIR)

local-test::
	@ for item in *; do case $${item} in ($(ITEMS:%=%[-_]spec.rb|)$(ITEMS:%=%[-_]test.rb|)$(ITEMS:%=%.rb|)'') case $${item} in (*[-_]spec.rb) ${call local.rspec-exec,$${item}};; (*) ${call local.ruby-exec,$${item}};; esac;; esac; done

local-spec::
	@ for item in *; do case $${item} in ($(ITEMS:%=%[-_]spec.rb|)'') ${call local.rspec-exec,$${item},--color -fs};; esac; done
