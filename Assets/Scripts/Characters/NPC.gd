extends Character

#TODO:
#добавить неписям режим ведущего и прячущегося

export var dialogue_id: String
export var message_text: String

var tempInteractArea = null


func interact(interactArea):
	if dialogue_id.length() > 0:
		tempInteractArea = interactArea
		tempInteractArea.HideLabels = true
		G.dialogueMenu.StartDialogue(self, dialogue_id)
	elif message_text.length() > 0:
		ShowMessage(message_text)


func afterInteract():
	if tempInteractArea:
		tempInteractArea.HideLabels = false


func _ready():
	ChangeAnimation("idle")
