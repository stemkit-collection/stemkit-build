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

ITEMS ?= *.rb

local.ruby-exec = ruby -rubygems ${addprefix -I,$(ruby.LOAD_PATH)} $(1) || exit $${?}

all::
	@ echo "Available targets: test local-test"

test::
	@ find . -name '[Mm]akefile' -print | while read path; do (cd `dirname $${path}` && $(MAKE) local-$(@)) || exit $${?}; done

local-test::
	@ echo Folder: $(PWD)
	@ for item in *; do case $${item} in ${call util.join,$(ITEMS),|}) ${call local.ruby-exec,$${item}};; esac; done
