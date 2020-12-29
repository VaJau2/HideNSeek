extends Node

#-----
#настроен на синглтон "G" через интерфейс движка
#-----

enum STATE {IDLE, SEARCHING, HIDING, LOST}
const HIDING_TIME = 10
const SEARCHING_TIME = 60
const ADD_TIME = 20

var player: Character
var dialogueMenu: Control
var timer: Label
var randomSpots: Array
var currentCamera: Camera2D


func getPhrase(_name: String, section: String, phrase: String):
	var phrasePath = "res://Assets/json/phrases/" + _name + ".json"
	var phraseData = loadFile(phrasePath)
	var phrasesArray = phraseData[section][phrase]
	randomize()
	var phraseI = randi() % phrasesArray.size()
	return phrasesArray[str(phraseI)]


func loadFile(file_path) -> Dictionary:
	var file = File.new()
	file.open(file_path, file.READ)
	return parse_json(file.get_as_text())
