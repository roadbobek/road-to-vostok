extends Control


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var loadButton = $Main / Buttons / Load
@onready var menuButton = $Main / Buttons / Menu
@onready var quitButton = $Main / Buttons / Quit


@onready var hint = $Main / Hint
@onready var permadeath = $Main / Permadeath


@onready var blocker = $Blocker

func _ready():

    get_tree().paused = false


    Engine.max_fps = 120


    Simulation.simulate = false


    if gameData.permadeath:
        permadeath.show()
        hint.text = "All save files deleted"
    else:
        permadeath.hide()
        hint.text = "Character died"


    gameData.Reset()


    Loader.FadeOut()
    Loader.ShowCursor()


    if Loader.ValidateShelter() == "":
        loadButton.disabled = true
    else:
        loadButton.disabled = false


    blocker.mouse_filter = MOUSE_FILTER_IGNORE

func _on_load_pressed():
    Loader.LoadScene(Loader.ValidateShelter())
    PlayClick()


    blocker.mouse_filter = MOUSE_FILTER_STOP

func _on_menu_pressed():
    Loader.LoadScene("Menu")
    PlayClick()


    blocker.mouse_filter = MOUSE_FILTER_STOP

func _on_quit_pressed():
    Loader.Quit()
    PlayClick()


    blocker.mouse_filter = MOUSE_FILTER_STOP

func PlayClick():
    var click = audioInstance2D.instantiate()
    add_child(click)
    click.PlayInstance(audioLibrary.UIClick)
