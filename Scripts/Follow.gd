extends Node3D


var gameData = preload("res://Resources/GameData.tres")

func _physics_process(_delta):
    global_position = gameData.playerPosition
