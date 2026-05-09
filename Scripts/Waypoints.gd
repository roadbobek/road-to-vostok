@tool
extends Node3D


const waypoint = preload("res://AI/Tools/AI_WP.tscn")
@export var terrain: Mesh
@export var generate: bool = false: set = ExecuteGenerate
@export var clear: bool = false: set = ExecuteClear


const area = 380.0
const gridDensity = 25.0

func ExecuteClear(_value: bool) -> void :

    for child in get_children():
        child.free()

func ExecuteGenerate(_value: bool) -> void :

    ExecuteClear(true)


    if !terrain:
        print("Terrain not assigned!")
        return
    if !waypoint:
        print("Waypoint not assigned!")
        return


    var MDT = MeshDataTool.new()
    MDT.create_from_surface(terrain, 0)


    var halfArea = area / 2.0
    var steps = int(area / gridDensity)


    var spaceState = get_world_3d().direct_space_state


    for i in range(steps + 1):
        for j in range(steps + 1):

            var posX = ( - halfArea) + (i * gridDensity)
            var posZ = ( - halfArea) + (j * gridDensity)


            var expectedY = GetMeshY(MDT, posX, posZ)


            var rayStart = Vector3(posX, 1000.0, posZ)
            var rayEnd = Vector3(posX, -1000.0, posZ)
            var query = PhysicsRayQueryParameters3D.create(rayStart, rayEnd, 4294967295)
            var hit = spaceState.intersect_ray(query)


            if hit:

                var yComparison = abs(hit.position.y - expectedY)
                if yComparison <= 0.1: SpawnWaypoint(hit.position)

func GetMeshY(mdt: MeshDataTool, x: float, z: float) -> float:
    var closestY = 0.0
    var minimumDistance = INF

    for i in range(mdt.get_vertex_count()):
        var vPosition = mdt.get_vertex(i)
        var vDistance = Vector2(vPosition.x, vPosition.z).distance_to(Vector2(x, z))
        if vDistance < minimumDistance:
            minimumDistance = vDistance
            closestY = vPosition.y
    return closestY

func SpawnWaypoint(spawnPosition: Vector3) -> void :
    var instance = waypoint.instantiate()
    add_child(instance, true)
    instance.owner = get_tree().edited_scene_root
    instance.global_position = spawnPosition
