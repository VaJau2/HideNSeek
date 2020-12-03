extends Character

#-----
# Скрипт игрока
# Доступен глобально через G.player
#-----

const HIDE_IN_AIR_CAMERA_RADIUS = 300

onready var hidingCamera = get_node("/root/Main/hidingCamera")
onready var mainCamera = get_node("Camera")
onready var interactArea = get_node("interactArea")
var mayMove = true


func setState(newState):
	state = newState
	match newState:
		G.STATE.IDLE:
			if is_hiding:
				setHide(false)
		G.STATE.HIDING:
			if !(self in get_parent().characters):
				get_parent().addCharacter(self)


func setHide(hide_on: bool) -> void:
	.setHide(hide_on)
	mayMove = !is_hiding
	hidingCamera.set_process(is_hiding)
	if is_hiding:
		hidingCamera.global_position = mainCamera.global_position
		hidingCamera.setCurrent(global_position, HIDE_IN_AIR_CAMERA_RADIUS)
	else:
		mainCamera.current = true


func _checkHidingKey() -> void:
	if state == G.STATE.HIDING:
		if Input.is_action_just_pressed("ui_hide"):
			setHide(!is_hiding)


func updateKeys():
	if mayMove:
		if (Input.is_action_pressed("ui_shift")):
			is_running = true
		
		if (Input.is_action_pressed("ui_up")):
			dir.y = -1
		elif (Input.is_action_pressed("ui_down")):
			dir.y = 1
		
		if (Input.is_action_pressed("ui_left")):
			dir.x = -1
			sprite.flip_h = true
		elif (Input.is_action_pressed("ui_right")):
			dir.x = 1
			sprite.flip_h = false


func _ready():
	G.player = self


func _process(delta):
	dir = Vector2(0, 0)
	is_running = false
	_checkHidingKey()
	
	updateKeys()
	updateVelocity(delta)
