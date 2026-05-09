extends Control


var gameData = preload("res://Resources/GameData.tres")


@onready var map = $Info / Map
@onready var FPS = $Info / FPS
@onready var frames = $Info / FPS / Frames
@onready var tooltip = $Tooltip
@onready var label = $Tooltip / Label
@onready var permadeath = $Permadeath
@onready var decor = $Decor
@onready var magnet = $Decor / Margin / Elements / Header / Magnet
@onready var placement = $Placement
@onready var magazine = $Magazine
@onready var chamber = $Chamber
@onready var stats = $Stats
@onready var vitals = $Stats / Vitals
@onready var medical = $Stats / Medical
@onready var oxygen = $Stats / Oxygen
@onready var malfunction = $Malfunction


@onready var transition = $Transition
@onready var destination = $Transition / Elements / Header / Destination
@onready var zone = $Transition / Elements / Header / Zone
@onready var cost = $Transition / Elements / Cost
@onready var timeCost = $Transition / Elements / Cost / Time / Value
@onready var energyCost = $Transition / Elements / Cost / Energy / Value
@onready var hydrationCost = $Transition / Elements / Cost / Hydration / Value
@onready var details = $Transition / Elements / Details
@onready var detailsHint = $Transition / Elements / Details / Hint


var showDecor = true
var showPlacement = true

func _ready():

    tooltip.hide()


    label.text = str(gameData.tooltip)


    var currentMap = get_tree().current_scene.get_node("/root/Map")


    if currentMap:
        if gameData.tutorial: map.text = str(currentMap.mapName)
        else: map.text = str(currentMap.mapName + " (" + currentMap.mapType + ")")

func _physics_process(_delta):
    if Engine.get_physics_frames() % 10 == 0 && !gameData.isTransitioning:

        if FPS.visible:
            frames.text = str(Engine.get_frames_per_second())


        label.text = str(gameData.tooltip)
        tooltip.visible = gameData.interaction && !gameData.transition
        transition.visible = gameData.transition && !gameData.interaction && !gameData.isPlacing && !gameData.isInserting
        oxygen.visible = gameData.isSwimming
        permadeath.visible = gameData.permadeath || gameData.difficulty == 3
        magazine.visible = gameData.isChecking
        chamber.visible = gameData.isChecking
        malfunction.visible = gameData.jammed
        magnet.visible = gameData.magnet


        if gameData.decor:
            if showDecor || gameData.tutorial:
                decor.show()
                stats.hide()
        else:
            decor.hide()
            stats.show()


        if !gameData.decor && gameData.isPlacing:
            if showPlacement || gameData.tutorial:
                placement.show()
                stats.hide()
        elif !gameData.decor:
            placement.hide()
            stats.show()



func Transition(transitionData):

    destination.text = transitionData.nextMap
    zone.text = transitionData.nextZone


    if transitionData.time != 0 || transitionData.energy != 0 || transitionData.hydration != 0:
        timeCost.text = "+" + str(int(transitionData.time)) + "h"
        energyCost.text = "-" + str(int(transitionData.energy))
        hydrationCost.text = "-" + str(int(transitionData.hydration))
        cost.show()
    else:
        cost.hide()


    if transitionData.nextZone == "Vostok":
        detailsHint.text = "Permadeath Zone"
        detailsHint.modulate = Color.RED
        details.show()
    elif transitionData.locked && transitionData.shelterEnter:
        detailsHint.text = "Unlock with " + transitionData.key.name
        detailsHint.modulate = Color.GREEN
        details.show()
    else:
        details.hide()



func ShowMap(state: bool):
    if state:
        map.show()
    else:
        map.hide()

func ShowFPS(state: bool):
    if state:
        FPS.show()
    else:
        FPS.hide()

func ShowVitals(state: bool):
    if state:
        vitals.show()
    else:
        vitals.hide()

func ShowMedical(state: bool):
    if state:
        medical.show()
    else:
        medical.hide()

func ShowPlacement(state: bool):
    if state:
        showPlacement = true
    else:
        showPlacement = false

func ShowDecor(state: bool):
    if state:
        showDecor = true
    else:
        showDecor = false
