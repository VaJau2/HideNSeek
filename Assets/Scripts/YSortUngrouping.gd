extends YSort

#-----
# Перемещает все сгруппированные объекты из группы sorting в YSort
# Перемещает всех пней в исходные позиции при перезагрузке игры
#-----

onready var background = get_node("/root/Main/canvas/background")
var characters = []
var startPlaces = []


#плавное затемнение экрана
func setBackgroundOn() -> bool:
	background.color.a += 0.1
	return background.color.a < 1


#плавное растемнение экрана
func setBackgroundOff() -> bool:
	background.color.a -= 0.1
	return background.color.a > 0


func addCharacter(character):
	characters.append(character)
	startPlaces.append(character.global_position)


func resetPlaces():
	for i in range(characters.size()):
		characters[i].global_position = startPlaces[i]


func _moveToYSort(oldParent, movingObj):
	var pos = movingObj.global_position
	oldParent.remove_child(movingObj)
	add_child(movingObj)
	movingObj.global_position = pos


func _ready():
	G.ySort = self
	for group in get_tree().get_nodes_in_group("sorting"):
		for child in group.get_children():
			_moveToYSort(group, child)
		group.queue_free()
