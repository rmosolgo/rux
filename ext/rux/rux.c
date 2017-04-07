// Include Ruby's C API:
#include <ruby.h>
// Include Rax
#include "rax/rax.c"
#include <stdlib.h>
// Convert intern value to Ruby value
VALUE rux_cTree_data_to_value(void *data) {
  if (data) {
    return (VALUE)(data);
  } else {
    return Qnil;
  }
}

void* rux_cTree_value_to_data(VALUE value) {
  if (value == Qnil) {
    // Use rax's null compression?
    return NULL;
  } else {
    return (void*)(value);
  }
}

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
    if (iter.data) {
      rb_gc_mark(rux_cTree_data_to_value(iter.data));
    }
  }
  raxStop(&iter);
}

size_t rux_cTree_memsize(const void* rtp) {
  rax *rt = (rax *)rtp;
  return rt->numnodes * sizeof(raxNode);
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
    rux_cTree_memsize,
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
  rax *rt;
  TypedData_Get_Struct(self, rax, &rux_rax_type, rt);
  return INT2FIX(rt->numele);
}

VALUE rux_cTree_node_size(VALUE self) {
  rax *rt;
  TypedData_Get_Struct(self, rax, &rux_rax_type, rt);
  return INT2FIX(rt->numnodes);
}

VALUE rux_cTree_set(int argc, VALUE* argv, VALUE self) {
  VALUE key, value, fallback;
  if (argc > 3 || argc < 2) {
    rb_raise(rb_eArgError, "expected 2-3 arguments");
  }
  key = argv[0];
  value = argv[1];
  if (argc == 3) {
    fallback = argv[2];
  } else {
    fallback = Qnil;
  }

  if (!RB_TYPE_P(key, T_STRING)) {
    rb_raise(rb_eArgError, "key must be String");
  }
  // Read the stored tree into this pointer
  rax *rt;
  TypedData_Get_Struct(self, rax, &rux_rax_type, rt);
  char *c_str = RSTRING_PTR(key);
  size_t str_len = RSTRING_LEN(key);
  void *prev;
  int res = raxInsert(rt, (unsigned char *)(c_str), str_len, rux_cTree_value_to_data(value), &prev);
  if (res == 1) {
    return fallback;
  } else {
    // TODO: This could also be out-of-memory error
    return rux_cTree_data_to_value(prev);
  }
}

VALUE rux_cTree_get(int argc, VALUE* argv, VALUE self) {
  VALUE key, fallback;
  if (argc > 2 || argc < 1) {
    rb_raise(rb_eArgError, "expected 1-2 argumets");
  }
  key = argv[0];
  if (argc == 2) {
    fallback = argv[1];
  } else {
    fallback = Qnil;
  }
  if (!RB_TYPE_P(key, T_STRING)) {
    rb_raise(rb_eArgError, "key must be String");
  }
  rax *rt;
  TypedData_Get_Struct(self, rax, &rux_rax_type, rt);
  char *c_str = RSTRING_PTR(key);
  size_t str_len = RSTRING_LEN(key);
  void *valptr = raxFind(rt, (unsigned char *)c_str, str_len);
  if (valptr == raxNotFound) {
    return fallback;
  } else {
    return rux_cTree_data_to_value(valptr);
  }
}

VALUE rux_cTree_delete(int argc, VALUE* argv, VALUE self) {
  VALUE key, fallback;
  if (argc > 2 || argc < 1) {
    rb_raise(rb_eArgError, "expected 1-2 arguments");
  }
  key = argv[0];
  if (argc == 2) {
    fallback = argv[1];
  } else {
    fallback = Qnil;
  }

  if (!RB_TYPE_P(key, T_STRING)) {
    rb_raise(rb_eArgError, "key must be String");
  }
  rax *rt;
  TypedData_Get_Struct(self, rax, &rux_rax_type, rt);
  char *c_str = RSTRING_PTR(key);
  size_t str_len = RSTRING_LEN(key);
  void *prev;
  int wasRemoved = raxRemove(rt, (unsigned char *)(c_str), str_len, &prev);
  if (wasRemoved) {
    return rux_cTree_data_to_value(prev);
  } else {
    return fallback;
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
      rb_yield_values(2, rb_str_new((char*)iter.key, (size_t)iter.key_len), rux_cTree_data_to_value(iter.data));
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
  rb_define_method(rux_cTree, "node_size", rux_cTree_node_size, 0);
  rb_define_method(rux_cTree, "get", rux_cTree_get, -1);
  rb_define_method(rux_cTree, "set", rux_cTree_set, -1);
  rb_define_method(rux_cTree, "delete", rux_cTree_delete, -1);
  rb_define_method(rux_cTree, "each", rux_cTree_each, 0);
  rb_define_method(rux_cTree, "show", rux_cTree_show, 0);
}
