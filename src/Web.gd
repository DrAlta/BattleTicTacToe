extends Control

onready var board = [ $TicTacButton1, $TicTacButton2, $TicTacButton3,
					  $TicTacButton4, $TicTacButton5, $TicTacButton6,
					  $TicTacButton7, $TicTacButton8, $TicTacButton9, 
					]

onready var winDialog = $WinDialog

var game : MonteCarloTreeSearch.TicTacToe

var thread
var mutex
var AI_speed = 100
var AI_brain = null

var currentRound = 0
var winner = false
var legal_moves =[]
var offense
var defense

enum {PEACE, ATTACKING, DEFENDING, START_THINKING, THINKING, AIDONE, CRASHED}
var move_phase : = PEACE
var selected = null

func _ready():
	#setup th game
	game = MonteCarloTreeSearch.TicTacToe.new()
	var battles = game.get_battles()
	offense = battles[0]
	defense = battles[1]

	#setup for AI
	mutex = Mutex.new()


	# Setup our playing board
	for btn in board:
		btn.connect( "custom_pressed", self, "onTicTacBtnPressed" )
		btn.connect( "test", self, "onTicTacBtnHover" )
	
	# Setup our dialog box
	var cancelBtn = winDialog.get_cancel()
	cancelBtn.set_text("Quit")
	cancelBtn.connect("pressed", self, "onQuit")
	winDialog.get_ok().set_text("Play Again!")

func _process(delta):
	if move_phase == START_THINKING:
		move_phase = THINKING
		for btn in board:
			if btn.id in defense:
	#				btn.get_node("Attacker").visible = true
	#				btn.get_node("Attacker").rotation_degrees += delta * AI_speed
				btn.get_node("AI").visible = true
			elif btn.piece == " ":
	#				btn.get_node("Attacker").visible = true
	#				btn.get_node("Attacker").rotation_degrees += -delta * AI_speed
				btn.get_node("AI").visible = true
	elif move_phase == THINKING:
		move_phase = CRASHED
		AI_move()
		onTicTacBtnHover(selected)

	elif move_phase == CRASHED:
		showWinDialog("Game Over","O forfeits the match!")

	if move_phase == DEFENDING: #or (buttons[id-1].value == "O"):
		for btn in board:
			var id = btn.id
			if id in offense:
				#print(str(id)+ "is D in proc")

				if selected == id - 1:
					btn.get_node("Defender").rotation_degrees = 0
					btn.get_node("Defender").visible = true
				elif selected == id + 1:
					btn.get_node("Defender").rotation_degrees = 180
					btn.get_node("Defender").visible = true
				elif selected == id - 3:
					btn.get_node("Defender").rotation_degrees = 90
					btn.get_node("Defender").visible = true
				elif selected == id + 3:
					btn.get_node("Defender").rotation_degrees = -90
					btn.get_node("Defender").visible = true
				else:
					btn.get_node("Defender").visible = false
			else:
				btn.get_node("Defender").visible = false
	if move_phase == ATTACKING :#or (buttons[id - 1].value == "O"):
		for btn in board:
			if [int(selected), int(btn.id)] in legal_moves:
				if selected == btn.id + 1:
					btn.get_node("Attacker").rotation_degrees = 180
					btn.get_node("Attacker").visible = true
				elif selected == btn.id - 1:
					btn.get_node("Attacker").rotation_degrees = 0
					btn.get_node("Attacker").visible = true
				elif selected == btn.id + 3:
					btn.get_node("Attacker").rotation_degrees = -90
					btn.get_node("Attacker").visible = true
				elif selected == btn.id - 3:
					btn.get_node("Attacker").rotation_degrees = 90
					btn.get_node("Attacker").visible = true
			else:
				btn.get_node("Attacker").visible = false
	mutex.unlock()


