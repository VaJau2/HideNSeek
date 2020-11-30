extends Camera2D

#-----
# Скрипт свободной камеры
# Врубается, когда игрок прячется
# Камерой можно управлять через WASD или через перетаскивания мышкой
#-----

const SPEED_KEY = 4
const SPEED_FAST_KEY = 10
const SPEED_MOUSE = 0.02

var cameraCenter: Vector2
var maxRadius: float


func setCurrent(_cameraCenter: Vector2, _maxRadius: float):
	cameraCenter = _cameraCenter
	maxRadius = _maxRadius
	current = true
	set_process(true)


func _isClose(dir: Vector2, speedModifier: float):
	var newPosition = global_position + dir * speedModifier
	var newDistance = newPosition.distance_to(cameraCenter)
	return newDistance < maxRadius


func _ready():
	set_process(false)


func _process(_delta):
	var dir = Vector2(0,0)
	if (Input.is_action_pressed("ui_up")):
		dir.y = -1
	elif (Input.is_action_pressed("ui_down")):
		dir.y = 1
	if (Input.is_action_pressed("ui_left")):
		dir.x = -1
	elif (Input.is_action_pressed("ui_right")):
		dir.x = 1
	
	var speedModifier = SPEED_KEY
	if (Input.is_action_pressed("ui_shift")):
		speedModifier = SPEED_FAST_KEY
	
	if dir.length() > 0 && _isClose(dir, speedModifier):
		position += dir * speedModifier


func _input(event):
	if event is InputEventMouseMotion && Input.is_mouse_button_pressed(1):
		position -= event.speed * SPEED_MOUSE
