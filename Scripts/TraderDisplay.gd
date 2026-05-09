extends Node3D

func _ready() -> void :
    for child in get_children():

        if child is Pickup:
            child.Freeze()
            child.collision.disabled = true


        if child is LootContainer:
            child.locked = true
