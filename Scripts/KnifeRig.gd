extends Node3D
class_name Knife


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@export var data: Resource
@export var animator: AnimationTree
@export var arms: MeshInstance3D
@export var knife: MeshInstance3D
@export var collision: RayCast3D
@export var raycast: RayCast3D


var canCombo = false
var slashTime = 0.4
var stabTime = 0.6
var attack = 1
var comboTimer = 0.0
var comboTime = 0.5


var rigManager

func _ready():

    rigManager = get_parent()

    animator.active = true

func _input(_event):
    if Input.is_action_just_pressed("inspect"):
        gameData.isInspecting = !gameData.isInspecting


        if gameData.isInspecting:
            gameData.inspectPosition = 1
            PlayInspectStart()
            animator["parameters/conditions/Inspect_Front"] = true
            animator["parameters/conditions/Inspect_Idle"] = false
        else:

            if gameData.inspectPosition == 1:
                PlayInspectEnd()
                animator["parameters/conditions/Inspect_Front"] = false
                animator["parameters/conditions/Inspect_Idle"] = true

            elif gameData.inspectPosition == 2:
                PlayInspectEnd()
                animator["parameters/conditions/Inspect_Back"] = false
                animator["parameters/conditions/Inspect_Idle"] = true
                gameData.inspectPosition = 1


    elif Input.is_action_just_pressed("weapon_high") && gameData.isInspecting:
        if gameData.inspectPosition == 1:
            PlayInspectRotate()
            animator["parameters/conditions/Inspect_Front"] = false
            animator["parameters/conditions/Inspect_Back"] = true
            gameData.inspectPosition = 2


    elif Input.is_action_just_pressed("weapon_low") && gameData.isInspecting:
        if gameData.inspectPosition == 2:
            PlayInspectRotate()
            animator["parameters/conditions/Inspect_Front"] = true
            animator["parameters/conditions/Inspect_Back"] = false
            gameData.inspectPosition = 1

func _physics_process(delta):

    if gameData.freeze || gameData.isPlacing || gameData.isInspecting:
        return


    comboTimer += delta

    if comboTimer > comboTime:
        canCombo = true
    else:
        canCombo = false


    if Input.is_action_just_pressed(("slash")):

        if animator["parameters/conditions/Slash_03"] && canCombo:
            animator["parameters/conditions/Slash_04"] = true
            comboTimer = 0.0
            attack = 4

        elif animator["parameters/conditions/Slash_02"] && canCombo:
            animator["parameters/conditions/Slash_03"] = true
            comboTimer = 0.0
            attack = 3

        elif animator["parameters/conditions/Slash_01"] && canCombo:
            animator["parameters/conditions/Slash_02"] = true
            comboTimer = 0.0
            attack = 2

        elif !animator["parameters/conditions/Slash_01"]:
            animator["parameters/conditions/Slash_01"] = true
            comboTimer = 0.0
            attack = 1


    if Input.is_action_just_pressed(("stab")):

        if animator["parameters/conditions/Stab_03"] && canCombo:
            animator["parameters/conditions/Stab_04"] = true
            comboTimer = 0.0
            attack = 8

        elif animator["parameters/conditions/Stab_02"] && canCombo:
            animator["parameters/conditions/Stab_03"] = true
            comboTimer = 0.0
            attack = 7

        elif animator["parameters/conditions/Stab_01"] && canCombo:
            animator["parameters/conditions/Stab_02"] = true
            comboTimer = 0.0
            attack = 6

        elif !animator["parameters/conditions/Stab_01"]:
            animator["parameters/conditions/Stab_01"] = true
            comboTimer = 0.0
            attack = 5

func HitCheck():
    if raycast.is_colliding():
        var hitCollider = raycast.get_collider()
        var hitPoint = raycast.get_collision_point()
        var hitNormal = raycast.get_collision_normal()
        var hitSurface = raycast.get_collider().get("surface")
        KnifeDecal(hitCollider, hitPoint, hitNormal, hitSurface)

        if hitCollider is Hitbox:
            hitCollider.ApplyDamage(25.0)

