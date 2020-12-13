extends Area2D

#-----
# Делает дома полупрозрачными
# Когда туда заходит игрок
#-----

onready var sprite: Sprite = get_node("../Sprite")


func _on_opacityArea_body_entered(body):
	if body == G.player:
		sprite.modulate.a = 0.6


func _on_opacityArea_body_exited(body):
	if body == G.player:
		sprite.modulate.a = 1
