class_name ChessGame
extends Node
## The controller/model for the game. 

enum {E, BR, BN, BB, BQ, BK, BP, WR, WN, WB, WQ, WK, WP}
enum {WHITE_STARTING_ROW = 6, BLACK_STARTING_ROW = 1}
const EMPTY_SQUARE = null
const classic_piece_layout = [
	[BR, BN, BB, BQ, BK, BB, BN, BR], #0
	[BP, BP, BP, BP, BP, BP, BP, BP], #1
	[E,  E,  E,  E,  E,  E,  E,  E ], #2 
	[E,  E,  E,  E,  E,  E,  E,  E ], #3 
	[E,  E,  E,  E,  E,  E,  E,  E ], #4
	[E,  E,  E,  E,  E,  E,  E,  E ], #5
	[WP, WP, WP, WP, WP, WP, WP, WP], #6
	[WR, WN, WB, WQ, WK, WB, WN, WR], #7
]

@export_group("Gameplay")
## Turn on to rotate the board before starting a turn.
@export var turn_rotation = true
@export_group("Visual Components")
@export var pieces := {"white": {}, "black": {}}
@export var first_square_marker: Marker3D
@export var second_square_marker: Marker3D
@export var move_marker: PackedScene
@export var board: Node3D

var chess_board: Array[Array]
var move_markers: Array[StaticBody3D]
var active_piece: ChessPiece
var turn_owner := ChessPiece.Side.WHITE

