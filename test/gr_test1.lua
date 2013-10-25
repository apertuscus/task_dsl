local gr_spec =require "gr_spec"
--local tostring 



point = gr_spec.Point{x=1,y=2,z=3}
versor = gr_spec.Point{x=0,y=0,z=1}

line = gr_spec.Line{origin=gr_spec.Point{x=0,y=0,z=0},direction=gr_spec.Versor{x=1,y=0,z=0}}
plane = gr_spec.Plane{origin=gr_spec.Point{x=0,y=0,z=0},normal=gr_spec.Versor{x=1,y=0,z=0}}


o1=gr_spec.ObjectFrame{frame_name="o1"}
o2=gr_spec.ObjectFrame{frame_name="o2"}

pr_line = gr_spec.Primitive{entity=line,object_frame=o1}
pr_point = gr_spec.Primitive{entity=point,object_frame=o1}
pr_plane = gr_spec.Primitive{entity=plane,object_frame=o2}
pr_versor = gr_spec.Primitive{entity=versor,object_frame=o2}


g1 = gr_spec.GeometricExpression{p1=pr_point,p2=pr_point,expression=	"point-point distance"}
g2 = gr_spec.GeometricExpression{p1=pr_point,p2=pr_line,expression=	"line-point distance"}
g3 = gr_spec.GeometricExpression{p1=pr_line,p2=pr_line,expression=	"line-point distance"}
g4 = gr_spec.GeometricExpression{p1=pr_point,p2=pr_point,expression=	"line-point distance"}
g5 = gr_spec.GeometricExpression{p1=pr_line,p2=pr_line,expression=	"distance from lines"}
g6 = gr_spec.GeometricExpression{p1=pr_plane,p2=pr_line,expression=	"distance from lines"}

--umf.check(g4,gr_spec.geometric_output_expression_spec,true)

j1 = gr_spec.JointExpression{joint_names={"j1"},expression="single_joint_value"}




print("======\n output_expression..\n==========")

umf.check(g1,gr_spec.ExpressionSpec{},true)
print("======\n constraints..\n==========")
umf.check(gr_spec.Constraint{output_expression=g2,behaviour="Velocity Limit"},gr_spec.constraint_spec,true)
print("======\n  1\n==========")
umf.check(gr_spec.Constraint{output_expression=g3,behaviour="Velocity Limit"},gr_spec.constraint_spec,true)
print("======\n  2\n==========")
umf.check(gr_spec.Constraint{output_expression=g4,behaviour="Velocity Limit"},gr_spec.constraint_spec,true)
print("======\n  3\n==========")
umf.check(gr_spec.Constraint{output_expression=g5,behaviour="Velocity Limit"},gr_spec.constraint_spec,true)
print("======\n  4\n==========")
umf.check(gr_spec.Constraint{output_expression=g6,behaviour="Velocity Limit"},gr_spec.constraint_spec,true)
print("======\n  5\n==========")
umf.check(gr_spec.Constraint{output_expression=j1,behaviour="Velocity Limit"},gr_spec.constraint_spec,true)
print("======\n  6\n==========")
c1=gr_spec.Constraint{output_expression=g1,behaviour="Velocity Limit"}
umf.check(c1,gr_spec.constraint_spec,true)
print("======\n  7\n==========")
M1=gr_spec.Monitor{monitor_expression=g1,
	event_risen="done",
	monitored_variable="POS",
	comparison_type="EQUAL"
}
prim_c={c1}
--i can pass empty table and pass the check, if precheck is not implemented
T1=gr_spec.Task{primary_constraints=prim_c,monitors={M1}}
umf.check(T1,gr_spec.task_spec,true)


