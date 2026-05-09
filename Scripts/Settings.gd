extends Control
class_name Settings


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


var world
var mainMenu


@export var HUD: Control
@export var interface: Control
@export var audio: Node3D
@export var camera: Camera


const sharpen = preload("res://UI/Effects/MT_Sharpen.tres")


@onready var settings = $Settings


@onready var masterBus = AudioServer.get_bus_index("Master")
@onready var ambientBus = AudioServer.get_bus_index("Ambient")
@onready var musicBus = AudioServer.get_bus_index("Music")



@onready var inputs = $Settings / Inputs




@onready var masterSlider = $Settings / Row_01 / Audio / Settings / Master_Slider
@onready var ambientSlider = $Settings / Row_01 / Audio / Settings / Ambient_Slider
@onready var musicSlider = $Settings / Row_01 / Audio / Settings / Music_Slider


@onready var musicOff = $Settings / Row_01 / Music / Elements / Settings / Music_Off
@onready var musicDynamic = $Settings / Row_01 / Music / Elements / Settings / Music_Dynamic
@onready var musicShelter = $Settings / Row_01 / Music / Elements / Settings / Music_Shelter
@onready var musicArea05 = $Settings / Row_01 / Music / Elements / Settings / Music_Area_05
@onready var musicBorder = $Settings / Row_01 / Music / Elements / Settings / Music_Border
@onready var musicVostok = $Settings / Row_01 / Music / Elements / Settings / Music_Vostok

@onready var interpolateOff = $Settings / Row_01 / Camera / Elements / Settings / Interpolate_Off
@onready var interpolateOn = $Settings / Row_01 / Camera / Elements / Settings / Interpolate_On
@onready var FOVslider = $Settings / Row_01 / Camera / Elements / FOV_Slider
@onready var headbobSlider = $Settings / Row_01 / Camera / Elements / Headbob_Slider

@onready var lookSlider = $Settings / Row_01 / Mouse / Settings / Look_Slider
@onready var aimSlider = $Settings / Row_01 / Mouse / Settings / Aim_Slider
@onready var scopeSlider = $Settings / Row_01 / Mouse / Settings / Scope_Slider

@onready var exposureSlider = $Settings / Row_01 / Color / Settings / Exposure_Slider
@onready var contrastSlider = $Settings / Row_01 / Color / Settings / Contrast_Slider
@onready var saturationSlider = $Settings / Row_01 / Color / Settings / Saturation_Slider





@onready var map = $Settings / Row_02 / HUD / Settings / Map
@onready var fps = $Settings / Row_02 / HUD / Settings / FPS
@onready var vitals = $Settings / Row_02 / HUD / Settings / Vitals
@onready var medical = $Settings / Row_02 / HUD / Settings / Medical
@onready var placement = $Settings / Row_02 / HUD / Settings / Placement
@onready var decor = $Settings / Row_02 / HUD / Settings / Decor

@onready var tooltipOn = $Settings / Row_02 / Tooltip / Settings / Tooltip_On
@onready var tooltipOff = $Settings / Row_02 / Tooltip / Settings / Tooltip_Off

@onready var PIPOn = $Settings / Row_02 / PIP / Settings / PIP_On
@onready var PIPOff = $Settings / Row_02 / PIP / Settings / PIP_Off

@onready var shadowsOn = $Settings / Row_02 / Shadows / Settings / Shadows_On
@onready var shadowsOff = $Settings / Row_02 / Shadows / Settings / Shadows_Off

@onready var reflectionsOn = $Settings / Row_02 / Water / Settings / Reflections_On
@onready var reflectionsOff = $Settings / Row_02 / Water / Settings / Reflections_Off

@onready var AOOn = $Settings / Row_02 / AO / Settings / AO_On
@onready var AOOff = $Settings / Row_02 / AO / Settings / AO_Off




@onready var fullscreen = $Settings / Row_03 / Display / Settings / Fullscreen
@onready var windowed = $Settings / Row_03 / Display / Settings / Windowed
@onready var monitors = $Settings / Row_03 / Display / Settings / Monitors
@onready var sizes = $Settings / Row_03 / Display / Settings / Sizes
var windowSizes: Dictionary = {
"Window: 100%": int(0), 
"Window: 90%": int(1), 
"Window: 75%": int(2), 
"Window: 50%": int(3)}

@onready var fps60 = $Settings / Row_03 / Frames / Settings / FPS_60
@onready var fps120 = $Settings / Row_03 / Frames / Settings / FPS_120
@onready var fps200 = $Settings / Row_03 / Frames / Settings / FPS_200
@onready var fps300 = $Settings / Row_03 / Frames / Settings / FPS_300
@onready var vsync = $Settings / Row_03 / Frames / Settings / Vsync
@onready var unlimited = $Settings / Row_03 / Frames / Settings / Unlimited

