class_name ChessPiece
extends Node

enum PieceColor {WHITE, BLACK}
const color_str = ["white", "black"]
enum PieceType {ROOK, KNIGHT, BISHOP, QUEEN, KING, PAWN}
const type_str = ["rook","knight","bishop","queen","king","pawn"]

var color: PieceColor
var type: PieceType 
var location: Vector2i
var obj_ref: RigidBody3D

func _init(piece_color: PieceColor, piece_type: PieceType, piece_location: Vector2i, piece_obj_ref: RigidBody3D):
	color = piece_color
	type = piece_type
	location = piece_location
	obj_ref = piece_obj_ref
