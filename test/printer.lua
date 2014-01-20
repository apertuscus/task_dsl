local gr =require "geometric_relations_spec"

o1=gr.ObjectFrame{frame_name="o1a"}
o2=gr.ObjectFrame{frame_name="o2"}
origin_p=gr_spec.Point{x=0,y=0,z=0}

tray_normal_direction = gr.Primitive{entity=gr.Versor{x=1,y=0,z=0},object_frame=o1}
tray_normal_line = gr.Primitive{
	entity=gr.Line{origin=origin_p,direction=gr.Versor{x=1,y=0,z=0}},
	object_frame=o1}
tray_up_line = gr.Primitive{
	entity=gr.Line{origin=origin_p,direction=gr.Versor{x=0,y=1,z=0}},
	object_frame=o1}
finger_tip_normal_direction = gr.Primitive{entity=gr.Versor{x=0,y=0,z=1},object_frame=o2}
finger_tip_ref_point = gr.Primitive{entity=gr.Point{x=0,y=0,z=0},object_frame=o2}

angle_btw_normals = gr_spec.GeometricExpression{
	p1=tray_normal_direction,
	p2=finger_tip_normal_direction,
	expression="angle between versors"}
finger_vertical_direction=gr_spec.GeometricExpression{
	p1=finger_tip_ref_point,
	p2=tray_up_line,
	expression="projection of point on line"}
finger_orizontal_direction=gr_spec.GeometricExpression{
	p1=finger_tip_ref_point,
	p2=tray_normal_line,
	expression="projection of point on line"}

rotate_behind_handler=gr_spec.Constraint{
	output_expression=angle_btw_normals,
	behaviour="Move Toward",
	tr_gen="des_velocity_rotation"}
insert=gr_spec.Constraint{
	output_expression=finger_vertical_direction,
	behaviour="Move Toward",
	tr_gen="des_velocity_up"}
compliant_insertion=gr_spec.Constraint{
	output_expression=finger_orizontal_direction,
	behaviour="Interaction"}

insertion_monitor=gr_spec.Monitor{
	monitor_expression=finger_vertical_direction,
	event_risen="e_contact_achieved",
	monitored_variable="FORCE",
	comparison_type="MORE",
	reference_value="max_force"}

grasping_task=gr_spec.Task{
	primary_constraints={rotate_behind_handler,insert,compliant_insertion},
	monitors={insertion_monitor}}


