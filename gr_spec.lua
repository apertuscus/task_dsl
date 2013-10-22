local utils = require "utils"
local umf = require "umf"
local string = string
local table = table
local tostring = tostring
local pairs = pairs
local print = print
local math =require "math"
module("gr_spec")

Point=umf.class("Point")
Line=umf.class("Line")
Versor=umf.class("Versor")
Plane=umf.class("Plane")

--non ordered association btw relations and entities
geometric_relation_entity_legal_association = { 
	["point-point distance"]		={Point,	Point},
 	["line-point distance"]			={Point,	Line},
 	["projection of point on line"]	={Point,	Line},
 	["distance from lines"]			={Line, 	Line},
 	["distance o1-f1"]				={Line, 	Line},
 	["distance o2-f2"]				={Line, 	Line},
 	["point-plane distance"]		={Point,	Plane},
 	["angle between versors"]		={Versor, 	Versor},
 	["incident angle"]				={Versor, 	Plane},
 	["angles between planes"]		={Plane, 	Plane}
 	 }
--building enum of type spec from index of previous table
geometric_relation_type_spec = umf.EnumSpec{} 	
for k ,v in pairs(geometric_relation_entity_legal_association) 
	do table.insert(geometric_relation_type_spec,k) 
end 	


function check_legal_pairs(obj)
relation=obj.relation_type
tab=geometric_relation_entity_legal_association
print(relation)
print(tab[relation])
if (umf.instance_of(tab[relation][1] ,obj.p1.entity) 
	and  umf.instance_of(tab[relation][2] ,obj.p2.entity))
	or
	 (umf.instance_of(tab[relation][2] ,obj.p1.entity) 
	and  umf.instance_of(tab[relation][1] ,obj.p2.entity))
	then return true
	else return false
end
end





joint_relation_type_spec = umf.EnumSpec{ 
	"single_joint_value" }


--Frame=umf.class("Frame")
ObjectFrame=umf.class("ObjectFrame")



point_spec = umf.ObjectSpec{
  name='point',
  type=Point,
  sealed='both',
  dict={
      x=umf.NumberSpec{},
      y=umf.NumberSpec{},
      z=umf.NumberSpec{},
  },
}
--versor
function versor_unitary_mod_check (self, obj, vres)
 	umf.log("validating object against versor_unitary_mod_check")
 	modl= math.abs(math.sqrt (obj.x*obj.x + obj.y*obj.y + obj.z*obj.z))
   	if math.abs(modl -1)>10^-6 then
   		umf.add_msg(vres, "err", "versor needs unitary modulus vectors!\n"..
   		"Mod="..tostring(modl))
   	end
end

versor_spec = umf.ObjectSpec{
  name='versor',
  postcheck=versor_unitary_mod_check,
  type=Versor,
  sealed='both',
  dict={
      x=umf.NumberSpec{},
      y=umf.NumberSpec{},
      z=umf.NumberSpec{},
  },
}
line_spec = umf.ObjectSpec{
  name='line',
  type=Line,
  sealed='both',
  dict={
       origin=point_spec,
       direction=versor_spec,
  },
}
plane_spec = umf.ObjectSpec{
  name='plane',
  type=Plane,
  sealed='both',
  dict={
       origin=point_spec,
       normal=versor_spec,
  },
}
EntitySpec = umf.class("EntitySpec", umf.Spec)

entity_spec_table={
	[Point]=point_spec,
	[Versor]=versor_spec,
	[Line]=line_spec,
	[Plane]=plane_spec}

