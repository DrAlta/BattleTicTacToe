extends Object
class_name MonteCarloTreeSearch

class MonteCarloTreeSearchNode:
	var rng = RandomNumberGenerator.new()
	var state : TicTacToe # For our game it represents the board state. Generally the board state is represented by an array. For normal Tic Tac Toe, it is a 3 by 3 array.
	var parent #: MonteCarloTreeSearchNode # It is null for the root node and for other nodes it is equal to the node it is derived from.
	var parent_action # null for the root node and for other nodes it is equal to the action which it’s parent carried out.
	var children = [] # It contains all possible actions from the current node.
	var _number_of_visits = 0 # Number of times current node is visited
	var _results = {
		1 : 0,
		0 : 0,
		-1 : 0
	} 

	func _argmax(arg: Array):
		var ret : int
		var max_val = arg[0]
		for i in range(arg.size()):
			var c = arg[i]
			if c > max_val:
				ret = i
				max_val = c
			#printraw("max"+str(ret)+" of "+ str(arg.size()))
		return (ret)

	var _untried_actions = [] # Represents the list of all possible actions
	var action # Move which has to be carried out. 

	func  _init(my_state, my_parent=null, my_parent_action=null):
		state = my_state
		parent = my_parent
		parent_action = my_parent_action
		_untried_actions = untried_actions()

	func untried_actions():
	# Returns the list of untried actions from a given state.
		_untried_actions = state.get_good_actions()
		return _untried_actions

	func q(): 
	# Returns the difference of wins - losses
		var wins = _results[1]
		var loses = _results[-1]
		return(float(wins - loses))

	func n(): 
	# Returns the number of times each node is visited.
		return(float(_number_of_visits))

	func expand(): 
	# From the present state, next state is generated depending on the action which 
	# is carried out. In this step all the possible child nodes corresponding to 
	# generated states are appended to the children array and the child_node is
	# returned. The states which are possible from the present state are all generated
	# and the child_node corresponding to this generated state is returned.
		var action_x = _untried_actions.pop_back()
		var next_state = state.move(action_x)
		var child_node = MonteCarloTreeSearchNode.new(next_state, self, action_x)
		children.append(child_node)
		return(child_node)

	func is_terminal_node():
	# This is used to check if the current node is terminal or not. Terminal node is reached when the game is over.
		#state.print_board()get_position(
		#printraw("#")
		if state.debug == true:

			print("62:is game over"+str(state.is_game_over()))
		if state.get_good_actions().size() == 0:
			return(true)
		return(state.is_game_over())

	func rollout():
		var current_rollout_state = self.state
	
		while not current_rollout_state.is_game_over():
			if state.debug == true:
				print("71:is game over"+str(current_rollout_state.is_game_over()))
		
			var possible_moves = current_rollout_state.get_good_actions()
		
			var action_x = rollout_policy(possible_moves)
			current_rollout_state = current_rollout_state.move(action_x)
		return current_rollout_state.game_result()

	func backpropagate(result):
		_number_of_visits += 1
		_results[result] += 1
		if parent:
			parent.backpropagate(result)

	func is_fully_expanded():
	# All the actions are poped out of _untried_actions one by one. When it becomes empty, that is when the size is zero, it is fully expanded.
		return (_untried_actions.size() == 0)

	func best_child(c_param=sqrt(2)):
	# Once fully expanded, this function selects the best child out of the children array. The first term in the formula corresponds to exploitation and the second term corresponds to exploration.
		var choices_weights = []
#		print("Children:" + str(children))
		for c in children:
			choices_weights.append(
				(
					c.q() / c.n()
				) + c_param * sqrt(
					(
						2 * log(n())
					) / c.n()
				)
			) 
		#printraw("|BC:"+str(children[_argmax(choices_weights)]))
		return(children[_argmax(choices_weights)])

	func rollout_policy(possible_moves):
	# Randomly selects a move out of possible moves. This is an example of random playout.
		return possible_moves[randi() % possible_moves.size()]

	func _tree_policy():
	# Selects node to run rollout.
		var current_node = self
		while not current_node.is_terminal_node():        
			if not current_node.is_fully_expanded():
				return current_node.expand()
			else:
				current_node = current_node.best_child()
		return current_node

	func prexpand2():
		var current_node = self
		while not current_node.is_fully_expanded():
			if not current_node.is_terminal_node():        
				var v = current_node.expand()
				var reward = v.rollout()
				v.backpropagate(reward)

	func prexpand():
		var current_node = self
		while not current_node.is_fully_expanded():
			if not current_node.is_terminal_node():        
				var v = current_node.expand()
				var reward = v.rollout()
				v.backpropagate(reward)
				v.prexpand2()


	func best_action():
	# This is the best action function which returns the node corresponding to best possible move. The step of expansion, simulation and backpropagation are carried out by the code above.
		var simulation_no = 1000
#		for action_x in _untried_actions:
#			var next_state = state.move(action_x)
#			var child_node = MonteCarloTreeSearchNode.new(next_state, self, action_x)
#			children.append(child_node)
#			var reward = child_node.rollout()
#			child_node.backpropagate(reward)
		prexpand2()
		for _i in range(simulation_no):
			var v = _tree_policy()
			var reward = v.rollout()
			#print("reward:"+ str(reward))
			v.backpropagate(reward)
		var choices_weights = []
