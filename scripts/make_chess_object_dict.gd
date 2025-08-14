@tool
extends EditorScript

var pieces = {"white": {}, "black": {}}

func add_piece(color: String, piece: String, number: int, obj_ref):
	if !pieces[color].has(piece):
		pieces[color][piece] = {}
	pieces[color][piece][number] = obj_ref
	
func _run():
	var root = get_scene()
	if not root:
		push_error("No open scene to modify.")
		return
	
	for object in root.get_node("ChessBoard").get_children():
		var piece_data = object.name.split("_")
		if object is RigidBody3D:
			var piece_number = 0
			if len(piece_data) == 5:
				piece_number = int(piece_data[3])
			add_piece(piece_data[2], piece_data[1], piece_number, root.get_path_to(object))
	
	root.get_node("ChessGame").pieces = pieces
