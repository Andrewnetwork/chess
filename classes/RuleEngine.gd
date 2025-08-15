class_name RuleEngine
extends Node

const EMPTY_SQUARE = null
const FULL_BOARD = 8
enum {WHITE_STARTING_ROW = 6, BLACK_STARTING_ROW = 1}
# Directional vectors: North, South, North West, etc. 
const N=Vector2i(1,0)
const S=-N
const E=Vector2i(0,1)
const W=-E
const NE = Vector2i(1,1)
const SW = -NE
const NW = Vector2i(1,-1)
const SE = -NW

var game: ChessGame

## A high-level description of the rules of chess.[br]
## [param basis_vectors]: TODO document
const RULES = { 
	ChessPiece.Type.KING:{
		"movement_axes": [N,S,E,W,NE,NW,SW,SE]
	},
	ChessPiece.Type.QUEEN:{
		"movement_axes": [N,S,E,W,NE,NW,SW,SE],
		"max_distance": FULL_BOARD
	},
	ChessPiece.Type.PAWN:{
		"movement_axes": [N],
		"take": [NW, NE],
		"conditional_moves": {"STARTING_ROW": [N*2]}
	},
	ChessPiece.Type.ROOK:{
		"movement_axes": [N,S,E,W],
		"max_distance": FULL_BOARD
	},
	ChessPiece.Type.BISHOP:{
		"movement_axes": [NW,NE,SW,SE],
		"max_distance": FULL_BOARD
	},
	ChessPiece.Type.KNIGHT:{
		"movement_axes": [N*2+E, N*2+W, S*2+E, S*2+W, W*2+N, W*2+S, E*2+N, E*2+S]
	}
}
#=== Overloaded Functions
func _init(parent_game: ChessGame):
	game = parent_game

#=== Main Functions
## Returns the possible moves for a given chess piece. 
func get_possible_moves(piece: ChessPiece)->Array[Vector2i]:
	var moves : Array[Vector2i]
	if piece == null || !RULES.has(piece.type):
		push_error("Unable to apply rule to %s."%[str(piece)])
	else:
		var rule = RULES[piece.type] as Dictionary
		var movement_axes = rule.movement_axes.duplicate()
		var distance = 1
		var idx = 0
		var move = null
		var opponent_side = ChessPiece.Side.BLACK if piece.color == ChessPiece.Side.WHITE else ChessPiece.Side.WHITE
		var flip = -1 if piece.color == ChessPiece.Side.WHITE  else 1
		
		# Add moves if certain conditions are met. TODO cleanup.
		if rule.has("conditional_moves"):
			if rule.conditional_moves.has("STARTING_ROW"):
				if (piece.color == ChessPiece.Side.WHITE && piece.location.x == WHITE_STARTING_ROW) or (piece.color == ChessPiece.Side.BLACK && piece.location.x == BLACK_STARTING_ROW):
					movement_axes += rule.conditional_moves["STARTING_ROW"]
		# Add moves if this piece can take along a specified axis. 
		if rule.has("take"):
			for take_move in rule.take:
				move = piece.location+take_move*flip
				if is_move_within_board(move) and !is_empty_square(move) and _B(game.chess_board, move).color == opponent_side:
					moves.append(move)
		# Find possible moves along the movement axes. 
		while len(movement_axes) > 0:
			move = piece.location+movement_axes[idx]*distance*flip
			if is_empty_square(move):
				moves.append(move)
			else:
				if is_move_within_board(move) and _B(game.chess_board, move).color == opponent_side and (!rule.has("take") || (rule.has("take") and rule.take.has(movement_axes[idx]))):
					moves.append(move)
				movement_axes.remove_at(idx)
				idx -= 1
				
			if idx+1 >= len(movement_axes):
				idx = 0
				distance += 1
				if !rule.has("max_distance") || distance > rule.max_distance:
					break
			else:
				idx += 1
	return moves

#=== Helpers
func is_empty_square(move: Vector2i):
	return is_move_within_board(move) and _B(game.chess_board, move) == EMPTY_SQUARE
func _apply_filter(basis_vectors: Array, piece:ChessPiece, filter_name: String):
	var out: Array[Vector2i]
	var filter := Callable(self, filter_name)
	for basis_vector in basis_vectors:
		var filter_res = filter.call(piece, basis_vector)
		if filter_res != null:
			out.append(filter_res)
	return out
	
func _B(board: Array[Array], position: Vector2i):
	return board[position.x][position.y]
	
func is_move_within_board(move: Vector2i)->bool:
	return move.x >= 0 && move.x <= 7 && move.y >= 0 && move.y <= 7
