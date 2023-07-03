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

local M = {}

M.encoders = {}

M.encoders.node = function(value)
  return {
    parent = value.parent,
    previousSibling = value.previousSibling,
    nextSibling = value.nextSibling,
    firstChild = value.firstChild,
  }
end

M.encoders.tag = function(value)
  return {}
end

M.encoders.transform = function(value)
  return {
    rotation = M.encoders.vec2(value.rotation),
    translation = M.encoders.vec2(value.translation),
  }
end

M.encoders.vec2 = function(value)
  return { value.x, value.y }
end

function M.encode(valueType, value)
  return M.encoders[valueType](value)
end

return M
