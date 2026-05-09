extends Node3D


var layout: Node3D

func _ready():

    var randomLayout = randi_range(0, get_child_count() - 1)

    layout = get_child(randomLayout)
    layout.show()


    for child in get_children():
        if child != layout:
            child.queue_free()
