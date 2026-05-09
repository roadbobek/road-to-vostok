@tool
extends Node3D


@export var skyMaterial: Material
@export var missile: PackedScene
@export var missileCount = 50
@export var launchWidth = 1000.0
@export var launchDistance = 1000.0
@export var launchDelay = 0.5


@export var prepareMissiles: bool = false: set = ExecutePrepareMissiles
@export var launchMissiles: bool = false: set = ExecuteLaunchMissiles
@export var clearMissiles: bool = false: set = ExecuteClearMissiles


var launched = false
var skyEffect = 0.0

func _process(delta: float) -> void :

    if !skyMaterial:
        return


    if launched:
        skyEffect = move_toward(skyEffect, 1.0, delta * 0.2)
    else:
        skyEffect = move_toward(skyEffect, 0.0, delta * 0.1)


    skyMaterial.set_shader_parameter("missiles", skyEffect)

func ExecutePrepareMissiles(_value: bool) -> void :

    ExecuteClearMissiles(true)


    for i in range(missileCount):
        var newMissile = missile.instantiate()
        add_child(newMissile, true)
        newMissile.owner = get_tree().edited_scene_root


        var fraction = float(i) / (missileCount - 1) if missileCount > 1 else 0.5
        newMissile.global_position = global_position + Vector3((fraction - 0.5) * launchWidth, 0, - launchDistance)
        newMissile.global_rotation = global_rotation


        newMissile.visible = false
        newMissile.set_process(false)


    prepareMissiles = false

func ExecuteLaunchMissiles(_value: bool) -> void :

    var pool = get_children().filter( func(node): return node.has_method("ExecuteLaunch"))


    if pool.is_empty():
        ExecutePrepareMissiles(true)
        pool = get_children().filter( func(node): return node.has_method("ExecuteLaunch"))


    pool.shuffle()


    launched = true


    var missilesLaunched = 0


    for element in pool:

        await get_tree().create_timer(randf_range(0.0, launchDelay)).timeout


        if is_instance_valid(element):
            element.visible = true
            element.ExecuteLaunch(true)
            missilesLaunched += 1


            if missilesLaunched == pool.size():
                launched = false


    launchMissiles = false

func ExecuteClearMissiles(_value: bool) -> void :

    launched = false


    for child in get_children():
        if child.has_method("ExecuteLaunch"):
            child.queue_free()


    clearMissiles = false