func onTicTacBtnHover(id):
	mutex.lock()
	if move_phase == PEACE :#or (buttons[id - 1].value == "O"):
		for btn in board:
			if btn.id == 8:
				print("L114:" + str([id, btn.id]))
			if [int(id), int(btn.id)] in legal_moves:
				if id == btn.id + 1:
					btn.get_node("Attacker").rotation_degrees = 180
					btn.get_node("Attacker").visible = true
				elif id == btn.id - 1:
					btn.get_node("Attacker").rotation_degrees = 0
					btn.get_node("Attacker").visible = true
				elif id == btn.id + 3:
					btn.get_node("Attacker").rotation_degrees = -90
					btn.get_node("Attacker").visible = true
				elif id == btn.id - 3:
					btn.get_node("Attacker").rotation_degrees = 90
					btn.get_node("Attacker").visible = true
				else:
					btn.get_node("Attacker").visible = false
			else:
				btn.get_node("Attacker").visible = false
	mutex.unlock()

func clearBoard():
	# Resets the game for a new round
	currentRound = 0
	winner = false
	# Resets the board
	for btn in board:
		btn.reset()
	#reset the game
	game = MonteCarloTreeSearch.TicTacToe.new()
	var battles = game.get_battles()
	offense = battles[0]
	defense = battles[1]
	move_phase = PEACE

func do_move(move):
	print("doing move:" + str(move))
	if move[0] != move[1]:
		board[move[0] - 1].reset()

	game = game.move(move)
	game.print_board()
	legal_moves = game.get_legal_actions()
	print("possible moves=" + str(legal_moves))
	var result = game.game_result()
	if game.is_game_over() :
		move_phase = PEACE
		showWinDialog("Game Over","Good match.")
		return(false)
	else:
		var battles = game.get_battles()
		offense = battles[0]
		defense = battles[1]
	return(true)
		

func AI_move():
	# calculate move
	var root = MonteCarloTreeSearch.MonteCarloTreeSearchNode.new(MonteCarloTreeSearch.TicTacToe.new(game.board, game.player))
	var selected_node = root.best_action()
	#print("L163:"+str(game.get_legal_actions()))
	var move = selected_node.parent_action
	#print("AI predicts:")
	#selected_node.state.print_board()

	#var move = MonteCarloTreeSearch.MonteCarloTreeSearchNode.new(game).best_action().parent_action
	print("AI doing " + str(move))
	place_mark(board[move[1]- 1], "O")

	do_move(move)
	print("AI mutex lock")
	mutex.lock()
	move_phase = PEACE
	for btn in board:
		btn.get_node("Attacker").visible = false
		btn.get_node("Defender").visible = false
		btn.get_node("AI").visible = false
		if btn.id in offense:
			btn.set_attack_hover(true)
		else:
			if game.get_position(btn.id)[1] > 0:
				btn.set_attack_hover(false)
	mutex.unlock()
	print("AI mutex unlock")


func AIturn():
		move_phase = START_THINKING

func showWinDialog( title, text ):
	# A simple helper method to display the dialog along with whatever
	# text and title supplied by the calling function
	winner = true
	winDialog.window_title = title
	winDialog.dialog_text = text
	winDialog.show()

func place_mark(btn, player):
	if player == "X":
		btn.setX()
	else:
		btn.setO()

	
func onTicTacBtnPressed( button ):
	# When a TicTacButton is pressed, it fires a signal
	# We've registered to "respond" to that signal here.
	var btn = board[button - 1]
	if game.player == "X":

		if move_phase == PEACE:
			if btn.piece == " ":
				print(game.player + " took " + str(button))
				place_mark(btn, game.player)
				if do_move([button, button]):
					AIturn()
					selected= btn.id
			elif btn.piece == game.player:
				print("Attack who?")
				selected = btn.id
				move_phase = ATTACKING
			else:
				print("Who attacks?")
				selected = btn.id
				move_phase = DEFENDING
			selected = button

		elif move_phase == DEFENDING:
			if btn.piece == game.player:
				print(game.player + " attacked " + str(button))
				place_mark(board[selected - 1], game.player)
				btn.reset()

				if do_move([button, selected]):
					AIturn()
					onTicTacBtnHover(btn.id)

				#reset the UI state
				selected = null

			else:
				move_phase = PEACE
		elif move_phase == ATTACKING:
			if [selected, button] in legal_moves:
				print(game.player + " attacks " + str(button))
				place_mark(btn, game.player)
				board[selected - 1].reset()

				if do_move([selected, button]):
					AIturn()
			else:
				print("caneling Attack:"+str([selected, button]))
				move_phase = PEACE

func onPlayAgain():
	clearBoard()

func onQuit():
	get_tree().quit()
