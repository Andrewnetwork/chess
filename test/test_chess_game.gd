@tool
extends EditorScript

enum {E, BR, BN, BB, BQ, BK, BP, WR, WN, WB, WQ, WK, WP}
const test_layout = [
	[E,  E,  E,  E,  E,  E,  E,  E ], #0
	[E,  E,  E,  E,  E,  E,  E,  E ], #1
	[E,  E,  E,  E,  E,  E,  E,  E ], #2 
	[E,  E,  E,  E,  E,  E,  E,  E ], #3 
	[E,  E,  E,  E,  WK, E,  E,  E ], #4
	[E,  E,  E,  E,  E,  E,  E,  E ], #5
	[E,  E,  E,  E,  E,  E,  E,  E ], #6
	[E,  E,  E,  E,  E,  E,  E,  E ], #7
   # 0   1   2   3   4   5   6   7
]
func _run():
	initilization_test()
	custom_layout_test()

	
func custom_layout_test():
	var chess_game = ChessGame.new()
	chess_game.setup_board(test_layout)
	assert(chess_game.chess_board[4][4] is ChessPiece, "Custom layout was not set up properly.")
	assert(chess_game.chess_board[4][4].type == ChessPiece.Type.KING, "Custom layout was corrupted in setup")
	print("✅Passed custom layout test.")
	
func initilization_test():
	var chess_game = ChessGame.new()
	assert(chess_game.chess_board[0][0] is ChessPiece, "Failed initialization test.")
	print("✅Passed initialization test.")