function EntitySpec.check(self, obj, vres)
   local ret = true
    umf.add_msg(vres, "inf", ",EntitySpec.check on "..tostring(obj:class()))
     umf.ind_inc()--increment an index, defined in umf.lua
   umf.log("validating object against EntitySpec")
   if not umf.uoo_type(obj) then
      umf.add_msg(vres, "err", tostring(obj) .. " not an UMF object")
      umf.ind_dec()
      return false
   end
   ret=false
   for c,f_spec in pairs (entity_spec_table)
   do
    --umf.add_msg(vres, "inf", ",check on "..tostring(c))
   	  if  umf.instance_of(c, obj) then
   	  	umf.ind_dec()--decrement an index, defined in umf.lua 	   
      	return  f_spec:check(obj, vres)
      end
   end
  
   umf.add_msg(vres, "err", "expected Point, Versor,Line, Plane, got:"..tostring(obj:class()))
   ret=false

   umf.ind_dec()--decrement an index, defined in umf.lua
   return ret
end




ObjectFrame=umf.class("ObjectFrame")
object_frame_spec = umf.ObjectSpec{
  name='objectFrame',
  type=ObjectFrame,
  sealed='both',
  dict={
	frame_name=umf.StringSpec{},
	--base_frame=FrameSpec{}
  },
}

Primitive=umf.class("Primitive")
primitive_spec = umf.ObjectSpec{
  name='primitive',
  type=Primitive,
  sealed='both',
  dict={
	entity=EntitySpec{},
	base_frame=object_frame_spec
  },
}
	

function geometric_relation_type_check (self, obj, vres)
 	umf.log("validating object against geometric_relation_type_check")
	umf.add_msg(vres, "inf", obj.relation_type .. ", passed " 
   		.. tostring(obj.p1.entity:class()) 
   		.." and ".. tostring(obj.p2.entity:class()) )  	
   	
   	if not check_legal_pairs(obj)
   	 then umf.add_msg(vres, "err", obj.relation_type .. " needs two points, passed " 
   		.. tostring(obj.p1.entity:class()) 
   		.." and ".. tostring(obj.p2.entity:class()) )
   		return false
   		else return true
   	end
    
end

--[[
function dummy_check (self, obj, vres)
 	umf.log("dummy_check")
	umf.add_msg(vres, "inf", obj.relation_type .. ",dummy passed " 
   		.. tostring(obj.p1.entity:class()) 
   		.." and "
   		.. tostring(obj.p2.entity:class()))
   		return true
end
--]]
GeometricRelation=umf.class("GeometricRelation")
geometric_relation_spec = umf.ObjectSpec{
  name='geometric_relation',
  postcheck=geometric_relation_type_check,
  type=GeometricRelation,
  sealed='both',
  dict={
	p1=primitive_spec,	
	p2=primitive_spec,
	relation_type=geometric_relation_type_spec
  },
}
string_array_spec = umf.TableSpec {
   name='string_array_spec',
   sealed='both',
   array={ umf.StringSpec{} }
}
JointRelation=umf.class("JointRelation")
joint_relation_spec = umf.ObjectSpec{
  name='joint_relation',
  --postcheck=joint_relation_type_check,
  type=JointRelation,
  sealed='both',
  dict={
	joint_names=string_array_spec,
	relation_type=joint_relation_type_spec
  },
}

RelationSpec = umf.class("RelationSpec", umf.Spec)

-- Relation are Joint or geometrical
function RelationSpec.check(self, obj, vres)
   local ret = true
   umf.ind_inc()--increment an index, defined in umf.lua
   umf.log("validating object against RelationSpec")
   if not umf.uoo_type(obj) then
      umf.add_msg(vres, "err", tostring(obj) .. " not an UMF object")
      umf.ind_dec()
      return false
   end
   
   if  umf.instance_of(JointRelation, obj) then
      ret = joint_relation_spec:check(obj, vres)
   elseif umf.instance_of(GeometricRelation, obj) then
      ret = geometric_relation_spec:check(obj, vres)
   else
      umf.add_msg(vres, "err", "expected Geometric or Joint relation, got:"..tostring(obj:class()))
      ret=false
   end

   umf.ind_dec()--decrement an index, defined in umf.lua
   return ret
end
Constraint=umf.class("Constraint")
constraint_spec = umf.ObjectSpec{
  name='constraint_spec',
  --postcheck=joint_relation_type_check,
  type=Constraint,
  sealed='both',
  dict={
	relation=RelationSpec{},
  },
}

