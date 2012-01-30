# vim: ft=make: sw=2:

${call core.show-current-location}
${call core.ensure-defined,SK_MAKE_PROJECT_ROOT,SK_MAKE_PATH_FROM_TOP,SK_MAKE_PATH_TO_TOP}

enum.LOCATION := ${basename $(core.LAST_LOADED_FILE)}
enum.BINDIR := $(SK_MAKE_PATH_TO_TOP)/../bin/$(SK_MAKE_PATH_FROM_TOP)
enum.GENERATOR := $(enum.LOCATION)/generate-makefile

$(enum.BINDIR):
	mkdir -p $@

define enum.generate-makefile
  $(enum.BINDIR)/$(1): . $(enum.BINDIR) $(enum.GENERATOR) $(core.LAST_LOADED_FILE)
	@ echo "### Rebuilding $(enum.BINDIR)/$(1)"
	@ $(enum.GENERATOR) -o "$(enum.BINDIR)/$(1)" -t "$(2)" -c "$(3)" -a "$(5)" $(4)

  ${call core.load-if-present,$(enum.BINDIR)/$(1)}
endef

