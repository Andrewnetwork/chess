@tool
extends EditorScript
## Tests for the rule engine. 
var rook_test = {"basis_vectors": [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1), Vector2i(0,-1)], 
	"max_distance": -1}

func _run():
	var chess_game = ChessGame.new()
	print(chess_game.board)
	print("HI")
