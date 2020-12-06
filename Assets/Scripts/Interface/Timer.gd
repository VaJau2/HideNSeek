extends Label

#-----
# Скрипт для вывода таймера через интерфейс
# Вызывается глобально через G.timer.StartTimer()
# Генерирует сигнал, когда посчитает время
#-----

var time: float

signal timeout


func startTimer(_seconds: int) -> void:
	time = _seconds
	_makeWork(true)


func addTime(newSeconds: int) -> void:
	time += newSeconds


func finishTimer() -> void:
	time = 0


func _makeWork(work: bool) -> void:
	visible = work
	set_process(work)


func _getMinuresSecondsString() -> String:
	var seconds = int(time) % 60
	var minutes = int(time / 60)
	
	#делаем "01" из "1"
	var strSeconds = str(round(seconds))
	if seconds < 10:
		strSeconds = "0" + strSeconds
	
	return str(minutes) + ":" + strSeconds


func _ready():
	G.timer = self
	_makeWork(false)


func _process(delta):
	text = _getMinuresSecondsString()
	
	if time > 0:
		time -= delta
	else:
		_makeWork(false)
		emit_signal("timeout")
