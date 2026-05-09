extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export var targets: Array[Node3D]
@export var active = false

func Interact():
    active = !active

    if active:
        Activate()
        PlaySwitch()
    else:
        Deactivate()
        PlaySwitch()

func Activate():
    for target in targets:
        target.Activate()
        active = true

func Deactivate():
    for target in targets:
        target.Deactivate()
        active = false

func UpdateTooltip():
    if active:
        gameData.tooltip = "Turn Off"
    else:
        gameData.tooltip = "Turn On"

func PlaySwitch():
    var switch = audioInstance2D.instantiate()
    add_child(switch)
    switch.PlayInstance(audioLibrary.switch)
