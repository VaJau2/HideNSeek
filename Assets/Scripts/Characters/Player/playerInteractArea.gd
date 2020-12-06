extends Area2D

#-----
# Скрипт для взаимодействия с предметами/неписями
# Обрабатывает массив предметов в радиусе interactArea
# В качестве текущего объекта для взаимодействия берет ближайший
# Вызывает его interact()-метод
#-----

var theme = preload("res://Assets/Fonts/RusFontTheme.tres")
onready var inputs = get_node("/root/Main/canvas/gamepadCheck")

var tempInteractObj = null
var tempHint = "dialogue"
var interactObjectsArray = []
var hintsArray = []
var objI = 0

var leftLabel = null
var rightLabel = null
var useButtons = {
	"dialogue": "ui_use",
	"hide": "ui_hide",
	"search": "ui_use"
}

var hideLabels = false


func _spawnLabels() -> void:
	leftLabel = tempInteractObj.get_node("hints/leftLabel")
	rightLabel = tempInteractObj.get_node("hints/rightLabel")
	leftLabel.text = inputs.getInterfaceText(tempHint)
	rightLabel.text = inputs.getInterfaceText(tempHint)


func _showLabels() -> void:
	if !hideLabels:
		var leftOn = _objIsLefter()
		leftLabel.visible = leftOn
		rightLabel.visible = !leftOn
	else:
		leftLabel.visible = false
		rightLabel.visible = false


func _hideLabels() -> void:
	if tempInteractObj != null:
		if leftLabel != null:
			leftLabel.visible = false
		if rightLabel != null:
			rightLabel.visible = false


func _respawnLabels(_objI: int) -> void:
	_hideLabels()
	tempInteractObj = interactObjectsArray[_objI]
	tempHint = hintsArray[_objI]
	_spawnLabels()


func _objIsLefter() -> bool:
	return tempInteractObj.global_position.x > get_parent().global_position.x


func _getClosestObject() -> void:
	#проверяем и берем текущий объект по расстоянию
	if tempInteractObj != interactObjectsArray[objI]:
		var tempDist = tempInteractObj.global_position.distance_to(G.player.global_position)
		var newDist = interactObjectsArray[objI].global_position.distance_to(G.player.global_position)
		if newDist < tempDist:
			_respawnLabels(objI)
	
	#проверяем hidingSpot на случай, если его кто-то займет раньше
	if G.player.state == G.STATE.HIDING \
	&& tempInteractObj is HidingSpot \
	&& tempInteractObj.my_character != null \
	&& tempInteractObj.my_character != self:
		_removeInteractObject(tempInteractObj)
	
	if objI < interactObjectsArray.size() - 1:
		objI += 1
	else:
		objI = 0


func _checkDialogue(body) -> bool:
	if body is Character:
		if body.dialogue_id && body.dialogue_id.length() > 0:
			return true
		if body.phraseCode && body.phraseCode.length() > 0:
			return true
	return false


func _checkHideSpot(body) -> String:
	if G.player.state == G.STATE.HIDING:
		if body is HidingSpot && body.my_character == null:
			return "hide"
	if G.player.state == G.STATE.SEARCHING:
		if body is HidingSpot:
			return "search"
	return "";


func _addInteractObject(newObject, hint) -> void:
	if tempInteractObj == null:
		tempInteractObj = newObject
		tempHint = hint
	interactObjectsArray.append(newObject)
	hintsArray.append(hint)
	_spawnLabels()


func _removeInteractObject(object) -> void:
	objI = 0
	var deleteObjI = interactObjectsArray.find(object)
	interactObjectsArray.remove(deleteObjI)
	hintsArray.remove(deleteObjI)
	if (interactObjectsArray.size() == 1):
		_respawnLabels(0)
	if (interactObjectsArray.size() == 0):
		_hideLabels()
		tempInteractObj = null


func _on_interactArea_body_entered(body):
	if body == G.player:
		return
	
	if _checkDialogue(body):
		_addInteractObject(body, "dialogue")
	
	var hideButton = _checkHideSpot(body)
	if hideButton != "":
		_addInteractObject(body, hideButton)


func _on_interactArea_body_exited(body):
	if body in interactObjectsArray:
		_removeInteractObject(body)


func _process(_delta):
	if interactObjectsArray.size() > 0:
		_getClosestObject()
	
	if tempInteractObj:
		_showLabels()
		if (Input.is_action_just_pressed(useButtons[tempHint])):
			tempInteractObj.interact(self)
			if tempHint == "search":
				G.player.waitTime = G.player.SEARCH_WAIT_TIME
	else:
		_hideLabels()
