extends Control


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var overlay = $Overlay


var world
var interface
var NVGSlot
var NVGData
var NVGMaterial

func _ready():

    world = get_tree().current_scene.get_node("/root/Map/World")
    interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")
    await get_tree().create_timer(0.1, false).timeout
    NVGSlot = interface.equipmentUI.get_child(17)
    NVGMaterial = overlay.get_child(0).material


    overlay.hide()
    world.environment.environment.tonemap_exposure = 1.0

func _physics_process(delta):

    if !NVGSlot: return


    if gameData.NVG:
        if NVGSlot.get_child_count() != 0:
            Consumption(delta)


    ResetCheck()


    if Input.is_action_just_pressed("nvg") && !gameData.freeze:

        if NVGSlot.get_child_count() == 0: return

        if NVGSlot.get_child(0).slotData.condition <= 0: return

        if gameData.NVG: Deactivate()
        else: Activate()
        NVGAudio()

func Activate():

    if NVGSlot.get_child_count() == 0: return

    NVGData = NVGSlot.get_child(0).slotData.itemData

    if !NVGData: return

    gameData.NVG = true
    overlay.show()

    if NVGData.power == NVGData.Power.Low:
        world.environment.environment.tonemap_exposure = 2.0
    elif NVGData.power == NVGData.Power.Medium:
        world.environment.environment.tonemap_exposure = 2.5
    elif NVGData.power == NVGData.Power.High:
        world.environment.environment.tonemap_exposure = 3.0

    NVGMaterial.set_shader_parameter("tint", NVGData.color)

func Deactivate():

    gameData.NVG = false

    NVGData = null

    overlay.hide()

    world.environment.environment.tonemap_exposure = 1.0

func ResetCheck():

    if Engine.get_physics_frames() % 10 != 0: return

    if gameData.isSubmerged || gameData.isSleeping:
        Deactivate()
        return

    if NVGSlot.get_child_count() == 0:
        Deactivate()
        return

    if NVGSlot.get_child(0).slotData.condition <= 0:
        Deactivate()
        return

    if gameData.NVG:
        NVGData = NVGSlot.get_child(0).slotData.itemData
        Activate()

func Consumption(delta):

    if NVGSlot.get_child_count() == 0: return

    if !NVGData: return

    var coldMultiplier = 2.0 if gameData.season == 2 else 1.0

    if NVGSlot.get_child(0).slotData.condition > 0:
        if NVGData.power == NVGData.Power.Low:
            NVGSlot.get_child(0).slotData.condition -= delta * (0.05 * coldMultiplier)
        elif NVGData.power == NVGData.Power.Medium:
            NVGSlot.get_child(0).slotData.condition -= delta * (0.1 * coldMultiplier)
        elif NVGData.power == NVGData.Power.High:
            NVGSlot.get_child(0).slotData.condition -= delta * (0.2 * coldMultiplier)
        if gameData.interface:
            NVGSlot.get_child(0).UpdateDetails()

func NVGAudio():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.flashlight)

func Load():

    await get_tree().physics_frame

    if gameData.NVG: Activate()
    else: Deactivate()
