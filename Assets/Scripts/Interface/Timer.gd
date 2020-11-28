extends Label

#-----
# Скрипт для вывода таймера через интерфейс
# Вызывается глобально через G.timer.StartTimer()
# Генерирует сигнал, когда посчитает время
#-----

var minutes = 0
var seconds = 0

signal timeout


func StartTimer(_seconds, _minutes = 0) -> void:
	minutes = _minutes
	seconds = _seconds
	_makeWork(true)


func _makeWork(work: bool) -> void:
	visible = work
	set_process(work)


func _getSecondString() -> String:
	var tempSeconds = round(seconds)
	var strSeconds = str(tempSeconds)
	if tempSeconds < 10:
		strSeconds = "0" + strSeconds
	return strSeconds


func _ready():
	G.timer = self
	_makeWork(false)


func _process(delta):
	text = str(minutes) + ":" + _getSecondString()
	
	if seconds > 0:
		seconds -= delta
	else:
		if minutes > 0:
			minutes -= 1
			seconds = 60
		else:
			emit_signal("timeout")
			_makeWork(false)
