local gr_spec =require "gr_spec"
--local tostring 



x1 = gr_spec.Point{a=1,b=2,c=3}
umf.check(x1,gr_spec.point_spec,true)
x2 = gr_spec.Line{x=1,y=2,z=3}

pr1 = gr_spec.Primitive{entity=x1}
pr2 = gr_spec.Primitive{entity=x2}
umf.check(pr1,gr_spec.primitive_spec,true)
umf.check(pr2,gr_spec.primitive_spec,true)

g1 = gr_spec.Geo_Relation{p1=pr1,p2=pr1,relation_type=	"point-point distance"}
g2 = gr_spec.Geo_Relation{p1=pr1,p2=pr2,relation_type=	"line-point distance"}
g3 = gr_spec.Geo_Relation{p1=pr2,p2=pr1,relation_type=	"line-point distance"}
g4 = gr_spec.Geo_Relation{p1=pr1,p2=pr1,relation_type=	"line-point distance"}
umf.check(g1,gr_spec.geo_relation_spec,true)
umf.check(g2,gr_spec.geo_relation_spec,true)
umf.check(g3,gr_spec.geo_relation_spec,true)
print("g4 check")
umf.check(g4,gr_spec.geo_relation_spec,true)