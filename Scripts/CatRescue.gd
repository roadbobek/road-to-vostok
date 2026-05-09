extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")

@export var slotData: SlotData
var interface
var cat

func _ready():
    interface = get_tree().current_scene.get_node_or_null("/root/Map/Core/UI/Interface")



func Interact():

    if interface.Create(slotData, interface.inventoryGrid, false):
        interface.UpdateStats(false)
        gameData.catFound = true
        Loader.Message("Cat Rescued", Color.GREEN)
        Loader.Message("Cat Vital Activated", Color.GREEN)
        PlayPickup()
        cat.queue_free()
        queue_free()

    else:
        interface.PlayError()



func UpdateTooltip():
    gameData.tooltip = "Rescue Cat"



func PlayPickup():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.pickup)
