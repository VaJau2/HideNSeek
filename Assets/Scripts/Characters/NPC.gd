extends Character

#-----
# Скрипт для неписей обоих видов (searching | hiding)
# тк хз как здесь делать смену класса при смене типа
#-----

#переменные для диалогов
export var dialogue_id    = ""
export var phraseSection = ""
export var phraseCode    = ""
var isStartGameNPC   = false
var startPhrase      = ""
var tempInteractArea = null

#переменные для навигации по карте
const RUN_DISTANCE = 150
const CLOSE_DISTANCE = 45
const PATH_DISTANCE = 20
const WAIT_TIME = 0.5

var targetPlace = null
var targetPosition = Vector2.ZERO
var tempCloseDistance = CLOSE_DISTANCE

onready var navigation = get_node("/root/Main/navigation")
var path: PoolVector2Array

#переменные для ведущего
const SEARCH_CHANCE = 0.87
const SAY_CHANCE = 0.5
const LOST_SAY_CHANCE = 0.05
const SEARCHED_PLACES_COUNT = 8
const NEED_CHECK_VALUE = 0.2
const CHECK_SEE_TIMER = 0.6

var searchedPlaceNames = []
var charactersISee = {} # key = name, values = (character, seeValue)
var lastSeePoint: Vector2
var checkLastSeeTimer = 0

#переменные для прячущегося
const HIDE_CHANCE = 0.8
const UPDATE_FOLLOW_TIME = 1.5
const MIN_HIDING_TIME = 10
const MAX_HIDING_TIME = 60
var update_follow_timer = 0


func setState(newState) -> void:
	.setState(newState)
	if newState == G.STATE.IDLE || newState == G.STATE.LOST:
		if is_hiding: setHide(false)
		if hiding_in_prop: myProp.interact(null, self)
		
		checkLastSeeTimer = 0
		targetPlace       = null
		targetPosition    = Vector2.ZERO
		
		if newState == G.STATE.LOST:
			if (waitState == waitStates.hiding):
				waitState = waitStates.none
				waitTime  = 0
			
			if randf() <= SAY_CHANCE:
				showMessage("hiding", "fail", 2)
		
		if newState == G.STATE.IDLE:
			phraseCode = startPhrase
		return
	
	if newState == G.STATE.SEARCHING:
		waitTime += 0.1
	
	if newState == G.STATE.HIDING:
		if randf() <= SAY_CHANCE:
			showMessage("hiding", "start", 2)
	
	dialogue_id = ""
	phraseCode = ""


func goTo(position: Vector2, distance = null) -> void:
	targetPosition = position
	tempCloseDistance = distance if distance else CLOSE_DISTANCE
	if global_position.distance_to(targetPosition) > tempCloseDistance:
		path = navigation.get_simple_path(global_position, targetPosition)


func _getNextPoint(delta) -> void:
	if state == G.STATE.IDLE || is_hiding:
		return
	
	#преследуем ведущего, если проиграли
	if state == G.STATE.LOST:
		#позиция ведущего обновляется каждую секунду
		#или когда непись пришел на последнюю обновленную позицию
		if update_follow_timer > 0:
			update_follow_timer -= delta
			if targetPosition == Vector2.ZERO:
				update_follow_timer = 0
		else:
			update_follow_timer = UPDATE_FOLLOW_TIME
			targetPlace = manager.searchingCharacter
			goTo(manager.searchingCharacter.global_position, CLOSE_DISTANCE * 2)
	
	if targetPosition == Vector2.ZERO:
		var randNum = randi() % G.randomSpots.size()
		targetPlace = G.randomSpots[randNum]
		goTo(targetPlace.global_position)


func _stopHidingInProp() -> void:
	if is_hiding: setHide(false)
	if hiding_in_prop: myProp.interact(null, self)
	stopWaiting()


func sayAfterSearching(found: bool, character = null) -> void:
	if found:
		.sayAfterSearching(found, character)
	else:
		if randf() <= SAY_CHANCE:
			if manager.getHidingCount() > 1:
				showMessage("searching", "fail", 2)
			else:
				showMessage("searching", "fail_one", 2)



func _interactWithTarget() -> void:
	if targetPlace is HidingSpot:
		if state == G.STATE.HIDING:
			setHide(true)
			targetPlace.interact(null, self)
			waitState = waitStates.hiding
			waitTime  = rand_range(MIN_HIDING_TIME, MAX_HIDING_TIME)
		if state == G.STATE.SEARCHING:
			targetPlace.interact(null, self)
			waitState = waitStates.searching
			waitTime  = SEARCH_WAIT_TIME
	
	if targetPlace is Character && state == G.STATE.LOST:
		var dist = global_position.distance_to(targetPlace.global_position) 
		if dist < RUN_DISTANCE:
			if randf() <= LOST_SAY_CHANCE:
				showMessage("lost", "random", 2)


