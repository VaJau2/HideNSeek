extends KinematicBody2D

#-----
# Базовый скрипт для игрока и неписей
#-----

class_name Character

#переменные состояния
#TODO: добавить состояние is_searching
var is_hiding = false
var hiding_in_prop = false
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
var messageCount = false

const MATERIAL_ACCELS = {
	"snow": 1000,
	"ice": 400
}

func ShowMessage(text: String, timer = 3) -> void:
	messageLabel.text = text
	messageTimer = timer
	messageCount = true


func ChangeAnimation(newAnimation: String) -> void:
	anim.current_animation = newAnimation


func Hide(hide_on: bool) -> void:
	is_hiding = hide_on
	
	if is_hiding:
		ChangeAnimation("hide")
	else:
		ChangeAnimation("idle")


func _checkIceWalking() -> void:
	var cellCoords = iceMap.world_to_map(position)
	var cellNum = iceMap.get_cell(cellCoords.x - 3, cellCoords.y - 3)
	if (cellNum == -1):
		acceleration = MATERIAL_ACCELS.snow
	else:
		acceleration = MATERIAL_ACCELS.ice


func _process(delta):
	if velocity.length() > 0:
		_checkIceWalking()
	
	if messageCount:
		if messageTimer > 0:
			messageTimer -= delta
		else:
			messageCount = false
			messageLabel.text = ""


func _physics_process(_delta):
	if (velocity.length() > 0):
		move_and_slide(velocity)
