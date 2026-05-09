extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


var active = false
@export var furniture: Furniture
@export var mesh: MeshInstance3D
@export var defaultMaterial: Material
@export var activeMaterial: Material
@export var light: SpotLight3D
@export var audio: AudioStreamPlayer3D

func _ready() -> void :
    Deactivate()

func _physics_process(_delta):
    if Engine.get_physics_frames() % 10 == 0:
        if active && furniture.isMoving:
            MoveReset()

func UpdateTooltip():
    if active:
        gameData.tooltip = "Television [Turn Off]"
    else:
        gameData.tooltip = "Television [Turn On]"

func Interact():
    active = !active
    if active: Activate()
    else: Deactivate()
    PlayToggle()

func Activate():
    mesh.set_surface_override_material(1, activeMaterial)
    light.spot_range = 1.0
    light.show()
    audio.play()

func Deactivate():
    mesh.set_surface_override_material(1, defaultMaterial)
    light.spot_range = 0.0
    light.hide()
    audio.stop()

func MoveReset():
    mesh.set_surface_override_material(1, furniture.furnitureMaterial)
    light.spot_range = 0.0
    light.hide()
    audio.stop()
    active = false

func PlayToggle():
    var toggle = audioInstance2D.instantiate()
    add_child(toggle)
    toggle.PlayInstance(audioLibrary.UICasettePlay)