func _decreaseWaitTime(delta) -> void:
	if waitState == waitStates.hiding:
		#если ведущий в поле видимости, не выходим
		if !(manager.searchingCharacter.name in charactersISee):
			waitTime -= delta
		if !hiding_in_prop:
			stopWaiting()
	else:
		waitTime -= delta



func _updateWalking(delta) -> void:
	if waitTime > 0:
		_decreaseWaitTime(delta)
	elif targetPosition != Vector2.ZERO:
		_stopHidingInProp()
		sayAfterWaiting()
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
			targetPosition = Vector2.ZERO
			waitTime = WAIT_TIME
			if targetPlace != null:
				_interactWithTarget()
				targetPlace = null


#проверяем точку, в которой видели кого-то последний раз
func _checkLastSeePoint(delta) -> bool:
	if checkLastSeeTimer > 0:
		checkLastSeeTimer -= delta
		targetPlace = null
		goTo(lastSeePoint)
	else:
		lastSeePoint = Vector2.ZERO
	
	return checkLastSeeTimer > 0


#проходим по всем неписям в списке видимых, прибавляем их seeValue
#если он больше CHECK_SEE_TIMER, "находим" их
func _checkSeeCharacters(delta) -> void:
	if charactersISee.size() > 0:
		for chName in charactersISee:
			var body = charactersISee[chName].character
			if body.state != G.STATE.HIDING:
				return
			
			var increment = body.getSeeValueIncrement() * delta
			charactersISee[chName].seeValue += increment
			
			#если стоим с закрытыми глазами, но кто-то ждет рядом
			#считаем его замеченным, но пока не палим с:
			if waitState == waitStates.waiting:
				return
			
			#идем проверять
			if charactersISee[chName].seeValue >= NEED_CHECK_VALUE \
			&& lastSeePoint == Vector2.ZERO:
				lastSeePoint = body.global_position
				checkLastSeeTimer = CHECK_SEE_TIMER
				showMessage("searching", "checkSee", 1)
			
			#палим
			if charactersISee[chName].seeValue >= CHECK_SEE_TIMER:
				sayAfterSearching(true, body)


func _on_seekArea_body_entered(body):
	if body == self:
		return
	
	if state == G.STATE.HIDING:
		if body is HidingSpot \
			&& !(targetPlace is HidingSpot) \
			&& body.my_character == null \
			&& randf() <= HIDE_CHANCE:
				targetPlace = body
				goTo(body.global_position)
	
	if state == G.STATE.SEARCHING:
		if body is HidingSpot \
			&& !(targetPlace is HidingSpot) \
			&& !(body.name in searchedPlaceNames) \
			&& randf() <= SEARCH_CHANCE:
				targetPlace = body
				goTo(body.global_position)
				searchedPlaceNames.append(body.name)
				if searchedPlaceNames.size() == SEARCHED_PLACES_COUNT:
					searchedPlaceNames.clear()
	
	if body is Character:
		charactersISee[body.name] = {
			"character": body,
			"seeValue": 0
		}


func _on_seekArea_body_exited(body):
	if body.name in charactersISee.keys():
		charactersISee.erase(body.name)


func interact(interactArea) -> void:
	if state == G.STATE.HIDING:
		setState(G.STATE.LOST)
		return
	if dialogue_id.length() > 0 && !G.dialogueMenu.isOn():
		setFlipX(G.player.global_position.x < global_position.x)
		tempInteractArea = interactArea
		tempInteractArea.hideLabels = true
		G.dialogueMenu.StartDialogue(self, dialogue_id)
	elif phraseCode.length() > 0:
		showMessage(phraseSection, phraseCode)


func afterInteract() -> void:
	if tempInteractArea:
		tempInteractArea.hideLabels = false


func _ready():
	isStartGameNPC = dialogue_id != ""
	startPhrase    = phraseCode
	#чтоб не моргали одинаково
	yield(get_tree().create_timer(randf() * 2), "timeout")
	anim.seek(0, true)


func _process(delta):
	dir = Vector2(0, 0)
	is_running = false
	_updateWalking(delta)
	updateVelocity(delta)
	
	if state == G.STATE.SEARCHING:
		_checkSeeCharacters(delta)
		if _checkLastSeePoint(delta):
			return
	
	_getNextPoint(delta)
