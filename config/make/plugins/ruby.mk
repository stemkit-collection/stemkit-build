# vim: ft=make: sw=2:

define ruby.add-item-to-loadpath
  ${call core.info,ruby,Adding to LOADPATH - $(1)}
  ruby.LOAD_PATH += $(1)
endef

define ruby.add-cwd-to-loadpath
  ${eval ${call ruby.add-item-to-loadpath,${dir $(core.LAST_LOADED_FILE)}}}
endef

define ruby.add-path-to-loadpath
  ${eval ${call ruby.add-item-to-loadpath,$(PATH)}}
endef

${call core.show-current-location}
${foreach item,$(SK_MAKE_MAKEFILES_TO_TOP),${call core.load,$(item)}}

ITEMS ?= *

local.ruby-exec = ruby -rubygems ${addprefix -I,$(ruby.LOAD_PATH)} $(1) || exit $${?}
local.rspec-exec = ${call local.ruby-exec,-rubygems -S rspec --require sk/spec/config $(1)}

all::
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
	@ for item in *; do case $${item} in ${call util.join,${addsuffix [-_]test,$(ITEMS)} $(ITEMS),.rb |} '') ${call local.ruby-exec,$${item}};; esac; done

local-spec::
	@ for item in *; do case $${item} in ${call util.join,$(ITEMS),[-_]spec.rb |} '') ${call local.rspec-exec,$${item}};; esac; done
