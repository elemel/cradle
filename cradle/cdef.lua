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
    vec2 position;
    vec2 orientation;
  } transform;

  typedef struct color3 {
    double red;
    double green;
    double blue;
  } color3;

  typedef struct color4 {
    double red;
    double green;
    double blue;
    double alpha;
  } color4;
]])

local M = {}

M.encoders = {}

M.encoders.color3 = function(value)
  return { value.red, value.green, value.blue }
end

M.encoders.color4 = function(value)
  return { value.red, value.green, value.blue, value.alpha }
end

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
    orientation = M.encoders.vec2(value.orientation),
    position = M.encoders.vec2(value.position),
  }
end

M.encoders.vec2 = function(value)
  return { value.x, value.y }
end

function M.encode(valueType, value)
  return M.encoders[valueType](value)
end

return M
