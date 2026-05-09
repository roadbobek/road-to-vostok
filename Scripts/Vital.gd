extends Control


var gameData = preload("res://Resources/GameData.tres")


enum Type{Health, Energy, Hydration, Mental, Temperature, Cat, BodyStamina, ArmStamina, Oxygen}
@export var type = Type.Health
@export var value: Label
@export var icon: TextureRect
@export var progress: ProgressBar

func _physics_process(_delta):
    if Engine.get_physics_frames() % 20 == 0 && !gameData.isTransitioning:



        if type == Type.Health:
            if value:
                value.text = str(int(round(gameData.health)))

                if gameData.health <= 25:
                    value.modulate = Color.RED
                elif gameData.health > 25 && gameData.health <= 50:
                    value.modulate = Color.YELLOW
                else:
                    value.modulate = Color.GREEN



        elif type == Type.Energy:
            if value:
                value.text = str(int(round(gameData.energy)))

                if gameData.energy <= 25:
                    value.modulate = Color.RED
                elif gameData.energy > 25 && gameData.energy <= 50:
                    value.modulate = Color.YELLOW
                else:
                    value.modulate = Color.GREEN



        elif type == Type.Hydration:
            if value:
                value.text = str(int(round(gameData.hydration)))

                if gameData.hydration <= 25:
                    value.modulate = Color.RED
                elif gameData.hydration > 25 && gameData.hydration <= 50:
                    value.modulate = Color.YELLOW
                else:
                    value.modulate = Color.GREEN



        elif type == Type.Mental:
            if value:
                value.text = str(int(round(gameData.mental)))

                if gameData.mental <= 25:
                    value.modulate = Color.RED
                elif gameData.mental > 25 && gameData.mental <= 50:
                    value.modulate = Color.YELLOW
                else:
                    value.modulate = Color.GREEN



        elif type == Type.Temperature:
            if value:
                value.text = str(int(round(gameData.temperature)))

                if gameData.temperature <= 25:
                    value.modulate = Color.RED
                elif gameData.temperature > 25 && gameData.temperature <= 50:
                    value.modulate = Color.YELLOW
                else:
                    value.modulate = Color.GREEN



        elif type == Type.Cat:
            if value:
                value.text = str(int(round(gameData.cat)))

                if gameData.cat <= 25:
                    value.modulate = Color.RED
                elif gameData.cat > 25 && gameData.cat <= 50:
                    value.modulate = Color.YELLOW
                else:
                    value.modulate = Color.GREEN



        elif type == Type.BodyStamina:
            if progress:
                progress.value = clampf(gameData.bodyStamina, 0, 100)
            if icon:
                if gameData.bodyStamina > 1 && !gameData.overweight:
                    icon.modulate = Color.GRAY
                else:
                    icon.modulate = Color.RED

        elif type == Type.ArmStamina:
            if progress:
                progress.value = clampf(gameData.armStamina, 0, 100)
            if icon:
                if gameData.armStamina > 1 && !gameData.overweight:
                    icon.modulate = Color.GRAY
                else:
                    icon.modulate = Color.RED



        elif type == Type.Oxygen:
            if progress:
                progress.value = clampi(gameData.oxygen, 0, 100)
