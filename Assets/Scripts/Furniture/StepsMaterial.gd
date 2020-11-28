extends Area2D


func _on_body_entered(body):
	if body is Character:
		body.audi.land_material = name


func _on_body_exited(body):
	if body is Character:
		body.audi.land_material = "snow"
