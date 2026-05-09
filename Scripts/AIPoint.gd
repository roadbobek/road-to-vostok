extends Node3D
var occupied: bool

func _ready() -> void :

    for child in get_children():

        if child is Area3D: continue
        child.queue_free()
