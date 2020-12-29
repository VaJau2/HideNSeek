extends Node

export (String, FILE, "*.json") var keyboard_json: String
export (String, FILE, "*.json") var gamepad_json: String
var gamepadOn = false


func getInterfaceText(interfaceCode: String):
	var keysData = {}
	if gamepadOn:
		keysData = G.loadFile(gamepad_json)
	else:
		keysData = G.loadFile(keyboard_json)
	return keysData[interfaceCode]


func _input(event):
	gamepadOn = (event is InputEventJoypadButton || event is InputEventJoypadMotion)
