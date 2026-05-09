extends Node3D


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")
var gameData = preload("res://Resources/GameData.tres")


@export var cat: Node3D
@export var feeder: Node3D
@onready var lid1: MeshInstance3D = $Lid_01
@onready var lid2: MeshInstance3D = $Lid_02
var interface


var isOpen = false
var lid1Rotated = 0.0
var lid2Rotated = 0.0
var lidTarget = 250.0
var lidSpeed = 250.0


var lastPosition = Vector3.ZERO
var stillTimer = 0.0
var stillThreshold = 10.0
var tiltLimit = 5.0

func _ready() -> void :
    interface = get_tree().current_scene.get_node_or_null("/root/Map/Core/UI/Interface")
    lastPosition = global_position

func _physics_process(delta: float) -> void :

    var currentPosition = global_position
    var tiltX = abs(global_rotation_degrees.x)
    var tiltZ = abs(global_rotation_degrees.z)
    var isTilted = tiltX > tiltLimit || tiltZ > tiltLimit
    var isMoved = currentPosition.distance_to(lastPosition) > 0.05


    if isMoved || isTilted || gameData.isFiring || gameData.catDead:

        stillTimer = 0.0

        lastPosition = currentPosition

        if isOpen:
            isOpen = false
            feeder.Deactivate()
            cat.ForceMeow()


    else:

        stillTimer += delta

        if stillTimer >= stillThreshold && !isOpen:
            isOpen = true
            feeder.Activate()
            cat.ForceMeow()


    if isOpen:
        if lid1Rotated < lidTarget:
            var step = min(delta * lidSpeed, lidTarget - lid1Rotated)
            lid1Rotated += step
            lid1.rotation_degrees.x += step
        if lid2Rotated < lidTarget:
            var step = min(delta * lidSpeed, lidTarget - lid2Rotated)
            lid2Rotated += step
            lid2.rotation_degrees.x -= step

    else:
        if lid1Rotated > 0.0:
            var step = min(delta * lidSpeed, lid1Rotated)
            lid1Rotated -= step
            lid1.rotation_degrees.x -= step
        if lid2Rotated > 0.0:
            var step = min(delta * lidSpeed, lid2Rotated)
            lid2Rotated -= step
            lid2.rotation_degrees.x += step
