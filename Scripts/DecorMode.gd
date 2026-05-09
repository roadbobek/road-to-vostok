extends Node


var gameData = preload("res://Resources/GameData.tres")


var currentMap

func _ready():

    await get_tree().create_timer(1.0, false).timeout;


    currentMap = get_tree().current_scene.get_node("/root/Map")

    if gameData.shelter || gameData.tutorial || currentMap.mapName == "Template":
        gameData.decor = false
        FurnitureVisibility(false)

func _physics_process(_delta):

    if (gameData.freeze
    || gameData.isPlacing
    || gameData.isOccupied
    || gameData.interface
    || gameData.settings):
        return

    if Input.is_action_just_pressed("decor") && (gameData.shelter || gameData.tutorial || currentMap.mapName == "Template"):
        gameData.decor = !gameData.decor

        if gameData.decor:
            FurnitureVisibility(true)
        else:
            FurnitureVisibility(false)

func FurnitureVisibility(visibility: bool):

    var furnitures = get_tree().get_nodes_in_group("Furniture")
    var transitions = get_tree().get_nodes_in_group("Transition")


    for furniture in furnitures:

        for child in furniture.owner.get_children():
            if child is Furniture:
                if visibility:
                    child.indicator.show()
                else:
                    child.indicator.hide()


    for transition in transitions:

        if transition.owner.spawn:
            if visibility:
                transition.owner.spawn.show()
            else:
                transition.owner.spawn.hide()
