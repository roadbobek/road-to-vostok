@tool
extends Node3D

@export var generate: bool = false: set = ExecuteGenerate
@export var clear: bool = false: set = ExecuteClear
@export var elements: Array[PackedScene]

@export_group("Masking")
@export_flags_3d_physics var layers
@export var surfaces: Array[String] = ["Grass"]


const density = 4
const spacing = 3.0
const rows = 3
const length = 198


var hitPosition
var hitNormal

func ExecuteGenerate(_value: bool) -> void :

    ExecuteClear(true)


    var rowOffset = - ((rows - 1) * spacing) / 2.0


    for i in range(rows):

        var spread = rowOffset + (i * spacing)


        for z in range( - length, length + 1):

            if z % density == 0:

                var spawnLocal = Vector3(spread, 0, z)
                var spawnGlobal = global_transform * spawnLocal


                if !RaycastCheck(spawnGlobal + Vector3(0, 100, 0), spawnGlobal + Vector3(0, -200, 0)):
                    continue


                var randomRotation = Vector3(deg_to_rad(randf_range(-5, 5)), deg_to_rad(randf_range(-360, 360)), deg_to_rad(randf_range(-5, 5)))
                var randomScale = randf_range(1.0, 2.0)


                var element = elements[randi() % elements.size()].instantiate()
                add_child(element, true)
                element.set_owner(get_tree().edited_scene_root)


                element.scale = Vector3(randomScale, randomScale, randomScale)
                element.position = to_local(hitPosition) + Vector3(0, -0.5, 0)
                element.rotation = randomRotation


    generate = false

func RaycastCheck(rayStart: Vector3, rayEnd: Vector3) -> bool:

    var ray = PhysicsRayQueryParameters3D.create(rayStart, rayEnd, layers)
    var hit = get_world_3d().direct_space_state.intersect_ray(ray)


    if !hit.is_empty() && hit.collider.get("surface") != null && surfaces.has(hit.collider.get("surface")):
        hitPosition = hit.position
        hitNormal = hit.normal


        return true
    else:

        return false

func ExecuteClear(_value: bool) -> void :

    for child in get_children():
        remove_child(child)
        child.queue_free()
