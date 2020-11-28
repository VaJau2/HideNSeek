extends Node2D

class_name HidingSpot

const OPEN_TIMER = 0.5
export var open_sprite: Resource
export var hide_animation = "hide"

onready var sprite = get_node("Sprite")
onready var hidePlace = get_node("hidePlace")
onready var ySort = get_node("/root/Main/YSort")
var oldPlace = Vector2()
var close_sprite
var is_busy = false


func _ready():
	close_sprite = sprite.texture


func _changeCollision(layer):
	G.player.collision_layer = layer
	G.player.collision_mask = layer
	

func _changeParent(new_parent):
	var pos = G.player.global_position
	G.player.get_parent().remove_child(G.player)
	new_parent.add_child(G.player)
	G.player.global_position = pos


func interact(interactArea, character = G.player):
	interactArea.HideLabels = character.is_hiding
	
	if character.is_hiding:
		if is_busy:
			print("character " + str(character.name) + "is trying to hide in busy spot")
			return
		
		_changeCollision(0)
		_changeParent(hidePlace)
		oldPlace = character.global_position
		character.global_position = hidePlace.global_position
		character.changeAnimation(hide_animation)
		sprite.texture = open_sprite
		yield(get_tree().create_timer(OPEN_TIMER), "timeout")
		sprite.texture = close_sprite
		is_busy = true
	else:
		character.global_position = oldPlace
		_changeCollision(1)
		_changeParent(ySort)
		is_busy = false
