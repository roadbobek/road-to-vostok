extends Resource
class_name ItemData

@export_group("Naming")
@export var file: String
@export var name: String
@export var inventory: String
@export var rotated: String
@export var equipment: String
@export var display: String

@export_group("Stats")
@export var type: String
@export var subtype: String
@export var weight = 1.0
@export var value = 1
enum Rarity{Common, Rare, Legendary, Null}
@export var rarity = Rarity.Common

@export_group("Icons")
@export var icon: Texture2D
@export var tetris: PackedScene
@export var size = Vector2(1, 1)

@export_group("Scaling")
@export_subgroup("Magazine")
@export var magazineScale = 0.5
@export var magazineOffset = 0.0
@export_subgroup("Optic")
@export var opticScale = 0.5
@export var opticOffset = 0.0
@export_subgroup("Suppressor")
@export var suppressorScale = 0.5
@export var suppressorOffset = 0.0
@export_subgroup("Magazine + Optic")
@export var magazineOpticScale = 0.5
@export var magazineOpticOffset = 0.0
@export_subgroup("Magazine + Suppressor")
@export var magazineSuppressorScale = 0.5
@export var magazineSuppressorOffset = Vector2(0, 0)
@export_subgroup("Optic + Suppressor")
@export var opticSuppressorScale = 0.5
@export var opticSuppressorOffset = Vector2(0, 0)
@export_subgroup("Fully Modded")
@export var fullyModdedScale = 0.5
@export var fullyModdedOffset = Vector2(0, 0)

@export_group("Use")
@export var usable = false
@export var phrase: String
@export var audio: AudioEvent
@export var used: Array[ItemData]

@export_group("Vitals")
@export var health = 0.0
@export var energy = 0.0
@export var hydration = 0.0
@export var mental = 0.0
@export var temperature = 0.0

@export_group("Medical")
@export var bleeding = false
@export var fracture = false
@export var burn = false
@export var insanity = false
@export var rupture = false
@export var headshot = false

@export_group("Combine")
@export var compatible: Array[ItemData]

@export_group("Equipment")
@export var slots: Array[String]
@export var material: Material
@export var capacity = 0.0
@export var insulation = 0.0

@export_group("Details")
@export var showCondition = false
@export var showAmount = false
@export var defaultAmount = 0
@export var maxAmount = 0
@export var stackable = false
@export var freezable = false

@export_group("Electronic")
enum Power{None, Low, Medium, High}
@export var power = Power.None
@export var color: Color

@export_group("Armor")
@export var plate = false
@export var carrier = false
@export var helmet = false
@export var protection = 0
@export var rating: String

@export_group("Crafting")
@export var tool = false
@export var repairs = false
@export var returns = false

@export_group("Loot Tables")
@export_subgroup("Types")
@export var civilian = false
@export var industrial = false
@export var military = false

@export_subgroup("Traders")
@export var generalist = false
@export var doctor = false
@export var gunsmith = false
@export var grandma = false

@export_group("Placement")
@export var orientation = 0.0
@export var wallOffset = 0.0
