extends Resource
class_name TraderData

@export var icon: Texture2D
@export var name: String
@export var resupply = 10.0
@export var tax = 100.0
@export var tasks: Array[TaskData]

@export_group("Voices")
@export var randomVoices: AudioEvent
@export var startVoices: AudioEvent
@export var endVoices: AudioEvent
@export var tradeVoices: AudioEvent
@export var taskVoices: AudioEvent
