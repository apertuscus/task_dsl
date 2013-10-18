local utils = require "utils"
local umf = require "umf"
local json = require "json"
require "strict"
local string = string
local table = table

local ts, tonum, pairs, error, print = tostring, tonumber, pairs, error, print

module("primitives")


Primitive=umf.class("Primitive")

 
point_spec = umf.ObjectSpec{
   name='point',
   type=Primitive,
   sealed='both',
   dict={
      x=umf.NumberSpec{},
      y=umf.NumberSpec{},
      z=umf.NumberSpec{},
   },
}

vector_spec = umf.ObjectSpec{
   name='Vector',
   type=Primitive,
   sealed='both',
   dict={
      x=umf.NumberSpec{},
      y=umf.NumberSpec{},
      z=umf.NumberSpec{},
   },
}

return primitive_spec