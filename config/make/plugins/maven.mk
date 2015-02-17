# vim: ft=make: sw=2:

all:: info

${call core.show-current-location}

local.MAVEN_TARGETS = compile package install clean test
local.MAVEN_BINTOP := ${abspath $(sys.BINTOP)}

.PHONY: info build local.MAVEN_TARGETS
info::
	@ echo "Available targets: $(local.MAVEN_TARGETS)"

local.setup-maven-target = ${if ${filter true yes,$(EMC_TOOLS_B_OUTSIDE_MAVEN_TARGET)},EMC_TOOLS_B_MAVEN_PARENT_TARGET=$(local.MAVEN_BINTOP),}

$(local.MAVEN_TARGETS)::
	cd $(sys.SRCTOP) && ${local.setup-maven-target} mvn $(@) $(TEST:%=-Dtest=%)

build:: package
