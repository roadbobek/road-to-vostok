extends Node3D


var gameData = preload("res://Resources/GameData.tres")

@export var camera = false

var jumpKick = 0.02
var jumpKickPower = 20.0
var jumpXRotation = 0.1
var jumpYRotation = 0.02
var jumpRotationPower = 5.0

var currentKick = Vector3.ZERO
var currentRotation = Vector3.ZERO

func _physics_process(delta):
    currentKick = lerp(currentKick, Vector3.ZERO, delta * jumpKickPower)
    currentRotation = lerp(currentRotation, Vector3.ZERO, delta * jumpRotationPower)

    position = lerp(position, currentKick, delta * jumpKickPower)
    rotation = lerp(rotation, currentRotation, delta * jumpRotationPower)

    if gameData.jump:
        if gameData.isRunning:
            JumpKick(1.5)
        else:
            JumpKick(1)

    if gameData.land:
        if gameData.isRunning:
            LandKick(1.5)
        else:
            LandKick(1)

    if gameData.crouch:
        JumpKick(0.5)

    if gameData.stand:
        LandKick(0.5)

func JumpKick(multiplier):
    if camera:
        currentRotation = Vector3(jumpXRotation * multiplier, jumpYRotation * multiplier, 0.0)
    else:
        currentRotation = Vector3( - jumpXRotation * multiplier, jumpYRotation * multiplier, 0.0)
    currentKick = Vector3(0.0, jumpKick * multiplier, 0.0)

func LandKick(multiplier):
    if camera:
        currentRotation = Vector3( - jumpXRotation * multiplier, jumpYRotation * multiplier, 0.0)
    else:
        currentRotation = Vector3(jumpXRotation * multiplier, jumpYRotation * multiplier, 0.0)
    currentKick = Vector3(0.0, - jumpKick * multiplier, 0.0)
