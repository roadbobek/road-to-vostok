extends Node3D

var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var laser = $Laser
@onready var point = $Laser / Point
@onready var raycast = $Laser / Raycast


var active = false

func _input(_event):
    if Input.is_action_just_pressed("laser") && visible:
        active = !active

        if active:
            raycast.global_position = owner.raycast.global_position
            laser.show()
            PlayLaser()
        else:
            laser.hide()
            PlayLaser()

func _process(_delta):
    if active:
        if raycast.is_colliding():
            point.global_position = raycast.get_collision_point()
            point.show()
        else:
            point.hide()

func PlayLaser():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.flashlight)
