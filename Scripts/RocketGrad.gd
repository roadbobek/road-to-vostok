@tool
extends Node3D


@export var launch: bool = false: set = ExecuteLaunch

var launched = false
var speed = 150.0
var deviation = 5.0
var maxAngle = 30.0
var phase = 0.0
var horizontalFrequency: float
var verticalFrequency: float
var verticalOffset: float
var tracking = -1000.0

func ExecuteLaunch(_value: bool) -> void :

    phase = randf() * 10.0
    horizontalFrequency = randf_range(1.5, 2.5)
    verticalFrequency = randf_range(1.5, 2.5)
    verticalOffset = randf() * TAU


    tracking = global_position.z


    launched = true
    set_process(true)
    launch = false

func _process(delta: float) -> void :
    if launched:

        var horizonDistance = abs(tracking)
        var progress = clamp(global_position.z / horizonDistance, -1.0, 1.0)


        rotation_degrees.x = progress * maxAngle


        phase += delta
        rotate_y(deg_to_rad(sin(phase * horizontalFrequency) * deviation * delta))
        rotate_x(deg_to_rad(sin(phase * verticalFrequency + verticalOffset) * deviation * delta))


        global_position += transform.basis.z * speed * delta


        if global_position.z > horizonDistance + 100:
            queue_free()
