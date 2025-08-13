class_name ChessGame
extends Node
## The controller/model for the game. 

@export var pieces := {"white": {}, "black": {}}

func add_piece(color: String, piece: String, number: int, obj_ref: PhysicsBody3D):
	if !pieces[color].has(piece):
		pieces[color][piece] = {}
	pieces[color][piece][number] = obj_ref
	
