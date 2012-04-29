# vim: ft=make: sw=2:
${call core.show-current-location}

enum.p.GENERATOR := $(core.PLUGINS_DIR)/enum/generate-makefile

define enum.generate-makefile
  $(sys.BINDIR)/$(1): . $(sys.BINDIR) $(enum.p.GENERATOR) $(core.LAST_LOADED_FILE)
	@ echo "### Rebuilding $(sys.BINDIR)/$(1)"
	@ $(enum.p.GENERATOR) -o "$(sys.BINDIR)/$(1)" -t "$(2)" -c "$(3)" -a "$(5)" "$(4)"

  ${call core.load-if-present,$(sys.BINDIR)/$(1)}
endef

