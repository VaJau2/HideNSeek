extends Character

#-----
# Скрипт для неписей обоих видов 
# тк хз как здесь делать смену класса при смене типа
#-----

#переменные для диалогов
export var female: bool
export var dialogue_id: String
export var phraseSection: String
export var phraseCode: String
var tempInteractArea = null
var startDialogueId = ""

#переменные для навигации по карте
const RUN_DISTANCE = 150
const CLOSE_DISTANCE = 35
const PATH_DISTANCE = 20
const WAIT_TIME = 0.5
const SEARCH_WAIT_TIME = 1
var waitTime = 0

var targetPlace = null
var tempCloseDistance = CLOSE_DISTANCE

onready var navigation = get_node("/root/Main/navigation")
var path: PoolVector2Array

#переменные для ведущего
const SEARCH_CHANCE = 0.7
const FAIL_SAY_CHANCE = 0.5
const SEARCHED_PLACES_COUNT = 7
onready var seekArea = get_node("seekArea")
var searchedPlaceNames = []

#переменные для прячущегося
const HIDE_CHANCE = 0.8


func showMessage(section: String, phrase: String, timer = 3) -> void:
	var text = G.getPhrase(female, section, phrase)
	messageLabel.text = text
	messageTimer = timer
	messageCount = true


func setState(newState) -> void:
	state = newState
	match newState:
		G.STATE.IDLE:
			if startDialogueId.length() > 0:
				dialogue_id = "TestAgain"
				targetPlace = null
		G.STATE.SEARCHING:
			dialogue_id = ""
			waitTime = G.HIDING_TIME
			waitState = waitStates.waiting
			changeAnimation("wait")
			if !(self in get_parent().characters):
				get_parent().addCharacter(self)


func goTo(object: Node2D, distance = null) -> void:
	targetPlace = object
	path = navigation.get_simple_path(global_position, targetPlace.global_position)
	
	tempCloseDistance = CLOSE_DISTANCE
	if distance:
		tempCloseDistance = distance


func _getRandomPoint() -> void:
	if state == G.STATE.IDLE || is_hiding:
		return
	
	if targetPlace == null:
		var newPlace = null
		var randNum = randi() % G.randomSpots.size()
		newPlace = G.randomSpots[randNum]
		goTo(newPlace)


func setFlipX(flipOn: bool) -> void:
	if sprite.flip_h != flipOn:
		seekArea.position.x *= -1
	sprite.flip_h = flipOn


func sayAfterSearching(found: bool) -> void:
	if found:
		showMessage("searching", "found", 2)
		setState(G.STATE.IDLE)
		G.player.setState(G.STATE.IDLE)
	else:
		if randf() <= FAIL_SAY_CHANCE:
			showMessage("searching", "fail", 2)


func _sayAfterWaiting() -> void:
	if waitState == waitStates.waiting:
		showMessage("searching", "start", 2)


func _updateWalking(delta) -> void:
	if waitTime > 0:
		waitTime -= delta
	elif targetPlace != null:
		_sayAfterWaiting()
		waitState = waitStates.none
		var targetPosition = targetPlace.global_position
		var tempDistance = global_position.distance_to(targetPosition)
		if tempDistance > tempCloseDistance:
			is_running = (tempDistance > RUN_DISTANCE)
			
			var pathDistance = global_position.distance_to(path[0])
			if pathDistance > PATH_DISTANCE:
				dir = global_position.direction_to(path[0]).normalized()
				setFlipX(dir.x < 0)
			else:
				if path.size() > 1:
					path.remove(0)
		else:
			#когда нпц пришел к точке
			waitTime = WAIT_TIME
			if targetPlace is HidingSpot:
				if state == G.STATE.HIDING:
					setHide(true)
					targetPlace.interact(null, self)
				if state == G.STATE.SEARCHING:
					waitState = waitStates.searching
					changeAnimation("use")
					targetPlace.search(self)
					waitTime = SEARCH_WAIT_TIME
			targetPlace = null


#TODO: добавить Character'ов
func _on_seekArea_body_entered(body):
	if state == G.STATE.HIDING:
		if body is HidingSpot \
			&& !(targetPlace is HidingSpot) \
			&& randf() <= HIDE_CHANCE:
				goTo(body)
	
	if state == G.STATE.SEARCHING:
		if body is HidingSpot \
			&& !(targetPlace is HidingSpot) \
			&& !(body.name in searchedPlaceNames) \
			&& randf() <= SEARCH_CHANCE:
				goTo(body)
				searchedPlaceNames.append(body.name)
				if searchedPlaceNames.size() == SEARCHED_PLACES_COUNT:
					searchedPlaceNames.clear()


#TODO: добавить Character'ов
func _on_seekArea_body_exited(body):
	pass 


func interact(interactArea) -> void:
	if dialogue_id.length() > 0:
		setFlipX(G.player.global_position.x < global_position.x)
		tempInteractArea = interactArea
		tempInteractArea.HideLabels = true
		G.dialogueMenu.StartDialogue(self, dialogue_id)
	elif phraseSection.length() > 0:
		showMessage(phraseSection, phraseCode)


func afterInteract() -> void:
	if tempInteractArea:
		tempInteractArea.HideLabels = false


func _ready():
	changeAnimation("idle")
	startDialogueId = dialogue_id


func _process(delta):
	dir = Vector2(0, 0)
	is_running = false
	
	_getRandomPoint()
	_updateWalking(delta)
	updateVelocity(delta)
