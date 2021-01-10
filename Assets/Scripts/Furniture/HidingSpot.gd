extends Node2D

#-----
# Скрипт для обьектов, в которых можно спрятаться
#-----

class_name HidingSpot

const OPEN_TIMER = 0.5

var my_character = null

export var open_sprite: Resource
export var hide_animation = "hide"
export var free_camera_scale = 1

onready var sprite = get_node("Sprite")
onready var hidePlace = get_node("hidePlace")
onready var ySort = get_node("/root/Main/YSort")
var oldPlace = Vector2()
var close_sprite

var may_interact = true


func _ready():
	close_sprite = sprite.texture


func search(searchingChar) -> void:
	searchingChar.changeAnimation("use")
	sprite.texture = open_sprite
	var is_busy = my_character != null
	may_interact = false
	yield(get_tree().create_timer(OPEN_TIMER), "timeout")
	may_interact = true
	
	searchingChar.sayAfterSearching(is_busy, my_character)
	
	yield(get_tree().create_timer(OPEN_TIMER), "timeout")
	sprite.texture = close_sprite


# Character прячется через свой стандартный метод, затем вызывает interact
# Проп перемещает его внутрь себя
func interact(interactArea = null, character = G.player) -> void:
	if !may_interact:
		return 
	
	if character.state == G.STATE.SEARCHING:
		search(character)
		return
	
	if interactArea != null:
		interactArea.hideLabels = character.is_hiding
	character.hiding_in_prop = character.is_hiding
	
	if character.is_hiding:
		if my_character != null:
			character.hiding_in_prop = false
			character.setHide(false)
			return
		if character == G.player:
			character.cameraBlock.global_position = global_position
			character.hidingCamera.setCurrent(free_camera_scale)
		
		my_character = character
		character.myProp = self
		character.changeCollision(0)
		character.changeParent(hidePlace)
		oldPlace = character.global_position
		character.global_position = hidePlace.global_position
		character.changeAnimation(hide_animation)
		sprite.texture = open_sprite
		yield(get_tree().create_timer(OPEN_TIMER), "timeout")
		sprite.texture = close_sprite
	else:
		if oldPlace != Vector2.ZERO:
			character.global_position = oldPlace
		
		if character.is_player:
			character.changeCollision(1)
		elif character.state != G.STATE.LOST:
			character.changeCollision(2)
		character.changeParent(ySort)
		character.myProp = null
		my_character = null
	
	if interactArea != null:
		interactArea.tempInteractObj = self if character.is_hiding else null
