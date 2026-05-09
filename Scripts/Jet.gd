extends Node3D

@onready var audio = $Audio

var passed = false
var audioThreshold = 500.0
var flyHeight = 200.0
var flySpeed = 200.0

func _ready():

    var randomPosition = randf_range(-1000, 1000)
    var randomDirection = randi_range(0, 1)


    if randomDirection == 0:
        global_position = Vector3(1000, flyHeight, randomPosition)
    else:
        global_position = Vector3(-1000, flyHeight, randomPosition)


    look_at(Vector3(0, flyHeight, 0), Vector3.UP, true)

func _physics_process(delta):
    Flyby(delta)
    DistanceClear()

func Flyby(delta):

    global_position += transform.basis.z * delta * flySpeed


    var distanceToCenter = global_position.distance_to(Vector3(0, flyHeight, 0))


    if distanceToCenter < audioThreshold && !passed:
        audio.play()
        passed = true

func DistanceClear():

    var distanceToCenter = global_position.distance_to(Vector3(0, flyHeight, 0))


    if distanceToCenter > 2000:
        print("Fighter Jet: Distance cleared")
        queue_free()
