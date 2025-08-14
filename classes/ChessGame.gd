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
@export var pieces := {"white": {}, "black": {}}
@export var first_square_marker: Marker3D
@export var second_square_marker: Marker3D
@export var move_marker: PackedScene
@export var board: Node3D
var chess_board: Array[Array]
var move_markers: Array[StaticBody3D]
var active_piece: ChessPiece

func get_available_moves(piece: ChessPiece):
	var moves = []
	var move = null
	if piece.type == ChessPiece.PieceType.PAWN:
		if piece.color == ChessPiece.PieceColor.WHITE:
			move = piece.location-Vector2i(1,0)
			if BOARD(move) == EMPTY_SQUARE:
				# One forward.
				moves.append(move)
				
			move = piece.location-Vector2i(2,0)
			if piece.location.x == WHITE_STARTING_ROW and BOARD(move) == null:
				# Two forward, from starting row.
				moves.append(move)
		else:
			# BLACK
			move = piece.location+Vector2i(1,0)
			if BOARD(move) == EMPTY_SQUARE:
				# One forward.
				moves.append(move)
				
			move = piece.location+Vector2i(2,0)
			if piece.location.x == BLACK_STARTING_ROW and BOARD(move) == null:
				# Two forward, from starting row.
				moves.append(move)
	return moves
			
			
			
		
			
func piece_clicked(piece: ChessPiece):
	active_piece = piece
	display_available_moves(piece)
func finish_move():
	clear_move_markers()
	active_piece = null
func clear_move_markers():
	for placed_move_marker in move_markers:
		placed_move_marker.queue_free()
	move_markers.clear()
## Gets the phyiscal location of the chess piece on the 3D board. 
func get_cell_center(location: Vector2)->Vector3:
	# TODO: Fix this hack
	var offset = abs(second_square_marker.position-first_square_marker.position).x
	return Vector3((7-location.y)*offset,0,(7-location.x)*offset)+first_square_marker.position

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
						piece.obj_ref.position.x = marker.position.x
						piece.obj_ref.position.z = marker.position.z
						piece.location = move
						finish_move())
		board.add_child(marker)
		move_markers.append(marker)
	
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
				BR: piece_color = ChessPiece.PieceColor.BLACK; piece_type = ChessPiece.PieceType.ROOK
				BN: piece_color = ChessPiece.PieceColor.BLACK; piece_type = ChessPiece.PieceType.KNIGHT
				BB: piece_color = ChessPiece.PieceColor.BLACK; piece_type = ChessPiece.PieceType.BISHOP
				BQ: piece_color = ChessPiece.PieceColor.BLACK; piece_type = ChessPiece.PieceType.QUEEN
				BK: piece_color = ChessPiece.PieceColor.BLACK; piece_type = ChessPiece.PieceType.KING
				BP: piece_color = ChessPiece.PieceColor.BLACK; piece_type = ChessPiece.PieceType.PAWN
				WR: piece_color = ChessPiece.PieceColor.WHITE; piece_type = ChessPiece.PieceType.ROOK
				WN: piece_color = ChessPiece.PieceColor.WHITE; piece_type = ChessPiece.PieceType.KNIGHT
				WB: piece_color = ChessPiece.PieceColor.WHITE; piece_type = ChessPiece.PieceType.BISHOP
				WQ: piece_color = ChessPiece.PieceColor.WHITE; piece_type = ChessPiece.PieceType.QUEEN
				WK: piece_color = ChessPiece.PieceColor.WHITE; piece_type = ChessPiece.PieceType.KING
				WP: piece_color = ChessPiece.PieceColor.WHITE; piece_type = ChessPiece.PieceType.PAWN
			
			if piece_type != null and piece_color != null:
				make_piece(row, col, piece_color, piece_type, counters[layout_flag])
func make_piece(row: int,col: int, color: ChessPiece.PieceColor, type: ChessPiece.PieceType, number: int):
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
func BOARD(location: Vector2i):
	return chess_board[location.x][location.y]
func get_physical_piece(color: String, piece: String, number: int) -> RigidBody3D:
	return get_node(pieces[color][piece][number])
