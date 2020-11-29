extends AudioStreamPlayer2D

#-----
# Озучивает шаги для всех Character
#-----

const STEP_COOLDOWN = 0.5
const STEP_RUN_COOLDOWN = 0.55

const STEP_SOUNDS_COUNT = 3

var timer = 0
var stepI = 0

var land_material = "snow"
onready var parent = get_parent()

var steps = {}
var stepsRun = {}

func _ready():
	var tempMaterials = ["snow", "wood", "dirt", "ice"]
	for material in tempMaterials:
		steps[material] = []
		stepsRun[material] = []
		for i in range(STEP_SOUNDS_COUNT):
			steps[material].append(
				load("res://assets/audio/steps/" + material + "/walk" + str(i + 1) + ".wav")
			)
			# звуки бега на мосту нинужны, тк мосты маленькие
			if material != "wood":
				stepsRun[material].append(
					load("res://assets/audio/steps/" + material + "/run" + str(i + 1) + ".wav")
				)


func _process(delta):
	if parent.velocity.length() > 0:
		if timer > 0:
			timer -= delta
		else:
			if parent.is_running:
				if (stepsRun[land_material]):
					parent.audi.stream = stepsRun[land_material][stepI]
				else:
					parent.audi.stream = steps[land_material][stepI]
				timer = STEP_RUN_COOLDOWN
			else:
				parent.audi.stream = steps[land_material][stepI]
				timer = STEP_COOLDOWN
			parent.audi.play()
			
			var oldI = stepI
			stepI = randi() % STEP_SOUNDS_COUNT
			while oldI == stepI:
				stepI = randi() % STEP_SOUNDS_COUNT
