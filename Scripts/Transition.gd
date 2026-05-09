extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@export var spawn: Node3D
@export var time: float
@export var nextMap: String
@export var nextZone: String
@export var currentMap: String
@export var shelterEnter: bool
@export var shelterExit: bool
@export var tutorialExit: bool
@export var key: ItemData
var locked = false


var energy: float
var hydration: float

func _ready():

    energy = time * 5.0
    hydration = time * 10.0


    if spawn: spawn.hide()


    if shelterEnter && key:
        if !Loader.CheckShelterState(nextMap):
            locked = true

func Interact():

    if locked:
        CheckKey()
        return


    Simulation.simulate = false


    if tutorialExit: Loader.LoadScene(nextMap)


    else:

        UpdateSimulation()


        Simulation.simulate = true


        gameData.currentMap = nextMap
        gameData.previousMap = currentMap
        gameData.energy -= energy
        gameData.hydration -= hydration


        Loader.LoadScene(nextMap)
        Loader.SaveCharacter()
        Loader.SaveWorld()


        if shelterExit: Loader.SaveShelter(currentMap)

func CheckKey():

    var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")


    for item in interface.inventoryGrid.get_children():

        if item.slotData.itemData.file == key.file:

            locked = false
            Loader.UnlockShelter(nextMap)
            PlayUnlock()

            interface.inventoryGrid.Pick(item)
            item.queue_free()
            break

func UpdateSimulation():

    var travelTime = time * 100.0
    var currentTime = Simulation.time
    var combinedTime = currentTime + travelTime
    var arrivalTime: float


    if combinedTime >= 2400.0:
        arrivalTime = combinedTime - 2400.0
        Simulation.day += 1
        Simulation.time = arrivalTime
        Simulation.weatherTime -= travelTime
        Loader.UpdateProgression()

    else:
        arrivalTime = combinedTime
        Simulation.time = arrivalTime
        Simulation.weatherTime -= travelTime

    print("Transition: " + nextMap)
    print("Current time: " + str(int(currentTime)) + " Travel time: " + str(int(travelTime)) + " Arrival time: " + str(int(arrivalTime)))

func PlayUnlock():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.doorUnlock)
