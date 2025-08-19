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

func _run():
	#king_rule_test_1()
	#check_test_1()
	king_on_king_test()
	pass

## Ensures that kings cannot enter eachother's zone of control.s
func king_on_king_test():
	const layout = [
	[E,  E,  E,  E,  E,  E,  E,  E ], #0
	[E,  E,  E,  E,  E,  E,  E,  E ], #1
	[E,  E,  E,  E,  E,  E,  E,  E ], #2 
	[E,  E,  E,  E,  BK, E,  E,  E ], #3 
	[E,  E,  E,  E,  E,  E,  E,  E ], #4
	[E,  E,  E,  E,  WK, E,  E,  E ], #5
	[E,  E,  E,  E,  E,  E,  E,  E ], #6
	[E,  E,  E,  E,  E,  E,  E,  E ]] #7
	# 0   1   2   3   4   5   6   7 
	var chess_game = ChessGame.new()
	chess_game.setup_board(layout)
	var rule_engine = RuleEngine.new(chess_game)
	var possible_moves := rule_engine.get_possible_moves(chess_game.chess_board[5][4]).get_all()
	assert(!possible_moves.has(Vector2i(4,4)), "King can move in another king's zone of control!")
	print("✅Passed king on king test.")
	
func check_test_1():
	const check_layout = [
	[E,  E,  E,  E,  E,  E,  E,  BK ], #0
	[E,  E,  E,  E,  E,  E,  E,  E ],  #1
	[E,  E,  E,  E,  E,  E,  E,  E ],  #2 
	[E,  E,  E,  E,  E,  E,  E,  E ],  #3 
	[E,  E,  E,  E,  E,  E,  E,  E ],  #4
	[E,  E,  E,  E,  E,  E,  E,  BQ ], #5
	[E,  E,  E,  E,  E,  E,  E,  E ],  #6
	[E,  E,  E,  E,  E,  E,  E,  WK ]] #7
	# 0   1   2   3   4   5   6   7 
	var chess_game = ChessGame.new()
	chess_game.setup_board(check_layout)
	var rule_engine = RuleEngine.new(chess_game)
	assert(!rule_engine.is_square_safe(chess_game.chess_board[7][7],Vector2i(6,7)), "Failed check test.")
	assert(rule_engine.is_square_safe(chess_game.chess_board[7][7],Vector2i(7,6)), "Failed check test.")
	assert(!rule_engine.is_square_safe(chess_game.chess_board[7][7],Vector2i(6,6)), "Failed check test.")
	print("✅Passed check test 1.")
	
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
	print(moves.get_all())
