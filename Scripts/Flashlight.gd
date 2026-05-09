extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var lightWorld = $World
@onready var lightFPS = $FPS


var interface
var lightSlot
var lightData

func _ready():

    interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")
    await get_tree().create_timer(0.1, false).timeout
    lightSlot = interface.equipmentUI.get_child(16)


    lightWorld.spot_range = 0.0
    lightWorld.light_energy = 0.0
    lightFPS.omni_range = 0.0
    lightFPS.light_energy = 0.0

func _physics_process(delta):

    if !lightSlot: return


    if gameData.flashlight:
        if lightSlot.get_child_count() != 0:
            Consumption(delta)


    ResetCheck()


    if Input.is_action_just_pressed("flashlight") && !gameData.freeze:

        if lightSlot.get_child_count() == 0: return

        if lightSlot.get_child(0).slotData.condition <= 0: return

        if gameData.flashlight: Deactivate()
        else: Activate()
        LightAudio()

func Activate():

    if lightSlot.get_child_count() == 0: return

    lightData = lightSlot.get_child(0).slotData.itemData

    if !lightData: return

    gameData.flashlight = true

    if lightData.power == lightData.Power.Low:
        lightWorld.spot_range = 25.0
        lightWorld.light_energy = 10.0
        lightFPS.omni_range = 2.0
        lightFPS.light_energy = 2.0
    elif lightData.power == lightData.Power.Medium:
        lightWorld.spot_range = 50.0
        lightWorld.light_energy = 20.0
        lightFPS.omni_range = 2.0
        lightFPS.light_energy = 3.0
    elif lightData.power == lightData.Power.High:
        lightWorld.spot_range = 100.0
        lightWorld.light_energy = 50.0
        lightFPS.omni_range = 2.0
        lightFPS.light_energy = 4.0

    lightWorld.light_color = lightData.color
    lightFPS.light_color = lightData.color

func Deactivate():

    gameData.flashlight = false

    lightData = null

    lightWorld.spot_range = 0.0
    lightWorld.light_energy = 0.0
    lightFPS.omni_range = 0.0
    lightFPS.light_energy = 0.0

func ResetCheck():

    if Engine.get_physics_frames() % 10 != 0: return

    if gameData.isSubmerged:
        Deactivate()
        return

    if lightSlot.get_child_count() == 0:
        Deactivate()
        return

    if lightSlot.get_child(0).slotData.condition <= 0:
        Deactivate()
        return

    if gameData.flashlight:
        lightData = lightSlot.get_child(0).slotData.itemData
        Activate()

func Consumption(delta):

    if lightSlot.get_child_count() == 0: return

    if !lightData: return

    var coldMultiplier = 2.0 if gameData.season == 2 else 1.0

    if lightSlot.get_child(0).slotData.condition > 0:
        if lightData.power == lightData.Power.Low:
            lightSlot.get_child(0).slotData.condition -= delta * (0.05 * coldMultiplier)
        elif lightData.power == lightData.Power.Medium:
            lightSlot.get_child(0).slotData.condition -= delta * (0.1 * coldMultiplier)
        elif lightData.power == lightData.Power.High:
            lightSlot.get_child(0).slotData.condition -= delta * (0.2 * coldMultiplier)
        if gameData.interface:
            lightSlot.get_child(0).UpdateDetails()

func LightAudio():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.flashlight)

func Load():

    await get_tree().physics_frame

    if gameData.flashlight: Activate()
    else: Deactivate()
