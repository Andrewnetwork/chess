class_name Moves
extends Node

var to_empty_square: Array[Vector2i]
var to_opponent: Array[Vector2i] 
var to_king: Array[Vector2i]
## Moves that put the king in or leave the king in check. 
var unsafe_moves: Array[Vector2i]

func to_opponent_piece() -> Array[Vector2i]:
	return to_opponent + to_king
func get_all() -> Array[Vector2i]:
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

func _to_string() -> String:
	var out_str := ""
	out_str+="To empty square: "
	out_str += str(to_empty_square) + "\n"
	out_str+="To opponent: "
	out_str += str(to_opponent) + "\n"
	out_str+="To king: "
	out_str += str(to_king) + "\n"
	return out_str
