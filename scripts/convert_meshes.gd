@tool
extends EditorScript
## Script developed to convert the raw blender file into objects we can use in the game.

func _run():
	var root = get_scene()
	if not root:
		push_error("No open scene to modify.")
		return

	for object in root.get_children():
		var piece_data = object.name.split("_")
		var mesh := object.mesh as Mesh
		var collision_shape := CollisionShape3D.new()
		collision_shape.name=object.name+"_cshape"
		var body = RigidBody3D.new()
		body.name = object.name+"_body"
		
		if piece_data[0] == "board":
			body = StaticBody3D.new()
		else:
			var piece_number = 0
			if len(piece_data) == 4:
				piece_number = int(piece_data[3])
		
		root.add_child(body)
		# Critical. Root must be the owner for the added child to be reflected in the editor!
		body.owner = root
		body.position = object.position
		object.reparent(body)
		collision_shape.shape = mesh.create_convex_shape()
		body.add_child(collision_shape)
		collision_shape.owner = root
		
		
