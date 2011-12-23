# vim: ft=make: sw=2:

define ruby.add-item-to-loadpath
  ${call core.info,ruby,Adding to LOADPATH - $(1)}
  ruby.EXTRA_LOAD_PATH += $(1)
endef

define ruby.add-cwd-to-loadpath
  ${eval ${call ruby.add-item-to-loadpath,${dir $(core.LAST_LOADED_FILE)}}}
endef

ITEMS ?= *.rb

${call core.show-current-location}
${foreach item,$(SK_MAKE_MAKEFILES_TO_TOP),${call core.load,$(item)}}

define ruby.exec
  ruby -rubygems -I$(PATH) ${addprefix -I,$(ruby.EXTRA_LOAD_PATH)} $(1) || exit $${?}
endef

all:: 
	@ echo "Available targets: test local-test"

test:: 
	@ find . -name makefile -print | while read path; do (cd `dirname $${path}` && $(MAKE) local-$(@)) || exit $${?}; done

local-test:: 
	@ echo Folder: $(PWD)
	@ ls -1 | while read item; do case $${item} in ${call util.join,$(ITEMS),|}) ${call ruby.exec,$${item}};; esac; done
