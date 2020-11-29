extends KinematicBody2D

#-----
# Базовый скрипт для игрока и неписей
#-----

class_name Character

#переменные состояния
var state = G.STATE.IDLE

enum waitStates {waiting, searching, none}
var waitState = waitStates.none

var is_running = false
var is_hiding = false
var hiding_in_prop = false

#переменные для перемещения
onready var audi = get_node("audi")
onready var anim = get_node("anim")
onready var sprite = get_node("Sprite")
onready var iceMap = get_node("/root/Main/tiles/ice")
var velocity = Vector2()
var dir = Vector2()
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


func changeAnimation(newAnimation: String) -> void:
	anim.current_animation = newAnimation


func setHide(hide_on: bool) -> void:
	is_hiding = hide_on
	changeAnimation("hide" if is_hiding else "idle")


func updateVelocity(delta: float) -> void:
	var temp_speed = run_speed if (is_running) else speed
	var temp_anim = "idle"
	if dir.length() > 0:
		temp_anim = "run" if (is_running) else "walk"
	
	if !is_hiding && (waitState == waitStates.none):
		velocity = velocity.move_toward(dir * temp_speed, acceleration * delta)
		changeAnimation(temp_anim)
	else:
		velocity = Vector2(0, 0)


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
