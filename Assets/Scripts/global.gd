extends Node

#-----
#настроен на синглтон "G" через интерфейс движка
#-----

enum STATE {IDLE, SEARCHING, HIDING}

const HIDING_TIME = 10

var player: Character
var dialogueMenu: Control
var timer: Label
var randomSpots: Array


func getPhrase(female: bool, section: String, phrase: String):
	var tempSex = "male"
	if female:
		tempSex = "female"
	var phrasesArray = dialogueMenu.phrases[tempSex][section][phrase]
	var phraseI = randi() % phrasesArray.size()
	return phrasesArray[str(phraseI)]
