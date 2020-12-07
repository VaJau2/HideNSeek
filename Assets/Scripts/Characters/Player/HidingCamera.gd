extends Camera2D

#-----
# Скрипт свободной камеры
# Врубается, когда игрок прячется
# Камерой можно управлять через WASD
#-----
const FAST_SPEED = 200
const SPEED     = 120

onready var body = get_parent()


func setCurrent(scale: float = 1):
	body.get_parent().scale = Vector2(scale, scale)
	position = Vector2.ZERO
	current = true
	set_process(true)


func _ready():
	set_process(false)


func _process(_delta):
	var fast = false
	var dir = Vector2.ZERO
	
	if (Input.is_action_pressed("ui_up")):
		dir.y = -1
	elif (Input.is_action_pressed("ui_down")):
		dir.y = 1
	if (Input.is_action_pressed("ui_left")):
		dir.x = -1
	elif (Input.is_action_pressed("ui_right")):
		dir.x = 1
	
	if (Input.is_action_pressed("ui_shift")):
		fast = true
	
	if dir.length() > 0:
		body.move_and_slide(dir * (FAST_SPEED if fast else SPEED))
