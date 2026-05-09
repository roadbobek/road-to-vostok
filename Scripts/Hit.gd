extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")


@export var decal: Decal
@export var impact: GPUParticles3D

func _ready():
    var tween = create_tween()
    tween.tween_callback(Fade).set_delay(10.0)

func Fade():
    var tween = create_tween()
    tween.tween_property($Decal, "scale", Vector3(0.01, 0.01, 0.01), 2.0)
    tween.tween_callback(queue_free).set_delay(2.0)

func Emit():
    impact.emitting = true

func PlayHit(surface):
    var audio = audioInstance3D.instantiate()
    add_child(audio)
    if surface == "Grass": audio.PlayInstance(audioLibrary.hitGrass, 40, 50)
    elif surface == "Dirt": audio.PlayInstance(audioLibrary.hitDirt, 40, 50)
    elif surface == "Asphalt": audio.PlayInstance(audioLibrary.hitAsphalt, 40, 50)
    elif surface == "Rock": audio.PlayInstance(audioLibrary.hitRock, 40, 50)
    elif surface == "Wood": audio.PlayInstance(audioLibrary.hitWood, 40, 50)
    elif surface == "Metal": audio.PlayInstance(audioLibrary.hitMetal, 40, 50)
    elif surface == "Concrete": audio.PlayInstance(audioLibrary.hitConcrete, 40, 50)
    elif surface == "Generic": audio.PlayInstance(audioLibrary.hitGeneric, 40, 50)
    elif surface == "Water": audio.PlayInstance(audioLibrary.hitWater, 40, 50)
    elif surface == "Target": return
    else: audio.PlayInstance(audioLibrary.hitGeneric, 40, 50)

func PlayKnifeHit(surface):
    var audio = audioInstance3D.instantiate()
    add_child(audio)
    if surface == "Grass": audio.PlayInstance(audioLibrary.knifeHitSoft, 10, 50)
    elif surface == "Dirt": audio.PlayInstance(audioLibrary.knifeHitSoft, 10, 50)
    elif surface == "Asphalt": audio.PlayInstance(audioLibrary.knifeHitHard, 10, 50)
    elif surface == "Rock": audio.PlayInstance(audioLibrary.knifeHitHard, 10, 50)
    elif surface == "Wood": audio.PlayInstance(audioLibrary.knifeHitWood, 10, 50)
    elif surface == "Metal": audio.PlayInstance(audioLibrary.knifeHitMetal, 10, 50)
    elif surface == "Concrete": audio.PlayInstance(audioLibrary.knifeHitHard, 10, 50)
    elif surface == "Target": audio.PlayInstance(audioLibrary.knifeHitHard, 10, 50)
    elif surface == "Water": audio.PlayInstance(audioLibrary.hitWater, 10, 50)
    else: audio.PlayInstance(audioLibrary.knifeHitSoft, 10, 50)

func PlayKnifeHitFlesh(attack: int):
    var audio = audioInstance3D.instantiate()
    add_child(audio)

    if attack < 4: audio.PlayInstance(audioLibrary.knifeHitFleshSlash, 10, 50)
    else: audio.PlayInstance(audioLibrary.knifeHitFleshStab, 10, 50)
