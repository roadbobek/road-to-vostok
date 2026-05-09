extends Control


var gameData = preload("res://Resources/GameData.tres")

enum Type{Overweight, Starvation, Dehydration, Bleeding, Fracture, Burn, Frostbite, Insanity, Poisoning, Rupture, Headshot}
@export var type = Type.Overweight

func _physics_process(_delta):
    if Engine.get_physics_frames() % 10 == 0:

        if type == Type.Overweight:
            if gameData.overweight:
                modulate = Color8(255, 0, 0, 255)
            else:
                modulate = Color8(255, 255, 255, 64)

        elif type == Type.Starvation:
            if gameData.starvation:
                modulate = Color8(255, 0, 0, 255)
            else:
                modulate = Color8(255, 255, 255, 64)

        elif type == Type.Dehydration:
            if gameData.dehydration:
                modulate = Color8(255, 0, 0, 255)
            else:
                modulate = Color8(255, 255, 255, 64)

        elif type == Type.Bleeding:
            if gameData.bleeding:
                modulate = Color8(255, 0, 0, 255)
            else:
                modulate = Color8(255, 255, 255, 64)

        elif type == Type.Fracture:
            if gameData.fracture:
                modulate = Color8(255, 0, 0, 255)
            else:
                modulate = Color8(255, 255, 255, 64)

        elif type == Type.Burn:
            if gameData.burn:
                modulate = Color8(255, 0, 0, 255)
            else:
                modulate = Color8(255, 255, 255, 64)

        elif type == Type.Frostbite:
            if gameData.frostbite:
                modulate = Color8(255, 0, 0, 255)
            else:
                modulate = Color8(255, 255, 255, 64)

        elif type == Type.Insanity:
            if gameData.insanity:
                modulate = Color8(255, 0, 0, 255)
            else:
                modulate = Color8(255, 255, 255, 64)

        elif type == Type.Poisoning:
            if gameData.poisoning:
                modulate = Color8(255, 0, 0, 255)
            else:
                modulate = Color8(255, 255, 255, 64)

        elif type == Type.Rupture:
            if gameData.rupture:
                modulate = Color8(255, 0, 0, 255)
            else:
                modulate = Color8(255, 255, 255, 64)

        elif type == Type.Headshot:
            if gameData.headshot:
                modulate = Color8(255, 0, 0, 255)
            else:
                modulate = Color8(255, 255, 255, 64)
