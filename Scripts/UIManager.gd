extends Control


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var gameData = preload("res://Resources/GameData.tres")


@onready var NVG = $NVG
@onready var HUD = $HUD
@onready var settings = $Settings
@onready var interface = $Interface

func _ready():
    settings.hide()
    interface.hide()

func _input(event):
    if (gameData.isDead
    || gameData.isCaching
    || gameData.isTransitioning
    || gameData.isReloading
    || gameData.isInserting
    || gameData.isChecking
    || gameData.isPlacing
    || gameData.isSleeping
    || (interface.container && gameData.isOccupied)
    || (interface.isCrafting)):
        return


    if event.is_action_pressed("settings") && (gameData.interface || gameData.settings || gameData.isInspecting):
        if (gameData.interface && !interface.container && !interface.trader) || gameData.settings:
            PlayClick()

        Return()
        return


    if event.is_action_pressed("settings") && !gameData.interface && !gameData.isInspecting:
        PlayClick()
        ToggleSettings()


    if event.is_action_pressed("interface") && !gameData.settings && !gameData.isInspecting && !gameData.isSwimming && !gameData.isSubmerged:
        if (gameData.interface && !interface.container && !interface.trader):
            PlayClick()
        elif !gameData.interface:
            PlayClick()

        ToggleInterface()


    if event.is_action_pressed("interact") && (interface.container || interface.trader):
        ToggleInterface()

func Return():
    if gameData.settings:
        UIClose()
        get_tree().paused = false
        settings.hide()
        gameData.settings = false

    if gameData.interface:
        UIClose()
        interface.hide()
        interface.Close()
        gameData.interface = false

func ToggleSettings():
    gameData.settings = !gameData.settings

    if gameData.settings:
        UIOpen()
        settings.show()
        get_tree().paused = true

    else:
        UIClose()
        settings.hide()
        get_tree().paused = false

func ToggleInterface():
    gameData.interface = !gameData.interface

    if gameData.interface:
        UIOpen()
        interface.Open()
        interface.show()
    else:
        UIClose()
        interface.Close()
        interface.hide()

func OpenContainer(container: LootContainer):
    UIOpen()
    gameData.interface = true
    interface.container = container
    interface.Open()
    interface.show()

func OpenTrader(trader):
    UIOpen()
    gameData.interface = true
    gameData.isTrading = true
    interface.trader = trader
    interface.Open()
    interface.show()

func UIOpen():
    gameData.freeze = true
    Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
    HUD.hide()

func UIClose():
    gameData.freeze = false
    gameData.isTrading = false
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    HUD.show()

func PlayClick():
    var click = audioInstance2D.instantiate()
    add_child(click)
    click.PlayInstance(audioLibrary.UIClick)
