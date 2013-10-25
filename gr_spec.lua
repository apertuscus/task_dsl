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

--non ordered association btw expressions and entities
geometric_expression_entity_legal_association = { 
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
geometric_expression_type_spec = umf.EnumSpec{} 	
for k ,v in pairs(geometric_expression_entity_legal_association) 
	do table.insert(geometric_expression_type_spec,k) 
end 	


function check_legal_pairs(obj)
expression=obj.expression
tab=geometric_expression_entity_legal_association
--print(expression)
--print(tab[expression])
if (umf.instance_of(tab[expression][1] ,obj.p1.entity) 
	and  umf.instance_of(tab[expression][2] ,obj.p2.entity))
	or
	 (umf.instance_of(tab[expression][2] ,obj.p1.entity) 
	and  umf.instance_of(tab[expression][1] ,obj.p2.entity))
	then return true
	else return false
end
end





joint_expression_type_spec = umf.EnumSpec{ 
	"single_joint_value" }


--Frame=umf.class("Frame")
ObjectFrame=umf.class("ObjectFrame")



point_spec = umf.ObjectSpec{
  name='point',
  type=Point,
  sealed='both',
  dict={x=umf.NumberSpec{}, y=umf.NumberSpec{}, z=umf.NumberSpec{}}
}
--versor
function versor_unitary_mod_check (self, obj, vres)
 	umf.log("validating object against versor_unitary_mod_check")
 	modl= math.abs(math.sqrt (obj.x*obj.x + obj.y*obj.y + obj.z*obj.z))
   	if math.abs(modl -1)>10^-6 then
   		umf.add_msg(vres, "err", "versor needs unitary modulus vectors!\n"..
   		"Mod="..tostring(modl))
   		return false
   	end
   	return true
end

versor_spec = umf.ObjectSpec{
  name='versor',
  postcheck=versor_unitary_mod_check,
  type=Versor,
  sealed='both',
   dict={x=umf.NumberSpec{}, y=umf.NumberSpec{}, z=umf.NumberSpec{}}
}
line_spec = umf.ObjectSpec{
  name='line',
  type=Line,
  sealed='both',
  dict={origin=point_spec, direction=versor_spec}
}
plane_spec = umf.ObjectSpec{
  name='plane',
  type=Plane,
  sealed='both',
  dict={origin=point_spec, normal=versor_spec}
}
function check_inheritance(obj,spec_table,vres)

for c,f_spec in pairs (spec_table) 
   do
   		if  umf.instance_of(c, obj) then
   		--print("found")
   	 	return  f_spec:check(obj, vres)
      	end
   end
   return false
end

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
   ret=check_inheritance (obj,entity_spec_table,vres)
   if not ret 
   then
   		umf.add_msg(vres, "err", "expected Point, Versor,Line, Plane, got:"..tostring(obj:class()))
    	ret=false
   end
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
	object_frame=object_frame_spec
  },
}
	

function geometric_entity_vs_expression_check (self, obj, vres)
 	umf.log("validating object against geometric_entity_vs_expression_check")
	umf.add_msg(vres, "inf", obj.expression .. ", passed " 
   		.. tostring(obj.p1.entity:class()) 
   		.." and ".. tostring(obj.p2.entity:class()) )  	
   	
   	if not check_legal_pairs(obj)
   	 then umf.add_msg(vres, "err", obj.expression .. " needs: "  
   		.. tostring(geometric_expression_entity_legal_association[obj.expression][1]) 
   		.." and "
   		.. tostring(geometric_expression_entity_legal_association[obj.expression][2] ))
   		return false
   		else return true
   	end
    
end


GeometricExpression=umf.class("GeometricExpression")
geometric_expression_spec = umf.ObjectSpec{
  name='geometric_expression',
  postcheck=geometric_entity_vs_expression_check,
  type=GeometricExpression,
  sealed='both',
  dict={
	p1=primitive_spec,	
	p2=primitive_spec,
	expression=geometric_expression_type_spec
  },
}
string_array_spec = umf.TableSpec {
   name='string_array_spec',
   sealed='both',
   array={ umf.StringSpec{} }
}
JointExpression=umf.class("JointExpression")

