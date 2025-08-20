class_name Piece3D
extends Node3D

@export var color: ChessPiece.Side
@export var type: ChessPiece.Type

var active_piece = null
var world_env := WorldEnvironment.new()

func _init() -> void:
	var env = Environment.new()
	add_child(world_env)
	world_env.environment = env 
	world_env.environment.background_mode = Environment.BG_COLOR
	
func _ready():
	select(color, type)
	
func select(piece_color: ChessPiece.Side, piece_type: ChessPiece.Type) -> RigidBody3D:
	$AnimationPlayer.play("piece_preview")
	if active_piece != null:
		active_piece.visible = false
	color = piece_color
	type = piece_type 
	match color:
		ChessPiece.Side.WHITE:
			world_env.environment.background_color = Color.BLACK
			match type:
				ChessPiece.Type.PAWN:
					$White/Pawn.visible = true
					active_piece = $White/Pawn
					return $White/Pawn.duplicate()
				ChessPiece.Type.QUEEN:
					$White/Queen.visible = true;
					active_piece = $White/Queen
					return $White/Queen.duplicate()
				ChessPiece.Type.ROOK:
					$White/Rook.visible = true;
					active_piece = $White/Rook
					return $White/Rook.duplicate()
				ChessPiece.Type.BISHOP:
					$White/Bishop.visible = true;
					active_piece = $White/Bishop
					return $White/Bishop.duplicate()
				ChessPiece.Type.KNIGHT:
					$White/Knight.visible = true;
					active_piece = $White/Knight
					return $White/Knight.duplicate()
		ChessPiece.Side.BLACK:
			world_env.environment.background_color = Color.WHITE
			match type:
				ChessPiece.Type.PAWN:
					$Black/Pawn.visible = true;
					active_piece = $Black/Pawn
					return $Black/Pawn.duplicate()
				ChessPiece.Type.QUEEN:
					$Black/Queen.visible = true;
					active_piece = $Black/Queen
					return $Black/Queen.duplicate()
				ChessPiece.Type.ROOK:
					$Black/Rook.visible = true;
					active_piece = $Black/Rook
					return $Black/Rook.duplicate()
				ChessPiece.Type.BISHOP:
					$Black/Bishop.visible = true;
					active_piece = $Black/Bishop
					return $Black/Bishop.duplicate()
				ChessPiece.Type.KNIGHT:
					$Black/Knight.visible = true;
					active_piece = $Black/Knight
					return $Black/Knight.duplicate()
					
	push_error("Error in selecting piece.")
	return $Black/Pawn
		
		
