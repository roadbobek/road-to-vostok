extends MeshInstance3D


var gameData = preload("res://Resources/GameData.tres")


@export var species: Array[PackedScene] = []
var playerDistance3D = 0.0
var active = false

func _ready():

    set_layer_mask_value(1, false)


    if species.size() != 0:

        var poolBounds = mesh.get_aabb()
        var poolSize = poolBounds.size
        var poolPosition = global_position + poolBounds.position


        var fishAmount = randi_range(1, 10)


        for index in fishAmount:

            var randomFish = species[randi_range(0, species.size() - 1)]

            var randomPosition = Vector3(randf_range(0, poolSize.x), randf_range(0, poolSize.y), randf_range(0, poolSize.z))


            var fish = randomFish.instantiate()
            fish.name = "Fish"
            add_child(fish, true)
            fish.global_position = randomPosition + poolPosition

func _physics_process(_delta):
    if Engine.get_physics_frames() % 100 == 0:
        playerDistance3D = global_position.distance_to(gameData.playerPosition)


        if !active && playerDistance3D < 50.0:
            if get_child_count() != 0:
                for child in get_children():
                    child.process_mode = Node.PROCESS_MODE_INHERIT
                    child.active = true
                    child.show()
            active = true


        elif active && playerDistance3D > 50.0:

            if get_child_count() != 0:
                for child in get_children():
                    child.hide()
                    child.active = false
                    child.process_mode = Node.PROCESS_MODE_DISABLED
            active = false
