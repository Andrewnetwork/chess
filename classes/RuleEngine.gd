class_name RuleEngine
extends Node

const EMPTY_SQUARE = null
const FULL_BOARD = 8
enum {WHITE_STARTING_ROW = 6, BLACK_STARTING_ROW = 1}
# Directional vectors: North, South, North West, etc. 
const N=Vector2i(1,0)
const E=Vector2i(0,1)
const S=-N
const W=-E
const NE = N+E
const SW = S+W
const NW = N+W
const SE = S+E

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
func get_possible_moves(piece: ChessPiece, second_pass:=true) -> Moves:
	var moves := Moves.new()
	if piece == null:
		push_error("Unable to apply rule to %s."%[str(piece)])
	else:
		var rule = RULES[piece.type] as Dictionary
		var movement_axes = rule.movement_axes.duplicate()
		var distance = 1
		var idx = 0
		var move = null
		var opponent_side = ChessPiece.Side.BLACK if piece.color == ChessPiece.Side.WHITE else ChessPiece.Side.WHITE
		var flip = -1 if piece.color == ChessPiece.Side.WHITE  else 1
		
		#== First pass: generate possible moves.
		if rule.has("conditional_moves"):
			if rule.conditional_moves.has("STARTING_ROW"):
				if (piece.color == ChessPiece.Side.WHITE && piece.location.x == WHITE_STARTING_ROW) or (piece.color == ChessPiece.Side.BLACK && piece.location.x == BLACK_STARTING_ROW):
					movement_axes += rule.conditional_moves["STARTING_ROW"]
		# Add moves if this piece can take along a specified axis. 
		if rule.has("take"):
			for take_move in rule.take:
				move = piece.location+take_move*flip
				if is_move_within_board(move) and !is_empty_square(move) and _B(move).color == opponent_side:
					if _B(move).type == ChessPiece.Type.KING:
						moves.to_king.append(move)
					else:
						moves.to_opponent.append(move)
		# Find possible moves along the movement axes. 
		while len(movement_axes) > 0:
			move = piece.location+movement_axes[idx]*distance*flip
			if is_empty_square(move):
				moves.to_empty_square.append(move)
			else:
				if is_move_within_board(move) and _B(move).color == opponent_side and (!rule.has("take") || (rule.has("take") and rule.take.has(movement_axes[idx]))):
					if _B(move).type == ChessPiece.Type.KING:
						moves.to_king.append(move)
					else:
						moves.to_opponent.append(move)
				movement_axes.remove_at(idx)
				idx -= 1
				
			if idx+1 >= len(movement_axes):
				idx = 0
				distance += 1
				if !rule.has("max_distance") || distance > rule.max_distance:
					break
			else:
				idx += 1
		#=== Second pass: prune moves that violate checking rules. 
		# Prune unsafe moves, where king moves into check. 
		if second_pass:
			if piece.type == ChessPiece.Type.KING:
				for possible_move in moves.get_all():
					if !is_square_safe(piece, possible_move):
						moves.remove(possible_move)
						moves.unsafe_moves.append(possible_move)
			# Prune moves if king is in check and the move does not remove the king from check. 
			if game.is_in_check:
				for possible_move in moves.get_all():
					if !move_breaks_check(piece, possible_move):
						moves.remove(possible_move)
						moves.unsafe_moves.append(possible_move)
	return moves
		
## Checks if a game in the state of check is check mate.
func is_check_mate():
	# Super lazy. TODO cleanup
	if game.is_in_check:
		var checked_side = ChessPiece.Side.BLACK if game.checking_piece.color == ChessPiece.Side.WHITE else ChessPiece.Side.WHITE 
		
		for row in game.chess_board:
			for square in row:
				if square != EMPTY_SQUARE and square.color == checked_side:
					if len(get_possible_moves(square).get_all()) > 0:
						return false
		return true
	else:
		return false
	
func move_breaks_check(piece: ChessPiece, move: Vector2i):
	if move == game.checking_piece.location:
		return true
	else:
		# Simulate move. 
		var swap = game.chess_board[move.x][move.y]
		game.chess_board[move.x][move.y] = piece
		game.chess_board[piece.location.x][piece.location.y] = EMPTY_SQUARE
		var res = !get_possible_moves(game.checking_piece, false).is_checking()
		# Restore pieces as they were before the simulated move. 
		game.chess_board[move.x][move.y] = swap	
		game.chess_board[piece.location.x][piece.location.y] = piece
		return res
## Returns true if no opposing piece is attacking the given square.
func is_square_safe(piece: ChessPiece, move: Vector2i)->bool:
	return len(get_threats(piece, move)) == 0
## Gets an array of all the pieces threatening a square. 
func get_threats(piece: ChessPiece, move: Vector2i = piece.location) -> Array[ChessPiece]:
	# Create a dummy piece and place it on the move square. If that 
	# piece threatens a type of its own, then because of the symmetry, 
	# it is also threatened by a piece of that type. We use these dummy pieces 
	# as a threat probe. 
	var threats: Array[ChessPiece]
	var piece_types = ChessPiece.Type.keys()
	# Process king seperately so as to avoid infinite recursion. 
	piece_types.erase("KING")
	for type in piece_types:
		var dummy = ChessPiece.create_dummy(piece.color, ChessPiece.Type[type], move)
		for opp_move in get_possible_moves(dummy, false).to_opponent:
			if _B(opp_move).type == ChessPiece.Type[type]:
				threats.append(_B(opp_move))
	# Check if the square is not in a king's zone of control.
	var opp_side = ChessPiece.Side.BLACK if piece.color == ChessPiece.Side.WHITE else ChessPiece.Side.WHITE
	for piece_within_1 in get_pieces_within_range(move, Vector2i(1,1), opp_side):
		if piece.type == ChessPiece.Type.KING:
			threats.append(piece_within_1)
			break
			
	return threats
func threatens(defender: ChessPiece, attacker: ChessPiece):
	return get_possible_moves(attacker, false).has(defender.location)
#=== Helpers
func get_pieces_within_range(location: Vector2i, loc_range: Vector2i, side = null) -> Array[ChessPiece]:
	var pieces_within_range : Array[ChessPiece]
	for row in range(location.x-loc_range.x, location.x+loc_range.x+1):
		for col in range(location.y-loc_range.y, location.y+loc_range.y+1):
			var loc = Vector2i(row,col)
			if is_move_within_board(loc) and _B(loc) != EMPTY_SQUARE:
				if side != null:
					if _B(loc).color == side:
						pieces_within_range.append(_B(loc))
				else:
					pieces_within_range.append(loc)
	return pieces_within_range
	
func is_empty_square(move: Vector2i):
	return is_move_within_board(move) and _B(move) == EMPTY_SQUARE
func _B(position: Vector2i)->ChessPiece:
	return game.chess_board[position.x][position.y]
func is_move_within_board(move: Vector2i)->bool:
	return move.x >= 0 && move.x <= 7 && move.y >= 0 && move.y <= 7
