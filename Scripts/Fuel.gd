extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export var isActive = false

func UpdateTooltip():
    gameData.tooltip = "Fuel Tank [89%]"

func Interact():
    ErrorAudio()

func ErrorAudio():
    var error = audioInstance2D.instantiate()
    add_child(error)
    error.PlayInstance(audioLibrary.UIError)
