extends Node3D


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var gameData = preload("res://Resources/GameData.tres")


@onready var leak = $Leak


@onready var submerged = $Submerged
@onready var masterBus = AudioServer.get_bus_index("Master")
@onready var ambientBus = AudioServer.get_bus_index("Ambient")
var ambientAmplify: AudioEffectAmplify = AudioServer.get_bus_effect(1, 1)

var masterLowPass
var lowPassEffect
var lowPassValue


var world
var controller
var rigManager
var UIManager

func _ready():

    world = get_tree().current_scene.get_node("/root/Map/World")
    controller = get_tree().current_scene.get_node("/root/Map/Core/Controller")
    rigManager = get_tree().current_scene.get_node("/root/Map/Core/Camera/Manager")
    UIManager = get_tree().current_scene.get_node("/root/Map/Core/UI")


    masterLowPass = AudioServer.get_bus_effect(0, 0)
    lowPassEffect = AudioServer.get_bus_effect(1, 0)
    masterLowPass.cutoff_hz = 20000


    leak.show()

func _physics_process(_delta):

    if !gameData.indoor && visible:


        if controller.global_position.y < -2.0:
            gameData.isWater = true
        elif controller.global_position.y > -2.0:
            gameData.isWater = false


        if controller.camera.global_position.y < -1.98 && !gameData.isSubmerged:
            leak.hide()
            gameData.isSubmerged = true
            gameData.isFalling = false
            masterLowPass.cutoff_hz = 2000
            ambientAmplify.volume_db = linear_to_db(0)


            if !gameData.compatibility:
                world.environment.environment.fog_enabled = true
                world.environment.environment.volumetric_fog_enabled = false


            if gameData.interface:
                UIManager.ToggleInterface()


            if rigManager.get_child_count() != 0:
                rigManager.ClearRig()
                rigManager.PlayUnequip()


            submerged.play()
            PlayWaterDive()


        elif controller.camera.global_position.y > -1.98 && gameData.isSubmerged:
            leak.show()
            gameData.isSubmerged = false
            masterLowPass.cutoff_hz = 20000
            ambientAmplify.volume_db = linear_to_db(1)


            if !gameData.compatibility:
                world.environment.environment.fog_enabled = false
                world.environment.environment.volumetric_fog_enabled = true


            if gameData.oxygen < 50:
                PlayWaterGasp()


            submerged.stop()
            PlayWaterSurface()


    else:
        gameData.isWater = false
        gameData.isSubmerged = false

func PlayWaterDive():
    var waterDive = audioInstance2D.instantiate()
    add_child(waterDive)
    waterDive.PlayInstance(audioLibrary.waterDive)

func PlayWaterSurface():
    var waterSurface = audioInstance2D.instantiate()
    add_child(waterSurface)
    waterSurface.PlayInstance(audioLibrary.waterSurface)

func PlayWaterGasp():
    var waterGasp = audioInstance2D.instantiate()
    add_child(waterGasp)
    waterGasp.PlayInstance(audioLibrary.waterGasp)
