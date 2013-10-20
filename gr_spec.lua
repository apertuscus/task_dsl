local utils = require "utils"
local umf = require "umf"
local string = string
local table = table
local tostring = tostring

module("gr_spec")

relation_type_spec = umf.EnumSpec{ 
	"point-point distance",
 	"line-point distance",
 	"projection of point on line",
 	"distance from lines",
 	"distance o1-f1",
 	"distance o2-f2",
 	"point-plane distance",
 	"angle between versor",	
 	"incident angle",
 	"angles between planes" }


Line=umf.class("Line")
Point=umf.class("Point")


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

EntitySpec = umf.class("EntitySpec", umf.Spec)
-- location can be either an frame_spec or external input or external_input_spec

function EntitySpec.check(self, obj, vres)
   local ret = true
   umf.ind_inc()--increment an index, defined in umf.lua
   umf.log("validating object against EntitySpec")
   if not umf.uoo_type(obj) then
      umf.add_msg(vres, "err", tostring(obj) .. " not an UMF object")
      ind_dec()
      return false
   end

   if umf.instance_of(Line, obj) then
      ret = line_spec:check(obj, vres)
   elseif umf.instance_of(Point, obj) then
      ret = point_spec:check(obj, vres)
   else
      umf.add_msg(vres, "err", "expected Line or Point, got:"..tostring(obj))
      ret=false
   end

   umf.ind_dec()--decrement an index, defined in umf.lua
   return ret
end


Primitive=umf.class("Primitive")

primitive_spec = umf.ObjectSpec{
  name='primitive',
  type=Primitive,
  sealed='both',
  dict={
	entity=EntitySpec{},
	--base_frame=FrameSpec{}
  },
}

---here i have to make all the possible combination of legal stuff

function geo_relation_type_check (self, obj, vres)
 	umf.log("validating object against geo_relation_type_check")
   	if(obj.relation_type=="point-point distance") then
   		if not(umf.instance_of(Point, obj.p1.entity) and umf.instance_of(Point, obj.p2.entity) )
   		then umf.add_msg(vres, "err", obj.relation_type .. " needs two points, passed " 
   		.. tostring(obj.p1.entity:class()) 
   		.." and ".. tostring(obj.p2.entity:class()) )
   		return false
   		else return true
   	end
   	elseif (obj.relation_type=="line-point distance") then
   	   		if not(
   	   			(umf.instance_of(Line, obj.p1.entity) and umf.instance_of(Point, obj.p2.entity))
   	   			or
   	   			(umf.instance_of(Point, obj.p1.entity) and umf.instance_of(Line, obj.p2.entity))
   	   		)
   		then umf.add_msg(vres, "err", obj.relation_type .. " needs a point and a line, passed " 
   		.. tostring(obj.p1.entity:class()) 
   		.." and ".. tostring(obj.p2.entity:class()) )
   		return false
   		else return true
   	end
   	elseif (obj.relation_type=="projection of point on line") then
   	elseif (obj.relation_type=="distance from lines") then
   	elseif (obj.relation_type=="distance o1-f1") then
   	elseif (obj.relation_type=="distance o2-f2") then
   	elseif (obj.relation_type=="point-plane distance") then
   	elseif (obj.relation_type=="incident angle") then
   	elseif (obj.relation_type=="angles between planes") then
	end
end


Geo_Relation=umf.class("Geo_Relation")
geo_relation_spec = umf.ObjectSpec{
  name='geo_relation',
  postcheck=geo_relation_type_check,
  type=Geo_Relation,
  sealed='both',
  dict={
	p1=primitive_spec,	--base_frame=FrameSpec{}
	p2=primitive_spec,
	relation_type=relation_type_spec
	
  },
}




--[[
x1 = Point{a=1,b=2,c=3}
umf.check(x1,point_spec,true)
x2 = Line{x=1,y=2,z=3}

pr1 = Primitive{entity=x1}
pr2 = Primitive{entity=x2}
umf.check(pr1,primitive_spec,true)
umf.check(pr2,primitive_spec,true)

g1 = Geo_Relation{p1=pr1,p2=pr1,relation_type=	"point-point distance"}
g2 = Geo_Relation{p1=pr1,p2=pr2,relation_type=	"line-point distance"}
g3 = Geo_Relation{p1=pr2,p2=pr1,relation_type=	"line-point distance"}
g4 = Geo_Relation{p1=pr1,p2=pr1,relation_type=	"line-point distance"}
umf.check(g1,geo_relation_spec,true)
umf.check(g2,geo_relation_spec,true)
umf.check(g3,geo_relation_spec,true)
umf.check(g4,geo_relation_spec,true)
]]