@onready var RLow = $Settings / Row_03 / Rendering / Settings / R_Low
@onready var RNative = $Settings / Row_03 / Rendering / Settings / R_Native
@onready var sharpnessSlider = $Settings / Row_03 / Rendering / Settings / Sharpness_Slider

@onready var LLow = $Settings / Row_03 / Lighting / Settings / L_Low
@onready var LMedium = $Settings / Row_03 / Lighting / Settings / L_Medium
@onready var LHigh = $Settings / Row_03 / Lighting / Settings / L_High
@onready var LUltra = $Settings / Row_03 / Lighting / Settings / L_Ultra

@onready var msaaOff = $Settings / Row_03 / Antialiasing / Settings / MSAA_Off
@onready var msaa2x = $Settings / Row_03 / Antialiasing / Settings / MSAA_2x
@onready var msaa4x = $Settings / Row_03 / Antialiasing / Settings / MSAA_4x
@onready var msaa8x = $Settings / Row_03 / Antialiasing / Settings / MSAA_8x
@onready var smaaOff = $Settings / Row_03 / Antialiasing / Settings / SMAA_Off
@onready var smaaOn = $Settings / Row_03 / Antialiasing / Settings / SMAA_On


@onready var menu = $Settings / Row_03 / Exit / Settings / Menu
@onready var quit = $Settings / Row_03 / Exit / Settings / Quit

@onready var warning = $Warning
@onready var exitMenu = $Warning / Buttons / Exit_Menu
@onready var exitQuit = $Warning / Buttons / Exit_Quit
@onready var exitReturn = $Warning / Buttons / Exit_Return


var preferences: Preferences
var currentRID: RID


@onready var pause = $Pause
@onready var blocker = $Blocker

func _ready():

    await get_tree().create_timer(0.1, false).timeout;


    currentRID = get_tree().get_root().get_viewport_rid()


    if !gameData.menu: world = get_tree().current_scene.get_node("/root/Map/World")
    else: mainMenu = get_tree().current_scene.get_node("/root/Menu")


    if !gameData.menu: pause.show()
    else: pause.hide()


    if !gameData.menu:
        menu.disabled = false
        quit.disabled = false
    else:
        menu.disabled = true
        quit.disabled = true


    if gameData.compatibility:
        AOOff.text = "Compatibility"
        AOOn.text = "Compatibility"
        AOOff.disabled = true
        AOOn.disabled = true


    GetMonitors()
    GetWindowSizes()


    preferences = Preferences.Load() as Preferences
    LoadPreferences()


    blocker.mouse_filter = MOUSE_FILTER_IGNORE



