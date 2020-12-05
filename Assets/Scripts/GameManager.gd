extends Node

#-----
# Управляет правилами игры
# Определяет состояние игроков (ведущий, пряущийся, проигравший)
#-----

onready var background = get_node("canvas/background")
onready var gameLabel = get_node("canvas/Timer")

var allCharacters = []
var startPlaces = []

var hidingCharacters = []
var searchingCharacter: Character


func addCharacter(character) -> void:
	allCharacters.append(character)


func getHidingCount() -> int:
	return hidingCharacters.size()


func findCharacter(character) -> void:
	if hidingCharacters.size() == 0:
		return
	
	hidingCharacters.erase(character)
	character.setState(G.STATE.LOST)
	if hidingCharacters.size() == 0:
		for character in allCharacters:
			character.setState(G.STATE.IDLE)
		gameLabel.visible = true
		gameLabel.text = "Все игроки были найдены!"
		yield(get_tree().create_timer(1.5), "timeout")
		_resetGame()


func _savePlaces() -> void:
	startPlaces.clear()
	for character in allCharacters:
		startPlaces.append(character.global_position)


func _resetGame() -> void:
	while background.setBackgroundOn():
		yield(get_tree().create_timer(0.05), "timeout")
	
	gameLabel.visible = false
	for i in range(allCharacters.size()):
		allCharacters[i].global_position = startPlaces[i]
		allCharacters[i].setState(G.STATE.IDLE)
	
	while background.setBackgroundOff():
		yield(get_tree().create_timer(0.05), "timeout")


func startGame(searchingNPC: Character) -> void:
	_savePlaces()
	var searchingCharI = allCharacters.find(searchingNPC)
	for i in range(allCharacters.size()):
		if i != searchingCharI:
			allCharacters[i].setState(G.STATE.HIDING)
			hidingCharacters.append(allCharacters[i])
	searchingCharacter = searchingNPC
	searchingNPC.setState(G.STATE.SEARCHING)
	
	G.timer.StartTimer(G.HIDING_TIME)
