extends Node3D


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")
var gameData = preload("res://Resources/GameData.tres")

@export var cat: Node3D
@export var collision: CollisionShape3D
@export var feedItems: Array[ItemData] = []

func Activate():
    position.y = 0.05
    collision.disabled = false

func Deactivate():
    position.y = 0.0
    collision.disabled = true

func Interact():

    if cat.currentState != cat.State.Eat:
        TryFeeding()

func TryFeeding():

    var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")


    for child in interface.inventoryGrid.get_children():

        var itemData = child.slotData.itemData


        if itemData in feedItems:

            cat.currentState = cat.State.Eat

            gameData.cat = 100.0
            cat.ForceMeow()

            interface.inventoryGrid.Pick(child)
            child.queue_free()

            Loader.Message("Cat Fed (" + itemData.name + ")", Color.GREEN)

            await get_tree().create_timer(30.0, false).timeout;

            if is_instance_valid(cat): cat.currentState = cat.State.Idle
            return

func UpdateTooltip():

    if cat.currentState == cat.State.Eat: gameData.tooltip = "Cat is eating, do not disturb"

    else: gameData.tooltip = "Feed cat:" + "\n" + "[" + CreateFeedString() + "]"

func CreateFeedString() -> String:
    var string = ""
    var stringSize = feedItems.size()

    for element in feedItems:
        string += String(element.display)
        stringSize -= 1

        if stringSize > 0:
            string += ", "

    return string
