class_name Moves
extends Node

var to_empty_square: Array[Vector2i]
var to_opponent: Array[Vector2i] 
var to_king: Array[Vector2i]
## Used only for kings. 
var unsafe_moves: Array[Vector2i]
	
func get_all():
	return to_empty_square+to_opponent+to_king
# Returns true if there is a move that puts the to_king in check. 
func is_checking():
	return !to_king.is_empty()
func has(move: Vector2i):
	return to_empty_square.has(move) || to_opponent.has(move) || to_king.has(move)
func remove(move: Vector2i):
	to_empty_square.erase(move)
	to_opponent.erase(move)
	to_king.erase(move)
