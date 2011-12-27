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

define ruby.set-local-offset
  ${if ${findstring true,$(OFFSET)},${eval ${call util.set-variable,ruby.LOCAL_OFFSET,$(1)}}}
endef

${call core.show-current-location}
${foreach item,$(SK_MAKE_MAKEFILES_TO_TOP),${call core.load,$(item)}}

ITEMS ?= *.rb
OFFSET ?= false

ruby.LOCAL_OFFSET ?= .

local.ruby-exec = ruby -rubygems ${addprefix -I,$(ruby.LOAD_PATH)} $(1) || exit $${?}
local.item-list = ${call util.join,${addprefix $(ruby.LOCAL_OFFSET)/,$(ITEMS)},|}

all::
	@ echo "Available targets: test local-test"

test::
	@ find . -name '[Mm]akefile' -print | while read path; do (cd `dirname $${path}` && $(MAKE) local-$(@)) || exit $${?}; done

local-test::
	@ echo Folder: $(PWD)
	@ for item in $(ruby.LOCAL_OFFSET)/*; do case $${item} in ${local.item-list}) ${call local.ruby-exec,$${item}};; esac; done
