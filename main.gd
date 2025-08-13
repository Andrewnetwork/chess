extends Node3D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_up"):
		$RigidBody3D.apply_force(Vector3(0,0,-100))
	if event.is_action("ui_down"):
		$RigidBody3D.apply_force(Vector3(0,0,100))


func _on_rigid_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	#$RigidBody3D.position.x = event_position.x
	#$RigidBody3D.position.z = event_position.z
	#$RigidBody3D.set_axis_velocity(Vector3(0,0,0.3))
	pass