joint_expression_spec = umf.ObjectSpec{
  name='joint_expression',
  --postcheck=...
  type=JointExpression,
  sealed='both',
  dict={
	joint_names=string_array_spec,
	expression=joint_expression_type_spec
  },
}

ExpressionSpec = umf.class("ExpressionSpec", umf.Spec)

-- Relation are Joint or geometrical

expression_spec_table={
	[JointExpression]=joint_expression_spec,
	[GeometricExpression]=geometric_expression_spec,
	}



function ExpressionSpec.check(self, obj, vres)
   local ret = true
    umf.ind_inc()--increment an index, defined in umf.lua

    umf.add_msg(vres, "inf", ",ExpressionSpec.check on "..tostring(obj:class()))
    umf.log("validating object against ExpressionSpec")
   if not umf.uoo_type(obj) then
      umf.add_msg(vres, "err", tostring(obj) .. " not an UMF object")
      umf.ind_dec()
      return false
   end
   ret=check_inheritance (obj,expression_spec_table,vres)
  
   if not ret
   then
   		umf.add_msg(vres, "err", "Joint or Geometric expression, got:"..tostring(obj:class()))
    	ret=false
   end
   umf.ind_dec()--decrement an index, defined in umf.lua
   return ret
end

--in case i want to add further specification in the future...
behaviour_spec_table = { 
	["Positioning"]={},
	["Move Toward"]={},
	["Interaction"]={},
	["Compliant"]={},
	["Position Limit"]={},
	["Velocity Limit"]={}
	}
behaviour_type_spec = umf.EnumSpec{} 	
for k ,v in pairs(behaviour_spec_table) 
	do table.insert(behaviour_type_spec,k) 
end 	
trj_gen_type_spec = umf.StringSpec{} 

Constraint=umf.class("Constraint")
constraint_spec = umf.ObjectSpec{
  name='constraint_spec',
  --postcheck=joint_expression_type_check,
  type=Constraint,
  sealed='both',
  dict={
	output_expression=ExpressionSpec{},
	behaviour=behaviour_type_spec,
	tr_gen=trj_gen_type_spec
  },
  optional={"tr_gen"}
}
constraint_array_spec = umf.TableSpec {
   name='string_array_spec',
   sealed='both',
   array={ constraint_spec }
}
----------monitor-------------
monitored_variable_type_spec = umf.EnumSpec{"POS","FOR","VEL"} 
comparison_type_spec = umf.EnumSpec{"EQUAL","LESS","MORE"} 

Monitor=umf.class("Monitor")

monitor_spec = umf.ObjectSpec{
  name='monitor_spec',
  type=Monitor,
  sealed='both',
  dict={
	monitor_expression=ExpressionSpec{},
	event_risen=umf.StringSpec{},
	monitored_variable=monitored_variable_type_spec,
	comparison_type=comparison_type_spec
  },
}


-------------end monitor-------------

-------------array spec -------------
function not_empty_array(self, obj, vres) 
if #obj<1 then umf.add_msg(vres, "err",  " needs non-empty array. It has size: ".. #obj )
  	return false else return true end
end

monitor_array_spec = umf.TableSpec {
   name='monitor_array_spec',
   postcheck=not_empty_array,
   sealed='both',
   array={ monitor_spec }
}

constraint_array_spec = umf.TableSpec {
   name='string_array_spec',
   postcheck=not_empty_array,
   sealed='both',
   array={ constraint_spec }
}
-------------end array spec ---------


--to be filled: 
function task_type_check(self, obj, vres) return true end

Task=umf.class("Task")
task_spec = umf.ObjectSpec{
  name='task_spec',
  postcheck=task_type_check,
  type=Task,
  sealed='both',
  dict={
	emergency_constraints=constraint_array_spec,
	primary_constraints=constraint_array_spec,
	auxiliary_constraints=constraint_array_spec,
	monitors=monitor_array_spec
  },
    optional={"emergency_constraints","auxiliary_constraints","monitors"}
}

