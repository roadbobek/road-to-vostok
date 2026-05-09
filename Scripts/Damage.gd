extends Node3D


var gameData = preload("res://Resources/GameData.tres")

@export var noise: FastNoiseLite
var weaponNoiseOffset = Vector3.ZERO
var weaponNoise = Vector3.ZERO
var weaponRotation = Vector3.ZERO
var time

var targetFrequency = 0.0
var targetAmplitude = 0.0
var targetLerpSpeed = 0.0

var finalFrequency = 0.0
var finalAmplitude = 0.0

func _physics_process(delta):
    if gameData.flycam:
        return

    if gameData.impact || gameData.damage:
        targetFrequency = 0.5
        targetAmplitude = 0.5
        targetLerpSpeed = 5.0
    else:
        targetFrequency = 0.0
        targetAmplitude = 0.0
        targetLerpSpeed = 2.5

    finalFrequency = lerp(finalFrequency, targetFrequency, delta * targetLerpSpeed)
    finalAmplitude = lerp(finalAmplitude, targetAmplitude, delta * targetLerpSpeed)

    var weaponScrollOffset = delta * finalFrequency

    weaponNoiseOffset.x += weaponScrollOffset
    weaponNoiseOffset.y += weaponScrollOffset
    weaponNoiseOffset.z += weaponScrollOffset

    weaponNoise.x = noise.get_noise_2d(weaponNoiseOffset.x, 0.0)
    weaponNoise.y = noise.get_noise_2d(weaponNoiseOffset.y, 1.0)
    weaponNoise.z = noise.get_noise_2d(weaponNoiseOffset.z, 2.0)

    weaponNoise *= finalAmplitude

    rotation.x = weaponNoise.x
    rotation.y = weaponNoise.y
    rotation.z = weaponNoise.z
