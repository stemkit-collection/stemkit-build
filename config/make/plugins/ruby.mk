# vim: ft=make: sw=2:

define ruby.add-cwd-to-loadpath
  ${info >>> ADDING LOADPATH}
endef

${call core.trace-current-location}
${foreach item,$(SK_MAKE_MAKEFILES_TO_TOP),${call core.load,$(item)}}

define ruby.exec
  ruby -rubygems -I$(PATH) $(1) || exit $${?}
endef

ITEMS ?= *.rb

all:: 
	@ echo "Available targets: test local-test"

test:: 
	@ find . -name makefile -print | while read path; do (cd `dirname $${path}` && $(MAKE) local-$(@)) || exit $${?}; done

local-test:: 
	@ echo Folder: $(PWD)
	@ ls -1 | while read item; do case $${item} in ${call util.join,$(ITEMS),|}) ${call ruby.exec,$${item}};; esac; done
