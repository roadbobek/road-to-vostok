extends Resource
class_name RecipeData

@export var name: String
@export var time: float
@export var audio: AudioEvent
@export var input: Array[ItemData]
@export var output: Array[ItemData]
@export var repair = false
@export var upgrade = false

@export_group("Proximity")
@export var heat: bool
@export var workbench: bool
@export var testbench: bool
@export var shelter: bool
