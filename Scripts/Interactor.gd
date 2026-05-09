extends RayCast3D


var gameData = preload("res://Resources/GameData.tres")


@onready var HUD = $"../../UI/HUD"
var target

func _physics_process(_delta):

    if (gameData.freeze
    || gameData.isReloading
    || gameData.isInserting
    || gameData.isInspecting
    || gameData.isPlacing
    || gameData.isOccupied):
        gameData.interaction = false
        return


    if gameData.interaction || gameData.transition:
        Interact()


    if Engine.get_physics_frames() % 5 == 0:

        if is_colliding():

            target = get_collider()


            if target.is_in_group("Interactable") && !gameData.decor:
                target.owner.UpdateTooltip()
                gameData.interaction = true


            elif target.is_in_group("Item") && !gameData.decor:
                target.UpdateTooltip()
                gameData.interaction = true


            elif target.is_in_group("Transition") && !gameData.decor:
                HUD.Transition(target.owner)
                gameData.transition = true


            elif target.is_in_group("Furniture") && gameData.decor:
                    gameData.interaction = true
                    target.owner.get_node("Furniture").UpdateTooltip()

            else:
                gameData.interaction = false
                gameData.transition = false

        else:
            gameData.interaction = false
            gameData.transition = false

func Interact():
    if Input.is_action_just_pressed(("interact")):

        if !gameData.decor && target.is_in_group("Interactable"):
            target.owner.Interact()


        elif !gameData.decor && target.is_in_group("Transition"):
            if !target.owner.locked:
                gameData.isTransitioning = true
                target.owner.Interact()
            else:
                target.owner.Interact()


        elif !gameData.decor && target.is_in_group("Item"):
            gameData.interaction = true
            target.Interact()


        if gameData.decor && target.is_in_group("Furniture"):

            for child in target.owner.get_children():
                if child is Furniture:
                    child.Catalog()
