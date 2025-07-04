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

var interactLabel = null
var useButtons = {
	"dialogue": "ui_use",
	"hide": "ui_hide",
	"search": "ui_use",
	"find": "ui_use"
}

var hideLabels = false


func _spawnLabels() -> void:
	interactLabel = tempInteractObj.get_node("hints/leftLabel")
	interactLabel.text = inputs.getInterfaceText(tempHint)


func _showLabels() -> void:
	interactLabel.visible = !hideLabels


func _hideLabels() -> void:
	if tempInteractObj != null:
		if interactLabel != null:
			interactLabel.visible = false


func _setTempInteractObj(_objI: int) -> void:
	_hideLabels()
	tempInteractObj = interactObjectsArray[_objI]
	tempHint = hintsArray[_objI]
	_spawnLabels()


func _getClosestObject() -> void:
	#если прячемся, то ничего не проверяем,
	#тк текущим объектом должен быть только тот,
	#в котором гг прячется
	if G.player.hiding_in_prop:
		return
	
	#проверяем и берем текущий объект по расстоянию
	if tempInteractObj != interactObjectsArray[objI]:
		var tempDist = tempInteractObj.global_position.distance_to(G.player.global_position)
		var newDist = interactObjectsArray[objI].global_position.distance_to(G.player.global_position)
		if newDist < tempDist:
			_setTempInteractObj(objI)
	
	
	if G.player.state == G.STATE.HIDING:
		#проверяем character, тк с ними в этом режиме взаимодействовать нельзя
		if tempInteractObj is Character:
			removeInteractObject(tempInteractObj)
		#проверяем hidingSpot на случай, если его кто-то займет раньше
		if tempInteractObj is HidingSpot \
		&& tempInteractObj.my_character != null \
		&& tempInteractObj.my_character != self:
			removeInteractObject(tempInteractObj)
	
	#проверяем Character на случай, если тот спрятался
	#или уже проиграл
	if G.player.state == G.STATE.SEARCHING \
	&& tempInteractObj is Character:
		if tempInteractObj.hiding_in_prop \
		|| tempInteractObj.state != G.STATE.HIDING:
			removeInteractObject(tempInteractObj)
	
	if objI < interactObjectsArray.size() - 1:
		objI += 1
	else:
		objI = 0


func _checkDialogue(body) -> bool:
	if body is Character:
		if body.dialogue_id.length() > 0:
			return true
		if body.phraseCode.length() > 0:
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


func addInteractObject(newObject, hint) -> void:
	if tempInteractObj == null:
		tempInteractObj = newObject
		tempHint = hint
	interactObjectsArray.append(newObject)
	hintsArray.append(hint)
	_spawnLabels()


func removeInteractObject(object) -> void:
	objI = 0
	if !object in interactObjectsArray:
		return
	var deleteObjI = interactObjectsArray.find(object)
	interactObjectsArray.remove(deleteObjI)
	hintsArray.remove(deleteObjI)
	if (interactObjectsArray.size() == 1):
		_setTempInteractObj(0)
	if (interactObjectsArray.size() == 0):
		_hideLabels()
		tempInteractObj = null


func clearInteractObjects() -> void:
	objI = 0
	interactObjectsArray.clear()
	_hideLabels()
	tempInteractObj = null


func _on_interactArea_body_entered(body):
	if body == G.player:
		return
	
	if _checkDialogue(body):
		addInteractObject(body, "dialogue")
	
	var hideButton = _checkHideSpot(body)
	if hideButton != "":
		addInteractObject(body, hideButton)


func _on_interactArea_body_exited(body):
	if body in interactObjectsArray:
		removeInteractObject(body)


func _process(_delta):
	if interactObjectsArray.size() > 0:
		_getClosestObject()
	
	if tempInteractObj && !G.player.isWaiting():
		_showLabels()
		if (Input.is_action_just_pressed(useButtons[tempHint])):
			tempInteractObj.interact(self)
			if tempHint == "search":
				G.player.waitTime = G.player.SEARCH_WAIT_TIME
			if tempHint == "find":
				G.player.sayAfterSearching(true, tempInteractObj)
	else:
		_hideLabels()
