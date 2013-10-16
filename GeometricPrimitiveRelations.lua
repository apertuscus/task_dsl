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
frame_spec=dofile("kdl_frame_spec.lua")


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












-- a translational axis
trans_axis_spec = umf.ObjectSpec{
   name='rotational_axis',
   postcheck=axis_check_type_unit,
   sealed='both',
   type=Axis,
   dict={
      value=umf.NumberSpec{},
      type=axis_type_spec,
      unit=umf.EnumSpec{ 'N', 'm/sec' },
      overridable=umf.BoolSpec{},
   },
   optional={ 'overridable' },
}

-- motion_spec
motion_spec = umf.ObjectSpec{
   name='axis',
   type=TFFMotion,
   sealed='both',
   dict = {
      xt=trans_axis_spec, yt=trans_axis_spec, zt=trans_axis_spec,
      axt=rot_axis_spec, ayt=rot_axis_spec, azt=rot_axis_spec
   },
}

function Axis:__tostring()
   return self.type .. " " .. self.value .. " " .. (self.unit or "")
end

function TFFMotion:__tostring()
   local res = {}
   res[#res+1] = "xt:  " .. ts(self.xt)
   res[#res+1] = "yt:  " .. ts(self.yt)
   res[#res+1] = "zt:  " .. ts(self.zt)
   res[#res+1] = "axt: " .. ts(self.axt)
   res[#res+1] = "ayt: " .. ts(self.ayt)
   res[#res+1] = "azt: " .. ts(self.azt)
   return table.concat(res, '\n')
end

function TFFMotion:tojson()
   local function ax2str(val, type, is_rot)
      local unit
      if type == 'velocity' and is_rot then unit='rad/sec'
      elseif type == 'velocity' and not is_rot then unit='m/sec'
      elseif type == 'force' and is_rot then unit='Nm'
      elseif type == 'force' and not is_rot then unit='N' end
      return '"'..val..unit..'"'
   end
   return "{ "..
      '"xt":' .. ax2str(self.xt.value, self.xt.type, false)..", "..
      '"yt":' .. ax2str(self.yt.value, self.yt.type, false)..", " ..
      '"zt":' .. ax2str(self.zt.value, self.zt.type, false)..", "..
      '"axt":' .. ax2str(self.axt.value, self.axt.type, true)..", "..
      '"ayt":' .. ax2str(self.ayt.value, self.ayt.type, true)..", " ..
      '"azt":' .. ax2str(self.azt.value, self.azt.type, true).." }"
end

function fromjson(jstr)
   local unit_to_type = {
      ['N']='force', ['Nm']='force',
      ['m/sec']='velocity', ['rad/sec']='velocity',
      ['m/s']='velocity', ['rad/s']='velocity' }

   local function str2axis(str)
      local val, un = string.match(str, "([-%d%.]+)(.*)")
      return Axis{ value=tonum(val), type=unit_to_type[un], unit=un }
   end

   local t = json.decode(jstr)

   return TFFMotion {
      xt=str2axis(t.xt),
      yt=str2axis(t.yt),
      zt=str2axis(t.zt),
      axt=str2axis(t.axt),
      ayt=str2axis(t.ayt),
      azt=str2axis(t.azt),
   }
end

function is_TFFMotion(x)
   return umf.uoo_type(x) == 'instance' and umf.instance_of(TFFMotion, x)
end


function parametrize(motion, params)
   if not is_TFFMotion(motion) then error("parametrize: first argument not a motion") end
   m = utils.deepcopy(motion)
   for k,v in pairs(params) do
      if not m[k] then error("parametrize: unkown key "..ts(k)) end
      if not m[k].overridable then error("parametrize: key "..ts(k).." not overridable!") end
      m[k].value=v
   end
   return m
end