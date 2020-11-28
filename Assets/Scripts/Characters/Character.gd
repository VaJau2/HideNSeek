extends KinematicBody2D

class_name Character

var is_hiding = false
var is_running = false

onready var audi = get_node("audi")
onready var anim = get_node("anim")
onready var sprite = get_node("Sprite")
onready var iceMap = get_node("/root/Main/tiles/ice")
var velocity = Vector2()
var speed = 120
var run_speed = 200
var acceleration = 800

onready var messageLabel = get_node("message")
var messageTimer = 0
var messageClearOnetime = false

const MATERIAL_ACCELS = {
	"snow": 1000,
	"ice": 400
}

func showMessage(text: String, timer = 3) -> void:
	messageLabel.text = text
	messageTimer = timer


func changeAnimation(newAnimation: String) -> void:
	anim.current_animation = newAnimation


func setFlipX(flipX: bool) -> void:
	sprite.flip_h = flipX


func checkIceWalking() -> void:
	var cellCoords = iceMap.world_to_map(position)
	var cellNum = iceMap.get_cell(cellCoords.x - 3, cellCoords.y - 3)
	if (cellNum == -1):
		acceleration = MATERIAL_ACCELS.snow
	else:
		acceleration = MATERIAL_ACCELS.ice


func _process(delta) -> void:
	if velocity.length() > 0:
		checkIceWalking()
	
	if messageTimer > 0:
		messageTimer -= delta
		messageClearOnetime = false
	else:
		if !messageClearOnetime:
			messageClearOnetime = true
			messageLabel.text = ""


func _physics_process(_delta) -> void:
	if (velocity.length() > 0):
		move_and_slide(velocity)
