extends Node3D


var gameData = preload("res://Resources/GameData.tres")


var knifeData: Resource
var collision: RayCast3D

var targetPosition = Vector3.ZERO
var targetRotation = Vector3.ZERO
var lerpSpeed = 7.5

func _ready():
    knifeData = owner.data
    collision = owner.collision
    position = Vector3(0.0, -0.5, -0.5)

func _physics_process(delta):
    if gameData.freeze:
        return


    if gameData.isInspecting:
        targetPosition = knifeData.inspectPosition
        targetRotation = knifeData.inspectRotation

    else:

        if collision.is_colliding():
            gameData.isColliding = true
        else:
            gameData.isColliding = false


        if gameData.isColliding:
            targetPosition = knifeData.collisionPosition
            targetRotation = knifeData.collisionRotation


        else:


            if gameData.isRunning:
                targetPosition = knifeData.runPosition
                targetRotation = knifeData.runRotation
                lerpSpeed = 6.0


            else:
                targetPosition = knifeData.idlePosition
                targetRotation = knifeData.idleRotation
                lerpSpeed = 6.0

    position = lerp(position, Vector3( - targetPosition.x, targetPosition.y, - targetPosition.z), delta * lerpSpeed)
    rotation_degrees.x = lerp(rotation_degrees.x, targetRotation.x, delta * lerpSpeed)
    rotation_degrees.y = lerp(rotation_degrees.y, targetRotation.y, delta * lerpSpeed)
    rotation_degrees.z = lerp(rotation_degrees.z, targetRotation.z, delta * lerpSpeed)