func LoadPreferences():


    if gameData.menu:
        if preferences.menuLog == 1:
            mainMenu.logOffButton.set_pressed_no_signal(true)
            mainMenu.logOnButton.set_pressed_no_signal(false)
            mainMenu.changelog.hide()
        elif preferences.menuLog == 2:
            mainMenu.logOffButton.set_pressed_no_signal(false)
            mainMenu.logOnButton.set_pressed_no_signal(true)
            mainMenu.changelog.show()

        if preferences.menuHardware == 1:
            mainMenu.hardwareOffButton.set_pressed_no_signal(true)
            mainMenu.hardwareOnButton.set_pressed_no_signal(false)
            mainMenu.profiler.hide()
        elif preferences.menuHardware == 2:
            mainMenu.hardwareOffButton.set_pressed_no_signal(false)
            mainMenu.hardwareOnButton.set_pressed_no_signal(true)
            mainMenu.profiler.Basic()
            mainMenu.profiler.show()

        if preferences.menuIntro == 1:
            mainMenu.introOffButton.set_pressed_no_signal(true)
            mainMenu.introOnButton.set_pressed_no_signal(false)
            mainMenu.intro = false
        elif preferences.menuIntro == 2:
            mainMenu.introOffButton.set_pressed_no_signal(false)
            mainMenu.introOnButton.set_pressed_no_signal(true)
            mainMenu.intro = true

        if preferences.menuMusic == 1:
            mainMenu.musicOffButton.set_pressed_no_signal(true)
            mainMenu.musicOnButton.set_pressed_no_signal(false)
            mainMenu.music.stream_paused = true
        elif preferences.menuMusic == 2:
            mainMenu.musicOffButton.set_pressed_no_signal(false)
            mainMenu.musicOnButton.set_pressed_no_signal(true)
            mainMenu.music.stream_paused = false



    if !gameData.menu:
        interface.LoadDefaultType(preferences.defaultType)
        interface.LoadCasetteVolume(preferences.casetteVolume)
        interface.LoadCasetteOverride(preferences.casetteOverride)
        interface.LoadDefaultTool(preferences.defaultTool)





    masterSlider.value = preferences.masterVolume
    AudioServer.set_bus_volume_db(masterBus, linear_to_db(preferences.masterVolume))
    AudioServer.set_bus_mute(masterBus, preferences.masterVolume < 0.01)
    ambientSlider.value = preferences.ambientVolume
    AudioServer.set_bus_volume_db(ambientBus, linear_to_db(preferences.ambientVolume))
    AudioServer.set_bus_mute(ambientBus, preferences.ambientVolume < 0.01)
    musicSlider.value = preferences.musicVolume
    AudioServer.set_bus_volume_db(musicBus, linear_to_db(preferences.musicVolume))
    AudioServer.set_bus_mute(musicBus, preferences.musicVolume < 0.01)



    if preferences.musicPreset == 1:
        musicOff.set_pressed_no_signal(true)
        musicDynamic.set_pressed_no_signal(false)
        musicShelter.set_pressed_no_signal(false)
        musicArea05.set_pressed_no_signal(false)
        musicBorder.set_pressed_no_signal(false)
        musicVostok.set_pressed_no_signal(false)
    elif preferences.musicPreset == 2:
        musicOff.set_pressed_no_signal(false)
        musicDynamic.set_pressed_no_signal(true)
        musicShelter.set_pressed_no_signal(false)
        musicArea05.set_pressed_no_signal(false)
        musicBorder.set_pressed_no_signal(false)
        musicVostok.set_pressed_no_signal(false)
    elif preferences.musicPreset == 3:
        musicOff.set_pressed_no_signal(false)
        musicDynamic.set_pressed_no_signal(false)
        musicShelter.set_pressed_no_signal(true)
        musicArea05.set_pressed_no_signal(false)
        musicBorder.set_pressed_no_signal(false)
        musicVostok.set_pressed_no_signal(false)
    elif preferences.musicPreset == 4:
        musicOff.set_pressed_no_signal(false)
        musicDynamic.set_pressed_no_signal(false)
        musicShelter.set_pressed_no_signal(false)
        musicArea05.set_pressed_no_signal(true)
        musicBorder.set_pressed_no_signal(false)
        musicVostok.set_pressed_no_signal(false)
    elif preferences.musicPreset == 5:
        musicOff.set_pressed_no_signal(false)
        musicDynamic.set_pressed_no_signal(false)
        musicShelter.set_pressed_no_signal(false)
        musicArea05.set_pressed_no_signal(false)
        musicBorder.set_pressed_no_signal(true)
        musicVostok.set_pressed_no_signal(false)
    elif preferences.musicPreset == 6:
        musicOff.set_pressed_no_signal(false)
        musicDynamic.set_pressed_no_signal(false)
        musicShelter.set_pressed_no_signal(false)
        musicArea05.set_pressed_no_signal(false)
        musicBorder.set_pressed_no_signal(false)
        musicVostok.set_pressed_no_signal(true)

    if !gameData.menu:
        gameData.musicPreset = preferences.musicPreset
        audio.UpdateMusic()



    if preferences.interpolate:
        interpolateOff.set_pressed_no_signal(false)
        interpolateOn.set_pressed_no_signal(true)
    else:
        interpolateOff.set_pressed_no_signal(true)
        interpolateOn.set_pressed_no_signal(false)

    if !gameData.menu:
        camera.interpolate = preferences.interpolate
        gameData.baseFOV = preferences.baseFOV
        gameData.headbob = preferences.headbob

    FOVslider.value = preferences.baseFOV
    headbobSlider.value = preferences.headbob



    lookSlider.value = preferences.lookSensitivity
    aimSlider.value = preferences.aimSensitivity
    scopeSlider.value = preferences.scopeSensitivity

    if !gameData.menu:
        gameData.lookSensitivity = preferences.lookSensitivity
        gameData.aimSensitivity = preferences.aimSensitivity
        gameData.scopeSensitivity = preferences.scopeSensitivity



    exposureSlider.value = preferences.exposure
    contrastSlider.value = preferences.contrast
    saturationSlider.value = preferences.saturation

    if !gameData.menu:
        world.environment.environment.adjustment_brightness = preferences.exposure
        world.environment.environment.adjustment_contrast = preferences.contrast
        world.environment.environment.adjustment_saturation = preferences.saturation









    if preferences.map:
        map.set_pressed_no_signal(true)
    else:
        map.set_pressed_no_signal(false)

    if preferences.FPS:
        fps.set_pressed_no_signal(true)
    else:
        fps.set_pressed_no_signal(false)

    if preferences.vitals:
        vitals.set_pressed_no_signal(true)
    else:
        vitals.set_pressed_no_signal(false)

    if preferences.medical:
        medical.set_pressed_no_signal(true)
    else:
        medical.set_pressed_no_signal(false)

    if preferences.placement:
        placement.set_pressed_no_signal(true)
    else:
        placement.set_pressed_no_signal(false)

    if preferences.decor:
        decor.set_pressed_no_signal(true)
    else:
        decor.set_pressed_no_signal(false)

    if !gameData.menu:
        HUD.ShowMap(preferences.map)
        HUD.ShowFPS(preferences.FPS)
        HUD.ShowVitals(preferences.vitals)
        HUD.ShowMedical(preferences.medical)
        HUD.ShowPlacement(preferences.placement)
        HUD.ShowDecor(preferences.decor)



    if preferences.tooltip == 1:
        tooltipOn.set_pressed_no_signal(true)
        tooltipOff.set_pressed_no_signal(false)

    elif preferences.tooltip == 2:
        tooltipOn.set_pressed_no_signal(false)
        tooltipOff.set_pressed_no_signal(true)

    if !gameData.menu:
        interface.tooltipMode = preferences.tooltip



    if preferences.PIP == 1:
        PIPOn.set_pressed_no_signal(true)
        PIPOff.set_pressed_no_signal(false)
        gameData.PIP = true

    elif preferences.PIP == 2:
        PIPOn.set_pressed_no_signal(false)
        PIPOff.set_pressed_no_signal(true)
        gameData.PIP = false



    if preferences.detailShadows == 1:
        shadowsOn.set_pressed_no_signal(true)
        shadowsOff.set_pressed_no_signal(false)

        if !gameData.menu:
            world.ExecuteDetailShadowsOn(true)

    elif preferences.detailShadows == 2:
        shadowsOn.set_pressed_no_signal(false)
        shadowsOff.set_pressed_no_signal(true)

        if !gameData.menu:
            world.ExecuteDetailShadowsOff(true)



    if preferences.reflections == 1:
        reflectionsOn.set_pressed_no_signal(true)
        reflectionsOff.set_pressed_no_signal(false)

        if !gameData.menu:
            world.ExecuteWaterReflectionsOn(true)

    elif preferences.reflections == 2:
        reflectionsOn.set_pressed_no_signal(false)
        reflectionsOff.set_pressed_no_signal(true)

        if !gameData.menu:
            world.ExecuteWaterReflectionsOff(true)



    if preferences.ambientOcclusion == 1:
        AOOn.set_pressed_no_signal(true)
        AOOff.set_pressed_no_signal(false)

        if !gameData.menu:
            world.environment.environment.ssao_enabled = true
            world.environment.environment.ssil_enabled = true
            RenderingServer.global_shader_parameter_set("Occlusion", true)

    elif preferences.ambientOcclusion == 2:
        AOOn.set_pressed_no_signal(false)
        AOOff.set_pressed_no_signal(true)

        if !gameData.menu:
            world.environment.environment.ssao_enabled = false
            world.environment.environment.ssil_enabled = false
            RenderingServer.global_shader_parameter_set("Occlusion", false)





    var window = get_window()


    monitors.item_selected.disconnect(_on_monitors_item_selected)


    if preferences.monitor == 0:
        window.set_current_screen(0)
        monitors.select(0)

    elif preferences.monitor != 0:

        var monitorCount = DisplayServer.get_screen_count()

        if preferences.monitor <= monitorCount - 1:
            window.set_current_screen(preferences.monitor)
            monitors.select(preferences.monitor)

        else:
            window.set_current_screen(0)
            monitors.select(0)


    monitors.item_selected.connect(_on_monitors_item_selected)


    if preferences.displayMode == 1:
        fullscreen.set_pressed_no_signal(true)
        windowed.set_pressed_no_signal(false)
        window.set_mode(Window.MODE_FULLSCREEN)
        sizes.disabled = true


    elif preferences.displayMode == 2:
        fullscreen.set_pressed_no_signal(false)
        windowed.set_pressed_no_signal(true)
        window.set_mode(Window.MODE_WINDOWED)

        if preferences.windowSize == 0:
            window.set_size(DisplayServer.screen_get_size())
        elif preferences.windowSize == 1:
            window.set_size(DisplayServer.screen_get_size() / 1.1)
        elif preferences.windowSize == 2:
            window.set_size(DisplayServer.screen_get_size() / 1.25)
        elif preferences.windowSize == 3:
            window.set_size(DisplayServer.screen_get_size() / 1.5)

        CenterWindow()
        sizes.disabled = false

    sizes.select(preferences.windowSize)



    if preferences.frameLimit == 1:
        fps60.set_pressed_no_signal(true)
        fps120.set_pressed_no_signal(false)
        fps200.set_pressed_no_signal(false)
        fps300.set_pressed_no_signal(false)
        vsync.set_pressed_no_signal(false)
        unlimited.set_pressed_no_signal(false)

        if !gameData.menu:
            Engine.max_fps = 60


        if DisplayServer.window_get_vsync_mode() == 1:
            DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

    elif preferences.frameLimit == 2:
        fps60.set_pressed_no_signal(false)
        fps120.set_pressed_no_signal(true)
        fps200.set_pressed_no_signal(false)
        fps300.set_pressed_no_signal(false)
        vsync.set_pressed_no_signal(false)
        unlimited.set_pressed_no_signal(false)

        if !gameData.menu:
            Engine.max_fps = 120


        if DisplayServer.window_get_vsync_mode() == 1:
            DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

    elif preferences.frameLimit == 3:
        fps60.set_pressed_no_signal(false)
        fps120.set_pressed_no_signal(false)
        fps200.set_pressed_no_signal(true)
        fps300.set_pressed_no_signal(false)
        vsync.set_pressed_no_signal(false)
        unlimited.set_pressed_no_signal(false)

        if !gameData.menu:
            Engine.max_fps = 200


        if DisplayServer.window_get_vsync_mode() == 1:
            DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

    elif preferences.frameLimit == 4:
        fps60.set_pressed_no_signal(false)
        fps120.set_pressed_no_signal(false)
        fps200.set_pressed_no_signal(false)
        fps300.set_pressed_no_signal(true)
        vsync.set_pressed_no_signal(false)
        unlimited.set_pressed_no_signal(false)

        if !gameData.menu:
            Engine.max_fps = 300


        if DisplayServer.window_get_vsync_mode() == 1:
            DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

    elif preferences.frameLimit == 5:
        fps60.set_pressed_no_signal(false)
        fps120.set_pressed_no_signal(false)
        fps200.set_pressed_no_signal(false)
        fps300.set_pressed_no_signal(false)
        vsync.set_pressed_no_signal(true)
        unlimited.set_pressed_no_signal(false)

        if !gameData.menu:
            Engine.max_fps = 1000


        if DisplayServer.window_get_vsync_mode() == 0:
            DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

    elif preferences.frameLimit == 6:
        fps60.set_pressed_no_signal(false)
        fps120.set_pressed_no_signal(false)
        fps200.set_pressed_no_signal(false)
        fps300.set_pressed_no_signal(false)
        vsync.set_pressed_no_signal(false)
        unlimited.set_pressed_no_signal(true)

        if !gameData.menu:
            Engine.max_fps = 1000


        if DisplayServer.window_get_vsync_mode() == 1:
            DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)



    if preferences.rendering == 1:
        RLow.set_pressed_no_signal(true)
        RNative.set_pressed_no_signal(false)

        if !gameData.menu:
            world.ExecuteLowRendering(true)

    elif preferences.rendering == 2:
        RLow.set_pressed_no_signal(false)
        RNative.set_pressed_no_signal(true)

        if !gameData.menu:
            world.ExecuteNativeRendering(true)

    sharpnessSlider.value = preferences.sharpness
    sharpen.set_shader_parameter("sharpness", preferences.sharpness)



    if preferences.lighting == 1:
        LLow.set_pressed_no_signal(true)
        LMedium.set_pressed_no_signal(false)
        LHigh.set_pressed_no_signal(false)
        LUltra.set_pressed_no_signal(false)

        if !gameData.menu:
            world.ExecuteLowLighting(true)

    elif preferences.lighting == 2:
        LLow.set_pressed_no_signal(false)
        LMedium.set_pressed_no_signal(true)
        LHigh.set_pressed_no_signal(false)
        LUltra.set_pressed_no_signal(false)

        if !gameData.menu:
            world.ExecuteMediumLighting(true)

    elif preferences.lighting == 3:
        LLow.set_pressed_no_signal(false)
        LMedium.set_pressed_no_signal(false)
        LHigh.set_pressed_no_signal(true)
        LUltra.set_pressed_no_signal(false)

        if !gameData.menu:
            world.ExecuteHighLighting(true)

    elif preferences.lighting == 4:
        LLow.set_pressed_no_signal(false)
        LMedium.set_pressed_no_signal(false)
        LHigh.set_pressed_no_signal(false)
        LUltra.set_pressed_no_signal(true)

        if !gameData.menu:
            world.ExecuteUltraLighting(true)



    if preferences.antialiasing == 1:
        msaaOff.set_pressed_no_signal(true)
        msaa2x.set_pressed_no_signal(false)
        msaa4x.set_pressed_no_signal(false)
        msaa8x.set_pressed_no_signal(false)

        if !gameData.menu:
            RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_DISABLED)

    elif preferences.antialiasing == 2:
        msaaOff.set_pressed_no_signal(false)
        msaa2x.set_pressed_no_signal(true)
        msaa4x.set_pressed_no_signal(false)
        msaa8x.set_pressed_no_signal(false)

        if !gameData.menu:
            RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_2X)

    elif preferences.antialiasing == 3:
        msaaOff.set_pressed_no_signal(false)
        msaa2x.set_pressed_no_signal(false)
        msaa4x.set_pressed_no_signal(true)
        msaa8x.set_pressed_no_signal(false)

        if !gameData.menu:
            RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_4X)

    elif preferences.antialiasing == 4:
        msaaOff.set_pressed_no_signal(false)
        msaa2x.set_pressed_no_signal(false)
        msaa4x.set_pressed_no_signal(false)
        msaa8x.set_pressed_no_signal(true)

        if !gameData.menu:
            RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_8X)

    if preferences.smaa == 1:
        smaaOff.set_pressed_no_signal(true)
        smaaOn.set_pressed_no_signal(false)

        if !gameData.menu:
            RenderingServer.viewport_set_screen_space_aa(currentRID, RenderingServer.VIEWPORT_SCREEN_SPACE_AA_DISABLED)

    elif preferences.smaa == 2:
        smaaOff.set_pressed_no_signal(false)
        smaaOn.set_pressed_no_signal(true)

        if !gameData.menu:
            RenderingServer.viewport_set_screen_space_aa(currentRID, RenderingServer.VIEWPORT_SCREEN_SPACE_AA_SMAA)



