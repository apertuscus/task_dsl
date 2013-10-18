local utils = require "utils"
local umf = require "umf"
local string = string
local table = table


--module("cose")
Entity=umf.class("Entity")
Line=umf.class("Line",Entity)
Point=umf.class("Point",Entity)
Geo = umf.class("Geo")

entity_spec = umf.ObjectSpec{
  name='entity',
    type=Entity,
  sealed='both',
  dict={},
}

line_spec = umf.ObjectSpec{
  name='line',
  type=Line,
  sealed='both',
  dict={
       x=umf.NumberSpec{},
      y=umf.NumberSpec{},
      z=umf.NumberSpec{},
  },
}

point_spec = umf.ObjectSpec{
  name='point',
  type=Point,
  sealed='both',
  dict={
      a=umf.NumberSpec{},
      b=umf.NumberSpec{},
      c=umf.NumberSpec{},
  },
}



geo_spec = umf.ObjectSpec{
  name='geo',
  type=Geo,
  sealed='both',
  dict={
    data=entity_spec,
  },
}

x1 = Point{a=1,b=2,c=3}
e1 = Entity{}
g1 = Geo{data=x1}
e2 = { data={a=3,b=2,c=1}}

umf.check(x1,point_spec,true)
umf.check(e1,entity_spec,true)
umf.check(g1,geo_spec,true)
--umf.check(e2,Entity,true)