func KnifeDecal(hitCollider, hitPoint, hitNormal, hitSurface):
    var knifeDecal: Node3D

    if hitCollider is Hitbox:
        knifeDecal = rigManager.hitKnife.instantiate()
    else:
        knifeDecal = rigManager.hitKnife.instantiate()

    hitCollider.add_child(knifeDecal)
    knifeDecal.global_transform.origin = hitPoint

    if hitNormal == Vector3(0, 1, 0):
        knifeDecal.look_at(hitPoint + hitNormal, Vector3.RIGHT)
    elif hitNormal == Vector3(0, -1, 0):
        knifeDecal.look_at(hitPoint + hitNormal, Vector3.RIGHT)
    else:
        knifeDecal.look_at(hitPoint + hitNormal, Vector3.DOWN)

    if attack == 1:
        knifeDecal.global_rotation_degrees.z = 30.0
    elif attack == 2:
        knifeDecal.global_rotation_degrees.z = 10.0
    elif attack == 3:
        knifeDecal.global_rotation_degrees.z = -10.0
    elif attack == 4:
        knifeDecal.global_rotation_degrees.z = -30.0
    elif attack == 5:
        knifeDecal.global_rotation_degrees.z = 15.0
    elif attack == 6:
        knifeDecal.global_rotation_degrees.z = 0.0
    elif attack == 7:
        knifeDecal.global_rotation_degrees.z = -30.0
    elif attack == 8:
        knifeDecal.global_rotation_degrees.z = 45.0

    if hitCollider is Hitbox:
        knifeDecal.PlayKnifeHitFlesh(attack)
    else:
        knifeDecal.PlayKnifeHit(hitSurface)

func AttackFinished():
    attack = 0
    animator["parameters/conditions/Slash_01"] = false
    animator["parameters/conditions/Slash_02"] = false
    animator["parameters/conditions/Slash_03"] = false
    animator["parameters/conditions/Slash_04"] = false
    animator["parameters/conditions/Stab_01"] = false
    animator["parameters/conditions/Stab_02"] = false
    animator["parameters/conditions/Stab_03"] = false
    animator["parameters/conditions/Stab_04"] = false
    animator["parameters/conditions/Throw_Start"] = false
    animator["parameters/conditions/Throw_Reset"] = false
    animator["parameters/conditions/Throw_End"] = false

func SlashAudio():
    var slash = audioInstance2D.instantiate()
    add_child(slash)
    slash.PlayInstance(audioLibrary.knifeSlash)

func StabAudio():
    var stab = audioInstance2D.instantiate()
    add_child(stab)
    stab.PlayInstance(audioLibrary.knifeStab)

func InspectStartAudio():
    var inspectStart = audioInstance2D.instantiate()
    add_child(inspectStart)
    inspectStart.PlayInstance(audioLibrary.knifeInspectStart)

func InspectEndAudio():
    var inspectEnd = audioInstance2D.instantiate()
    add_child(inspectEnd)
    inspectEnd.PlayInstance(audioLibrary.knifeInspectEnd)

func InspectTurnAudio():
    var inspectTurn = audioInstance2D.instantiate()
    add_child(inspectTurn)
    inspectTurn.PlayInstance(audioLibrary.knifeInspectTurn)

func PlayInspectStart():
    var inspectStart = audioInstance2D.instantiate()
    add_child(inspectStart)
    inspectStart.PlayInstance(audioLibrary.inspectStart)

func PlayInspectRotate():
    var inspectRotate = audioInstance2D.instantiate()
    add_child(inspectRotate)
    inspectRotate.PlayInstance(audioLibrary.inspectRotate)

func PlayInspectEnd():
    var inspectEnd = audioInstance2D.instantiate()
    add_child(inspectEnd)
    inspectEnd.PlayInstance(audioLibrary.inspectEnd)