func SaveMenuLog(value: int):

    preferences.menuLog = value
    preferences.Save()

func SaveMenuHardware(value: int):

    preferences.menuHardware = value
    preferences.Save()

func SaveMenuIntro(value: int):

    preferences.menuIntro = value
    preferences.Save()

func SaveMenuMusic(value: int):

    preferences.menuMusic = value
    preferences.Save()



func SaveDefaultTool(tool: int):

    preferences.defaultTool = tool
    preferences.Save()

func SaveDefaultType(type: int):

    preferences.defaultType = type
    preferences.Save()

func SaveCasetteVolume(value: float):

    preferences.casetteVolume = value
    preferences.Save()

func SaveCasetteOverride(override: bool):

    preferences.casetteOverride = override
    preferences.Save()



func _on_master_slider_value_changed(value):

    preferences.masterVolume = value
    preferences.Save()


    AudioServer.set_bus_volume_db(masterBus, linear_to_db(value))
    AudioServer.set_bus_mute(masterBus, value < 0.01)

func _on_ambient_slider_value_changed(value):

    preferences.ambientVolume = value
    preferences.Save()


    AudioServer.set_bus_volume_db(ambientBus, linear_to_db(value))
    AudioServer.set_bus_mute(ambientBus, value < 0.01)

func _on_music_slider_value_changed(value):

    preferences.musicVolume = value
    preferences.Save()


    AudioServer.set_bus_volume_db(musicBus, linear_to_db(value))
    AudioServer.set_bus_mute(musicBus, value < 0.01)



