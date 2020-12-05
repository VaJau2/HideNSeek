extends Node2D

#-----
# Скрипт для обьектов, в которых можно спрятаться
#-----

class_name HidingSpot

const OPEN_TIMER = 0.5

var my_character = null

export var open_sprite: Resource
export var hide_animation = "hide"
export var free_camera_radius = 200

onready var sprite = get_node("Sprite")
onready var hidePlace = get_node("hidePlace")
onready var ySort = get_node("/root/Main/YSort")
var oldPlace = Vector2()
var close_sprite

var may_interact = true


func _ready():
	close_sprite = sprite.texture


func search(searchingNPC = null) -> void:
	sprite.texture = open_sprite
	var is_busy = my_character != null
	may_interact = false
	yield(get_tree().create_timer(OPEN_TIMER), "timeout")
	may_interact = true
	var tempCharacter = my_character
	
	if is_busy:
		var interactArea = null
		if my_character == G.player:
			interactArea = G.player.interactArea
		my_character.setState(G.STATE.LOST)
		my_character.setHide(false)
		interact(interactArea, my_character)
	
	if searchingNPC != null:
		searchingNPC.sayAfterSearching(is_busy, tempCharacter)
	
	yield(get_tree().create_timer(OPEN_TIMER), "timeout")
	sprite.texture = close_sprite


# Character прячется через свой стандартный метод, затем вызывает interact
# Проп перемещает его внутрь себя
func interact(interactArea = null, character = G.player) -> void:
	if !may_interact:
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
			character.hidingCamera.setCurrent(global_position, free_camera_radius)
		
		my_character = character
		character.changeCollision(0)
		character.changeParent(hidePlace)
		oldPlace = character.global_position
		character.global_position = hidePlace.global_position
		character.changeAnimation(hide_animation)
		sprite.texture = open_sprite
		yield(get_tree().create_timer(OPEN_TIMER), "timeout")
		sprite.texture = close_sprite
	else:
		character.global_position = oldPlace
		character.changeCollision(1)
		character.changeParent(ySort)
		my_character = null
	
	if interactArea != null:
			interactArea.tempInteractObj = self if character.is_hiding else null
