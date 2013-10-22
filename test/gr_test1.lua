local gr_spec =require "gr_spec"
--local tostring 



point = gr_spec.Point{x=1,y=2,z=3}
versor = gr_spec.Point{x=0,y=0,z=1}

line = gr_spec.Line{origin=gr_spec.Point{x=0,y=0,z=0},direction=gr_spec.Versor{x=1,y=0,z=0}}
plane = gr_spec.Plane{origin=gr_spec.Point{x=0,y=0,z=0},normal=gr_spec.Versor{x=1,y=0,z=0}}


o1=gr_spec.ObjectFrame{frame_name="o1"}
o2=gr_spec.ObjectFrame{frame_name="o2"}

pr_line = gr_spec.Primitive{entity=line,base_frame=o1}
pr_point = gr_spec.Primitive{entity=point,base_frame=o1}
pr_plane = gr_spec.Primitive{entity=plane,base_frame=o2}
pr_versor = gr_spec.Primitive{entity=versor,base_frame=o2}


g1 = gr_spec.GeometricRelation{p1=pr_point,p2=pr_point,relation_type=	"point-point distance"}
g2 = gr_spec.GeometricRelation{p1=pr_point,p2=pr_line,relation_type=	"line-point distance"}
g3 = gr_spec.GeometricRelation{p1=pr_line,p2=pr_line,relation_type=	"line-point distance"}
g4 = gr_spec.GeometricRelation{p1=pr_point,p2=pr_point,relation_type=	"line-point distance"}
g5 = gr_spec.GeometricRelation{p1=pr_line,p2=pr_line,relation_type=	"distance from lines"}
g6 = gr_spec.GeometricRelation{p1=pr_plane,p2=pr_line,relation_type=	"distance from lines"}

umf.check(g4,gr_spec.geometric_relation_spec,true)

j1 = gr_spec.JointRelation{joint_names={"j1"},relation_type="single_joint_value"}

umf.check(j1,gr_spec.joint_relation_spec,true)


print("======\nconstraints..\n==========")

umf.check(gr_spec.Constraint{relation=g1},gr_spec.constraint_spec,true)
umf.check(gr_spec.Constraint{relation=g2},gr_spec.constraint_spec,true)
umf.check(gr_spec.Constraint{relation=g3},gr_spec.constraint_spec,true)
umf.check(gr_spec.Constraint{relation=g4},gr_spec.constraint_spec,true)
umf.check(gr_spec.Constraint{relation=g5},gr_spec.constraint_spec,true)
umf.check(gr_spec.Constraint{relation=g6},gr_spec.constraint_spec,true)