#		print("Children:" + str(children))
		for i in children.size():
			var c = children[i]
			print("L166:"+str(c.parent_action) + "has" + \
			str(c._results[1]) + " of " +\
			str(c._number_of_visits)+ " = " +str(c._results[1] / float(c._number_of_visits)))
			choices_weights.append(
				c._results[1] / float(c._number_of_visits)
			) 
		return best_child(0.0)
		print("L173:"+str(children[_argmax(choices_weights)].parent_action))
		return(children[_argmax(choices_weights)])


func main():
		var root = MonteCarloTreeSearchNode.new(TicTacToe.new())
		var selected_node = root.best_action()
		print("129"+str(selected_node.parent_action))
		selected_node.state.print_board()
		#selected_node.state.debug=true
		
		while(not selected_node.is_terminal_node()):
			root = MonteCarloTreeSearchNode.new(TicTacToe.new(selected_node.state.board, selected_node.state.player))
			selected_node = root.best_action()
			print("134" + str(selected_node.parent_action))
			selected_node.state.print_board()
		print("L189:"+str(selected_node.state.game_result()))
		print("L190:"+str(selected_node.state.player))
		return

class TicTacToe:
	var debug = false
	var board
	var player : String


	func set_position(position:int, piece: Array):
		assert(typeof(piece[1])==typeof(1))
		board[position-1] = piece

	func get_position(position):
		return(board[position-1])
	func convert_piece(piece):
		if piece[1] == 0:
			if piece[0] == "X":
				return("v")
			elif piece[0] == "O":
				return("c")
			else:
				return(" ")
		else:
			return(piece[0])

	func print_board():
		var pp=""
		for x in range(9):
			pp = pp + convert_piece(board[x])
			if x % 3 == 2:
				pp = pp + "\n"
		print(str(pp))

	const attackers= [
		[2,4],     #1
		[1,3,5],   #2
		[2,6],     #3
		[1,5,7],   #4
		[2,4,6,8], #5
		[3,5,9],   #6
		[4,8],     #7
		[5,7,9],   #8
		[6,8]      #9
	]

	func move(my_action):
	# Modify according to your game or needs. Changes the state of your board with 
	# a new value. For a normal Tic Tac Toe game, it can be a 3 by 3 array with
	# all the elements of array being 0 initially. 0 means the board  position is 
	# empty. If you place x in row 2 column 3, then it would be some thing like
	# board[2][3] = 1, where 1 represents that x is placed. Returns the new state
	# after making a move.
		var opponent= ["X", " "]
		var new_state= TicTacToe.new(board.duplicate(), "X")
		if player == "X":
			opponent= ["O", " "]
			new_state.player = "O"
		
		if get_position(my_action[1])[0] in opponent:
			if (my_action[0] == my_action[1]):
				new_state.set_position(my_action[1], [player, 1])
				return(new_state)
			else:
				if get_position(my_action[0]) == [player, 1]:
					new_state.set_position(my_action[0], [" ", 1])#new_piece)
					new_state.set_position(my_action[1], [player, 0])
					return(new_state)
				else:
					print("Player " + player + " can't take postion " + str(my_action[1]) + " from " + str(my_action[0]) + " in game:" )
					print_board()
					return(self)
		else:
			print("Player " + player + " can't take postion " + str(my_action[1]) + " in game:" )
			print_board()
			return(self)
		pass

	func get_battles(): 
	# Modify according to your game or needs. Constructs a list of all possible actions from current state. Returns a list.
		var offense = []
		var defense = []

		var opponent= ["X", "v"]
		if player == "X":
			opponent= ["O", "c"]

		for x in range(1, 10):
			
			if get_position(x)[0] in opponent:
				for attacker in attackers[x-1]:
					if get_position(attacker) == [player, 1]:
						offense.append(attacker)
						defense.append(x)
		return([offense, defense])

	func get_good_actions(): 
	# Modify according to your game or needs. Constructs a list of all possible actions from current state. Returns a list.
		var moves = []

		var opponent= "X"
		if player == "X":
			opponent= "O"

		for x in heuristic():
			
			if get_position(x)[0] == opponent:
				for attacker in attackers[x-1]:
					if get_position(attacker) == [player, 1]:
						moves.append([int(attacker), int(x)])
			if get_position(x)[0] == " ":
				moves.append([int(x),int(x)])
		return(moves)
		pass

	func get_legal_actions(): 
	# Modify according to your game or needs. Constructs a list of all possible actions from current state. Returns a list.
		var moves = []

		var opponent= ["X", "v"]
		if player == "X":
			opponent= ["O", "c"]

		for x in range(1,10):
			
			if get_position(x)[0] in opponent:
				for attacker in attackers[x-1]:
					if get_position(attacker) == [player, 1]:
						moves.append([int(attacker), int(x)])
			if get_position(x)[0] == " ":
				moves.append([int(x),int(x)])
		return(moves)
		pass

	func winner(won):
		if won == "O":
			return(1)
		else:
			return(-1)



	func game_result():
	# Modify according to your game or needs. Returns 1 or 0 or -1 depending on your state 
	# corresponding to win, tie or a loss.
		#rows
		for x in range(3):
			if get_position((x*3) + 1)[0] != " " and \
			get_position((x*3) + 1)[0] == get_position((x*3) + 2)[0] and \
			get_position((x*3) + 2)[0] == get_position((x*3) + 3)[0]:
				#printraw("row|")
				return(winner(get_position((x*3) + 1)[0]))

		#collomes?
		for c in range(3):
			if get_position((0)+c)[0] != " " and \
			get_position(   (0)+c)[0] == get_position((3)+c)[0] and \
			get_position(   (3)+c)[0] == get_position((6)+c)[0]:
				#printraw("col|")
				return(winner(get_position((0)+c)[0]))

		#diagnals?
		if get_position(5)[0] != " " and ((get_position(1)[0] == get_position(5)[0] and get_position(5)[0] == get_position(9)[0]) or (get_position(3)[0] == get_position(5)[0] and get_position(5)[0] == get_position(7)[0])):
			#printraw("diag|")
			return(winner(get_position(5)[0]))
		return(0)

	func win_result():
	# Modify according to your game or needs. Returns 1 or 0 or -1 depending on your state 
	# corresponding to win, tie or a loss.
		#rows
		for x in range(3):
			if get_position((x*3) + 1)[0] != " " and \
			get_position((x*3) + 1)[0] == get_position((x*3) + 2)[0] and \
			get_position((x*3) + 2)[0] == get_position((x*3) + 3)[0]:
				#print("row win")
				return

		#collomes?
		for c in range(3):
			if get_position((0)+c)[0] != " " and \
			get_position(   (0)+c)[0] == get_position((3)+c)[0] and \
			get_position(   (3)+c)[0] == get_position((6)+c)[0]:
				#print_board()
				#print("col win")
				return

		#diagnals?
		if get_position(5)[0] != " " and ((get_position(1)[0] == get_position(5)[0] and get_position(5)[0] == get_position(9)[0]) or (get_position(3)[0] == get_position(5)[0] and get_position(5)[0] == get_position(7)[0])):
			#print("diag")
			return
		return


	func is_game_over():
	# Modify according to your game or needs. It is the game over condition and depends on your game. Returns true or false
		if get_good_actions().size() == 0:
			return(true)

		return(game_result() != 0)


	func _init(my_board = [[" ", 1],[" ", 1],[" ", 1],[" ", 1],[" ", 1],[" ", 1],[" ", 1],[" ", 1],[" ", 1],], turn = "X"):
		board = my_board
		player = turn

	func heuristic():
	# Modify according to your game or needs. Returns 1 or 0 or -1 depending on your state 
	# corresponding to win, tie or a loss.
		#rows
		var blocks =[]
		var winning = []

		var opponent = "X"
		if player == "X":
			opponent = "O"
		for x in range(3):
			var total = 0
			for p in range(1,4):
				var piece = get_position((x*3)+p)[0]
				if piece == opponent:
					total += 1
					if total == -2:
						print("L413:"+str((x*3)+p))
				elif piece == player:
					total -= 1
					if total == -2:
						print("L417:"+str((x*3)+p))
			if total == 2:
				for b in range(1,4):
					blocks.append((x*3)+b)
			elif total == -2:
				for w in range(1,4):
					winning.append((x*3)+w)
