extends Control


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var panel = $Content / Panel


@onready var use = $Content / Panel / Margin / VBox / Use
@onready var unload = $Content / Panel / Margin / VBox / Unload
@onready var split = $Content / Panel / Margin / VBox / Split
@onready var take = $Content / Panel / Margin / VBox / Take
@onready var equip = $Content / Panel / Margin / VBox / Equip
@onready var transfer = $Content / Panel / Margin / VBox / Transfer
@onready var drop = $Content / Panel / Margin / VBox / Drop
@onready var place = $Content / Panel / Margin / VBox / Place

var distance
var interface
var activationPosition: Vector2
var hideDistance = 100.0

func _ready():
    interface = owner

func _physics_process(_delta):
    if visible:
        CalculateDistance()

func Show(slot: Slot):

    var slotData = slot.slotData




    if slotData.itemData.usable:
        use.text = slotData.itemData.phrase
        use.show()
    else:
        use.hide()




    if slotData.itemData.type == "Weapon":

        if slotData.ammo != 0 && (slot.type == slot.SlotType.Inventory || slot.type == slot.SlotType.Equipment || slot.type == slot.SlotType.Loot):
            unload.text = "Unload"
            unload.show()
        else:
            unload.hide()


    elif slotData.itemData.type == "Equipment" && slotData.armor:
        unload.text = "Unload"
        unload.show()

    else:
        unload.hide()




    if slotData.itemData.type == "Ammunition":


        if slotData.ammo > 1:
            split.show()
        else:
            split.hide()


        if slotData.ammo > slotData.itemData.boxSize:
            take.text = "Take " + "(" + str(slotData.itemData.boxSize) + ")"
            take.show()
        else:
            take.hide()

    else:
        split.hide()
        take.hide()




    if slotData.itemData.equippable:

        if slot.type == slot.SlotType.Equipment:
            equip.text = "Unequip"
        else:
            equip.text = "Equip"

        equip.show()
    else:
        equip.hide()




    if interface.container && (slot.type == slot.SlotType.Inventory || slot.type == slot.SlotType.Loot):
        transfer.show()
    else:
        transfer.hide()




    drop.show()
    place.show()



    panel.size = Vector2(panel.size.x, 0)
    panel.global_position = get_global_mouse_position() - Vector2(0, panel.size.y)
    activationPosition = get_global_mouse_position() - Vector2( - panel.size.x / 2, panel.size.y / 2)
    show()

func Hide():
    hide()
    panel.size = Vector2(panel.size.x, 0)

    if interface.actionSlot:
        interface.actionSlot.ResetHighlight()

func CalculateDistance():
    distance = activationPosition.distance_to(get_global_mouse_position())

    if distance > hideDistance:
        Hide()


func _on_blocker_gui_input(event):
    if event is InputEventMouseButton && (event.button_index == MOUSE_BUTTON_LEFT || event.button_index == MOUSE_BUTTON_RIGHT) && event.is_pressed():
        Hide()

func _on_panel_gui_input(event):
    if event is InputEventMouseButton && (event.button_index == MOUSE_BUTTON_LEFT || event.button_index == MOUSE_BUTTON_RIGHT) && event.is_pressed():
        print("Hide")
        Hide()

func _on_use_gui_input(event):
    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed():
        print("Hide")
        Hide()

func _on_unload_gui_input(event):
    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed():
        Hide()

func _on_split_gui_input(event):
    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed():
        Hide()

func _on_take_gui_input(event):
    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed():
        Hide()

func _on_equip_gui_input(event):
    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed():
        Hide()

func _on_transfer_gui_input(event):
    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed():
        Hide()

func _on_drop_gui_input(event):
    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed():
        Hide()

func _on_place_gui_input(event):
    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed():
        Hide()


func _on_use_pressed():
    interface.ItemActionUse()
    ClickAudio()
    Hide()

func _on_unload_pressed():
    interface.ItemActionUnload()
    ClickAudio()
    Hide()

func _on_split_pressed():
    interface.ItemActionSplit()
    ClickAudio()
    Hide()

func _on_take_pressed():
    interface.ItemActionTake()
    ClickAudio()
    Hide()

func _on_equip_pressed():
    interface.ItemActionEquip()
    ClickAudio()
    Hide()

func _on_transfer_pressed():
    interface.ItemActionTransfer()
    ClickAudio()
    Hide()

func _on_drop_pressed():
    interface.ItemActionDrop()
    ClickAudio()
    Hide()

func _on_place_pressed():
    interface.ItemActionPlace()
    ClickAudio()
    Hide()

func ClickAudio():
    var click = audioInstance2D.instantiate()
    add_child(click)
    click.PlayInstance(audioLibrary.UIClick)
