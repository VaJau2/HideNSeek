extends Character

#TODO:
#добавить неписям режим ведущего и прячущегося

const RUN_DISTANCE = 150
const CLOSE_DISTANCE = 35

export var dialogue_id: String
export var message_text: String

var tempInteractArea = null
var targetPlace = null
var tempCloseDistance = CLOSE_DISTANCE

signal cameToPlace


func goTo(object: Node2D, distance = null) -> void:
	targetPlace = object.global_position
	tempCloseDistance = CLOSE_DISTANCE
	if distance:
		tempCloseDistance = distance


func interact(interactArea):
	if dialogue_id.length() > 0:
		tempInteractArea = interactArea
		tempInteractArea.HideLabels = true
		G.dialogueMenu.StartDialogue(self, dialogue_id)
	elif message_text.length() > 0:
		showMessage(message_text)


func afterInteract():
	if tempInteractArea:
		tempInteractArea.HideLabels = false


func _ready():
	changeAnimation("idle")


func _process(delta):
	dir = Vector2(0, 0)
	is_running = false
	
	if targetPlace != null:
		var tempDistance = global_position.distance_to(targetPlace)
		if tempDistance > tempCloseDistance:
			dir = global_position.direction_to(targetPlace).normalized()
			sprite.flip_h = (dir.x < 0)
			is_running    = (tempDistance > RUN_DISTANCE)
		else:
			targetPlace = null
			emit_signal("cameToPlace")
	
	updateVelocity(delta)
	
	if (Input.is_action_just_pressed("ui_page_up")):
		goTo(G.player, 50)
