# vim: ft=make: sw=2:

${call core.trace-current-location}
${foreach item,$(SK_MAKE_MAKEFILES_TO_TOP),${call core.load,$(item)}}

all:: 
	@ echo "Available targets: test local-test"

test:: 
	@ find . -name makefile -print | while read path; do (cd `dirname $${path}` && $(MAKE) local-$(@)) || exit $${?}; done

local-test:: 
	@ echo Folder: $(PWD)
	@ ls -1 | while read item; do case $${item} in *.rb) ruby -rubygems -I$(PATH) $${item} || exit $${?};; esac; done
