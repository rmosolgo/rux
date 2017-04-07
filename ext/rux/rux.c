// Include Ruby's C API:
#include <ruby.h>
// Include Rax
#include "rax/rax.c"

void rux_cTree_free(void* rt) {
  // Cast the data as a `rax *`, then free it.
  raxFree((rax *)(rt));
}

void rux_cTree_mark(void* rtp) {
  rax *rt = (rax *)rtp;
  raxIterator iter;
  raxStart(&iter, rt);
  raxSeek(&iter, "^", (unsigned char*)"", 0);
  while(raxNext(&iter)) {
    rb_gc_mark((VALUE)iter.data);
  }
  raxStop(&iter);
}

static const rb_data_type_t rux_rax_type = {
  // Type Name:
  "rax",
  // Memory management functions
  {
    // mark function
    rux_cTree_mark,
    // free function
    rux_cTree_free,
    // memsize function
    0,
  },
  // parent, Required to be 0:
  0,
  // data, not needed:
  0,
  // GC flags:
  0,
};

VALUE rux_cTree_alloc(VALUE cTree) {
  // Make a new rax tree
  rax *rt = raxNew();
  // Associate it with an instance of Rux::Tree
  VALUE inst = TypedData_Wrap_Struct(cTree, &rux_rax_type, rt);
  // Return the new instance
  return inst;
}

VALUE rux_cTree_size(VALUE self) {
  // Read the stored tree into this pointer
  rax *rt;
  TypedData_Get_Struct(self, rax, &rux_rax_type, rt);
  // Get the number of elements in the tree
  uint64_t size = rt->numele;
  // Return it as a Ruby VALUE
  return INT2FIX(size);
}

VALUE rux_cTree_set(VALUE self, VALUE key, VALUE value) {
  if (!RB_TYPE_P(key, T_STRING)) {
    rb_raise(rb_eArgError, "key must be String");
  }
  // Read the stored tree into this pointer
  rax *rt;
  TypedData_Get_Struct(self, rax, &rux_rax_type, rt);
  char *c_str = RSTRING_PTR(key);
  size_t str_len = RSTRING_LEN(key);
  void **prev;
  raxInsert(rt, (unsigned char *)(c_str), str_len, (void *)value, prev);
  return value;
}

VALUE rux_cTree_get(VALUE self, VALUE key) {
  if (!RB_TYPE_P(key, T_STRING)) {
    rb_raise(rb_eArgError, "key must be String");
  }
  rax *rt;
  TypedData_Get_Struct(self, rax, &rux_rax_type, rt);
  char *c_str = RSTRING_PTR(key);
  size_t str_len = RSTRING_LEN(key);
  void *valptr = raxFind(rt, (unsigned char *)c_str, str_len);
  if (valptr == raxNotFound) {
    return Qnil;
  } else {
    return (VALUE)valptr;
  }
}

VALUE rux_cTree_delete(VALUE self, VALUE key) {
  if (!RB_TYPE_P(key, T_STRING)) {
    rb_raise(rb_eArgError, "key must be String");
  }
  rax *rt;
  TypedData_Get_Struct(self, rax, &rux_rax_type, rt);
  char *c_str = RSTRING_PTR(key);
  size_t str_len = RSTRING_LEN(key);
  void **prev;
  int wasRemoved = raxRemove(rt, (unsigned char *)(c_str), str_len, prev);
  if (wasRemoved) {
    return (VALUE)(*prev);
  } else {
    return Qnil;
  }
}

VALUE rux_cTree_each(VALUE self) {
  if (!rb_block_given_p()) {
    rb_raise(rb_eArgError, "Expected block");
  } else {
    // TODO ensure cleanup if block raises an error
    rax *rt;
    TypedData_Get_Struct(self, rax, &rux_rax_type, rt);
    raxIterator iter;
    raxStart(&iter, rt);
    raxSeek(&iter, "^", (unsigned char*)"", 0);
    while(raxNext(&iter)) {
      rb_yield_values(2, rb_str_new((char*)iter.key, (size_t)iter.key_len), (VALUE)iter.data);
    }
    raxStop(&iter);
  }
  return Qnil;
}

VALUE rux_cTree_show(VALUE self) {
  rax *rt;
  TypedData_Get_Struct(self, rax, &rux_rax_type, rt);
  raxShow(rt);
  return Qnil;
}

// This function is called by Ruby,
// following the convention `Init_<extension-name>`:
void Init_rux(void) {
  // Get the top-level "Rux" module
  // (or define it if it doesn't exist yet)
  VALUE rux_mRux = rb_define_module("Rux");
  // Define Ruby class named "Tree" which extends Data
  // inside the "Rux" namespace
  VALUE rux_cTree = rb_define_class_under(rux_mRux, "Tree", rb_cData);
  rb_define_alloc_func(rux_cTree, rux_cTree_alloc);
  rb_define_method(rux_cTree, "size", rux_cTree_size, 0);
  rb_define_method(rux_cTree, "get", rux_cTree_get, 1);
  rb_define_method(rux_cTree, "set", rux_cTree_set, 2);
  rb_define_method(rux_cTree, "delete", rux_cTree_delete, 1);
  rb_define_alias(rux_cTree, "[]", "get");
  rb_define_alias(rux_cTree, "[]=", "set");
  rb_define_method(rux_cTree, "each", rux_cTree_each, 0);
  rb_define_method(rux_cTree, "show", rux_cTree_show, 0);
}
