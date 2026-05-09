extends Node3D


var gameData = preload("res://Resources/GameData.tres")

var data: Resource
var currentKick = Vector3.ZERO
var currentRotation = Vector3.ZERO

func _ready():
    data = owner.data

func _physics_process(delta):
    if gameData.freeze || gameData.flycam:
        return

    CalculateRecoil(delta)

func CalculateRecoil(delta):
    currentRotation = lerp(currentRotation, Vector3.ZERO, delta * data.rotationRecovery)
    rotation = lerp(rotation, currentRotation, delta * data.rotationPower)

    currentKick = lerp(currentKick, Vector3.ZERO, delta * data.kickRecovery)
    position = lerp(position, currentKick, delta * data.kickPower)

func ApplyRecoil():
    if gameData.firemode == 1:
        currentRotation = Vector3( - data.verticalRecoil, randf_range( - data.horizontalRecoil, data.horizontalRecoil), 0.0)
    else:
        currentRotation = Vector3( - data.verticalRecoil / 2, randf_range( - data.horizontalRecoil, data.horizontalRecoil), 0.0)
    currentKick = Vector3(0.0, 0.0, - data.kick)
