extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")

var dynamicTimer = 0.0
var map


const crow = preload("res://Audio/Dynamic/Crow.tres")
const woodBreak = preload("res://Audio/Dynamic/Wood_Break.tres")
const treeCreak = preload("res://Audio/Dynamic/Tree_Creak.tres")
const owl = preload("res://Audio/Dynamic/Owl.tres")
const windGust = preload("res://Audio/Dynamic/Wind_Gust.tres")


const cuckoo = preload("res://Audio/Dynamic/Cuckoo.tres")
const birdAlarm = preload("res://Audio/Dynamic/Bird_Alarm.tres")
const blackbird = preload("res://Audio/Dynamic/Blackbird.tres")
const chaffinch = preload("res://Audio/Dynamic/Chaffinch.tres")
const crane = preload("res://Audio/Dynamic/Crane.tres")
const fox = preload("res://Audio/Dynamic/Fox.tres")
const goshawk = preload("res://Audio/Dynamic/Goshawk.tres")
const magpie = preload("res://Audio/Dynamic/Magpie.tres")
const jackdaw = preload("res://Audio/Dynamic/Jackdaw.tres")
const plover = preload("res://Audio/Dynamic/Plover.tres")
const rooster = preload("res://Audio/Dynamic/Rooster.tres")
const seagull = preload("res://Audio/Dynamic/Seagull.tres")
const woodpecker = preload("res://Audio/Dynamic/Woodpecker.tres")
const woodpidgeon = preload("res://Audio/Dynamic/Woodpidgeon.tres")
const wren = preload("res://Audio/Dynamic/Wren.tres")
const mosquitos = preload("res://Audio/Dynamic/Mosquitos.tres")


const bear = preload("res://Audio/Dynamic/Bear.tres")
const dog = preload("res://Audio/Dynamic/Dog.tres")
const wolf = preload("res://Audio/Dynamic/Wolf.tres")
const car = preload("res://Audio/Dynamic/Car.tres")
const fighterJet = preload("res://Audio/Dynamic/Fighter_Jet.tres")
const helicopter = preload("res://Audio/Dynamic/Helicopter.tres")
const tank = preload("res://Audio/Dynamic/Tank.tres")
const artillery = preload("res://Audio/Dynamic/Artillery.tres")
const explosion = preload("res://Audio/Dynamic/Explosion.tres")
const rumble = preload("res://Audio/Dynamic/Rumble.tres")
const hit = preload("res://Audio/Dynamic/Hit.tres")


var area05Day: Array[AudioEvent]
var area05DayEvents = [crow, woodBreak, cuckoo, birdAlarm, blackbird, chaffinch, crane, fox, goshawk, jackdaw, magpie, plover, rooster, seagull, wren, mosquitos]
var area05Night: Array[AudioEvent]
var area05NightEvents = [crow, woodBreak, crane, fox, owl, treeCreak, windGust, woodpecker, woodpidgeon, mosquitos]


var borderZoneDay: Array[AudioEvent]
var borderZoneDayEvents = [bear, crow, birdAlarm, crane, dog, woodBreak, windGust, car, fighterJet, helicopter, tank, rumble]
var borderZoneNight: Array[AudioEvent]
var borderZoneNightEvents = [bear, crow, crane, dog, woodBreak, owl, treeCreak, windGust, wolf, car, fighterJet, helicopter, tank, rumble]


var vostokDay: Array[AudioEvent]
var vostokDayEvents = [fighterJet, helicopter, tank, artillery, explosion, rumble, hit]
var vostokNight: Array[AudioEvent]
var vostokNightEvents = [treeCreak, windGust, wolf, fighterJet, helicopter, tank, artillery, explosion, rumble, hit]

func _ready() -> void :
    map = get_tree().current_scene.get_node("/root/Map")
    dynamicTimer = randf_range(1, 10)
    AssignEvents()

func AssignEvents():
    for event in area05DayEvents: area05Day.append(event)
    for event in area05NightEvents: area05Night.append(event)
    for event in borderZoneDayEvents: borderZoneDay.append(event)
    for event in borderZoneNightEvents: borderZoneNight.append(event)
    for event in vostokDayEvents: vostokDay.append(event)
    for event in vostokNightEvents: vostokNight.append(event)

func _physics_process(delta):
    dynamicTimer -= delta

    if dynamicTimer <= 0:
        if !gameData.indoor && map.mapName != "Intro" && Simulation.season != 2:
            PlayDynamicAudio()

        dynamicTimer = randf_range(1, 120)

func PlayDynamicAudio():

    var audio = audioInstance3D.instantiate()
    add_child(audio)


    audio.bus = &"Ambient"


    var xDirection = randi_range(0, 1)
    var zDirection = randi_range(0, 1)
    var xPosition
    var zPosition


    if xDirection == 0:
        xPosition = randf_range(-200, -100)

    else:
        xPosition = randf_range(100, 200)


    if zDirection == 0:
        zPosition = randf_range(-200, -100)

    else:
        zPosition = randf_range(100, 200)


    var audioPositionX = gameData.playerPosition.x + xPosition
    var audioPositionY = gameData.playerPosition.y
    var audioPositionZ = gameData.playerPosition.z + zPosition
    audio.global_position = Vector3(audioPositionX, audioPositionY, audioPositionZ)


    if map.mapType == "Area 05":
        if gameData.TOD == 4:
            var randomEvent: AudioEvent = area05Night.pick_random()
            audio.PlayInstance(randomEvent, 250, 400)
        else:
            var randomEvent: AudioEvent = area05Day.pick_random()
            audio.PlayInstance(randomEvent, 250, 400)

    elif map.mapType == "Border Zone":
        if gameData.TOD == 4:
            var randomEvent: AudioEvent = borderZoneNight.pick_random()
            audio.PlayInstance(randomEvent, 250, 400)
        else:
            var randomEvent: AudioEvent = borderZoneDay.pick_random()
            audio.PlayInstance(randomEvent, 250, 400)

    elif map.mapType == "Vostok":
        if gameData.TOD == 4:
            var randomEvent: AudioEvent = vostokNight.pick_random()
            audio.PlayInstance(randomEvent, 250, 400)
        else:
            var randomEvent: AudioEvent = vostokDay.pick_random()
            audio.PlayInstance(randomEvent, 250, 400)
