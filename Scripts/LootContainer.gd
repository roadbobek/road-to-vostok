extends Node3D
class_name LootContainer


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var LT_Master: LootTable = preload("res://Loot/LT_Master.tres")

@export_group("Container")
@export var containerName: String
@export var containerSize = Vector2(8, 13)
@export var audioEvent: AudioEvent

@export_group("Generation")
@export var civilian = false
@export var industrial = false
@export var military = false
@export var limit: String
@export var exclude: String

@export_group("Modified")
@export var custom: Array[LootTable]
@export var force = false
@export var joker = false
@export var stash = false
@export var corpse = false
@export var locked = false
@export var furniture = false


var rarityRoll = 100
var commonBucket: Array[ItemData]
var uncommonBucket: Array[ItemData]
var rareBucket: Array[ItemData]
var legendaryBucket: Array[ItemData]


var table: LootTable
var loot: Array[SlotData]
var storage: Array[SlotData]
var storaged = false

func _ready():

    if custom.is_empty() && !locked && !furniture:
        ClearBuckets()
        FillBuckets()
        GenerateLoot()


    if !custom.is_empty() && !force:
        table = custom.pick_random()
        ClearBuckets()
        FillBucketsCustom()
        GenerateLoot()


    if !custom.is_empty() && force:
        table = custom.pick_random()
        for index in table.items.size():
            CreateLoot(table.items[index])


    if stash:

        if randi_range(0, 100) > 10:
            process_mode = ProcessMode.PROCESS_MODE_DISABLED
            hide()

func ClearBuckets():
    commonBucket.clear()
    uncommonBucket.clear()
    rareBucket.clear()
    legendaryBucket.clear()

func FillBuckets():
    if LT_Master.items.size() != 0:
        for item in LT_Master.items:

            if item.rarity != item.Rarity.Null:

                if (civilian && item.civilian) || (industrial && item.industrial) || (military && item.military):

                    if limit == "" && exclude != item.type:
                        if item.rarity == item.Rarity.Common: commonBucket.append(item)
                        elif item.rarity == item.Rarity.Rare: rareBucket.append(item)
                        elif item.rarity == item.Rarity.Legendary: legendaryBucket.append(item)

                    elif limit == item.type:
                        if item.rarity == item.Rarity.Common: commonBucket.append(item)
                        elif item.rarity == item.Rarity.Rare: rareBucket.append(item)
                        elif item.rarity == item.Rarity.Legendary: legendaryBucket.append(item)

func FillBucketsCustom():
    if table.items.size() != 0:
        for item in table.items:
            if item.rarity != item.Rarity.Null:
                if item.rarity == item.Rarity.Common: commonBucket.append(item)
                elif item.rarity == item.Rarity.Rare: rareBucket.append(item)
                elif item.rarity == item.Rarity.Legendary: legendaryBucket.append(item)

func GenerateLoot():

    rarityRoll = randi_range(1, 100)


    if joker: rarityRoll = 100
    if corpse: rarityRoll = randi_range(1, 30)


    if rarityRoll == 1:
        if legendaryBucket.size() != 0 && randi_range(1, 10) == 1:
            for pick in 1:
                CreateLoot(legendaryBucket.pick_random())


    elif rarityRoll <= 5:
        if rareBucket.size() != 0:
            for pick in randi_range(0, 1):
                CreateLoot(rareBucket.pick_random())


    elif rarityRoll <= 25:
        if commonBucket.size() != 0:
            for pick in randi_range(0, 4):
                CreateLoot(commonBucket.pick_random())


    elif rarityRoll == 100:
        if legendaryBucket.size() != 0 && randi_range(1, 10) == 1:
            for pick in 1:
                CreateLoot(legendaryBucket.pick_random())

        if rareBucket.size() != 0:
            for pick in randi_range(1, 2):
                CreateLoot(rareBucket.pick_random())

        if commonBucket.size() != 0:
            for pick in randi_range(4, 10):
                CreateLoot(commonBucket.pick_random())

func Interact():

    if !locked:
        var UIManager = get_tree().current_scene.get_node("/root/Map/Core/UI")
        UIManager.OpenContainer(self)
        ContainerAudio()

func UpdateTooltip():
    if locked:
        gameData.tooltip = containerName + " [Locked]"
    else:
        gameData.tooltip = containerName + " [Open]"

func CreateLoot(item: ItemData):

    var newSlotData = SlotData.new()
    newSlotData.itemData = item

    if gameData.tutorial:

        if item.defaultAmount != 0 && item.subtype != "Magazine":
            newSlotData.amount = item.defaultAmount
    else:

        if item.defaultAmount != 0:
            newSlotData.amount = randi_range(1, item.defaultAmount)

        if item.type == "Weapon" || item.subtype == "Light" || item.subtype == "NVG":
            newSlotData.condition = randi_range(25, 100)


    if Simulation.season == 2:
        if newSlotData.itemData.freezable:

            if randi_range(0, 100) < 10:
                newSlotData.state = "Frozen"


    loot.append(newSlotData)

func Storage(containerGrid: Grid):

    storaged = true

    storage.clear()

    for item in containerGrid.get_children():

        var newSlotData = SlotData.new()
        newSlotData.Update(item.slotData)

        newSlotData.GridSave(item.position, item.rotated)

        storage.append(newSlotData)



func ContainerAudio():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioEvent)
