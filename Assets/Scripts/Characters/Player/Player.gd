extends Character

onready var hidingCamera = get_node("/root/Main/hidingCamera")
onready var mainCamera = get_node("Camera")
var mayMove = true


func _checkHiding():
	if G.state == G.GAME_STATE.HIDING:
		if Input.is_action_just_pressed("ui_hide"):
			is_hiding = !is_hiding
			mayMove = !is_hiding
			hidingCamera.set_process(is_hiding)
			if is_hiding:
				changeAnimation("hide")
				hidingCamera.current = true
				hidingCamera.global_position = global_position
			else:
				changeAnimation("idle")
				mainCamera.current = true


func _getWalkAnim(running: bool):
	if running: 
		return "run"
	else:
		return "walk"


func _ready():
	G.player = self


func _process(delta):
	var dir = Vector2(0, 0)
	var temp_speed = speed
	var temp_anim = "idle"
	is_running = false
	_checkHiding()
	
	if mayMove:
		if (Input.is_action_pressed("ui_shift")):
			temp_speed = run_speed
			is_running = true
		
		if (Input.is_action_pressed("ui_up")):
			dir.y = -1
			temp_anim = _getWalkAnim(is_running)
		elif (Input.is_action_pressed("ui_down")):
			dir.y = 1
			temp_anim = _getWalkAnim(is_running)
		
		if (Input.is_action_pressed("ui_left")):
			dir.x = -1
			setFlipX(true)
			temp_anim = _getWalkAnim(is_running)
		elif (Input.is_action_pressed("ui_right")):
			dir.x = 1
			setFlipX(false)
			temp_anim = _getWalkAnim(is_running)
	
	if !is_hiding:
		velocity = velocity.move_toward(dir * temp_speed, acceleration * delta)
		changeAnimation(temp_anim)
	else:
		velocity = Vector2(0, 0)
