local utils = require "utils"
local umf = require "umf"
local json = require "json"
local string = string
local table = table

local ts, tonum, pairs, error, print = tostring, tonumber, pairs, error, print

module("GeometricPrimitiveRelations")

GeometricPrimitive=umf.class("GeometricPrimitive")
GeometricRelation=umf.class("GeometricRelation")
GeometricEntity=umf.class("GeometricEntity")

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


--for frame specification
rotation_spec=umf.ObjectSpec{
   name='kdl_rotation',
   sealed='both',
   type=Rotation,
   dict = { 
      X_x = umf.NumberSpec{}, Y_x = umf.NumberSpec{}, Z_x = umf.NumberSpec{},
      X_y = umf.NumberSpec{}, Y_y = umf.NumberSpec{}, Z_y = umf.NumberSpec{},
      X_z = umf.NumberSpec{}, Y_z = umf.NumberSpec{}, Z_z = umf.NumberSpec{}
   }
}

vector_spec=umf.ObjectSpec{
	name='kdl_vector',
    type=Vector,
	sealed='both',
	dict={ X = umf.NumberSpec{}, Y = umf.NumberSpec{}, Z = umf.NumberSpec{} }
}

--- Frame
frame_spec = umf.ObjectSpec{
   name='frame',
   type=Frame,
   sealed='both',

   dict={
        M=rotation_spec,
        p=vector_spec
   }
}

-- 
point_spec = umf.ObjectSpec{
   name='point',
   --postcheck=axis_check_type_unit,
   type=GeometricEntity,
   sealed='both',
   dict={
      x=umf.NumberSpec{},
      y=umf.NumberSpec{},
      z=umf.NumberSpec{},
   },
   optional={ 'overridable' },
}
--
vector_spec = umf.ObjectSpec{
   name='vector',
   --postcheck=axis_check_type_unit,
   type=GeometricEntity,
   sealed='both',
   dict={
      x=umf.NumberSpec{},
      y=umf.NumberSpec{},
      z=umf.NumberSpec{},
   },
   optional={ 'overridable' },
}
-- 
versor_spec = umf.ObjectSpec{
   name='vector',
   --postcheck=versor_check_unitary_mod,
   type=GeometricEntity,
   sealed='both',
   dict={
      x=umf.NumberSpec{},
      y=umf.NumberSpec{},
      z=umf.NumberSpec{},
   },
   optional={ 'overridable'},
}
line_spec = umf.ObjectSpec{
   name='line',
   --postcheck=versor_check_unitary_mod,
   type=GeometricEntity,
   sealed='both',
   dict={
     origin=point_spec,
     direction=versor_spec,
   },
   optional={ 'overridable'},
}
plane_spec = umf.ObjectSpec{
   name='plane',
   --postcheck=versor_check_unitary_mod,
   type=GeometricEntity,
   sealed='both',
   dict={
     origin=point_spec,
     normal=versor_spec,
   },
   optional={ 'overridable'},
}
-------------------
GeometricPrimitive_spec = umf.ObjectSpec{
   name='geometricPrimitive',
   type=GeometricPrimitive,
   sealed='both',
   dict={
     entity=point_spec,
     objectFrame = frame_spec,
   },
   optional={ 'overridable'},
}
GeometricRelation_spec = umf.ObjectSpec{
   name='geometricRelation',
   postcheck=geometric_relation_test_legal_couple,
   type=GeometricRelation,
   sealed='both',
   dict={
     geometricPrimitive1=GeometricPrimitive,
     geometricPrimitive2=GeometricPrimitive,
     relation_type=relation_type_spec,
   },
   optional={ 'overridable'},
}