#	for x in range(1,4):
#		for c in range(3):

		#collomes?
		for x in range(1,4):
			var total = 0
			for c in range(3):
					var piece = get_position((c*3)+x)[0]
					if piece == opponent:
						total += 1
						if total == 2:
							for b in range(1,4):
								blocks.append((b*3)+x)
					elif piece == player:
						total -= 1
						if total == -2:
							for w in range(0,3):
								winning.append((w*3)+x)

		#\diag
		var total = 0
		for x in [1,5,9]:
				var piece = get_position(x)[0]
				if piece == opponent:
					total += 1
				elif piece == player:
					total -= 1
		if total == 2:
			blocks.append_array([1,5,9])
		elif total == -2:
			winning.append_array([1,5,9])

		#/diag
		total = 0
		for x in [3,5,7]:
				var piece = get_position(x)[0]
				if piece == opponent:
					total += 1
				elif piece == player:
					total -= 1
		if total == 2:
			blocks.append_array([3,5,7])
		elif total == -2:
			winning.append_array([])
		if winning.empty():
			if blocks.empty():
				return([1,2,3,4,5,6,7,8,9])
			else:
				#print("block")
				return(blocks)
		else:
			#print("iwin")
			return(winning)
#		print("wins:"+str(winning) + " blocks:" + str(blocks))
	

		#diagnals?
#		if get_position(5)[0] != " " and ((get_position(1)[0] == get_position(5)[0] and get_position(5)[0] == get_position(9)[0]) or (get_position(3)[0] == get_position(5)[0] and get_position(5)[0] == get_position(7)[0])):
#			printraw("diag|")
#			return(winner(get_position(5)[0]))
#		return(0)
	
