@tool
extends Node3D

@export var snap: bool = false: set = ExecuteSnap

func ExecuteSnap(_value: bool) -> void :

    var spaceState = get_world_3d().direct_space_state


    for child in get_children():

        var rayStart = child.global_position + Vector3(0, 10.0, 0)
        var rayEnd = child.global_position + Vector3(0, -10.0, 0)
        var query = PhysicsRayQueryParameters3D.create(rayStart, rayEnd, 1)
        var hit = spaceState.intersect_ray(query)


        if hit:

            var hitPosition = hit.position.y
            var hitSnapped = floor(hitPosition / 0.1) * 0.1
            child.global_position.y = hitSnapped


    snap = false
