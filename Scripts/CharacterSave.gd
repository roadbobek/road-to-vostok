extends Resource
class_name CharacterSave


@export var health = 100.0
@export var energy = 100.0
@export var hydration = 100.0
@export var temperature = 100.0
@export var mental = 100.0


@export var cat = 100.0
@export var catFound = false
@export var catDead = false


@export var bodyStamina = 100.0
@export var armStamina = 100.0


@export var overweight = false
@export var starvation = false
@export var dehydration = false
@export var bleeding = false
@export var fracture = false
@export var burn = false
@export var frostbite = false
@export var insanity = false
@export var rupture = false
@export var headshot = false


@export var initialSpawn = false
@export var startingKit: LootTable


@export var inventory: Array[SlotData] = []

@export var equipment: Array[SlotData] = []

@export var catalog: Array[SlotData] = []


@export var primary = false
@export var secondary = false
@export var knife = false
@export var grenade1 = false
@export var grenade2 = false
@export var flashlight = false
@export var NVG = false
@export var weaponPosition = 1
