extends Node3D


const explosion = preload("res://Effects/Explosion.tscn")
@onready var ray: RayCast3D = $Ray

var speed = 150.0
var deviation = 5.0
var phase = 0.0
var horizontalFrequency: float
var verticalFrequency: float
var verticalOffset: float

func _ready() -> void :

    phase = randf() * 10.0


    horizontalFrequency = randf_range(1.5, 2.5)
    verticalFrequency = randf_range(1.5, 2.5)
    verticalOffset = randf() * TAU

func _physics_process(delta: float) -> void :

    phase += delta


    var horizontalDeviation = sin(phase * horizontalFrequency) * deviation * delta
    rotate_y(deg_to_rad(horizontalDeviation))


    var verticalDeviation = sin(phase * verticalFrequency + verticalOffset) * deviation * delta
    rotate_x(deg_to_rad(verticalDeviation))


    global_position += transform.basis.z * speed * delta


    if ray.is_colliding():

        var instance = explosion.instantiate()
        get_tree().get_root().add_child(instance)
        instance.global_position = global_position
        instance.size = 20.0
        instance.Explode()

        queue_free()


    if global_position.distance_to(Vector3.ZERO) > 1000:
        print("ROCKET: Distance cleared")
        queue_free()