func get_available_moves(piece: ChessPiece) -> Array[Vector2i]:
	# Initialize output array and temp move variable.
	var moves : Array[Vector2i]
	var move = null
	# Rule parameters.
	var flip = -1 if piece.color == ChessPiece.Side.WHITE else 1 
	var starting_row = WHITE_STARTING_ROW if piece.color == ChessPiece.Side.WHITE else BLACK_STARTING_ROW
	var opponent_side = ChessPiece.Side.BLACK if piece.color == ChessPiece.Side.WHITE else ChessPiece.Side.WHITE
	# Move logic.
	# TODO: this should be condensed. The movement constraints on the pieces should be represented
	# at a higher level.
	match piece.type:
		ChessPiece.Type.PAWN: 
			# One forward.
			move = piece.location+Vector2i(1,0)*flip
			if is_move_within_board(move) and BOARD(move) == EMPTY_SQUARE:
				moves.append(move)
				# Two forward, from starting row.
				move = piece.location+Vector2i(2,0)*flip
				if is_move_within_board(move) and piece.location.x == starting_row and BOARD(move) == EMPTY_SQUARE:
					moves.append(move)
			# Left diagonal.
			move = piece.location+Vector2i(1,1)*flip
			if is_move_within_board(move) and BOARD(move) != EMPTY_SQUARE and BOARD(move).color == opponent_side:
				moves.append(move)
			# Right diagonal.
			move = piece.location+Vector2i(1,-1)*flip
			if is_move_within_board(move) and BOARD(move) != EMPTY_SQUARE and BOARD(move).color == opponent_side:
				moves.append(move)
		ChessPiece.Type.ROOK:
			var basis_vectors = [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1), Vector2i(0,-1)]
			var locations = []
			locations.resize(4)
			locations.fill(piece.location)
		
			var idx = 0
			while len(basis_vectors) > 0:
				locations[idx] += basis_vectors[idx]
				if is_move_within_board(locations[idx]):
					if BOARD(locations[idx]) == EMPTY_SQUARE:
						moves.append(locations[idx])
					elif BOARD(locations[idx]).color == opponent_side:
						moves.append(locations[idx])
						# Done searching in this direction.
						basis_vectors.remove_at(idx)
						locations.remove_at(idx)
						# Removing an element shrinks the array, push the index back by one. 
						idx -= 1
					else:
						# Hit a friendly piece. 
						basis_vectors.remove_at(idx)
						locations.remove_at(idx)
						# Removing an element shrinks the array, push the index back by one. 
						idx -= 1
				else:
					# Out of bounds.
					basis_vectors.remove_at(idx)
					locations.remove_at(idx)
				if idx+1 >= len(basis_vectors):
					# Loop around until all baisis vectors have led to dead ends.
					idx = 0
				else:
					idx += 1
		ChessPiece.Type.KNIGHT:
			var knight_basis_vectors = [Vector2i(2,1), Vector2i(2,-1), Vector2i(1,2), Vector2i(1,-2)]
			knight_basis_vectors.append_array(knight_basis_vectors.map(func(basis_vector): return basis_vector*-1))
			for knight_basis_vector in knight_basis_vectors:
				move = piece.location+knight_basis_vector
				if is_move_within_board(move) and (BOARD(move) == EMPTY_SQUARE || BOARD(move).color == opponent_side):
					moves.append(move)
		ChessPiece.Type.BISHOP:
			var bishop_basis_vectors = [Vector2i(1,1),Vector2i(1,-1)]
			bishop_basis_vectors.append_array(bishop_basis_vectors.map(func(basis_vector): return basis_vector*-1))
			var distance = 1
			var idx = 0
			while len(bishop_basis_vectors) > 0:
				move = piece.location+bishop_basis_vectors[idx]*distance
				if is_move_within_board(move) and BOARD(move) == EMPTY_SQUARE:
					moves.append(move)
				else:
					if is_move_within_board(move) and BOARD(move).color == opponent_side:
						moves.append(move)
					bishop_basis_vectors.remove_at(idx)
					idx -= 1
					
				if idx+1 >= len(bishop_basis_vectors):
					idx = 0
					distance += 1
				else:
					idx += 1
		ChessPiece.Type.QUEEN:
			var rook_basis_vectors = [Vector2i(1,0),Vector2i(0,1),Vector2i(1,0)*-1,Vector2i(0,1)*-1]
			var bishop_basis_vectors = [Vector2i(1,1),Vector2i(1,-1),Vector2i(1,1)*-1,Vector2i(1,-1)*-1]
			var queen_basis_vectors = bishop_basis_vectors + rook_basis_vectors
			
			var distance = 1
			var idx = 0
			while len(queen_basis_vectors) > 0:
				move = piece.location+queen_basis_vectors[idx]*distance
				if is_move_within_board(move) and BOARD(move) == EMPTY_SQUARE:
					moves.append(move)
				else:
					if is_move_within_board(move) and BOARD(move).color == opponent_side:
						moves.append(move)
					queen_basis_vectors.remove_at(idx)
					idx -= 1
					
				if idx+1 >= len(queen_basis_vectors):
					idx = 0
					distance += 1
				else:
					idx += 1
		ChessPiece.Type.KING:
			var king_basis_vectors = [Vector2i(1,0), Vector2i(0,1),Vector2i(1,-1), Vector2i(1,1)]
			king_basis_vectors.append_array(king_basis_vectors.map(func(basis_vector): return basis_vector*-1))
			for king_basis_vector in king_basis_vectors:
				move = piece.location+king_basis_vector
				if is_move_within_board(move) and (BOARD(move) == EMPTY_SQUARE || BOARD(move).color == opponent_side):
					moves.append(move)
	return moves
func piece_clicked(piece: ChessPiece):
	if piece.color == turn_owner:
		active_piece = piece
		display_available_moves(piece)
func clear_move_markers():
	for placed_move_marker in move_markers:
		placed_move_marker.queue_free()
	move_markers.clear()
## Gets the phyiscal location of the chess piece on the 3D board. 
func get_cell_center(location: Vector2)->Vector3:
	# TODO: Fix this hack
	var offset = abs(second_square_marker.position-first_square_marker.position).x
	return Vector3((7-location.y)*offset,0,(7-location.x)*offset)+first_square_marker.position
