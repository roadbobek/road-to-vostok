extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export_group("References")
@export var data: Resource
@export var arms: MeshInstance3D
@export var animator: AnimationTree
@export var collision: RayCast3D
@export var point: Node3D
@export var lures: BoneAttachment3D
@export var line: Node3D
@export var reel: AudioStreamPlayer3D
var reelVolume = 0.0


var rigManager
var interface


var throwPrepared = false
var throwExecuted = false
var reelPrepared = false
var reelSpeed = 0.0
var reelAudio = false
var lure: RigidBody3D

func _ready():
    reel.play()
    line.scale.z = 0.01
    lure = lures.get_child(0).get_child(0)
    Freeze()

    animator.active = true
    rigManager = get_parent()
    interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")

func _input(_event):

    if gameData.freeze || gameData.isPlacing:
        return



    if Input.is_action_just_pressed("grenade_throw_high") && !throwPrepared && !throwExecuted:

        var currentAnimation = animator.get("parameters/playback").get_current_node()


        if currentAnimation == "Idle":
            animator["parameters/conditions/Throw_Start"] = true
            animator["parameters/conditions/Throw_End"] = false
            animator["parameters/conditions/Throw_Reset"] = false
            animator["parameters/conditions/Reel_Start"] = false
            animator["parameters/conditions/Reel_End"] = false
            PlayThrowStart()
            return



    elif Input.is_action_just_pressed("grenade_throw_high") && throwPrepared && !throwExecuted:
        animator["parameters/conditions/Throw_Start"] = false
        animator["parameters/conditions/Throw_End"] = true
        animator["parameters/conditions/Throw_Reset"] = false
        animator["parameters/conditions/Reel_Start"] = false
        animator["parameters/conditions/Reel_End"] = false
        PlayThrowEnd()
        throwPrepared = false
        return



    elif Input.is_action_just_pressed("grenade_throw_low") && !throwExecuted:
        animator["parameters/conditions/Throw_Start"] = false
        animator["parameters/conditions/Throw_End"] = false
        animator["parameters/conditions/Throw_Reset"] = true
        animator["parameters/conditions/Reel_Start"] = false
        animator["parameters/conditions/Reel_End"] = false
        throwPrepared = false
        return




    if Input.is_action_just_pressed("inspect") && !throwPrepared && !throwExecuted:
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

func _physics_process(delta):

    if throwExecuted && lure:

        Line()

        if lure.collided:
            Reeling(delta)


    ReelAudio(delta)

func Reeling(delta):

    if lure.global_position.y < -2.0:
        lure.gravity_scale = 0.2
        lure.linear_damp = 10.0
    else:
        lure.gravity_scale = 1.0
        lure.linear_damp = 0.0


    animator["parameters/Reel/Speed/scale"] = reelSpeed

    if Input.is_action_pressed("fire"):

        animator["parameters/conditions/Reel_Start"] = true
        reelSpeed = lerp(reelSpeed, 1.0, delta * 4.0)
        reelAudio = true


        var reelPoint = Vector3(point.global_position.x, gameData.playerPosition.y, point.global_position.z)
        var reelPoint2D = Vector3(reelPoint.x, 0, reelPoint.z)
        var lurePosition2D = Vector3(lure.global_position.x, 0, lure.global_position.z)
        var distanceToReelPoint2D = Vector3(lurePosition2D).distance_to(reelPoint2D)
        var distanceToRodPoint = lure.global_position.distance_to(point.global_position)


        var rotationTarget: Vector3
        var velocityTarget: Vector3
        var nearRotationTarget = point.global_position
        var nearVelocityTarget = (point.global_position - lure.global_position).normalized()
        var farRotationTarget = reelPoint
        var farVelocityTarget = (reelPoint - lure.global_position).normalized()


        if distanceToReelPoint2D < 0.1:
            rotationTarget = nearRotationTarget
            velocityTarget = nearVelocityTarget * 2.0

        else:
            rotationTarget = farRotationTarget
            velocityTarget = farVelocityTarget * 2.0


        var targetTransform = lure.global_transform.looking_at(rotationTarget, Vector3.UP, true).orthonormalized()
        lure.global_transform.basis = lure.global_transform.basis.slerp(targetTransform.basis, delta * 4.0).orthonormalized()
        lure.linear_velocity = velocityTarget


        if distanceToRodPoint < 0.01:
            throwExecuted = false
            animator["parameters/conditions/Reel_End"] = true
            lure.top_level = false
            reelAudio = false
            PlayReelEnd()
            Freeze()


            if lure.hooked:

                for child in lure.get_children():
                    if child is Fish:
                        interface.Create(child.slotData, interface.inventoryGrid, true)
                        lure.hooked = false
                        child.queue_free()
                        PlayCatch()

    else:
        reelSpeed = lerp(reelSpeed, 0.0, delta * 2.0)
        reelAudio = false

func ReelAudio(delta):
    if reelAudio:
        reelVolume = move_toward(reelVolume, 1.0, delta * 2.0)
    else:
        reelVolume = move_toward(reelVolume, 0.0, delta * 2.0)

    reel.volume_db = linear_to_db(reelVolume)

func Line():
    var lureDistance = lure.global_position.distance_to(point.global_position)
    line.scale.z = lureDistance
    line.look_at(lure.global_position, Vector3.FORWARD, true)

func ThrowPrepared():
    throwPrepared = true

func ThrowExecuted():
    throwExecuted = true

func ReelPrepared():
    reelPrepared = true

func ThrowExecute():

    throwExecuted = true


    var throwDirection = global_transform.basis.z
    var throwForce = 30.0


    Unfreeze()
    lure.top_level = true
    lure.global_rotation = Vector3.ZERO
    lure.linear_velocity = throwDirection * throwForce



func Freeze():
    lure.gravity_scale = 0
    lure.sleeping = true
    lure.can_sleep = true
    lure.freeze = true
    lure.continuous_cd = false
    lure.contact_monitor = false
    lure.max_contacts_reported = 0
    lure.freeze_mode = lure.FREEZE_MODE_STATIC

func Unfreeze():
    lure.gravity_scale = 1
    lure.sleeping = false
    lure.can_sleep = false
    lure.freeze = false
    lure.continuous_cd = true
    lure.contact_monitor = true
    lure.max_contacts_reported = 1
    lure.freeze_mode = lure.FREEZE_MODE_STATIC
    lure.ConnectBounce()



func PlayThrowStart():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.rodThrowStart)

func PlayThrowEnd():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.rodThrowEnd)

func PlayThrowReset():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.rodThrowReset)

func PlayReelEnd():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.rodReelEnd)

func PlayHooked():
    gameData.land = true
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.rodHooked)

func PlayCatch():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.rodCatch)
