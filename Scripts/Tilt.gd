extends Node3D


var gameData = preload("res://Resources/GameData.tres")

var tiltHorizontal = 0.1
var tiltVertical = 0.01
var tiltSmoothing = 4.0

var hipPushForward = 0.02
var hipPushBackward = 0.01
var pushSmoothing = 1.0

var targetTiltRotation = Vector3.ZERO
var targetPushPosition = Vector3.ZERO

var inputDirection = Vector2.ZERO

func _physics_process(delta):
    if gameData.freeze:
        return


    inputDirection = Input.get_vector("left", "right", "forward", "backward")

    if inputDirection.y < 0:
        targetPushPosition.z = hipPushForward * inputDirection.y
    else:
        targetPushPosition.z = hipPushBackward * inputDirection.y

    targetTiltRotation.z = tiltHorizontal * inputDirection.x
    targetTiltRotation.x = tiltVertical * - inputDirection.y

    position.z = lerp(position.z, targetPushPosition.z, delta * pushSmoothing)
    rotation.x = lerp(rotation.x, targetTiltRotation.x, delta * tiltSmoothing)
    rotation.z = lerp(rotation.z, targetTiltRotation.z, delta * tiltSmoothing)
