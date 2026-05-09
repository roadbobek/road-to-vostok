extends Resource
class_name AudioEvent

@export var audioClips: Array[AudioStreamWAV]
@export_range(-20.0, 20.0, 1.0) var volume = 0.0
@export var randomPitch = false
