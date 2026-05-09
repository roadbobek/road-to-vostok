extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var LT_Master: LootTable = preload("res://Loot/LT_Master.tres")

@export_group("Generation")
@export var civilian = false
@export var industrial = false
@export var military = false
@export var limit: String
@export var exclude: String

@export_group("Modified")
@export var custom: LootTable
@export var force = false
@export var joker = false


var rarityRoll = 100
var commonBucket: Array[ItemData]
var uncommonBucket: Array[ItemData]
var rareBucket: Array[ItemData]
var legendaryBucket: Array[ItemData]


var loot: Array[ItemData]

func _ready():

    get_child(0).queue_free()


    if !custom:
        ClearBuckets()
        FillBuckets()
        GenerateLoot()
        SpawnItems()


    if custom && !force:
        ClearBuckets()
        FillBucketsCustom()
        GenerateLoot()


    if custom && force:
        for index in custom.items.size():
            loot.append(custom.items[index])
            SpawnItems()

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
    if custom.items.size() != 0:
        for item in custom.items:

            if item.rarity != item.Rarity.Null:
                if item.rarity == item.Rarity.Common: commonBucket.append(item)
                elif item.rarity == item.Rarity.Rare: rareBucket.append(item)
                elif item.rarity == item.Rarity.Legendary: legendaryBucket.append(item)

func GenerateLoot():

    rarityRoll = randi_range(1, 100)
    if joker: rarityRoll = 100


    if rarityRoll == 1:
        if legendaryBucket.size() != 0 && randi_range(1, 10) == 1:
            for pick in 1:
                loot.append(legendaryBucket.pick_random())


    elif rarityRoll <= 5:
        if rareBucket.size() != 0:
            for pick in randi_range(0, 1):
                loot.append(rareBucket.pick_random())


    elif rarityRoll <= 25:
        if commonBucket.size() != 0:
            for pick in randi_range(0, 4):
                loot.append(commonBucket.pick_random())


    elif rarityRoll == 100:
        if legendaryBucket.size() != 0 && randi_range(1, 10) == 1:
            for pick in 1:
                loot.append(legendaryBucket.pick_random())

        if rareBucket.size() != 0:
            for pick in randi_range(1, 2):
                loot.append(rareBucket.pick_random())

        if commonBucket.size() != 0:
            for pick in randi_range(4, 10):
                loot.append(commonBucket.pick_random())

func SpawnItems():
    if loot.size() != 0:
        for itemData in loot:

            var file = Database.get(itemData.file)
            if !file:
                print("File not found: " + itemData.file)
                return


            var pickup = Database.get(itemData.file).instantiate()
            add_child(pickup)


            var dropDirection = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
            pickup.Unfreeze()
            pickup.linear_velocity = dropDirection * 10.0


            var newSlotData = SlotData.new()
            newSlotData.itemData = itemData


            if itemData.defaultAmount != 0:
                newSlotData.amount = randi_range(1, itemData.defaultAmount)


            if itemData.type == "Weapon" || itemData.subtype == "Light" || itemData.subtype == "NVG":
                newSlotData.condition = randi_range(25, 100)


            if Simulation.season == 2:
                if newSlotData.itemData.freezable:

                    if randi_range(0, 100) < 10:
                        newSlotData.state = "Frozen"


            pickup.slotData = newSlotData
