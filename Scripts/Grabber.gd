extends Control

@export var grabbedSlotData: SlotData
@export var swappedSlotData: SlotData
@onready var icon = $Icon

func Update(slotData: SlotData):
    global_position = get_global_mouse_position() - Vector2(32, 32)
    grabbedSlotData.Update(slotData)
    icon.texture = slotData.itemData.icon

func Swap(slotData: SlotData):
    swappedSlotData.Update(slotData)
    icon.texture = slotData.itemData.icon

func Reset():
    grabbedSlotData.Reset()
    swappedSlotData.Reset()
    icon.texture = null