func _on_music_off_pressed() -> void :

    gameData.musicPreset = 1
    preferences.musicPreset = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        audio.UpdateMusic()

func _on_music_dynamic_pressed() -> void :

    gameData.musicPreset = 2
    preferences.musicPreset = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        audio.UpdateMusic()

func _on_music_shelter_pressed() -> void :

    gameData.musicPreset = 3
    preferences.musicPreset = 3
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        audio.UpdateMusic()

func _on_music_area_05_pressed() -> void :

    gameData.musicPreset = 4
    preferences.musicPreset = 4
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        audio.UpdateMusic()

func _on_music_border_pressed() -> void :

    gameData.musicPreset = 5
    preferences.musicPreset = 5
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        audio.UpdateMusic()

func _on_music_vostok_pressed() -> void :

    gameData.musicPreset = 6
    preferences.musicPreset = 6
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        audio.UpdateMusic()



func _on_interpolate_off_pressed():

    preferences.interpolate = false
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        camera.interpolate = false

func _on_interpolate_on_pressed():

    preferences.interpolate = true
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        camera.interpolate = true

func _on_fov_slider_value_changed(value):

    preferences.baseFOV = value
    preferences.Save()


    gameData.baseFOV = value

func _on_headbob_slider_value_changed(value):

    preferences.headbob = clampf(value, 0.1, 2.0)
    preferences.Save()


    gameData.headbob = clampf(value, 0.1, 2.0)



