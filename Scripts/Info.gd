extends Control

@export var title: String
@export var type: String
@export_multiline var info: String
var interface

func _ready():
    interface = owner
    interface.hoverInfos.append(self)
