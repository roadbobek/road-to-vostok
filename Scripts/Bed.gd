extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


var canSleep = true
var randomSleep = 0

func _ready():

    canSleep = true
    randomSleep = randi_range(6, 12)

func Interact():
    if canSleep:

        Simulation.simulate = false
        gameData.isSleeping = true
        gameData.freeze = true


        UpdateSimulation(randomSleep * 100.0)
        PlayTransition()
        PlaySleep()


        await get_tree().create_timer(randomSleep, false).timeout;


        gameData.energy -= 20.0
        gameData.hydration -= 20.0
        gameData.mental += 20.0


        var controller = get_tree().current_scene.get_node("/root/Map/Core/Controller")
        controller.global_transform.basis = controller.global_transform.basis.rotated(Vector3.UP, deg_to_rad(180))


        Loader.Message("You slept " + str(int(randomSleep)) + " hours", Color.GREEN)


        Simulation.simulate = true
        gameData.isSleeping = false
        gameData.freeze = false
        canSleep = false

func UpdateTooltip():
    if canSleep:
        gameData.tooltip = "Sleep (Random sleep: 6-12h)"
    else:
        gameData.tooltip = ""

func UpdateSimulation(sleepTime):

    var currentTime = Simulation.time
    var combinedTime = currentTime + sleepTime
    var wakeTime: float


    if combinedTime >= 2400.0:
        wakeTime = combinedTime - 2400.0
        Simulation.day += 1
        Simulation.time = wakeTime
        Simulation.weatherTime -= sleepTime
        Loader.UpdateProgression()

    else:
        wakeTime = combinedTime
        Simulation.time = wakeTime
        Simulation.weatherTime -= sleepTime

    print("Current: " + str(int(currentTime)) + " Sleep: " + str(int(sleepTime)) + " Wake: " + str(int(wakeTime)))

func PlayTransition():
    var transition = audioInstance2D.instantiate()
    add_child(transition)
    transition.PlayInstance(audioLibrary.transition)

func PlaySleep():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.sleep)
