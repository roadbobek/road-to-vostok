extends Node3D

var gameData = preload("res://Resources/GameData.tres")

@export var hideDistance = 0.0
var distance: float
var scanTimer = 0.0
var scanCycle = 1.0

func _physics_process(delta):

    scanTimer += delta

    if scanTimer > scanCycle:
        distance = global_position.distance_to(gameData.playerPosition)

        if distance > hideDistance:
            hide()
        else:
            show()

        scanTimer = 0.0
