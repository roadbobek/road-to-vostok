extends Area3D


var gameData = preload("res://Resources/GameData.tres")

var sensorTimer = 0.0
var sensorCycle = 0.2
var indoorValue = 0.0


@onready var character = $"../Character"

func _physics_process(delta):

    if gameData.isCaching: return


    Indoor(delta)


    sensorTimer += delta


    if sensorTimer > sensorCycle:
        Detect()
        sensorTimer = 0.0

func Detect():
    var overlaps = get_overlapping_areas()

    if overlaps.size() > 0:
        for overlap in overlaps:
            if overlap is Area:

                if overlap.type == "Indoor":
                    gameData.indoor = true
                else:
                    gameData.indoor = false

                if overlap.type == "Mine":
                    if !overlap.owner.isDetonated:
                        overlap.owner.Detonate()

                if overlap.type == "Fire":
                    gameData.isBurning = true
                    if !gameData.burn:
                        character.Burn(true)
                else:
                    gameData.isBurning = false

                if overlap.type == "Heat":
                    gameData.heat = true
                else:
                    gameData.heat = false

                if overlap.type == "PRX_Heat":
                    gameData.PRX_Heat = true
                else:
                    gameData.PRX_Heat = false

                if overlap.type == "PRX_Workbench":
                    gameData.PRX_Workbench = true
                else:
                    gameData.PRX_Workbench = false
    else:
        gameData.indoor = false
        gameData.isBurning = false
        gameData.heat = false
        gameData.PRX_Heat = false
        gameData.PRX_Workbench = false

func Indoor(delta):
    if gameData.indoor: indoorValue = move_toward(indoorValue, 1.0, delta)
    else: indoorValue = move_toward(indoorValue, 0.0, delta)
    RenderingServer.global_shader_parameter_set("Indoor", indoorValue)
