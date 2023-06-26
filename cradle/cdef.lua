local ffi = require("ffi")

ffi.cdef([[
  typedef struct node {
    double parent;
    double previousSibling;
    double nextSibling;
    double firstChild;
  } node;

  typedef struct tag {} tag;

  typedef struct vec2 {
    double x;
    double y;
  } vec2;

  typedef struct transform {
    vec2 translation;
    vec2 rotation;
  } transform;
]])
