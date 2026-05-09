extends Area3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


var killTimer = 0.0
var killCycle = 2.0;


var map
var interface

func _ready():

    map = get_tree().current_scene.get_node("/root/Map")
    interface = get_tree().current_scene.get_node_or_null("/root/Map/Core/UI/Interface")

func _physics_process(delta) -> void :

    killTimer += delta


    if killTimer > killCycle:

        var bodies = get_overlapping_bodies()


        if bodies.size() > 0:

            for target in bodies:

                if target is Pickup:
                    HandleItem(target)

                elif target is Controller:
                    HandleController(target)


        killTimer = 0.0

func HandleItem(item):

    if map.mapType == "Shelter":

        interface.ItemReturn(item)
        PlayTeleport()


        Loader.Message("Item Returned: " + item.slotData.itemData.name, Color.GREEN)


    else:
        print("Killbox (Item Clear): " + item.name)
        item.queue_free()

func HandleController(controller):

    if map.mapType == "Shelter":

        var transition = get_tree().get_first_node_in_group("Transition")
        var spawnPoint = transition.owner.spawn

        if spawnPoint:
            gameData.isFalling = false
            controller.global_transform.basis = spawnPoint.global_transform.basis
            controller.global_transform.basis = controller.global_transform.basis.rotated(Vector3.UP, deg_to_rad(180))
            controller.global_position = spawnPoint.global_position + Vector3(0.0, 0.5, 0.0)
            PlayTeleport()


            Loader.Message("Player Returned", Color.GREEN)


    else:

        var waypoints = get_tree().get_nodes_in_group("AI_WP")

        if waypoints.size() != 0: controller.global_position = waypoints.pick_random().global_position

        else: controller.global_position = Vector3(0, 2, 0)
        PlayTeleport()


        Loader.Message("Player Returned", Color.GREEN)

func PlayTeleport():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.UITeleport)
