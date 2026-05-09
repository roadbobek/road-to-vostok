extends Node3D


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")
var gameData = preload("res://Resources/GameData.tres")


@export var data: CatData
@export var box: Node3D
@export var animator: AnimationMixer
@export var animations: AnimationPlayer
@export var skeleton: Skeleton3D
@export var jawIndex = 0


var meow = false
var canMeow = false
var meowTimer = 0.0
var meowCycle = 10.0
var meowRotation = 0.0
var meowTime = 0.5


enum State{Idle, Sit, Bake, Eat, Sleep, Rescue}
var currentState = State.Idle

func _ready() -> void :

    if gameData.catDead:
        Dead()
        return


    currentState = State.Sit
    animator.active = true

func _physics_process(delta: float) -> void :
    Behavior()
    Meow(delta)



func Behavior():

    if currentState != State.Rescue:

        if !box.isOpen && currentState != State.Sit:
            ResetAnimations()
            animator["parameters/conditions/Sit"] = true
            currentState = State.Sit
            return


        if box.isOpen && currentState == State.Sit:
            currentState = State.Idle
            return


    if currentState == State.Rescue: meowCycle = 5.0
    else: meowCycle = randf_range(30, 120)


    if currentState == State.Idle:
        canMeow = true
        ResetAnimations()
        animator["parameters/conditions/Idle"] = true
    elif currentState == State.Sit:
        canMeow = false
        ResetAnimations()
        animator["parameters/conditions/Sit"] = true
    elif currentState == State.Bake:
        canMeow = false
        ResetAnimations()
        animator["parameters/conditions/Bake"] = true
    elif currentState == State.Eat:
        canMeow = false
        ResetAnimations()
        animator["parameters/conditions/Eat"] = true
    elif currentState == State.Sleep:
        canMeow = false
        ResetAnimations()
        animator["parameters/conditions/Sleep"] = true
    elif currentState == State.Rescue:
        canMeow = true
        ResetAnimations()
        animator["parameters/conditions/Sleep"] = true

func Meow(delta):

    if canMeow:

        meowTimer += delta


        if meowTimer > meowCycle && !meow:

            meow = true
            PlayMeow()
            await get_tree().create_timer(0.5, false).timeout;

            meowTimer = 0.0
            meow = false


    if !meow: meowRotation = lerp(meowRotation, deg_to_rad(data.meowRotation.x), delta * 2.0)
    elif meow: meowRotation = lerp(meowRotation, deg_to_rad(data.meowRotation.y), delta * 2.0)


    var currentPose = skeleton.get_bone_global_pose_no_override(jawIndex)
    var updatedPose: Transform3D


    if data.meowDirection == 0: updatedPose = currentPose.rotated_local(Vector3.RIGHT, meowRotation)
    elif data.meowDDirection == 1: updatedPose = currentPose.rotated_local(Vector3.UP, meowRotation)
    else: updatedPose = currentPose.rotated_local(Vector3.FORWARD, meowRotation)


    skeleton.set_bone_global_pose_override(jawIndex, updatedPose, 1.0, true)

func ForceMeow():

    meow = true
    PlayMeow()
    await get_tree().create_timer(0.5, false).timeout;

    meowTimer = 0.0
    meow = false

func ResetAnimations():
    animator["parameters/conditions/Sit"] = false
    animator["parameters/conditions/Idle"] = false
    animator["parameters/conditions/Bake"] = false
    animator["parameters/conditions/Eat"] = false

func Dead():
    animator.active = false
    animations.play("Cat_Sleep")
    animations.stop()



func PlayMeow():

    var audio = audioInstance3D.instantiate()
    add_child(audio)
    audio.PlayInstance(data.meow, 2, 20)
