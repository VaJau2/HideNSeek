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


func _changeCollision(layer) -> void:
	G.player.collision_layer = layer
	G.player.collision_mask = layer
	

func _changeParent(new_parent) -> void:
	var pos = G.player.global_position
	G.player.get_parent().remove_child(G.player)
	new_parent.add_child(G.player)
	G.player.global_position = pos


func search(searchingNPC = null) -> void:
	sprite.texture = open_sprite
	var is_busy = my_character != null
	may_interact = false
	yield(get_tree().create_timer(OPEN_TIMER), "timeout")
	may_interact = true
	
	if is_busy:
		var interactArea = null
		if my_character == G.player:
			interactArea = G.player.interactArea
		my_character.setHide(false)
		interact(interactArea, my_character)
	
	if searchingNPC != null:
		searchingNPC.sayAfterSearching(is_busy)
	
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
			print("character " + str(character.name) + "is trying to hide in busy spot")
			return
		if character == G.player:
			character.hidingCamera.setCurrent(global_position, free_camera_radius)
		
		_changeCollision(0)
		_changeParent(hidePlace)
		oldPlace = character.global_position
		character.global_position = hidePlace.global_position
		character.changeAnimation(hide_animation)
		sprite.texture = open_sprite
		yield(get_tree().create_timer(OPEN_TIMER), "timeout")
		sprite.texture = close_sprite
		my_character = character
	else:
		character.global_position = oldPlace
		_changeCollision(1)
		_changeParent(ySort)
		my_character = null
