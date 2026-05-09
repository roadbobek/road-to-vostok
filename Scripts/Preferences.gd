extends Resource
class_name Preferences


@export var menuLog = 2
@export var menuHardware = 1
@export var menuIntro = 2
@export var menuMusic = 2

@export var defaultTool = 1
@export var defaultType = 1
@export var casetteVolume = 1.0
@export var casetteOverride = true

@export var actionEvents: Dictionary = {}
@export var mouseMode = 1
@export var sprintMode = 1
@export var leanMode = 1
@export var aimMode = 1

@export var masterVolume = 1.0
@export var ambientVolume = 1.0
@export var musicVolume = 0.1

@export var musicPreset = 2

@export var interpolate = true
@export var baseFOV = 70.0
@export var headbob = 1.0

@export var lookSensitivity = 1.0
@export var aimSensitivity = 1.0
@export var scopeSensitivity = 1.0

@export var exposure = 1.0
@export var contrast = 1.0
@export var saturation = 1.0





@export var map = true
@export var FPS = true
@export var vitals = true
@export var medical = true
@export var placement = true
@export var decor = true

@export var tooltip = 1

@export var PIP = 2

@export var detailShadows = 1

@export var reflections = 1

@export var ambientOcclusion = 1

@export var displayMode = 1
@export var windowSize = 0
@export var monitor = 0

@export var frameLimit = 5

@export var rendering = 2
@export var sharpness = 1.0

@export var lighting = 3

@export var antialiasing = 3
@export var smaa = 1

func Save():
    ResourceSaver.save(self, "user://Preferences.tres")

static func Load():
    var preferences: Preferences = load("user://Preferences.tres") as Preferences

    if !preferences:
        preferences = Preferences.new()
        print("Preferences not found")

    return preferences
