extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#123
#456
#789
var positions =[
	pow(3,0),#1
	pow(3,1),#2
	pow(3,2),#3
	pow(3,3),#4
	pow(3,4),#5
	pow(3,5),#6
	pow(3,6),#7
	pow(3,7),#8
	pow(3,8),#9
	]
var board= int((pow(3, 2))*1+(pow(3,9)*2)) % int(pow(3,3))

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
#	for x in range(1,4):
#		for c in range(3):
#			print((c*3)+x)
	print(
		MonteCarloTreeSearch.TicTacToe.new(
			[["O",1],["X",1],["X",1],
			["X",1],[" ",1],["X",1],
			["X",1],[" ",1],["O",1]]
		).block()
	)
#	MonteCarloTreeSearch.new().main()
	print("done")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
