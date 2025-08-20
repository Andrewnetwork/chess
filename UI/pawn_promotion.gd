class_name PawnPromotionScreen
extends Control

signal promotion_selected(piece: ChessPiece)

@export var color : ChessPiece.Side : set = change_color
var pice_previews: Array[Piece3D]

func _ready():
	update_viewports()
	
func _queen_clicked():
	emit_signal("promotion_selected", ChessPiece.Type.QUEEN)
	self.queue_free()
func _bishop_clicked():
	emit_signal("promotion_selected", ChessPiece.Type.BISHOP)
	self.queue_free()
func _rook_clicked():
	emit_signal("promotion_selected", ChessPiece.Type.ROOK)
	self.queue_free()
func _knight_clicked():
	emit_signal("promotion_selected", ChessPiece.Type.KNIGHT)
	self.queue_free()

func update_viewports():
	if is_node_ready():
		for p in pice_previews:
			p.queue_free()
				
		var queen = preload("res://objects/Piece.tscn").instantiate() as Piece3D
		queen.select(color, ChessPiece.Type.QUEEN)
		$HBoxContainer/QueenButton/SubViewport.add_child(queen)
		pice_previews.append(queen)
		
		var rook = preload("res://objects/Piece.tscn").instantiate() as Piece3D
		rook.select(color, ChessPiece.Type.ROOK)
		$HBoxContainer/RookButton/SubViewport.add_child(rook)
		pice_previews.append(rook)
		
		var bishop = preload("res://objects/Piece.tscn").instantiate() as Piece3D
		bishop.select(color, ChessPiece.Type.BISHOP)
		$HBoxContainer/BishopButton/SubViewport.add_child(bishop)
		pice_previews.append(bishop)
		
		var knight = preload("res://objects/Piece.tscn").instantiate() as Piece3D
		knight.select(color, ChessPiece.Type.KNIGHT)
		$HBoxContainer/KnightButton/SubViewport.add_child(knight)
		pice_previews.append(knight)
		
func change_color(new_color: ChessPiece.Side):
	color = new_color
	update_viewports()
