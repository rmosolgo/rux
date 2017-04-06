# This Ruby library gives you a DSL
# for generating Makefiles:
require "mkmf"

# We'll create a Makefile which compiles `ext/rux/rux.c`
create_makefile "rux/rux"
