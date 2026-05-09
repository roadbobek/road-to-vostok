extends Resource
class_name EventData

@export var day: int
@export var name: String
@export var type: String
@export var map: String
@export var zone: String
@export var function: String
@export_multiline var description: String

@export_group("Dynamic Rules")
@export var instant = false
@export var possibility: int
