extends Control

#-----
# Скрипт окошка диалога
# Взял из фалида, слегка поправил
# Сам хз, как работает)))0
#-----

const TEXT_SPEED = 2

onready var dialogueMenu: ColorRect = get_node("DialogueBackground")
onready var dialogueText: Label = get_node("DialogueBackground/DialogueText")
onready var dialogueTextNoIcon: Label = get_node("DialogueBackground/DialogueTextWithoutIcon")
onready var icon: TextureRect = get_node("DialogueBackground/icon")

onready var buttons: Control = get_node("DialogueBackground/Buttons")
onready var yesButton: Control = buttons.get_node("Yes")
onready var yesSelectedBack: Control = buttons.get_node("Yes/selected")
onready var noButton: Control = buttons.get_node("No")
onready var noSelectedBack: Control = buttons.get_node("No/selected")
var yesSelected = true

var tempDialogueLabel
var NPC
var TextArray: Array
var TempIcon: Array
var needAnswerId = -1
var i = 0
var onetime = false

export (String, FILE, "*.json") var dialogue_file_path: String
export (String, FILE, "*.json") var icon_file_path: String
var player_icon = ""
var dialogue_icons: Dictionary
var dialogues: Dictionary
var npc_dialogues: Dictionary
var npc_corridor_dialogues: Dictionary
var is_animating = false


func animateText():
	is_animating = true
	tempDialogueLabel.percent_visible = 0


func leftOrRightPressed() -> bool:
	return (Input.is_action_just_pressed("ui_left") || 
			Input.is_action_just_pressed("ui_right"))


#скорее всего, этот метод потом надо будет удалить
func checkPlayerIcon(icon_name) -> String:
	var name_parts = icon_name.split("_")
	if name_parts[0] == "player":
		var newName = ""
		if player_icon.length() > 0:
			name_parts[0] = player_icon + "_"
		for line in name_parts:
			newName += line
		return newName
	return icon_name


func updateDialogueText():
	if TempIcon[i]:
		dialogueTextNoIcon.text = ""
		tempDialogueLabel = dialogueText
		icon.texture = TempIcon[i]
	else:
		dialogueText.text = ""
		tempDialogueLabel = dialogueTextNoIcon
		icon.texture = null
	tempDialogueLabel.text = TextArray[i]
	animateText()


func StartDialogue(character, phrase = null):
	i = 0
	NPC = character
	var dialogue_id = phrase
	if phrase == null:
		dialogue_id = character.dialogue_id
	TextArray = [] #стираем прошлый диалог
	TempIcon = []
	icon.texture = null
	buttons.visible = false
	#проходим по словарю всех диалогов и заполняем его новыми значениями
	for phrase_num in dialogues[dialogue_id]:
		var tempDict = dialogues[dialogue_id][phrase_num]
		TextArray.append(tempDict["text"])
		var icon_name = tempDict["icon"]
		if icon_name != "-":
			if player_icon.length() > 0:
				icon_name = checkPlayerIcon(icon_name)
			TempIcon.append(dialogue_icons[icon_name])
		else:
			TempIcon.append(null)
		if(tempDict.has("needAnswer") && tempDict["needAnswer"] == "true"):
			needAnswerId = int(phrase_num)
	
	if TextArray.size() > 0:
		updateDialogueText()
		dialogueMenu.show()
		G.player.mayMove = false


func ClickNext():
	if i < TextArray.size() - 1:
		i += 1
		updateDialogueText()
	else:
		if buttons.visible:
			#TODO:
			#убрать смену режима игры
			#когда закончится разработка hiding-режима
			if yesSelected:
				G.state = G.GAME_STATE.HIDING
				
		if (NPC.has_method("afterInteract")):
			NPC.afterInteract()
		dialogueMenu.hide()
		G.player.mayMove = true


func loadDialogues():
	var file = File.new()
	file.open(dialogue_file_path, file.READ)
	var temp_dialogues = parse_json(file.get_as_text())
	for dialogue in temp_dialogues:
		dialogues[dialogue] = temp_dialogues[dialogue]


func loadIcons():
	var file = File.new()
	file.open(icon_file_path, file.READ)
	var icons_place = parse_json(file.get_as_text())
	
	for character_key in icons_place.keys():
		for icon_key in icons_place[character_key].keys():
			var new_key = character_key + "_" + icon_key
			var new_value = load(icons_place[character_key][icon_key])
			dialogue_icons[new_key] = new_value


func _ready():
	G.dialogueMenu = self
	if dialogues.size() == 0 && dialogue_file_path:
		loadDialogues()
	if (icon_file_path):
		loadIcons()


func _process(delta):
	if is_animating:
		if (tempDialogueLabel.percent_visible < 1):
			tempDialogueLabel.percent_visible += delta * TEXT_SPEED
		else:
			is_animating = false
			if (i == needAnswerId):
				buttons.visible = true


func _input(event):
	if dialogueMenu.is_visible():
		if Input.is_action_just_pressed("ui_accept"):
			if is_animating:
				tempDialogueLabel.percent_visible = 1
			else:
				ClickNext()
		
		if buttons.visible:
			if leftOrRightPressed():
				yesSelected = !yesSelected
				yesSelectedBack.visible = yesSelected
				noSelectedBack.visible = !yesSelected