func _on_look_slider_value_changed(value):

    preferences.lookSensitivity = value
    preferences.Save()


    gameData.lookSensitivity = value

func _on_aim_slider_value_changed(value):

    preferences.aimSensitivity = value
    preferences.Save()


    gameData.aimSensitivity = value

func _on_scope_slider_value_changed(value):

    preferences.scopeSensitivity = value
    preferences.Save()


    gameData.scopeSensitivity = value



func _on_exposure_slider_value_changed(value):

    preferences.exposure = value
    preferences.Save()


    if !gameData.menu:
        world.environment.environment.adjustment_brightness = value

func _on_contrast_slider_value_changed(value):

    preferences.contrast = value
    preferences.Save()


    if !gameData.menu:
        world.environment.environment.adjustment_contrast = value

func _on_saturation_slider_value_changed(value):

    preferences.saturation = value
    preferences.Save()


    if !gameData.menu:
        world.environment.environment.adjustment_saturation = value







func _on_map_toggled(toggled_on: bool) -> void :

    preferences.map = toggled_on
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        HUD.ShowMap(toggled_on)

func _on_fps_toggled(toggled_on: bool) -> void :

    preferences.FPS = toggled_on
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        HUD.ShowFPS(toggled_on)

func _on_vitals_toggled(toggled_on: bool) -> void :

    preferences.vitals = toggled_on
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        HUD.ShowVitals(toggled_on)

