extends Area2D

#-----
# Скрипт для взаимодействия с предметами/неписями
# Обрабатывает массив предметов в радиусе interactArea
# В качестве текущего объекта для взаимодействия берет ближайший
# Вызывает его interact()-метод
#-----

var theme = preload("res://Assets/Fonts/RusFontTheme.tres")

var tempInteractObj = null
var tempHint = "dialogue"
var interactObjectsArray = []
var hintsArray = []
var objI = 0

var leftLabel = null
var rightLabel = null
var hints = {
	"dialogue": "Е - поговорить",
	"hide": "H - спрятаться"
}
var useButtons = {
	"dialogue": "ui_use",
	"hide": "ui_hide"
}

var HideLabels = false


func _spawnLabels() -> void:
	leftLabel = tempInteractObj.get_node("hints/leftLabel")
	rightLabel = tempInteractObj.get_node("hints/rightLabel")
	leftLabel.text = hints[tempHint]
	rightLabel.text = hints[tempHint]


func _showLabels() -> void:
	if !HideLabels:
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


func _respawnLabels(objI: int) -> void:
	_hideLabels()
	tempInteractObj = interactObjectsArray[objI]
	tempHint = hintsArray[objI]
	_spawnLabels()


func _objIsLefter() -> bool:
	return tempInteractObj.global_position.x > get_parent().global_position.x


func _getClosestObject():
	if tempInteractObj != interactObjectsArray[objI]:
		var tempDist = tempInteractObj.global_position.distance_to(G.player.global_position)
		var newDist = interactObjectsArray[objI].global_position.distance_to(G.player.global_position)
		if newDist < tempDist:
			_respawnLabels(objI)
	
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


func _checkHideSpot(body) -> bool:
	if G.player.state == G.STATE.HIDING:
		if body is HidingSpot && body.my_character == null:
			return true;
	return false;


func _addInteractObject(newObject, hint):
	if tempInteractObj == null:
		tempInteractObj = newObject
		tempHint = hint
	interactObjectsArray.append(newObject)
	hintsArray.append(hint)
	_spawnLabels()


func _on_interactArea_body_entered(body):
	if body.name == "Player":
		return
	
	if _checkDialogue(body):
		_addInteractObject(body, "dialogue")
	
	if _checkHideSpot(body):
		_addInteractObject(body, "hide")


func _on_interactArea_body_exited(body):
	if body in interactObjectsArray:
		objI = 0
		var deleteObjI = interactObjectsArray.find(body)
		interactObjectsArray.remove(deleteObjI)
		hintsArray.remove(deleteObjI)
	
	if (interactObjectsArray.size() == 1):
		_respawnLabels(0)
	if (interactObjectsArray.size() == 0):
		_hideLabels()
		tempInteractObj = null


func _process(_delta):
	if interactObjectsArray.size() > 1:
		_getClosestObject()
		
	if tempInteractObj:
		_showLabels()
		if (Input.is_action_just_pressed(useButtons[tempHint])):
			tempInteractObj.interact(self)
