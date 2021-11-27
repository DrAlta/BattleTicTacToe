extends TextureButton

const otex = preload("res://O.png")
const ogtex = preload("res://OGlow.png")
const ohtex = preload("res://OHover.png")

const xtex = preload("res://X.png")
const xgtex = preload("res://XGlow.png")
const xhtex = preload("res://XHover.png")
const hover = preload("res://Hover.png")

var tween_node : Tween

var piece = " "
export(int) var id

export(int) var row = -1
export(int) var col = -1

signal custom_pressed(button)
signal test(id)

func _ready():
	tween_node = $AI/Tween
	tween_node.interpolate_property($AI, "scale", 
	Vector2(1,1), Vector2(0.5,0.5),
	1.33,Tween.TRANS_SINE,Tween.EASE_OUT)
	tween_node.start()
	reset()

func set_attack_hover(x:bool):
	if x:
		if piece == "X":
			texture_hover = xhtex
		elif piece == "O":
			texture_hover = ohtex
	else:
		if piece == "X":
			texture_hover = xgtex
		elif piece == "O":
			texture_hover = ogtex
			

func setX():
	if piece == "O":
		texture_normal = xtex
		texture_hover = xtex
	else:
		texture_normal = xgtex
		texture_hover = xgtex
	piece = "X";

func setO():
	if piece == "X":
		texture_normal = otex
		texture_hover = otex
	else:
		texture_normal = ogtex
		texture_hover = ogtex
	piece = "O"

func reset():
	print("reseting " + str(id))
	piece = " "
	texture_normal = null
	texture_hover = hover

func _on_TicTacButton_pressed():
	emit_signal( "custom_pressed", id )


func _on_TicTacButton_mouse_entered():
	emit_signal("test", id)
	pass # Replace with function body.
