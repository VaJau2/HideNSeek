extends KinematicBody2D

#-----
# Базовый скрипт для игрока и неписей
#-----

class_name Character

onready var manager = get_node("/root/Main")
export var female: bool

#переменные состояния
const SEARCH_WAIT_TIME = 0.9

var state = G.STATE.IDLE

enum waitStates {waiting, searching, none}
var waitState = waitStates.none
var waitTime = 0

var is_running = false
var is_hiding = false
var hiding_in_prop = false
var myProp = null

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

const SEE_IDLE_INCREMENT   = 1.0
const SEE_HIDING_INCREMENT = 0.5


func showMessage(section: String, phrase: String, timer = 3) -> void:
	var text = G.getPhrase(female, section, phrase)
	messageLabel.text = text
	messageTimer = timer
	messageCount = true


func sayAfterWaiting() -> void:
	if waitState == waitStates.waiting:
		showMessage("searching", "start", 2)
	waitState = waitStates.none


func sayAfterSearching(found: bool, character = null) -> void:
	if found:
		showMessage("searching", "found", 2)
		if character:
			manager.findCharacter(character)


func changeAnimation(newAnimation: String) -> void:
	anim.play(newAnimation)


func changeCollision(layer: int) -> void:
	collision_layer = layer
	collision_mask = layer


func changeParent(new_parent) -> void:
	var pos = global_position
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_position = pos


func setHide(hide_on: bool) -> void:
	is_hiding = hide_on
	changeAnimation("hide" if is_hiding else "idle")


func setState(newState) -> void:
	state = newState
	if state == G.STATE.SEARCHING:
		changeAnimation("wait")
		waitTime = G.HIDING_TIME
		waitState = waitStates.waiting
	if state == G.STATE.LOST:
		changeCollision(2)
	else:
		changeCollision(1)


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


func getSeeValueIncrement() -> float:
	if hiding_in_prop: return -1.0
	if is_hiding: return SEE_HIDING_INCREMENT
	return SEE_IDLE_INCREMENT


func _checkIceWalking() -> void:
	var cellCoords = iceMap.world_to_map(position)
	var cellNum = iceMap.get_cell(cellCoords.x - 3, cellCoords.y - 3)
	if (cellNum == -1):
		acceleration = MATERIAL_ACCELS.snow
	else:
		acceleration = MATERIAL_ACCELS.ice


func _ready():
	manager.addCharacter(self)


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
		velocity = move_and_slide(velocity)
