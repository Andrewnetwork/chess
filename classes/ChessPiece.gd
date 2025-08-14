class_name ChessPiece
extends Node

enum Side {WHITE, BLACK}
const color_str = ["white", "black"]
enum Type {ROOK, KNIGHT, BISHOP, QUEEN, KING, PAWN}
const type_str = ["rook","knight","bishop","queen","king","pawn"]

var color: ChessPiece.Side
var type: Type
var location: Vector2i
var piece_count_id: int
var obj_ref: RigidBody3D

func _init(piece_color: ChessPiece.Side, piece_type: Type, piece_location: Vector2i, id: int, piece_obj_ref: RigidBody3D):
	color = piece_color
	type = piece_type
	location = piece_location
	piece_count_id = id
	obj_ref = piece_obj_ref
func get_color_str()->String:
	return color_str[color]
func get_type_str()->String:
	return type_str[type]
func get_id()->int:
	return piece_count_id
func eliminate():
	obj_ref.queue_free()
	queue_free()
