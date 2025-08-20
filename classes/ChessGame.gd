class_name ChessGame
extends Node
## A chess game in 3D. 

#=== Enums and Constants
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
	[WR, WN, WB, WQ, WK, WB, WN, WR]] #7
	#0   1   2   3   4   5   6   7
#=== Exports
@export_group("Gameplay")
## Turn on to rotate the board before starting a turn.
@export var turn_rotation = true
@export_group("Scene Components")
@export var pieces := {"white": {}, "black": {}}
@export var first_square_marker: Marker3D
@export var second_square_marker: Marker3D
@export var animation_player: AnimationPlayer

@export var white_king_camera: Camera3D
@export var black_king_camera: Camera3D
@export var board: Node3D
@export var sfx_player: AudioStreamPlayer
@export_subgroup("Visuals")
@export var checking_adornment: PackedScene
@export var move_marker: PackedScene
@export var unsafe_move_marker: PackedScene
@export_subgroup("UI")
@export var pawn_promotion_screen: PackedScene
@export var black_win_screen: ColorRect
@export var white_win_screen: ColorRect
## Reference to the physical model of the chess board. 

@export_group("Sound Effects")
@export var piece_move_sound: AudioStream = preload("res://sound/piece_move.mp3")
#=== Game State
## Matrix representing the logical model of the chess board. 
var chess_board: Array[Array]
var is_in_check := false
var turn_owner := ChessPiece.Side.WHITE
var active_piece: ChessPiece
var white_king: ChessPiece
var black_king: ChessPiece
#=== Rule Engine
var rule_engine = RuleEngine.new(self)
#=== UI Properties
var move_markers: Array[StaticBody3D]
var check_adornments : Array[StaticBody3D]
#=== UI
## Displays available moves for the given piece by placing clickable MoveMarker's 
## on the chess board.
func display_available_moves(piece: ChessPiece):
	clear_move_markers()
	var moves = rule_engine.get_possible_moves(piece)
	for move in moves.get_all():
		var marker := move_marker.instantiate() as StaticBody3D
		marker.position = get_cell_center(move)
		marker.input_event.connect(
			func (_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int): 
				if event is InputEventMouseButton:
					if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
						move_piece(piece, move))
		board.add_child(marker)
		move_markers.append(marker)
		
	for unsafe_move in moves.unsafe_moves:
		#TODO: clean up
		var unsafe_marker := unsafe_move_marker.instantiate() as StaticBody3D
		unsafe_marker.position = get_cell_center(unsafe_move)
		board.add_child(unsafe_marker)
		move_markers.append(unsafe_marker)
func clear_check_display():
	for check_adornment in check_adornments:
		board.remove_child(check_adornment)
		check_adornment.queue_free()
	check_adornments.clear()
func clear_move_markers():
	for placed_move_marker in move_markers:
		placed_move_marker.queue_free()
	move_markers.clear()
func adorn_checking_pieces(checking_piece_location):
	var adornment := checking_adornment.instantiate() as StaticBody3D
	adornment.position = get_cell_center(checking_piece_location)
	board.add_child(adornment)
	check_adornments.append(adornment)
#=== Game loop
## The main function of the game loop. Called when a player clicks on a 
## valid move displayed via [code]display_available_moves()[/code].
func move_piece(piece: ChessPiece, new_location: Vector2i) -> bool:
	var target_square = chess_board[new_location.x][new_location.y]
	if target_square != EMPTY_SQUARE:
		if target_square.color != piece.color:
			# Attack. 
			target_square.eliminate()
		else:
			push_error("Moving a piece onto a pre-existing piece.")
			return false
	# Play sound.
	sfx_player.stream = piece_move_sound
	sfx_player.play()
	# Update logical model of chess board. 
	chess_board[piece.location.x][piece.location.y] = EMPTY_SQUARE
	chess_board[new_location.x][new_location.y] = piece
	# Update piece location.
	piece.location = new_location
	# Update physical model of chess board.
	var new_pos = get_cell_center(new_location)
	piece.obj_ref.position.x = new_pos.x
	piece.obj_ref.position.z = new_pos.z
	# Pawn promtion. 
	if piece.type == ChessPiece.Type.PAWN && ((piece.color == ChessPiece.Side.WHITE && piece.location.x == 0) || 
		(piece.color == ChessPiece.Side.BLACK && piece.location.x == 7)):
		piece.promote(await promote_pawn(piece))
	# Checking logic.
	if is_in_check:
		#Moved out of check.
		is_in_check = false
		clear_check_display()
	# Check if this move puts the opposing king in check.
	var threats_to_king := threats_to_opposing_king()
	if len(threats_to_king) > 0:
		is_in_check = true
		if rule_engine.is_check_mate():
			check_mate()
			clear_move_markers()
			active_piece = null
			return true
		else:
			animation_player.play("check")
			for threat in threats_to_king:
				adorn_checking_pieces(threat.location)
	# Cleanup 
	clear_move_markers()
	active_piece = null
	# Start new turn.
	start_next_turn()
	return true
