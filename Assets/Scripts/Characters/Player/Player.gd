extends Character

#-----
# Скрипт игрока
# Доступен глобально через G.player
#
# Нод игрока должен быть первым в списке YSort
# чтоб игра не учитывала его при выборе другого ведущего
# если тот не хочет
#-----

onready var cameraBlock = get_node("/root/Main/cameraBlock")
onready var hidingCamera = cameraBlock.get_node("cameraBody/camera")
onready var mainCamera = get_node("Camera")
onready var interactArea = get_node("interactArea")
var mayMove = true


func setState(newState):
	.setState(newState)
	if newState == G.STATE.IDLE \
	|| newState == G.STATE.LOST:
		if is_hiding: setHide(false)
		if hiding_in_prop: myProp.interact(interactArea, self)
		interactArea.clearInteractObjects()


func setHide(hide_on: bool) -> void:
	#если еще не до конца спрятался в пропе
	if hiding_in_prop && interactArea.tempInteractObj == null:
		return
	
	.setHide(hide_on)
	mayMove = !is_hiding
	if is_hiding:
		cameraBlock.global_position = mainCamera.global_position
		hidingCamera.setCurrent()
		G.currentCamera = hidingCamera
	else:
		mainCamera.global_position = cameraBlock.global_position
		mainCamera.current = true
		hidingCamera.set_process(false)
		G.currentCamera = mainCamera


func _checkHidingKey() -> void:
	if state == G.STATE.HIDING:
		if Input.is_action_just_pressed("ui_hide"):
			setHide(!is_hiding)
	if state == G.STATE.LOST:
		if Input.is_action_just_pressed("ui_hide"):
			showMessage("lost", "not_see", 1.5)
		if Input.is_action_just_pressed("ui_use"):
			showMessage("lost", "see", 1.5)


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
			setFlipX(true)
		elif (Input.is_action_pressed("ui_right")):
			dir.x = 1
			setFlipX(false)


func _ready():
	G.player = self
	G.currentCamera = mainCamera


func _process(delta):
	dir = Vector2(0, 0)
	is_running = false
	
	if waitTime > 0:
		velocity = Vector2(0, 0)
		waitTime -= delta
		return

	sayAfterWaiting()
	_checkHidingKey()
	updateKeys()
	updateVelocity(delta)


func _checkHidingNPC(body) -> bool:
	return state == G.STATE.SEARCHING \
	&& body is Character \
	&& !body.hiding_in_prop


func _on_seekArea_body_entered(body):
	if body == self:
		return
	
	if _checkHidingNPC(body):
		interactArea.addInteractObject(body, "find")


func _on_seekArea_body_exited(body):
	if _checkHidingNPC(body):
		interactArea.removeInteractObject(body)
