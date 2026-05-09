extends PanelContainer

var taskData: TaskData
var note = false
var noted = false
var completed = false
var interface

@onready var highlight = $Highlight
@onready var title = $Margin / Elements / Title
@onready var difficulty = $Margin / Elements / Difficulty / Value
@onready var description = $Margin / Elements / Description
@onready var inputItems = $Margin / Elements / Input / Items
@onready var inputGrid = $Margin / Elements / Input_Grid
@onready var outputItems = $Margin / Elements / Output / Items
@onready var outputGrid = $Margin / Elements / Output_Grid
@onready var inputButton = $Margin / Elements / Buttons / Input
@onready var completeButton = $Margin / Elements / Buttons / Complete
@onready var addButton = $Margin / Elements / Title / Add
@onready var removeButton = $Margin / Elements / Title / Remove
@onready var hint = $Margin / Elements / Hint


var defaultColor = Color8(0, 0, 0, 0)
var selectedColor = Color8(255, 255, 255, 16)
var completedColor = Color8(0, 255, 0, 16)



func Initialize(task: TaskData, targetInterface):

    taskData = task


    title.text = taskData.name
    difficulty.text = task.difficulty

    if difficulty.text == "Easy":
        difficulty.modulate = Color.GREEN
    elif difficulty.text == "Intermediate":
        difficulty.modulate = Color.ORANGE
    elif difficulty.text == "Hard":
        difficulty.modulate = Color.RED

    description.text = task.description
    inputItems.text = CreateInputString()
    outputItems.text = CreateOutputString()


    interface = targetInterface


    hint.hide()
    for itemData in taskData.receive:
        if itemData.type == "Furniture":
            hint.show()


    for item in inputGrid.get_children():
        item.queue_free()


    for item in outputGrid.get_children():
        item.queue_free()


    for itemData in taskData.deliver:
        var newSlotData = SlotData.new()
        newSlotData.itemData = itemData


        var newItem = interface.item.instantiate()
        inputGrid.add_child(newItem)


        if newSlotData.itemData.defaultAmount != 0 && newSlotData.itemData.subtype != "Magazine":
            newSlotData.amount = newSlotData.itemData.defaultAmount


        newItem.Display(interface, newSlotData, false)


    for itemData in taskData.receive:
        var newSlotData = SlotData.new()
        newSlotData.itemData = itemData


        var newItem = interface.item.instantiate()
        outputGrid.add_child(newItem)


        if newSlotData.itemData.defaultAmount != 0 && newSlotData.itemData.subtype != "Magazine":
            newSlotData.amount = newSlotData.itemData.defaultAmount


        newItem.Display(interface, newSlotData, false)

func InitializeNote(task: TaskData, targetInterface):

    taskData = task


    title.text = taskData.name
    difficulty.get_parent().text = taskData.trader
    inputItems.text = CreateInputString()
    outputItems.text = CreateOutputString()


    interface = targetInterface

func CreateInputString() -> String:
    var string = ""
    var deliverSize = taskData.deliver.size()

    for itemData in taskData.deliver:
        string += String(itemData.name)
        deliverSize -= 1

        if deliverSize > 0:
            string += ", "

    return string

func CreateOutputString() -> String:
    var string = ""
    var receiveSize = taskData.receive.size()

    for itemData in taskData.receive:
        string += String(itemData.name)
        receiveSize -= 1

        if receiveSize > 0:
            string += ", "

    return string



func _on_input_toggled(toggled_on: bool) -> void :
    if toggled_on:
        Selected()
        interface.StartInput(self)
        interface.PlayClick()
    elif !completed:
        Default()
        interface.ResetInput()
        interface.PlayClick()

func _on_complete_pressed() -> void :

    Completed()

    interface.Complete(taskData)

func CanInput(slotData):

    for element in inputGrid.get_children():

        if !element.selected:

            if slotData.itemData.name == element.slotData.itemData.name:

                if slotData.amount >= element.slotData.amount:
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


    if !completed:
        Default()
        completeButton.disabled = true

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



func _on_add_pressed() -> void :
    addButton.text = "Added"
    addButton.disabled = true
    Loader.SaveTaskNotes(taskData, true)
    interface.InitializeNotes()
    interface.PlayClick()

func _on_remove_pressed() -> void :
    Loader.SaveTaskNotes(taskData, false)
    interface.InitializeNotes()
    interface.PlayClick()

func UpdateNoteButtons():

    if note:
        addButton.hide()
        addButton.disabled = true
        removeButton.text = "Remove"
        removeButton.show()
        removeButton.disabled = false

    elif noted:
        addButton.text = "Added"
        addButton.show()
        addButton.disabled = true
        removeButton.hide()
        removeButton.disabled = true

    elif completed:
        addButton.text = "Completed"
        addButton.show()
        addButton.disabled = true
        removeButton.hide()
        removeButton.disabled = true

    else:
        addButton.text = "Add to Notes"
        addButton.show()
        addButton.disabled = false
        removeButton.hide()
        removeButton.disabled = true



func Default():

    note = false
    completed = false

    inputButton.text = "Start Delivery"
    inputButton.disabled = false
    completeButton.disabled = true
    UpdateNoteButtons()

    highlight.color = defaultColor

func Selected():

    note = false
    completed = false

    inputButton.text = "Stop Delivery"
    inputButton.disabled = false
    completeButton.disabled = true
    UpdateNoteButtons()

    highlight.color = selectedColor

func Locked():

    note = false
    completed = false

    inputButton.text = "Start Delivery"
    inputButton.disabled = true
    completeButton.disabled = true
    UpdateNoteButtons()

    highlight.color = defaultColor

func Completed():

    note = false
    completed = true

    inputButton.text = "Delivered"
    inputButton.disabled = true
    completeButton.disabled = true
    UpdateNoteButtons()

    highlight.color = completedColor

func Note():

    note = true
    completed = false

    difficulty.hide()
    description.hide()
    inputButton.hide()
    completeButton.hide()
    inputGrid.hide()
    outputGrid.hide()
    hint.hide()

    inputButton.disabled = true
    completeButton.disabled = true
    UpdateNoteButtons()

    highlight.color = defaultColor

    size.y = 0.0
