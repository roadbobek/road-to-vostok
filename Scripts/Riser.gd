extends Node3D


var gameData = preload("res://Resources/GameData.tres")


var semiRise = 2.5
var autoRise = 5.0
var riseSpeed = 2.5
var recoverySpeed = 5.0

func _physics_process(delta):
    if gameData.freeze:
        return

    if gameData.isFiring:
        if gameData.firemode == 1:
            rotation_degrees.x = lerp(rotation_degrees.x, semiRise, delta * riseSpeed)
        else:
            rotation_degrees.x = lerp(rotation_degrees.x, autoRise, delta * riseSpeed)
    else:
        rotation_degrees.x = lerp(rotation_degrees.x, 0.0, delta * recoverySpeed)
