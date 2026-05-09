extends Skeleton3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")

@export var hitBone: PhysicalBone3D

var simulationTime = 10.0
var simulationTimer = 0.0
var isActive = false

func _ready():
    DeactivateBones()

func DeactivateBones():
    physical_bones_stop_simulation()

    for child in get_children():
        if child is PhysicalBone3D:
            child.axis_lock_linear_x = true
            child.axis_lock_linear_y = true
            child.axis_lock_linear_z = true
            child.axis_lock_angular_x = true
            child.axis_lock_angular_y = true
            child.axis_lock_angular_z = true
            child.get_child(0).disabled = true

func ActivateBones():
    physical_bones_start_simulation()

    for child in get_children():
        if child is PhysicalBone3D:
            child.axis_lock_linear_x = false
            child.axis_lock_linear_y = false
            child.axis_lock_linear_z = false
            child.axis_lock_angular_x = false
            child.axis_lock_angular_y = false
            child.axis_lock_angular_z = false
            child.get_child(0).disabled = false


    await get_tree().create_timer(0.5, false).timeout;
    PlayRagdoll()

func _physics_process(delta):
    if isActive:
        simulationTimer += delta

        if simulationTimer > simulationTime:
            DeactivateBones()
            owner.Pause()
            print("AI: Process ended")
            isActive = false

func Activate(direction, force):
    isActive = true
    hitBone.linear_velocity = direction * force
    ActivateBones()

func PlayRagdoll():
    var ragdoll = audioInstance3D.instantiate()
    hitBone.add_child(ragdoll)
    ragdoll.PlayInstance(audioLibrary.ragdoll, 5, 100)