func _on_medical_toggled(toggled_on: bool) -> void :

    preferences.medical = toggled_on
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        HUD.ShowMedical(toggled_on)

func _on_placement_toggled(toggled_on: bool) -> void :

    preferences.placement = toggled_on
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        HUD.ShowPlacement(toggled_on)

func _on_decor_toggled(toggled_on: bool) -> void :

    preferences.decor = toggled_on
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        HUD.ShowDecor(toggled_on)



func _on_tooltip_on_pressed() -> void :

    preferences.tooltip = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        interface.tooltipMode = 1

func _on_tooltip_off_pressed() -> void :

    preferences.tooltip = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        interface.tooltipMode = 2



func _on_pip_on_pressed() -> void :

    preferences.PIP = 1
    preferences.Save()
    PlayClick()


    gameData.PIP = true

func _on_pip_off_pressed() -> void :

    preferences.PIP = 2
    preferences.Save()
    PlayClick()


    gameData.PIP = false



func _on_shadows_on_pressed() -> void :

    preferences.detailShadows = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteDetailShadowsOn(true)

func _on_shadows_off_pressed() -> void :

    preferences.detailShadows = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteDetailShadowsOff(true)



func _on_reflections_on_pressed() -> void :

    preferences.reflections = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteWaterReflectionsOn(true)

func _on_reflections_off_pressed() -> void :

    preferences.reflections = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteWaterReflectionsOff(true)



func _on_ao_on_pressed() -> void :

    preferences.ambientOcclusion = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.environment.environment.ssao_enabled = true
        world.environment.environment.ssil_enabled = true
        RenderingServer.global_shader_parameter_set("Occlusion", true)

func _on_ao_off_pressed() -> void :

    preferences.ambientOcclusion = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.environment.environment.ssao_enabled = false
        world.environment.environment.ssil_enabled = false
        RenderingServer.global_shader_parameter_set("Occlusion", false)



func _on_fullscreen_pressed() -> void :
    var window = get_window()
    window.set_mode(Window.MODE_FULLSCREEN)
    sizes.disabled = true

    preferences.displayMode = 1
    preferences.Save()
    PlayClick()

func _on_windowed_pressed() -> void :
    var window = get_window()
    window.set_mode(Window.MODE_WINDOWED)
    sizes.disabled = false

    if preferences.windowSize == 0:
        window.set_size(DisplayServer.screen_get_size())
    elif preferences.windowSize == 1:
        window.set_size(DisplayServer.screen_get_size() / 1.1)
    elif preferences.windowSize == 2:
        window.set_size(DisplayServer.screen_get_size() / 1.25)
    elif preferences.windowSize == 3:
        window.set_size(DisplayServer.screen_get_size() / 1.5)

    CenterWindow()
    preferences.displayMode = 2
    preferences.Save()
    PlayClick()

func _on_monitors_item_selected(index: int) -> void :
    var window = get_window()
    var mode = window.get_mode()

    window.set_mode(Window.MODE_WINDOWED)
    window.set_current_screen(index)

    if mode == Window.MODE_FULLSCREEN:
        window.set_mode(Window.MODE_FULLSCREEN)

    elif mode == Window.MODE_WINDOWED:
        if preferences.windowSize == 0:
            window.set_size(DisplayServer.screen_get_size())
        elif preferences.windowSize == 1:
            window.set_size(DisplayServer.screen_get_size() / 1.1)
        elif preferences.windowSize == 2:
            window.set_size(DisplayServer.screen_get_size() / 1.25)
        elif preferences.windowSize == 3:
            window.set_size(DisplayServer.screen_get_size() / 1.5)
        CenterWindow()

    preferences.monitor = index
    preferences.Save()
    PlayClick()

func _on_sizes_item_selected(index: int) -> void :
    var window = get_window()
    window.set_mode(Window.MODE_WINDOWED)
    var option = sizes.get_item_id(index)

    if option == 0:
        window.set_size(DisplayServer.screen_get_size())
    elif option == 1:
        window.set_size(DisplayServer.screen_get_size() / 1.1)
    elif option == 2:
        window.set_size(DisplayServer.screen_get_size() / 1.25)
    elif option == 3:
        window.set_size(DisplayServer.screen_get_size() / 1.5)
    CenterWindow()

    preferences.windowSize = index
    preferences.Save()
    PlayClick()



func _on_r_low_pressed() -> void :

    preferences.rendering = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteLowRendering(true)

func _on_r_native_pressed() -> void :

    preferences.rendering = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteNativeRendering(true)

func _on_sharpness_slider_value_changed(value: float) -> void :

    preferences.sharpness = value
    preferences.Save()


    if !gameData.menu:
        sharpen.set_shader_parameter("sharpness", value)



func _on_l_low_pressed() -> void :

    preferences.lighting = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteLowLighting(true)

func _on_l_medium_pressed() -> void :

    preferences.lighting = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteMediumLighting(true)

