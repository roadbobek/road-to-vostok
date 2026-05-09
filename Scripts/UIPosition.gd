extends Node3D

var gameData = preload("res://Resources/GameData.tres")

enum Type{Magazine, Chamber}
@export var type = Type.Magazine

var HUD
var camera: Camera
var target

func _ready():
    HUD = get_tree().current_scene.get_node("/root/Map/Core/UI/HUD")
    camera = get_tree().current_scene.get_node("/root/Map/Core/Camera")

    if type == Type.Chamber:
        target = HUD.chamber
    elif type == Type.Magazine:
        target = HUD.magazine

func _physics_process(_delta):
    if target != null:
        target.global_position = camera.unproject_position(global_position)
