extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export_group("Data")
@export var instrumentData: Resource

@export_group("References")
@export var animator: AnimationTree
@export var arms: MeshInstance3D
@export var collision: RayCast3D

@export_group("Audio")
@export var audioClips: Array[AudioStreamWAV]
@export var audioPlayer: AudioStreamPlayer2D

var currentState
var isPlaying = false
var isLooping = false
var targetPosition = Vector3.ZERO
var targetRotation = Vector3.ZERO
var lerpSpeed = 7.5
var clipOrder = 0

func _ready():
    position = Vector3(0.0, -0.5, -0.5)
    animator.active = true

func _physics_process(delta):
    if gameData.freeze:
        return


    if isPlaying:
        gameData.mental += delta / 4.0


    currentState = animator.get("parameters/playback").get_current_node()


    if Input.is_action_just_pressed(("fire")):

        if currentState == "Idle":
            isPlaying = true
            animator["parameters/conditions/End"] = false
            animator["parameters/conditions/Play"] = true
            await get_tree().create_timer(1.0, false).timeout;
            audioPlayer.stream = GetNextTrack()
            audioPlayer.play()
            isLooping = true


        elif currentState == "Loop_Mid":
            isPlaying = false
            animator["parameters/conditions/Play"] = false
            animator["parameters/conditions/End"] = true
            audioPlayer.stop()
            isLooping = false


    if !audioPlayer.is_playing() && isPlaying && isLooping:
        animator["parameters/conditions/Play"] = false
        animator["parameters/conditions/End"] = true
        audioPlayer.stop()
        isPlaying = false
        isLooping = false

    Handling(delta)

func Handling(delta):
    if gameData.freeze:
        return

    if collision.is_colliding():
        gameData.isColliding = true
    else:
        gameData.isColliding = false

        if gameData.isColliding:
            targetPosition = instrumentData.collisionPosition
            targetRotation = instrumentData.collisionRotation
        else:
            if isPlaying:
                targetPosition = instrumentData.playPosition
                targetRotation = instrumentData.playRotation
                lerpSpeed = 6.0
            else:
                targetPosition = instrumentData.idlePosition
                targetRotation = instrumentData.idleRotation
                lerpSpeed = 6.0

    position = lerp(position, Vector3( - targetPosition.x, targetPosition.y, - targetPosition.z), delta * lerpSpeed)
    rotation_degrees.x = lerp(rotation_degrees.x, targetRotation.x, delta * lerpSpeed)
    rotation_degrees.y = lerp(rotation_degrees.y, targetRotation.y, delta * lerpSpeed)
    rotation_degrees.z = lerp(rotation_degrees.z, targetRotation.z, delta * lerpSpeed)

func GetNextTrack():
    if clipOrder >= audioClips.size() - 1:
        clipOrder = 0
    else:
        clipOrder += 1

    return audioClips[clipOrder]
