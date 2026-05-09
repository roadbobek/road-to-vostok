extends Resource
class_name SlotData


@export var itemData: ItemData
@export var nested: Array[ItemData]
@export var storage: Array[SlotData]
@export var condition = 100
@export var amount = 0
@export var position = 0
@export var mode = 1
@export var zoom = 1
@export var chamber: bool
@export var casing: bool
@export var state: String


@export var gridPosition: Vector2
@export var gridRotated = false
@export var slot: String

func Update(slotData: SlotData):
    itemData = slotData.itemData
    nested = slotData.nested.duplicate()
    storage = slotData.storage.duplicate()
    condition = slotData.condition
    amount = slotData.amount
    position = slotData.position
    mode = slotData.mode
    zoom = slotData.zoom
    chamber = slotData.chamber
    casing = slotData.casing
    state = slotData.state

func Reset():
    itemData = null
    nested.clear()
    storage.clear()
    condition = 100
    amount = 0
    position = 0
    mode = 1
    zoom = 1
    chamber = false
    casing = false
    state = ""

func GridSave(UIPosition: Vector2, UIRotation: bool):
    gridPosition = UIPosition
    gridRotated = UIRotation

func SlotSave(slotName):
    slot = slotName
