extends Camera2D

const SPEED_KEY = 4
const SPEED_FAST_KEY = 10
const SPEED_MOUSE = 0.02


func _ready():
	set_process(false)


func _process(delta):
	var dir = Vector2(0,0)
	if (Input.is_action_pressed("ui_up")):
		dir.y = -1
	elif (Input.is_action_pressed("ui_down")):
		dir.y = 1
	if (Input.is_action_pressed("ui_left")):
		dir.x = -1
	elif (Input.is_action_pressed("ui_right")):
		dir.x = 1
	
	if (Input.is_action_pressed("ui_shift")):
		position += dir * SPEED_FAST_KEY
	else:
		position += dir * SPEED_KEY


func _input(event):
	if event is InputEventMouseMotion && Input.is_mouse_button_pressed(1):
		position -= event.speed * SPEED_MOUSE
