extends Control


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var panel = $Panel
@onready var buttons = $Panel / Margin / Buttons
@onready var useButton = $Panel / Margin / Buttons / Use
@onready var equipButton = $Panel / Margin / Buttons / Equip
@onready var unequipButton = $Panel / Margin / Buttons / Unequip
@onready var unloadButton = $Panel / Margin / Buttons / Unload
@onready var splitButton = $Panel / Margin / Buttons / Split
@onready var takeButton = $Panel / Margin / Buttons / Take
@onready var sleepButton = $Panel / Margin / Buttons / Sleep
@onready var transferButton = $Panel / Margin / Buttons / Transfer
@onready var dropButton = $Panel / Margin / Buttons / Drop
@onready var placeButton = $Panel / Margin / Buttons / Place
@onready var destroyButton: Button = $Panel / Margin / Buttons / Destroy
@onready var destroyProgress: ProgressBar = $Panel / Margin / Buttons / Destroy / Progress
@onready var remove0Button = $Panel / Margin / Buttons / Remove_0
@onready var remove1Button = $Panel / Margin / Buttons / Remove_1
@onready var remove2Button = $Panel / Margin / Buttons / Remove_2
@onready var remove3Button = $Panel / Margin / Buttons / Remove_3


var distance
var interface
var hover = false
var centerPosition: Vector2
var hideDistance = 200


const sleepItems = ["Sleeping_Bag", "Mattress", "Blanket", "Pillow", "Melatonin"]

func _ready():
    interface = owner
    hide()

func _physics_process(delta):
    if visible && interface.visible:
        CalculateDistance()
        GetHover()

    if destroyButton.visible:
        DestroyProgress(delta)

func Update(slotData: SlotData):

    for button in buttons.get_children():
        button.hide()



    if interface.contextItem.slotData.itemData.usable:
        if interface.contextItem.slotData.state == "Frozen":
            useButton.text = "Frozen"
            useButton.show()
            useButton.disabled = true
        else:
            useButton.text = interface.contextItem.slotData.itemData.phrase
            useButton.show()
            useButton.disabled = false



    if !interface.hoverSlot && interface.contextItem.slotData.itemData.slots.size() != 0:
        equipButton.show()

    if interface.hoverSlot:
        unequipButton.show()



    if !gameData.decor:
        dropButton.show()



    placeButton.show()



    if gameData.decor:
        destroyButton.show()
        destroyProgress.value = 0.0



    if interface.contextGrid && interface.container:
        transferButton.show()



    if interface.contextGrid && interface.contextItem.slotData.itemData.subtype == "Magazine" && (interface.contextItem.slotData.amount != 0):
        unloadButton.text = "Unload"
        unloadButton.show()

    if interface.contextGrid && interface.contextItem.slotData.itemData.type == "Weapon":
        if interface.contextItem.slotData.itemData.weaponAction == "Manual":
            if interface.contextItem.slotData.amount != 0 || interface.contextItem.slotData.chamber:
                unloadButton.text = "Unload"
                unloadButton.show()

    if interface.contextGrid && interface.contextItem.slotData.itemData.type == "Weapon":
        if interface.contextItem.slotData.itemData.weaponAction != "Manual":
            if interface.contextItem.slotData.amount == 0 && interface.contextItem.slotData.chamber:
                unloadButton.text = "Clear Chamber"
                unloadButton.show()



    if interface.contextItem.slotData.itemData.stackable && interface.contextItem.slotData.amount > 1:
        splitButton.show()



    if interface.contextItem.slotData.itemData.stackable && interface.contextItem.slotData.amount > interface.contextItem.slotData.itemData.defaultAmount:
        takeButton.text = "Take " + "(" + str(interface.contextItem.slotData.itemData.defaultAmount) + ")"
        takeButton.show()



    if slotData.nested.size() != 0:
        var nestedIndex = 0

        for nestedItem in slotData.nested:
            var removeString = "Remove_" + str(nestedIndex)
            var removeButton = buttons.get_node(removeString)
            removeButton.text = "Remove " + "(" + slotData.nested[nestedIndex].display + ")"
            removeButton.show()
            nestedIndex += 1



    if interface.contextItem.slotData.itemData.file in sleepItems:
        sleepButton.text = "Sleep"
        sleepButton.show()



    panel.size = Vector2(80.0, 0.0)
    panel.global_position = get_global_mouse_position() - Vector2(0, panel.size.y)
    centerPosition = get_global_mouse_position() - Vector2( - panel.size.x / 2, panel.size.y / 2)

func _on_use_pressed() -> void :
    if interface.visible:
        interface.ContextUse()

func _on_unload_pressed() -> void :
    if interface.visible:
        interface.ContextUnload()

func _on_take_pressed() -> void :
    if interface.visible:
        interface.ContextTake()

func _on_split_pressed() -> void :
    if interface.visible:
        interface.ContextSplit()

func _on_equip_pressed() -> void :
    if interface.visible:
        interface.ContextEquip()

func _on_unequip_pressed() -> void :
    if interface.visible:
        interface.ContextUnequip()

func _on_drop_pressed() -> void :
    if interface.visible:
        interface.ContextDrop()

func _on_place_pressed() -> void :
    if interface.visible:
        interface.ContextPlace()

func _on_sleep_pressed() -> void :
    if interface.visible:
        interface.ContextSleep()

func _on_transfer_pressed() -> void :
    if interface.visible:
        interface.ContextTransfer()

func _on_remove_0_pressed() -> void :
    if interface.visible:
        interface.ContextRemove(0)

func _on_remove_1_pressed() -> void :
    if interface.visible:
        interface.ContextRemove(1)

func _on_remove_2_pressed() -> void :
    if interface.visible:
        interface.ContextRemove(2)

func _on_remove_3_pressed() -> void :
    if interface.visible:
        interface.ContextRemove(3)

func GetHover():

    if panel.get_global_rect().has_point(get_global_mouse_position()):
        hover = true
    else:
        hover = false

func DestroyProgress(delta):
    if destroyButton.is_pressed():
        destroyProgress.value += delta * 100.0
    else:
        destroyProgress.value = 0.0

    if destroyProgress.value >= 100.0 && interface.visible:
        interface.ContextDestroy()

func CalculateDistance():
    distance = centerPosition.distance_to(get_global_mouse_position())

    if distance > hideDistance:
        interface.HideContext()
        interface.Reset()
