extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export_group("References")
@export var data: Resource
@export var arms: MeshInstance3D
@export var meshes: Array[MeshInstance3D]
@export var animator: AnimationTree
@export var collision: RayCast3D
@export var throwPoint: Node3D
@export var throw: PackedScene
@export var handle: PackedScene


var rigManager
var interface


var lowPrepared = false
var highPrepared = false

func _ready():
    animator.active = true
    rigManager = get_parent()
    interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")

func _input(_event):

    if gameData.freeze || gameData.isPlacing:
        return




    if Input.is_action_just_pressed("grenade_throw_high") && !highPrepared:

        var currentAnimation = animator.get("parameters/playback").get_current_node()

        if currentAnimation == "Idle":
            animator["parameters/conditions/Throw_High_Start"] = true
            animator["parameters/conditions/Throw_High_End"] = false
            animator["parameters/conditions/Throw_High_Reset"] = false
            return


    elif Input.is_action_just_pressed("grenade_throw_high") && highPrepared:
        animator["parameters/conditions/Throw_High_Start"] = false
        animator["parameters/conditions/Throw_High_End"] = true
        animator["parameters/conditions/Throw_High_Reset"] = false
        return


    elif Input.is_action_just_pressed("grenade_throw_low") && highPrepared:
        animator["parameters/conditions/Throw_High_Start"] = false
        animator["parameters/conditions/Throw_High_End"] = false
        animator["parameters/conditions/Throw_High_Reset"] = true
        highPrepared = false
        return




    if Input.is_action_pressed("grenade_throw_low") && !lowPrepared:

        var currentAnimation = animator.get("parameters/playback").get_current_node()

        if currentAnimation == "Idle":
            animator["parameters/conditions/Throw_Low_Start"] = true
            animator["parameters/conditions/Throw_Low_End"] = false
            animator["parameters/conditions/Throw_Low_Reset"] = false
            return


    elif Input.is_action_just_released("grenade_throw_low") && lowPrepared:
        animator["parameters/conditions/Throw_Low_Start"] = false
        animator["parameters/conditions/Throw_Low_End"] = true
        animator["parameters/conditions/Throw_Low_Reset"] = false
        return


    elif Input.is_action_just_pressed("grenade_throw_high") && lowPrepared:
        animator["parameters/conditions/Throw_Low_Start"] = false
        animator["parameters/conditions/Throw_Low_End"] = false
        animator["parameters/conditions/Throw_Low_Reset"] = true
        lowPrepared = false
        return




    if Input.is_action_just_pressed("inspect"):
        gameData.isInspecting = !gameData.isInspecting


        if gameData.isInspecting:
            gameData.inspectPosition = 1
            animator["parameters/conditions/Inspect_Front"] = true
            animator["parameters/conditions/Inspect_Idle"] = false
        else:

            if gameData.inspectPosition == 1:
                animator["parameters/conditions/Inspect_Front"] = false
                animator["parameters/conditions/Inspect_Idle"] = true

            elif gameData.inspectPosition == 2:
                animator["parameters/conditions/Inspect_Back"] = false
                animator["parameters/conditions/Inspect_Idle"] = true
                gameData.inspectPosition = 1


    elif Input.is_action_just_pressed("weapon_high") && gameData.isInspecting:
        if gameData.inspectPosition == 1:
            animator["parameters/conditions/Inspect_Front"] = false
            animator["parameters/conditions/Inspect_Back"] = true
            gameData.inspectPosition = 2


    elif Input.is_action_just_pressed("weapon_low") && gameData.isInspecting:
        if gameData.inspectPosition == 2:
            animator["parameters/conditions/Inspect_Front"] = true
            animator["parameters/conditions/Inspect_Back"] = false
            gameData.inspectPosition = 1

func ThrowHighPrepared():
    highPrepared = true

func ThrowLowPrepared():
    lowPrepared = true

func ThrowHighExecute():

    for mesh in meshes:
        mesh.hide()


    PlayHandleRelease()


    if gameData.grenade1:
        interface.equipmentUI.get_child(4).get_child(0).queue_free()
        interface.equipmentUI.get_child(4).hint.show()

    if gameData.grenade2:
        interface.equipmentUI.get_child(5).get_child(0).queue_free()
        interface.equipmentUI.get_child(5).hint.show()


    gameData.grenade1 = false
    gameData.grenade2 = false


    var throwDirection = global_transform.basis.z
    var throwPosition = throwPoint.global_position
    var throwRotation = Vector3(0, global_rotation_degrees.y, 0)
    var throwForce = 30.0


    var throwGrenade = throw.instantiate()
    get_tree().get_root().add_child(throwGrenade)


    var throwHandle = handle.instantiate()
    get_tree().get_root().add_child(throwHandle)


    throwGrenade.handle = throwHandle
    throwGrenade.position = throwPosition
    throwGrenade.rotation_degrees = throwRotation
    throwGrenade.linear_velocity = throwDirection * throwForce
    throwGrenade.angular_velocity = basis.x * 5.0


    throwHandle.position = throwPosition
    throwHandle.rotation_degrees = throwRotation
    throwHandle.linear_velocity = throwDirection * throwForce / 1.5
    throwHandle.angular_velocity = - basis.x * 5.0

func ThrowLowExecute():

    for mesh in meshes:
        mesh.hide()


    PlayHandleRelease()


    if gameData.grenade1:
        interface.equipmentUI.get_child(4).get_child(0).queue_free()
        interface.equipmentUI.get_child(4).hint.show()

    if gameData.grenade2:
        interface.equipmentUI.get_child(5).get_child(0).queue_free()
        interface.equipmentUI.get_child(5).hint.show()


    gameData.grenade1 = false
    gameData.grenade2 = false


    var throwDirection = global_transform.basis.z
    var throwPosition = throwPoint.global_position
    var throwRotation = Vector3(0, global_rotation_degrees.y, 0)
    var throwForce = 15.0


    var throwGrenade = throw.instantiate()
    get_tree().get_root().add_child(throwGrenade)


    var throwHandle = handle.instantiate()
    get_tree().get_root().add_child(throwHandle)


    throwGrenade.handle = throwHandle
    throwGrenade.position = throwPosition
    throwGrenade.rotation_degrees = throwRotation
    throwGrenade.linear_velocity = throwDirection * throwForce
    throwGrenade.angular_velocity = basis.x * 5.0


    throwHandle.position = throwPosition
    throwHandle.rotation_degrees = throwRotation
    throwHandle.linear_velocity = throwDirection * throwForce / 1.5
    throwHandle.angular_velocity = - basis.x * 5.0

func ThrowFinished():

    if !gameData.primary && !gameData.secondary && !gameData.knife:
        animator.active = false
        rigManager.ClearRig()



func PlayThrowPrepare():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.grenadeThrowPrepare)

func PlayThrowHigh():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.grenadeThrowHigh)

func PlayThrowLow():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.grenadeThrowLow)

func PlayPinRemove():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.grenadePinRemove)

func PlayPinAttach():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.grenadePinAttach)

func PlayHandleRelease():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.grenadeHandleRelease)

func PlayHandleDrop():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.grenadeHandleDrop)
