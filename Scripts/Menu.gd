extends Control


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var main = $Main
@onready var modes = $Modes
@onready var roadmap = $Roadmap
@onready var settings = $Settings
@onready var about = $About


@onready var newButton: Button = $Main / Buttons / New
@onready var loadButton: Button = $Main / Buttons / Load
@onready var tutorialButton: Button = $Main / Buttons / Tutorial
@onready var settingsButton: Button = $Main / Buttons / Settings
@onready var roadmapButton: Button = $Main / Buttons / Roadmap
@onready var aboutButton: Button = $Main / Buttons / About
@onready var quitButton: Button = $Main / Buttons / Quit


@onready var standard: Panel = $Modes / Difficulty / Standard
@onready var darkness: Panel = $Modes / Difficulty / Darkness
@onready var ironman: Panel = $Modes / Difficulty / Ironman
@onready var dynamic: Panel = $Modes / Season / Dynamic
@onready var summer: Panel = $Modes / Season / Summer
@onready var winter: Panel = $Modes / Season / Winter


@onready var directX = $API / DirectX
@onready var vulkan = $API / Vulkan
@onready var compatibility = $Compatibility


@onready var changelog = $Changelog
@onready var logOffButton = $Log / Buttons / Log_Off
@onready var logOnButton = $Log / Buttons / Log_On
@onready var profiler = $Profiler
@onready var hardwareOffButton = $Hardware / Buttons / HW_Off
@onready var hardwareOnButton = $Hardware / Buttons / HW_On
@onready var introOffButton = $Intro / Buttons / Intro_Off
@onready var introOnButton = $Intro / Buttons / Intro_On
@onready var music = $Audio
@onready var musicOffButton = $Music / Buttons / Music_Off
@onready var musicOnButton = $Music / Buttons / Music_On


@onready var UISettings = $Settings / UI_Settings


var intro = true


@onready var blocker = $Blocker

func _ready():

    get_tree().paused = false


    Engine.max_fps = 120


    Simulation.simulate = false


    gameData.Reset()
    gameData.menu = true


    Loader.FadeOut()
    Loader.ShowCursor()


    if !Loader.ValidateID():
        main.show()
        Loader.FormatAll()
        Loader.CreateValidator()
        tutorialButton.modulate = Color.GREEN
    else:
        main.show()
        tutorialButton.modulate = Color.WHITE


    if Loader.ValidateShelter() == "":
        loadButton.disabled = true
    else:
        loadButton.disabled = false


    var driver = RenderingServer.get_current_rendering_driver_name()
    var method = RenderingServer.get_current_rendering_method()
    print("Driver Detected: ", driver)
    print("Method Detected: ", method)


    if method == "mobile":
        RenderingServer.global_shader_parameter_set("Compatibility", true)
        gameData.compatibility = true
        compatibility.show()
    else:
        RenderingServer.global_shader_parameter_set("Compatibility", false)
        gameData.compatibility = false
        compatibility.hide()


    if driver == "d3d12":
        directX.show()
        vulkan.hide()
    elif driver == "vulkan":
        directX.hide()
        vulkan.show()
    else:
        directX.hide()
        vulkan.hide()


    blocker.mouse_filter = MOUSE_FILTER_IGNORE



func _on_new_pressed():
    modes.show()
    main.hide()
    PlayClick()


    if logOnButton.button_pressed: changelog.hide()

func _on_load_pressed():
    Loader.LoadScene(Loader.ValidateShelter())
    PlayClick()


    DeactivateButtons()
    blocker.mouse_filter = MOUSE_FILTER_STOP

func _on_tutorial_pressed():
    Loader.LoadScene("Tutorial")
    PlayClick()


    blocker.mouse_filter = MOUSE_FILTER_STOP

func _on_settings_pressed():
    settings.show()
    main.hide()
    PlayClick()


    if logOnButton.button_pressed: changelog.hide()

func _on_roadmap_pressed():
    roadmap.show()
    main.hide()
    PlayClick()


    if logOnButton.button_pressed: changelog.hide()

func _on_about_pressed():
    about.show()
    main.hide()
    PlayClick()


    if logOnButton.button_pressed: changelog.hide()

func _on_quit_pressed():
    Loader.Quit()
    PlayClick()


    DeactivateButtons()
    blocker.mouse_filter = MOUSE_FILTER_STOP



func _on_modes_enter_pressed():

    var difficulty = 1
    var season = 1


    if standard.chosen:
        difficulty = 1
    elif darkness.chosen:
        difficulty = 2
    elif ironman.chosen:
        difficulty = 3


    if summer.chosen:
        season = 1
    elif winter.chosen:
        season = 2
    elif dynamic.chosen:
        season = 3


    Loader.NewGame(difficulty, season)


    if intro:
        Loader.LoadScene("Intro")
        Loader.intro = difficulty

    elif difficulty == 1:
        Loader.LoadScene("Cabin")
        Loader.intro = difficulty

    else:
        Loader.LoadSceneRandom()
        Loader.intro = difficulty


    blocker.mouse_filter = MOUSE_FILTER_STOP
    DeactivateButtons()
    PlayClick()



func _on_modes_return_pressed():
    main.show()
    modes.hide()
    PlayClick()


    if logOnButton.button_pressed: changelog.show()

func _on_settings_return_pressed():
    main.show()
    settings.hide()
    PlayClick()


    if logOnButton.button_pressed: changelog.show()

func _on_roadmap_return_pressed():
    main.show()
    roadmap.hide()
    PlayClick()


    if logOnButton.button_pressed: changelog.show()

func _on_about_return_pressed() -> void :
    main.show()
    about.hide()
    PlayClick()


    if logOnButton.button_pressed: changelog.show()



func _on_log_off_pressed() -> void :
    UISettings.SaveMenuLog(1)
    changelog.hide()
    PlayClick()

func _on_log_on_pressed() -> void :
    UISettings.SaveMenuLog(2)
    changelog.show()
    PlayClick()

func _on_hw_off_pressed() -> void :
    UISettings.SaveMenuHardware(1)
    profiler.hide()
    PlayClick()

func _on_hw_on_pressed() -> void :
    UISettings.SaveMenuHardware(2)
    profiler.Basic()
    profiler.show()
    PlayClick()

func _on_intro_off_pressed() -> void :
    UISettings.SaveMenuIntro(1)
    intro = false
    PlayClick()

func _on_intro_on_pressed() -> void :
    UISettings.SaveMenuIntro(2)
    intro = true
    PlayClick()

func _on_music_off_pressed():
    UISettings.SaveMenuMusic(1)
    music.stream_paused = true
    PlayClick()

func _on_music_on_pressed():
    UISettings.SaveMenuMusic(2)
    music.stream_paused = false
    PlayClick()



func DeactivateButtons():
    newButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
    loadButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
    tutorialButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
    settingsButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
    roadmapButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
    aboutButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
    quitButton.mouse_filter = Control.MOUSE_FILTER_IGNORE



func PlayClick():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.UIClick)
