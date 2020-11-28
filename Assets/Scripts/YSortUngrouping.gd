extends YSort

# Перемещает все сгруппированные объекты в YSort

func moveToYSort(oldParent, movingObj):
	var pos = movingObj.global_position
	oldParent.remove_child(movingObj)
	add_child(movingObj)
	movingObj.global_position = pos


func _ready():
	for group in get_tree().get_nodes_in_group("sorting"):
		for child in group.get_children():
			moveToYSort(group, child)
		group.queue_free()
