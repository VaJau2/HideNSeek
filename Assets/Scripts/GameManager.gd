extends Node

#-----
# Управляет правилами игры
# Определяет состояние игроков (ведущий, пряущийся, проигравший)
#-----

const DIALOGUE_CODE = {
	"START": "Start",
	"CHOOSE" : "Choose",
	"AGAIN_HIDING": "AgainHiding",
	"AGAIN_SEARCHING": "AgainSearching"
}

onready var background = get_node("canvas/background")
onready var gameLabel = get_node("canvas/Timer")

var allCharacters = []
var startPlaces = []

var hidingCharacters = []
var searchingCharacter: Character
var firstFoundCharacter = null


func addCharacter(character) -> void:
	allCharacters.append(character)


func getHidingCount() -> int:
	return hidingCharacters.size()


func findCharacter(character) -> void:
	if firstFoundCharacter == null:
		firstFoundCharacter = character
	
	hidingCharacters.erase(character)
	character.setState(G.STATE.LOST)
	if hidingCharacters.size() == 0:
		G.timer.finishTimer()
	else:
		G.timer.addTime(G.ADD_TIME)


func _savePlaces() -> void:
	startPlaces.clear()
	for character in allCharacters:
		startPlaces.append(character.global_position)


func _resetGame() -> void:
	while background.setBackgroundOn():
		yield(get_tree().create_timer(0.05), "timeout")
	
	gameLabel.visible = false
	for i in range(allCharacters.size()):
		var character = allCharacters[i]
		character.global_position = startPlaces[i]
		character.setState(G.STATE.IDLE)
		if character.get("isStartGameNPC"):
			if firstFoundCharacter == G.player:
				character.dialogue_id = DIALOGUE_CODE.AGAIN_SEARCHING
			else:
				character.dialogue_id = DIALOGUE_CODE.AGAIN_HIDING
	
	while background.setBackgroundOff():
		yield(get_tree().create_timer(0.05), "timeout")


func startGame(newSearchingChar: Character = null) -> void:
	_savePlaces()
	var searchingCharI = 0
	#если не понятно, кто ведущий
	if newSearchingChar == null:
		if firstFoundCharacter == null:
			#берем рандомно из числа неписей
			searchingCharI = int(rand_range(1, allCharacters.size()))
			newSearchingChar = allCharacters[searchingCharI]
		else:
			#или первого, которого нашли в предыдущем раунде
			newSearchingChar = firstFoundCharacter
			searchingCharI = allCharacters.find(newSearchingChar)
	else:
		searchingCharI = allCharacters.find(newSearchingChar)
	firstFoundCharacter = null
	
	for i in range(allCharacters.size()):
		if i != searchingCharI:
			allCharacters[i].setState(G.STATE.HIDING)
			hidingCharacters.append(allCharacters[i])
	searchingCharacter = newSearchingChar
	searchingCharacter.setState(G.STATE.SEARCHING)
	
	G.timer.startTimer(G.HIDING_TIME)
	
	if searchingCharacter == G.player:
		while background.setBackgroundOn():
			yield(get_tree().create_timer(0.05), "timeout")
	
	yield(G.timer, "timeout")
	
	if searchingCharacter == G.player:
		while background.setBackgroundOff():
			yield(get_tree().create_timer(0.05), "timeout")
	
	G.timer.startTimer(G.SEARCHING_TIME)
	yield(G.timer, "timeout")
	_finishGame()


func _finishGame():
	for character in allCharacters:
		character.setState(G.STATE.IDLE)
	
	if hidingCharacters.size() > 0:
		gameLabel.visible = true
		gameLabel.text = "Ведущий не успел всех найти"
		firstFoundCharacter = searchingCharacter
	else:
		gameLabel.visible = true
		gameLabel.text = "Все игроки были найдены!"
	yield(get_tree().create_timer(1.5), "timeout")
	_resetGame()