func start_next_turn():
	if turn_owner == ChessPiece.Side.WHITE:
		turn_owner = ChessPiece.Side.BLACK
	else:
		turn_owner = ChessPiece.Side.WHITE
	var tween = create_tween()
	tween.tween_property(board, "rotation_degrees:y", 
		board.rotation_degrees.y-180, 2 ).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
func promote_pawn(piece: ChessPiece) -> ChessPiece.Type:
	var pawn_promotion = pawn_promotion_screen.instantiate() as PawnPromotionScreen
	pawn_promotion.color = piece.color
	board.add_child(pawn_promotion)
	return await pawn_promotion.promotion_selected
func check_mate():
	if turn_owner == ChessPiece.Side.WHITE:
		white_king_camera.current = true
		white_win_screen.visible = true
	else:
		black_king_camera.current = true
		black_win_screen.visible = true
#=== Event handling
func piece_clicked(piece: ChessPiece):
	if piece.color == turn_owner:
		active_piece = piece
		display_available_moves(piece)
#=== Setup 
func _init():
	setup_board(classic_piece_layout)
func _ready():
	_establish_physical_connection()
## Establishes a connection between the logical model of chess and its physical representation
## in the game.
func _establish_physical_connection():
	for row in chess_board:
		for cell in row:
			if cell is ChessPiece:
				cell.obj_ref = get_physical_piece(cell.get_color_str(), cell.get_type_str(), cell.get_id())
				cell.obj_ref.input_event.connect(
					func (_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int): 
						if event is InputEventMouseButton:
							if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
								piece_clicked(cell))
func setup_board(piece_layout: Array):
	# Initialize chess board.
	chess_board.clear()
	for col in range(8):
		var row = []
		row.resize(8)
		chess_board.append(row)
	# Add pieces according to the piece_layout.
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
				chess_board[row][col] = ChessPiece.new(piece_color,piece_type, 
					Vector2i(row, col), counters[layout_flag], null)
				if piece_type == ChessPiece.Type.KING:
					match piece_color:
						ChessPiece.Side.WHITE: white_king = chess_board[row][col]
						ChessPiece.Side.BLACK: black_king = chess_board[row][col]
func get_physical_piece(color: String, piece: String, number: int) -> RigidBody3D:
	return get_node(pieces[color][piece][number])
## Gets the phyiscal location of the chess piece on the 3D board. 
func get_cell_center(location: Vector2) -> Vector3:
	# TODO: Fix this hack
	var offset = abs(second_square_marker.position-first_square_marker.position).x
	return Vector3((7-location.y)*offset,0,(7-location.x)*offset)+first_square_marker.position
#=== Overloaded
func _to_string() -> String:
	var out_str := ""
	var flip = true
	var row_cntr = 0
	for row in chess_board:
		out_str += "%s: "%[row_cntr]
		for col in row:
			if col == null:
				out_str += "  □  " if flip else "  ■  "
			else: 
				out_str += "  %s "%[col.unicode_icon()]
			flip = !flip
		
		row_cntr += 1
		flip = !flip
		out_str += "\n"
	out_str += "     0    1    2    3    4    5    6    7 "
	return out_str
#=== Helpers
func threats_to_opposing_king() -> Array[ChessPiece]:
	var res: Array[ChessPiece]
	match turn_owner:
		ChessPiece.Side.BLACK: return rule_engine.get_threats(white_king)
		ChessPiece.Side.WHITE: return rule_engine.get_threats(black_king)
	return res