func _on_l_high_pressed() -> void :

    preferences.lighting = 3
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteHighLighting(true)

func _on_l_ultra_pressed() -> void :

    preferences.lighting = 4
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        world.ExecuteUltraLighting(true)



func _on_msaa_off_pressed() -> void :

    preferences.antialiasing = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_DISABLED)

func _on_msaa_2x_pressed() -> void :

    preferences.antialiasing = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_2X)

func _on_msaa_4x_pressed() -> void :

    preferences.antialiasing = 3
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_4X)

func _on_msaa_8x_pressed() -> void :

    preferences.antialiasing = 4
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        RenderingServer.viewport_set_msaa_3d(currentRID, RenderingServer.VIEWPORT_MSAA_8X)

func _on_smaa_off_pressed() -> void :

    preferences.smaa = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        RenderingServer.viewport_set_screen_space_aa(currentRID, RenderingServer.VIEWPORT_SCREEN_SPACE_AA_DISABLED)

func _on_smaa_on_pressed() -> void :

    preferences.smaa = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        RenderingServer.viewport_set_screen_space_aa(currentRID, RenderingServer.VIEWPORT_SCREEN_SPACE_AA_SMAA)



func _on_fps_60_pressed():

    preferences.frameLimit = 1
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        Engine.max_fps = 60


    if DisplayServer.window_get_vsync_mode() == 1:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_fps_120_pressed():

    preferences.frameLimit = 2
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        Engine.max_fps = 120


    if DisplayServer.window_get_vsync_mode() == 1:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_fps_200_pressed():

    preferences.frameLimit = 3
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        Engine.max_fps = 200


    if DisplayServer.window_get_vsync_mode() == 1:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_fps_300_pressed():

    preferences.frameLimit = 4
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        Engine.max_fps = 300


    if DisplayServer.window_get_vsync_mode() == 1:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_vsync_pressed():

    preferences.frameLimit = 5
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        Engine.max_fps = 1000


    if DisplayServer.window_get_vsync_mode() == 0:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

func _on_unlimited_pressed():

    preferences.frameLimit = 6
    preferences.Save()
    PlayClick()


    if !gameData.menu:
        Engine.max_fps = 1000


    if DisplayServer.window_get_vsync_mode() == 1:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)



func _on_menu_pressed():

    if gameData.shelter || gameData.tutorial:
        _on_exit_menu_pressed()
        return

    settings.hide()
    warning.show()
    exitMenu.show()
    exitQuit.hide()
    pause.hide()
    PlayClick()

func _on_quit_pressed():

    if gameData.shelter || gameData.tutorial:
        _on_exit_quit_pressed()
        return

    settings.hide()
    warning.show()
    exitMenu.hide()
    exitQuit.show()
    pause.hide()
    PlayClick()

func _on_exit_menu_pressed() -> void :

    if gameData.shelter:
        var currentMap = get_tree().current_scene.get_node("/root/Map")
        Loader.SaveWorld()
        Loader.SaveCharacter()
        Loader.SaveShelter(currentMap.mapName)


    elif !gameData.tutorial:
        Loader.SaveWorld()
        Loader.ResetCharacter()

    Loader.LoadScene("Menu")
    PlayClick()


    blocker.mouse_filter = MOUSE_FILTER_STOP

func _on_exit_quit_pressed() -> void :

    if gameData.shelter:
        var currentMap = get_tree().current_scene.get_node("/root/Map")
        Loader.SaveWorld()
        Loader.SaveCharacter()
        Loader.SaveShelter(currentMap.mapName)


    elif !gameData.tutorial:
        Loader.SaveWorld()
        Loader.ResetCharacter()

    Loader.Quit()
    PlayClick()


    blocker.mouse_filter = MOUSE_FILTER_STOP

func _on_exit_return_pressed() -> void :
    settings.show()
    warning.hide()
    pause.show()
    PlayClick()



func GetWindowSizes():
    var index = 0

    for element in windowSizes:
        sizes.add_item(element, index)
        index += 1

func GetMonitors():

    monitors.item_selected.disconnect(_on_monitors_item_selected)

    var monitorCount = DisplayServer.get_screen_count()

    for monitor in monitorCount:
        monitors.add_item("Monitor: " + str(monitor))

    monitors.item_selected.connect(_on_monitors_item_selected)

func CenterWindow():

    var centerPosition = Vector2(DisplayServer.screen_get_position()) + Vector2(DisplayServer.screen_get_size()) / 2.0
    var windowSize = get_window().get_size_with_decorations()

    get_window().set_position(Vector2i(centerPosition - Vector2(windowSize) / 2.0))



func PlayClick():
    var click = audioInstance2D.instantiate()
    add_child(click)
    click.PlayInstance(audioLibrary.UIClick)

func PlayError():
    var error = audioInstance2D.instantiate()
    add_child(error)
    error.PlayInstance(audioLibrary.UIError)
