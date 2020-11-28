extends AudioStreamPlayer2D

const STEP_COOLDOWN = 0.5
const STEP_RUN_COOLDOWN = 0.55

var timer = 0
var i = 0

var land_material = "snow"
onready var parent = get_parent()

var steps = {
	"snow": [
		preload("res://assets/audio/steps/snow/walk1.wav"),
		preload("res://assets/audio/steps/snow/walk2.wav"),
		preload("res://assets/audio/steps/snow/walk3.wav"),
	],
	"wood": [
		preload("res://assets/audio/steps/wood/walk1.wav"),
		preload("res://assets/audio/steps/wood/walk2.wav"),
		preload("res://assets/audio/steps/wood/walk3.wav"),
	],
	"dirt": [
		preload("res://assets/audio/steps/dirt/walk1.wav"),
		preload("res://assets/audio/steps/dirt/walk2.wav"),
		preload("res://assets/audio/steps/dirt/walk3.wav"),
	],
	"ice": [
		preload("res://assets/audio/steps/ice/walk1.wav"),
		preload("res://assets/audio/steps/ice/walk2.wav"),
		preload("res://assets/audio/steps/ice/walk3.wav"),
	],
}

var stepsRun = {
	"snow": [
		preload("res://assets/audio/steps/snow/run1.wav"),
		preload("res://assets/audio/steps/snow/run2.wav"),
		preload("res://assets/audio/steps/snow/run3.wav"),
	],
	"wood": [
		preload("res://assets/audio/steps/wood/walk1.wav"),
		preload("res://assets/audio/steps/wood/walk2.wav"),
		preload("res://assets/audio/steps/wood/walk3.wav"),
	],
	"dirt": [
		preload("res://assets/audio/steps/dirt/run1.wav"),
		preload("res://assets/audio/steps/dirt/run2.wav"),
		preload("res://assets/audio/steps/dirt/run3.wav"),
	],
	"ice": [
		preload("res://assets/audio/steps/ice/run1.wav"),
		preload("res://assets/audio/steps/ice/run2.wav"),
		preload("res://assets/audio/steps/ice/run3.wav"),
	],
}

func _process(delta):
	if parent.velocity.length() > 0:
		if timer > 0:
			timer -= delta
		else:
			if parent.is_running:
				parent.audi.stream = stepsRun[land_material][i]
				timer = STEP_RUN_COOLDOWN
			else:
				parent.audi.stream = steps[land_material][i]
				timer = STEP_COOLDOWN
			parent.audi.play()
			
			var oldI = i
			i = randi() % 3
			while oldI == i:
				i = randi() % 3
