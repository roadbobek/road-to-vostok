extends PanelContainer


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
const item = preload("res://UI/Elements/Item.tscn")

var recipeData: RecipeData
var interface


@onready var highlight = $Highlight
@onready var title = $Margin / Elements / Header / Title
@onready var time = $Margin / Elements / Header / Time
@onready var content = $Margin / Elements / Content


@onready var heat = $Margin / Elements / Header / Proximity / Heat
@onready var workbench = $Margin / Elements / Header / Proximity / Workbench
@onready var testbench = $Margin / Elements / Header / Proximity / Testbench
@onready var shelter = $Margin / Elements / Header / Proximity / Shelter


@onready var inputItems = $Margin / Elements / Content / Input / Items
@onready var inputGrid = $Margin / Elements / Content / Input_Grid
@onready var outputItems = $Margin / Elements / Content / Output / Items
@onready var outputGrid = $Margin / Elements / Content / Output_Grid


@onready var showButton = $Margin / Elements / Header / Show
@onready var inputButton = $Margin / Elements / Content / Buttons / Input
@onready var completeButton = $Margin / Elements / Content / Buttons / Complete


var defaultColor = Color8(0, 0, 0, 0)
var selectedColor = Color8(255, 255, 255, 16)
var activeColor = Color8(0, 255, 0, 16)



func Initialize(recipe: RecipeData, source):

    Collapse()


    recipeData = recipe


    title.text = recipeData.name
    var minutes = floor(recipeData.time / 60)
    var seconds = int(recipeData.time) % 60
    time.text = "%02d:%02d" % [minutes, seconds]


    interface = source


    SetProximity()


    if recipeData.repair:
        completeButton.text = "Repair"
    else:
        completeButton.text = "Craft"


    inputItems.text = CreateInputString()
    outputItems.text = CreateOutputString()


    for child in inputGrid.get_children():
        child.queue_free()


    for child in outputGrid.get_children():
        child.queue_free()


    for itemData in recipeData.input:
        var newSlotData = SlotData.new()
        newSlotData.itemData = itemData

        var newItem = item.instantiate()
        inputGrid.add_child(newItem)
        if recipeData.upgrade: newItem.Display(interface, newSlotData, false)
        else: newItem.Display(interface, newSlotData, true)


    for itemData in recipeData.output:
        var newSlotData = SlotData.new()
        newSlotData.itemData = itemData

        var newItem = item.instantiate()
        outputGrid.add_child(newItem)
        newItem.Display(interface, newSlotData, false)

func CreateInputString() -> String:
    var string = ""
    var inputSize = recipeData.input.size()

    for itemData in recipeData.input:
        string += String(itemData.display)
        inputSize -= 1

        if inputSize > 0:
            string += ", "

    return string

func CreateOutputString() -> String:
    var string = ""
    var outputSize = recipeData.output.size()

    for itemData in recipeData.output:
        if recipeData.repair: string += String(itemData.display) + " [100%]"
        else: string += String(itemData.display)
        outputSize -= 1

        if outputSize > 0:
            string += ", "

    return string



func _on_input_toggled(toggled_on: bool) -> void :
    if toggled_on:
        interface.StartInput(self)
        Selected()
        PlayClick()
    else:
        interface.ResetInput()
        Default()
        PlayClick()

func _on_complete_pressed() -> void :
    interface.Craft(recipeData)
    Active()
    PlayClick()

func CanInput(slotData):

    for element in inputGrid.get_children():

        if !element.selected:

            if slotData.itemData.name == element.slotData.itemData.name:
                return true
    return false

func CanComplete():
    var itemsInputted = 0
    var itemsNeeded = inputGrid.get_child_count()


    for element in inputGrid.get_children():
        if element.selected:
            itemsInputted += 1


    if itemsInputted == itemsNeeded:
        completeButton.disabled = false
    else:
        completeButton.disabled = true

func ResetInput():

    for element in inputGrid.get_children():

        if element.selected:
            element.State("Display")


    inputButton.set_pressed_no_signal(false)
    completeButton.disabled = true
    Default()

func AddInputItem(slotData):

    for child in inputGrid.get_children():

        if !child.selected:

            if slotData.itemData.name == child.slotData.itemData.name:
                child.State("Selected")
                CanComplete()
                break

func RemoveInputItem(slotData):

    for element in inputGrid.get_children():

        if element.selected:

            if slotData.itemData.name == element.slotData.itemData.name:
                element.State("Display")
                CanComplete()
                break



func SetProximity():
    heat.visible = recipeData.heat
    workbench.visible = recipeData.workbench
    testbench.visible = recipeData.testbench
    shelter.visible = recipeData.shelter

func UpdateProximity():

    if recipeData.heat:
        if gameData.heat || gameData.PRX_Heat:
            heat.modulate = Color.GREEN
            inputButton.text = "Start Input"
            inputButton.disabled = false
        else:
            heat.modulate = Color8(255, 255, 255, 32)
            inputButton.text = "Heat required"
            inputButton.disabled = true


    if recipeData.workbench:
        if gameData.PRX_Workbench:
            workbench.modulate = Color.GREEN
            inputButton.text = "Start Input"
            inputButton.disabled = false
        else:
            workbench.modulate = Color8(255, 255, 255, 32)
            inputButton.text = "Workbench required"
            inputButton.disabled = true


    if recipeData.shelter:
        if gameData.shelter:
            shelter.modulate = Color.GREEN
            inputButton.text = "Start Input"
            inputButton.disabled = false
        else:
            shelter.modulate = Color8(255, 255, 255, 32)
            inputButton.text = "Shelter required"
            inputButton.disabled = true



func _on_show_toggled(toggled_on):
    if toggled_on:
        Expand()
        PlayClick()
    else:
        Collapse()
        PlayClick()

func Collapse():

    content.hide()
    showButton.text = "Show"

func Expand():

    content.show()
    showButton.text = "Hide"



func Default():

    showButton.disabled = false
    inputButton.text = "Start Input"
    inputButton.disabled = false

    UpdateProximity()

    highlight.color = defaultColor

func Selected():

    showButton.disabled = false
    inputButton.text = "Stop Input"
    inputButton.disabled = false
    inputButton.set_pressed_no_signal(true)

    highlight.color = selectedColor

func Active():

    content.show()

    showButton.disabled = true
    inputButton.text = "Reset Input"
    inputButton.disabled = true
    inputButton.set_pressed_no_signal(false)
    completeButton.disabled = true

    highlight.color = activeColor



func PlayClick():
    var click = audioInstance2D.instantiate()
    add_child(click)
    click.PlayInstance(audioLibrary.UIClick)
