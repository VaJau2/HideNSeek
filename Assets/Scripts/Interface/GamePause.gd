extends ColorRect

var paused = false


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		paused = !paused
		get_tree().paused = paused
		visible = paused
