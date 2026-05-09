extends Node


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


const cache = preload("res://Resources/Cache.tscn")


@onready var camera = $"../../Camera"
@onready var controller = $"../../Controller"
@onready var settings = $"../../UI/Settings"
@onready var UIManager = $"../../UI"
var shaderCache
var cachePhase = 0

func _ready():

    shaderCache = cache.instantiate()
    camera.add_child(shaderCache)
    shaderCache.transform.origin.z -= 2.0

    gameData.isCaching = true
    camera.global_position = Vector3(0, 2, 0)
    camera.global_rotation = Vector3.ZERO

func _physics_process(delta):

    if gameData.isCaching:

        camera.rotation_degrees.y += delta * 500.0

        if camera.rotation_degrees.y >= 360 && cachePhase == 0:
            camera.global_position = Vector3(0, 2, 100)
            cachePhase = 1
        if camera.rotation_degrees.y >= 360 && cachePhase == 1:
            camera.global_position = Vector3(0, 2, 0)
            cachePhase = 2
        if camera.rotation_degrees.y >= 360 && cachePhase == 2:
            camera.global_position = Vector3(0, 2, -100)
            cachePhase = 3

        if camera.rotation_degrees.y >= 360 && cachePhase == 3:

            gameData.isCaching = false

            camera.remove_child(shaderCache)
            shaderCache.HideDecals()
            shaderCache.queue_free()

            Loader.FadeOutLoading()
            Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

            Spawn()

func Spawn():
    var spawnTarget: String
    var spawnPoint: Node3D
    var map = get_tree().current_scene.get_node("/root/Map")
    var transitions = get_tree().get_nodes_in_group("Transition")
    var waypoints = get_tree().get_nodes_in_group("AI_WP")


    if waypoints.size() != 0 && map.mapName != "Template":
        controller.global_position = waypoints.pick_random().global_position
        controller.global_rotation.y = randf_range(0, 360)

    else:
        controller.global_position = Vector3(0, 2, 0)


    if map.mapName == "Template":
        Loader.LoadCharacter()


    elif map.mapName == "Tutorial":
        Simulation.simulate = false
        controller.global_position = Vector3(0, 3, 12)



    elif map.mapName == "Cabin":
        Loader.LoadWorld()
        Loader.LoadCharacter()
        Loader.LoadShelter("Cabin")
        Simulation.simulate = true
        spawnTarget = "Door_Cabin_Exit"

    elif map.mapName == "Attic":
        Loader.LoadWorld()
        Loader.LoadCharacter()
        Loader.LoadShelter("Attic")
        Simulation.simulate = true
        spawnTarget = "Door_Attic_Exit"

    elif map.mapName == "Classroom":
        Loader.LoadWorld()
        Loader.LoadCharacter()
        Loader.LoadShelter("Classroom")
        Simulation.simulate = true
        spawnTarget = "Door_Classroom_Exit"

    elif map.mapName == "Tent":
        Loader.LoadWorld()
        Loader.LoadCharacter()
        Loader.LoadShelter("Tent")
        Simulation.simulate = true
        spawnTarget = "Transition_Tent_Exit"

    elif map.mapName == "Bunker":
        Loader.LoadWorld()
        Loader.LoadCharacter()
        Loader.LoadShelter("Bunker")
        Simulation.simulate = true
        spawnTarget = "Door_Bunker_Exit"



    elif map.mapName == "Village":
        Loader.LoadWorld()
        Loader.LoadCharacter()
        Simulation.simulate = true
        if gameData.previousMap == "Cabin": spawnTarget = "Door_Cabin_Enter"
        elif gameData.previousMap == "Attic": spawnTarget = "Door_Attic_Enter"
        elif gameData.previousMap == "School": spawnTarget = "Transition_School"
        elif gameData.previousMap == "Highway": spawnTarget = "Transition_Highway"

    elif map.mapName == "School":
        Loader.LoadWorld()
        Loader.LoadCharacter()
        Simulation.simulate = true
        if gameData.previousMap == "Village": spawnTarget = "Transition_Village"
        elif gameData.previousMap == "Highway": spawnTarget = "Transition_Highway"
        elif gameData.previousMap == "Outpost": spawnTarget = "Transition_Outpost"
        elif gameData.previousMap == "Classroom": spawnTarget = "Door_Classroom_Enter"

    elif map.mapName == "Highway":
        Loader.LoadWorld()
        Loader.LoadCharacter()
        Simulation.simulate = true
        if gameData.previousMap == "Village": spawnTarget = "Transition_Village"
        elif gameData.previousMap == "School": spawnTarget = "Transition_School"

    elif map.mapName == "Outpost":
        Loader.LoadWorld()
        Loader.LoadCharacter()
        Simulation.simulate = true
        if gameData.previousMap == "School": spawnTarget = "Transition_School"
        elif gameData.previousMap == "Minefield": spawnTarget = "Transition_Minefield"
        elif gameData.previousMap == "Tent": spawnTarget = "Transition_Tent_Enter"
        elif gameData.previousMap == "Bunker": spawnTarget = "Door_Bunker_Enter"



    elif map.mapName == "Minefield":
        Loader.LoadWorld()
        Loader.LoadCharacter()
        Simulation.simulate = true
        if gameData.previousMap == "Outpost": spawnTarget = "Transition_Outpost"
        elif gameData.previousMap == "Apartments": spawnTarget = "Transition_Apartments"



    elif map.mapName == "Apartments":
        Loader.LoadWorld()
        Loader.LoadCharacter()
        Simulation.simulate = true
        if gameData.previousMap == "Minefield": spawnTarget = "Transition_Minefield"
        elif gameData.previousMap == "Terminal": spawnTarget = "Transition_Terminal"

    elif map.mapName == "Terminal":
        Loader.LoadWorld()
        Loader.LoadCharacter()
        Simulation.simulate = true
        if gameData.previousMap == "Apartments": spawnTarget = "Transition_Apartments"


    if spawnTarget != "":
        for transition in transitions:
            if transition.owner.name == spawnTarget:

                spawnPoint = transition.owner.spawn

                if spawnPoint:
                    controller.global_transform.basis = spawnPoint.global_transform.basis
                    controller.global_transform.basis = controller.global_transform.basis.rotated(Vector3.UP, deg_to_rad(180))
                    controller.global_position = spawnPoint.global_position


    gameData.isTransitioning = false
    gameData.isSleeping = false
    gameData.isOccupied = false
    gameData.freeze = false


    if gameData.difficulty == 1 && gameData.permadeath:

        await get_tree().create_timer(1.0, false).timeout;
        PlayVostokEnter()

func PlayVostokEnter():
    var vostokEnter = audioInstance2D.instantiate()
    add_child(vostokEnter)
    vostokEnter.PlayInstance(audioLibrary.vostokEnter)