func start_next_turn():
	if turn_owner == ChessPiece.Side.WHITE:
		turn_owner = ChessPiece.Side.BLACK
	else:
		turn_owner = ChessPiece.Side.WHITE
	var tween = create_tween()
	tween.tween_property(board, "rotation_degrees:y", 
		board.rotation_degrees.y-180, 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	#board.rotate_y(deg_to_rad(180))
## Displays available moves for the given piece by placing clickable MoveMarker's 
## on the chess board.
func display_available_moves(piece: ChessPiece):
	clear_move_markers()
	
	for move in get_available_moves(piece):
		var marker := move_marker.instantiate() as StaticBody3D
		marker.position = get_cell_center(move)
		marker.input_event.connect(
			func (_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int): 
				if event is InputEventMouseButton:
					if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
						move_piece(piece, move))
		board.add_child(marker)
		move_markers.append(marker)
func move_piece(piece: ChessPiece, new_location: Vector2i) -> bool:
	var target_square = chess_board[new_location.x][new_location.y]
	if target_square != EMPTY_SQUARE:
		if target_square.color != piece.color:
			# Attack. 
			target_square.eliminate()
		else:
			push_error("Moving a piece onto a pre-existing piece.")
			return false
	# Update logical model of chess board. 
	chess_board[piece.location.x][piece.location.y] = EMPTY_SQUARE
	chess_board[new_location.x][new_location.y] = piece
	# Update piece location.
	piece.location = new_location
	# Update physical model of chess board.
	var new_pos = get_cell_center(new_location)
	piece.obj_ref.position.x = new_pos.x
	piece.obj_ref.position.z = new_pos.z
	# Cleanup 
	clear_move_markers()
	active_piece = null
	# Start new turn.
	start_next_turn()
	return true
# Setup 
func _init():
	for col in range(8):
		var row = []
		row.resize(8)
		chess_board.append(row)
func _ready():
	setup_board(classic_piece_layout)
func setup_board(piece_layout: Array):
	var counters = {}
	for row in range(8):
		for col in range(8):
			var piece_color = null
			var piece_type = null
			var layout_flag = piece_layout[row][col]
			
			if counters.has(layout_flag):
				counters[layout_flag] += 1
			else:
				if layout_flag == BK || layout_flag == BQ || layout_flag == WQ || layout_flag == WK:
					# WARNING: This weirdness is do the the accidental numbering of the unique pieces
					# from zero and the others from one.
					counters[layout_flag] = 0
				else:
					counters[layout_flag] = 1
			
			match layout_flag:
				BR: piece_color = ChessPiece.Side.BLACK; piece_type = ChessPiece.Type.ROOK
				BN: piece_color = ChessPiece.Side.BLACK; piece_type = ChessPiece.Type.KNIGHT
				BB: piece_color = ChessPiece.Side.BLACK; piece_type = ChessPiece.Type.BISHOP
				BQ: piece_color = ChessPiece.Side.BLACK; piece_type = ChessPiece.Type.QUEEN
				BK: piece_color = ChessPiece.Side.BLACK; piece_type = ChessPiece.Type.KING
				BP: piece_color = ChessPiece.Side.BLACK; piece_type = ChessPiece.Type.PAWN
				WR: piece_color = ChessPiece.Side.WHITE; piece_type = ChessPiece.Type.ROOK
				WN: piece_color = ChessPiece.Side.WHITE; piece_type = ChessPiece.Type.KNIGHT
				WB: piece_color = ChessPiece.Side.WHITE; piece_type = ChessPiece.Type.BISHOP
				WQ: piece_color = ChessPiece.Side.WHITE; piece_type = ChessPiece.Type.QUEEN
				WK: piece_color = ChessPiece.Side.WHITE; piece_type = ChessPiece.Type.KING
				WP: piece_color = ChessPiece.Side.WHITE; piece_type = ChessPiece.Type.PAWN
			
			if piece_type != null and piece_color != null:
				make_piece(row, col, piece_color, piece_type, counters[layout_flag])
func make_piece(row: int,col: int, color: ChessPiece.Side, type: ChessPiece.Type, number: int):
	# TODO: these arrays accompany the ChessPiece enums. Put them in a better place.
	var piece_ref := get_physical_piece(ChessPiece.color_str[color], ChessPiece.type_str[type], number)
	var piece = ChessPiece.new(color, type, Vector2i(row, col), piece_ref)
	piece_ref.input_event.connect(
		func (_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int): 
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					piece_clicked(piece))
	chess_board[row][col] = piece 
func CB(letter: String, num: int):
	return chess_board[letter[0].to_ascii_buffer()[0]-65][num-1]
func is_move_within_board(move: Vector2i):
	return move.x >= 0 && move.x <= 7 && move.y >= 0 && move.y <= 7
func BOARD(location: Vector2i) -> ChessPiece:
	return chess_board[location.x][location.y]
func get_physical_piece(color: String, piece: String, number: int) -> RigidBody3D:
	return get_node(pieces[color][piece][number])
