@tool
extends EditorScript

func _run():
	var chess_game = ChessGame.new()
	print(chess_game.chess_board)
