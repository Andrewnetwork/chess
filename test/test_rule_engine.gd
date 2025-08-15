@tool
extends EditorScript

enum {E, BR, BN, BB, BQ, BK, BP, WR, WN, WB, WQ, WK, WP}
const EMPTY_SQUARE = null
var BLANK_BOARD = [
	[E,  E,  E,  E,  E,  E,  E,  E ], #0
	[E,  E,  E,  E,  E,  E,  E,  E ], #1
	[E,  E,  E,  E,  E,  E,  E,  E ], #2 
	[E,  E,  E,  E,  E,  E,  E,  E ], #3 
	[E,  E,  E,  E,  E,  E,  E,  E ], #4
	[E,  E,  E,  E,  E,  E,  E,  E ], #5
	[E,  E,  E,  E,  E,  E,  E,  E ], #6
	[E,  E,  E,  E,  E,  E,  E,  E ], #7
   # 0   1   2   3   4   5   6   7
]
## Tests for the rule engine. 
var rook_test = {"basis_vectors": [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1), Vector2i(0,-1)], 
	"max_distance": -1}

func _run():
	king_rule_test_1()

func king_rule_tests():
	var chess_game = ChessGame.new()
	var king_test_board = BLANK_BOARD.duplicate()
	king_test_board[7][4] = WK
	var row = []
	row.resize(8)
	row.fill(WP)
	king_test_board[6] = row
	king_test_board[7][3] = WP
	king_test_board[7][5] = BB
	chess_game.setup_board(king_test_board)
	var rule_engine = RuleEngine.new(chess_game)
	var moves = rule_engine.get_possible_moves(chess_game.chess_board[7][4])
	print(chess_game)
	print(moves)
	
func king_rule_test_1():
	var chess_game = ChessGame.new()
	var king_test_board = BLANK_BOARD.duplicate()
	king_test_board[7][4] = WK
	var row = []
	row.resize(8)
	row.fill(WP)
	king_test_board[6] = row
	king_test_board[6][4] = E
	king_test_board[2][4] = WP
	king_test_board[7][3] = WP
	king_test_board[7][5] = WP
	chess_game.setup_board(king_test_board)
	var rule_engine = RuleEngine.new(chess_game)
	var moves = rule_engine.get_possible_moves(chess_game.chess_board[7][4])
	print(chess_game)
	print(moves)
