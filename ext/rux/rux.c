// Include Ruby's C API:
#include<ruby.h>
// Include Rax's API
#include "rax/rax.h"

// This function is called by Ruby,
// following the convention `Init_<extension-name>`:
void Init_rux(void) {
  // Get the top-level "Rux" module
  // (or define it if it doesn't exist yet)
  VALUE rux_mRux = rb_define_module("Rux");
  // Define Ruby class named "Tree" which extends Object
  // inside the "Rux" namespace
  VALUE rux_cTree = rb_define_class_under(rux_mRux, "Tree", rb_cObject);
}
