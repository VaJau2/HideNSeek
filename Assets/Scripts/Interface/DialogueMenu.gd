extends Control

#-----
# Скрипт окошка диалога
# Взял из фалида, слегка поправил
# Сам хз, как работает)))0
#-----

const TEXT_SPEED = 2

onready var inputs = get_node("../gamepadCheck")
onready var manager = get_node("/root/Main")

onready var dialogueMenu: ColorRect = get_node("DialogueBackground")
onready var dialogueText: Label = get_node("DialogueBackground/DialogueText")
onready var skipButton: Label = get_node("DialogueBackground/SpaceToContinue")

onready var buttons: Control = get_node("DialogueBackground/Buttons")
onready var yesButton: Control = buttons.get_node("Yes")
onready var yesSelectedBack: Control = buttons.get_node("Yes/selected")
onready var noButton: Control = buttons.get_node("No")
onready var noSelectedBack: Control = buttons.get_node("No/selected")
var yesSelected = true

var NPC
var tempDialogueId: String
var TextArray: Array
var needAnswerId = -1
var i = 0
var onetime = false

export (String, FILE, "*.json") var dialogue_file_path: String
var dialogues: Dictionary
var phrases: Dictionary
var is_animating = false


func isOn() -> bool:
	return dialogueMenu.is_visible()


func animateText():
	is_animating = true
	dialogueText.percent_visible = 0


func leftOrRightPressed() -> bool:
	return (Input.is_action_just_pressed("ui_left") || 
			Input.is_action_just_pressed("ui_right"))


func updateDialogueText():
	dialogueText.text = TextArray[i]
	animateText()


func StartDialogue(character, phrase = ""):
	i = 0
	NPC = character
	tempDialogueId = phrase
	if phrase == null:
		tempDialogueId = character.dialogue_id
	skipButton.text = inputs.getInterfaceText("skip")
	TextArray = [] #стираем прошлый диалог
	buttons.visible = false
	#проходим по словарю всех диалогов и заполняем его новыми значениями
	for phrase_num in dialogues[tempDialogueId]:
		var tempDict = dialogues[tempDialogueId][phrase_num]
		TextArray.append(tempDict["text"])
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
			match tempDialogueId:
				manager.DIALOGUE_CODE.START:
					if yesSelected:
						StartDialogue(NPC, manager.DIALOGUE_CODE.CHOOSE)
						return
				manager.DIALOGUE_CODE.CHOOSE:
					if yesSelected:
						manager.startGame(G.player)
					else:
						manager.startGame()
				_:
					if yesSelected:
						manager.startGame()
		
		if (NPC.has_method("afterInteract")):
			NPC.afterInteract()
		dialogueMenu.hide()
		G.player.mayMove = true


func _ready():
	G.dialogueMenu = self
	dialogues = G.loadFile(dialogue_file_path)


func _process(delta):
	if is_animating:
		if (dialogueText.percent_visible < 1):
			dialogueText.percent_visible += delta * TEXT_SPEED
		else:
			is_animating = false
			if (i == needAnswerId):
				buttons.visible = true


func _input(_event):
	if isOn():
		if Input.is_action_just_pressed("ui_accept"):
			if is_animating:
				dialogueText.percent_visible = 1
			else:
				ClickNext()
		
		if buttons.visible:
			if leftOrRightPressed():
				yesSelected = !yesSelected
				yesSelectedBack.visible = yesSelected
				noSelectedBack.visible = !yesSelected
