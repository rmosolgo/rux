# This Ruby library gives you a DSL
# for generating Makefiles:
require "mkmf"

$CFLAGS << " -std=c99"
find_header("rax/rax.h")
# We'll create a Makefile which compiles `ext/rux/rux.c`
create_makefile "rux/rux"
