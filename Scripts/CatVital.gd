extends Control


var gameData = preload("res://Resources/GameData.tres")


@export var header: Label
@export var value: Label
@export var icon: TextureRect

func _physics_process(_delta):
    if Engine.get_physics_frames() % 20 == 0 && !gameData.isTransitioning:


        if gameData.catFound && !gameData.catDead:
            header.modulate = Color.WHITE
            value.text = str(int(round(gameData.cat)))

            if gameData.cat <= 25: value.modulate = Color.RED
            elif gameData.cat > 25 && gameData.cat <= 50: value.modulate = Color.YELLOW
            else: value.modulate = Color.GREEN


        elif gameData.catFound && gameData.catDead:
            header.modulate = Color.DIM_GRAY
            value.modulate = Color.DIM_GRAY
            value.text = "RIP"


        else:
            header.modulate = Color.DIM_GRAY
            value.modulate = Color.DIM_GRAY
            value.text = "100"
