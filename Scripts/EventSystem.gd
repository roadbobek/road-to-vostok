extends Node3D


var gameData = preload("res://Resources/GameData.tres")
const events = preload("res://Events/Events.tres")
const helicopter = preload("res://Assets/Helicopter/Helicopter.tscn")
const crash = preload("res://Assets/Helicopter/Helicopter_Crash.tscn")
const jet = preload("res://Assets/Fighter_Jet/Fighter_Jet.tscn")
const casa = preload("res://Assets/CASA/CASA.tscn")
const btr = preload("res://Assets/BTR/BTR.tscn")
const police = preload("res://Assets/Police/Police.tscn")
const cat = preload("res://Items/Lore/Cat/Cat.tscn")
const rescue = preload("res://Items/Lore/Cat/Rescue.tscn")

var availableEvents: Array[EventData]
var dynamicEvents: Array[EventData]
var traderEvents: Array[EventData]
var specialEvents: Array[EventData]
var map


@onready var paths = $Paths
@onready var crashes = $Crashes

func _ready() -> void :
    await get_tree().create_timer(5.0, false).timeout;
    map = get_tree().current_scene.get_node("/root/Map")
    GetAvailableEvents()
    ActivateDynamicEvent()
    ActivateTraderEvent()
    ActivateSpecialEvent()



func GetAvailableEvents():

    for event in events.events:

        if event.day > Simulation.day:
            continue


        if event.map != "":
            if event.map != map.mapName:
                continue


        if event.zone != "":
            if event.zone != map.mapType:
                continue


        availableEvents.append(event)


        if event.type == "Dynamic": dynamicEvents.append(event)
        elif event.type == "Trader": traderEvents.append(event)
        elif event.type == "Special": specialEvents.append(event)

func ActivateDynamicEvent():

    if dynamicEvents.size() != 0:

        var event = dynamicEvents.pick_random()

        var eventRoll = randi_range(0, 100)

        print("Event Selected (Dynamic): " + event.name + " | " + "Roll: " + str(eventRoll) + "/" + str(event.possibility))


        if eventRoll < event.possibility:

            if event.instant:
                print("Event Activated (Dynamic): " + event.name)
                var eventFunction = Callable(self, event.function)
                eventFunction.call()

            else:
                var eventDelay = randi_range(0, 300)
                var minutes = floor(eventDelay / 60.0)
                var seconds = eventDelay % 60
                print("Event Activated (Dynamic): " + event.name + " | " + "Delay: " + "%02d:%02d" % [minutes, seconds])
                await get_tree().create_timer(eventDelay, false).timeout;
                var eventFunction = Callable(self, event.function)
                eventFunction.call()

func ActivateTraderEvent():

    if traderEvents.size() != 0:

        for event in traderEvents:
            print("Event Activated (Trader): " + event.name)
            var eventFunction = Callable(self, event.function)
            eventFunction.call()

func ActivateSpecialEvent():

    if specialEvents.size() != 0:

        for event in specialEvents:
            print("Event Activated (Special): " + event.name)
            var eventFunction = Callable(self, event.function)
            eventFunction.call()



func FighterJet():

    var event = jet.instantiate()
    add_child(event)

func Airdrop():

    var airdrop = casa.instantiate()
    add_child(airdrop)

func Police():

    var randomPath = paths.get_child(randi_range(0, paths.get_child_count() - 1))
    var initialWaypoint: Node3D
    var inversePath: bool


    var pathDirection = randi_range(1, 2)


    if pathDirection == 1:
        inversePath = false
        initialWaypoint = randomPath.get_child(0)

    else:
        inversePath = true
        initialWaypoint = randomPath.get_child(randomPath.get_child_count() - 1)


    var instance = police.instantiate()
    add_child(instance)


    instance.selectedPath = randomPath
    instance.inversePath = inversePath
    instance.global_transform = initialWaypoint.global_transform

func Helicopter():

    var heli = helicopter.instantiate()
    add_child(heli)

func CrashSite():

    var randomCrash = crashes.get_child(randi_range(0, crashes.get_child_count() - 1))

    var crashSite = crash.instantiate()
    randomCrash.add_child(crashSite)
    crashSite.global_transform = randomCrash.global_transform

func BTR():

    var randomPath = paths.get_child(randi_range(0, paths.get_child_count() - 1))
    var initialWaypoint: Node3D
    var inversePath: bool


    var pathDirection = randi_range(1, 2)


    if pathDirection == 1:
        inversePath = false
        initialWaypoint = randomPath.get_child(0)

    else:
        inversePath = true
        initialWaypoint = randomPath.get_child(randomPath.get_child_count() - 1)


    var instance = btr.instantiate()
    add_child(instance)


    instance.selectedPath = randomPath
    instance.inversePath = inversePath
    instance.global_transform = initialWaypoint.global_transform



func ActivateTrader():

    var traders = get_tree().get_nodes_in_group("Trader")


    for trader in traders:
        trader.Activate()

func DeactivateTrader():

    var traders = get_tree().get_nodes_in_group("Trader")


    for trader in traders:
        trader.Deactivate()



func Cat():

    if gameData.catFound || gameData.catDead: return


    var wells = get_tree().get_nodes_in_group("Well")


    if wells.size() == 0: return


    var randomWell: Node3D = wells.pick_random()


    var wellBottom = randomWell.get_node_or_null("Bottom")


    var catInstance = cat.instantiate()
    wellBottom.add_child(catInstance)
    catInstance.global_transform = wellBottom.global_transform


    var catSystem = catInstance.get_child(0)
    catSystem.currentState = catSystem.State.Rescue


    var rescueInstance = rescue.instantiate()
    wellBottom.add_child(rescueInstance)
    rescueInstance.global_transform = wellBottom.global_transform
    rescueInstance.cat = catInstance


    rescueInstance.position.y = 3.0

func Transmission():

    var radios = get_tree().get_nodes_in_group("Radio")


    if radios.size() == 0: return


    for radio in radios:
        radio.Transmission()
