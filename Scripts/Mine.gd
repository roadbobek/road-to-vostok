extends Node3D
class_name Mine


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")
var explosionVFX = preload("res://Effects/Explosion.tscn")

@export var mine: Node3D
@export var spring: AudioEvent

var isDetonated = false
var detonationHeight = 2.0
var character

func _ready():
    character = get_tree().current_scene.get_node("/root/Map/Core/Controller/Character/")

func _physics_process(delta):
    if isDetonated:
        mine.position.y = move_toward(mine.position.y, detonationHeight, delta * 10.0)

        if mine.position.y == detonationHeight:
            var effect = explosionVFX.instantiate()
            get_tree().get_root().add_child(effect)
            effect.position = global_position + Vector3(0, detonationHeight, 0)
            effect.Explode()
            queue_free()

func Detonate():
    if !isDetonated:
        isDetonated = true
        SpringAudio()

func InstantDetonate():
    if !isDetonated:
        var effect = explosionVFX.instantiate()
        get_tree().get_root().add_child(effect)
        effect.position = global_position + Vector3(0, 0.5, 0)
        effect.Explode()
        queue_free()

func SpringAudio():
    var audio = audioInstance3D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.position = global_position
    audio.PlayInstance(spring, 10, 20)
