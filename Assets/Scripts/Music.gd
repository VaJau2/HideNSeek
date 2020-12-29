extends AudioStreamPlayer

const MUTED_VOLUME  = -20
const NORMAL_VOLUME = 0

var tracks = {
	"idle": preload("res://Assets/Audio/Music/idle.ogg"),
	"game": preload("res://Assets/Audio/Music/game.ogg")
}

func muteTrack() -> void:
	while volume_db > MUTED_VOLUME:
		volume_db -= 1
		yield(get_tree().create_timer(0.05),"timeout")


func playTrack(newTrackName: String) -> void:
	volume_db = NORMAL_VOLUME
	stream = tracks[newTrackName]
	play()


func _ready():
	stream = tracks.idle
	play()
