extends Control


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var gameData = preload("res://Resources/GameData.tres")

const item = preload("res://UI/Elements/Item.tscn")
const task = preload("res://UI/Elements/Task.tscn")
const event = preload("res://UI/Elements/Event.tscn")
const recipe = preload("res://UI/Elements/Recipe.tscn")
const track = preload("res://UI/Elements/Track.tscn")
const progress = preload("res://UI/Elements/Progress.tscn")
const progressBar = preload("res://UI/Elements/ProgressBar.tscn")
const events = preload("res://Events/Events.tres")


@onready var camera = $"../../Camera"
@onready var placer = $"../../Camera/Placer"
@onready var character = $"../../Controller/Character"
@onready var rigManager = $"../../Camera/Manager"
@onready var UIManager = $".."
@onready var settings = $"../Settings"
@onready var tooltip = $Tooltip


@onready var catalogUI = $Catalog
@onready var inventoryUI = $Inventory
@onready var containerUI = $Container
@onready var equipmentUI = $Equipment
@onready var characterUI = $Character
@onready var traderUI = $Trader
@onready var supplyUI = $Supply
@onready var tasksUI = $Tasks
@onready var dealUI = $Deal
@onready var toolsUI = $Tools
@onready var eventsUI = $Tools / Events
@onready var craftingUI = $Tools / Crafting
@onready var notesUI = $Tools / Notes
@onready var mapUI = $Tools / Map
@onready var casetteUI = $Tools / Casette


@onready var background = $Background
@onready var catalogGrid = $Catalog / Margin / Scroll / Control / Grid
@onready var inventoryGrid = $Inventory / Grid
@onready var containerGrid = $Container / Grid
@onready var supplyGrid = $Supply / Grid
@onready var equipment = $Equipment
@onready var highlight = $Clipper / Highlight
@onready var clipper = $Clipper


@onready var traderIcon = $Trader / Panel / Icon
@onready var traderName = $Trader / Panel / Stats / Name / Value
@onready var traderTasks = $Trader / Panel / Stats / Tasks / Value
@onready var traderTax = $Trader / Panel / Stats / Tax / Value
@onready var traderResupply = $Trader / Panel / Stats / Resupply / Value
@onready var supplyButton = $Trader / Panel / Buttons / Supply
@onready var taskButton = $Trader / Panel / Buttons / Tasks
@onready var dealSlider = $Deal / Panel / Indicator / Slider
@onready var requestValue = $Deal / Panel / Indicator / Request / Value
@onready var offerValue = $Deal / Panel / Indicator / Offer / Value
@onready var resetButton = $Deal / Panel / Buttons / Reset
@onready var acceptButton = $Deal / Panel / Buttons / Accept
@onready var supplyValue = $Supply / Header / Value / Value
@onready var taskList = $Tasks / Panel / Margin / Scroll / List


@onready var eventsButton = $Tools / Buttons / Margin / Buttons / Events
@onready var eventList = $Tools / Events / Margin / Scroll / List
var currentDay: int


@onready var craftingButton = $Tools / Buttons / Margin / Buttons / Crafting
@onready var typeButtons = $Tools / Crafting / Types / Margin / Buttons
@onready var recipeList = $Tools / Crafting / Recipes / Margin / Scroll / List
@onready var consumablesButton = $Tools / Crafting / Types / Margin / Buttons / Consumables
@onready var medicalButton = $Tools / Crafting / Types / Margin / Buttons / Medical
@onready var equipmentButton = $Tools / Crafting / Types / Margin / Buttons / Equipment
@onready var weaponsButton = $Tools / Crafting / Types / Margin / Buttons / Weapons
@onready var electronicsButton = $Tools / Crafting / Types / Margin / Buttons / Electronics
@onready var miscButton = $Tools / Crafting / Types / Margin / Buttons / Misc
@onready var furnitureButton = $Tools / Crafting / Types / Margin / Buttons / Furniture
@onready var heat = $Tools / Crafting / Types / Margin / Buttons / Proximity / Margin / Icons / Heat
@onready var workbech = $Tools / Crafting / Types / Margin / Buttons / Proximity / Margin / Icons / Workbech
@onready var testbench = $Tools / Crafting / Types / Margin / Buttons / Proximity / Margin / Icons / Testbench
@onready var shelter = $Tools / Crafting / Types / Margin / Buttons / Proximity / Margin / Icons / Shelter

const recipes = preload("res://Crafting/Recipes.tres")
var defaultType: int


@onready var notesButton = $Tools / Buttons / Margin / Buttons / Notes
@onready var notesList = $Tools / Notes / Margin / Scroll / List
@onready var notesHint = $Tools / Notes / Hint


@onready var mapButton = $Tools / Buttons / Margin / Buttons / Map
@onready var mapHint = $Tools / Map / Hint
@onready var mapElements = $Tools / Map / Elements
@onready var mapScroll = $Tools / Map / Elements / Navigator / Scroll


@onready var casetteButton = $Tools / Buttons / Margin / Buttons / Casette
@onready var trackList = $Tools / Casette / Elements / Tracks / Scroll / List
@onready var casetteHint = $Tools / Casette / Hint
@onready var casetteElements = $Tools / Casette / Elements
@onready var casetteWarning = $Tools / Casette / Elements / Header / Panel / Margin / Preview / Warning
@onready var casettePreview = $Tools / Casette / Elements / Header / Panel / Margin / Preview
@onready var casetteName = $Tools / Casette / Elements / Header / Panel / Margin / Preview / Casette / Margin / Name
@onready var casetteCondition = $Tools / Casette / Elements / Header / Panel / Margin / Preview / Battery / Margin / Condition
@onready var overrideButton = $Tools / Casette / Elements / Volume / Panel / Margin / Settings / Override
@onready var casetteSlider = $Tools / Casette / Elements / Volume / Panel / Margin / Settings / Volume_Slider
@onready var casetteAudio = $Tools / Casette / Audio
var casetteOverride = true
var casetteData: CasetteData


@onready var nomadsButton = $Tools / Buttons / Margin / Buttons / Nomads


@onready var inventoryCapacity = $Inventory / Header / Capacity / Value
@onready var inventoryWeight = $Inventory / Header / Weight / Value
@onready var inventoryValue = $Inventory / Header / Value / Value
@onready var containerName = $Container / Header / Label
@onready var containerWeight = $Container / Header / Weight / Value
@onready var containerValue = $Container / Header / Value / Value

@onready var equipmentCapacity = $Equipment / Stats / Elements / Capacity / Value
@onready var equipmentValue = $Equipment / Stats / Elements / Value / Value
@onready var equipmentInsulation = $Equipment / Stats / Elements / Insulation / Value


@onready var day = $Character / Stats / Elements / Day / Value
@onready var shelters = $Character / Stats / Elements / Shelters / Value
@onready var tasks = $Character / Stats / Elements / Tasks / Value


@onready var context = $Context
@onready var warp = $Warp
@onready var blocker = $Blocker


var cellSize = 64
var itemDragged = null
var itemOffset = Vector2()
var mousePosition
var lastMousePosition = Vector2.ZERO


var tooltipMode = 1
var tooltipDelay = 0.5
var tooltipTimer = 0.0
var tooltipOffset = 0.0


var hoverGrid = null
var hoverItem = null
var hoverSlot = null
var hoverEquipment = null
var hoverInfo = null
var hoverInfos: Array


var trader
var container


var contextItem = null
var contextSlot = null
var contextGrid = null


var canEquip = false
var canUnequip = false
var canCombine = false
var canSlotSwap = false
var canGridSwap = false
var canCombineSwap = false
var canCombineLoad = false
var canCombineStack = false
var canCombineCharge = false


var returnSlot = null
var returnGrid = null
var returnRotated = false
var returnPosition = Vector2()


var activeProgress = null


var isInputting = false
var isCrafting = false
var inputTarget = null


var freezables: Array[Item]
var meltables: Array[Item]
var freezeTimer = 0.0
var freezeCycle = 30.0
var meltTimer = 0.0
var meltCycle = 5.0


var baseCarryWeight = 10.0
var currentInventoryCapacity = 0.0
var currentInventoryWeight = 0.0
var currentInventoryValue = 0.0
var currentContainerWeight = 0.0
var currentContainerValue = 0.0
var currentEquipmentWeight = 0.0
var currentEquipmentValue = 0.0
var currentEquipmentInsulation = 0.0
var currentSupplyValue = 0.0
var inventoryWeightPercentage = 0.0
var insulationMultiplier = 0.0


var hover = Color8(255, 255, 255, 32)
var valid = Color8(0, 255, 0, 32)
var invalid = Color8(255, 0, 0, 32)
var swap = Color8(255, 255, 0, 32)
var combine = Color8(0, 255, 0, 32)



func _physics_process(delta):


    ItemEffects(delta)



    if !visible:
        return


    if gameData.isOccupied || isCrafting:
        blocker.mouse_filter = MOUSE_FILTER_STOP
    else:
        blocker.mouse_filter = MOUSE_FILTER_IGNORE



    if Engine.get_physics_frames() % 20 == 0 && !itemDragged:
        UpdateStats(true)



    if Engine.get_physics_frames() % 20 == 0:
        Map()
        CasettePlayer()
        UpdateEvents()

    if casetteAudio.playing:
        CasetteConsumption(delta)



    if isInputting:

        if !craftingUI.visible && !trader:
            ResetInput()

        elif !tasksUI.visible && trader:
            ResetInput()



    if gameData.isOccupied:
        context.hide()
        highlight.hide()
        return



    if !gameData.isTrading && !isInputting:

        if Engine.get_physics_frames() % 100:
            DisplayTime()


        if Input.is_action_just_pressed("context") && !itemDragged:
            if context.visible:
                HideContext()
                Reset()
            else:
                ShowContext()
            return


        if Input.is_action_just_pressed("left_mouse") && contextItem && !context.hover:
            HideContext()
            Reset()
            return


        if Input.is_action_pressed("item_transfer") && Input.is_action_just_pressed("left_mouse") && !contextItem && !gameData.decor:
            FastTransfer()


        elif Input.is_action_pressed("item_equip") && Input.is_action_just_pressed("left_mouse") && !contextItem && !gameData.decor:
            FastEquip()


        elif Input.is_action_pressed("item_drop") && Input.is_action_just_pressed("left_mouse") && !contextItem && !gameData.decor:
            FastDrop()


        elif Input.is_action_just_pressed("left_mouse") && !contextItem:
            Grab()


        elif Input.is_action_just_released("left_mouse") && !contextItem:
            Release()


        elif Input.is_action_just_pressed("item_rotate") && itemDragged && !contextItem:
            Rotate(itemDragged)



    if trader:
        if Input.is_action_just_pressed("left_mouse") && supplyUI.visible:
            TradeSelection()



    if isInputting:
        if Input.is_action_just_pressed("left_mouse") && !supplyUI.visible:
            InputSelection()



    mousePosition = get_global_mouse_position()
    var mouseMoved = mousePosition.distance_to(lastMousePosition) > 1.0
    lastMousePosition = mousePosition

    Hover()
    Highlight()



    if tooltipMode == 1:


        if hoverItem && Engine.get_physics_frames() % 10 == 0:
            tooltip.Update(hoverItem)

        if hoverEquipment && Engine.get_physics_frames() % 10 == 0:
            tooltip.Update(hoverEquipment)

        if hoverInfo && Engine.get_physics_frames() % 10 == 0:
            tooltip.Info(hoverInfo)


        if tooltip.visible:
            tooltip.global_position = get_global_mouse_position() - Vector2(0, tooltipOffset)


        if !itemDragged && !context.visible && !mouseMoved:


            if (hoverItem || hoverEquipment || hoverInfo) && !tooltip.visible:

                tooltipTimer += delta


                if tooltipTimer > tooltipDelay:
                    tooltip.global_position = get_global_mouse_position() - Vector2(0, tooltipOffset)
                    tooltip.show()
                    tooltipTimer = 0.0


            elif !hoverItem && !hoverEquipment && !hoverInfo && tooltip.visible:
                tooltip.hide()
                tooltipTimer = 0.0
        else:
            tooltip.hide()
            tooltipTimer = 0.0
    else:
        tooltip.hide()



    if itemDragged:
        Drag()
        clipper.z_index = 0
    else:
        clipper.z_index = -1



func Open():

    Reset()
    HideAllUI()


    if gameData.decor:
        catalogUI.show()


    elif container:
        containerName.text = container.containerName
        inventoryUI.show()
        equipmentUI.show()
        characterUI.show()
        containerUI.show()
        UpdateContainerGrid()
        FillContainerGrid()


    elif trader:
        if !gameData.tutorial:
            Loader.LoadTrader(trader.traderData.name)

        UpdateTraderInfo()
        ResetTrading()
        supplyButton.button_pressed = true
        inventoryUI.show()
        characterUI.show()
        traderUI.show()
        supplyUI.show()
        dealUI.show()
        FillSupplyGrid()
        trader.PlayTraderStart()


    else:
        inventoryUI.show()
        equipmentUI.show()
        characterUI.show()
        toolsUI.show()


    UpdateUIDetails()
    UpdateStats(true)
    UpdateProximity()


    var warpPosition = get_viewport().get_final_transform() * get_viewport().get_canvas_transform() * warp.global_position
    Input.warp_mouse(warpPosition)
    tooltip.hide()
    highlight.hide()

func Close():

    if itemDragged:
        Drop(itemDragged)


    if container:
        StorageContainerGrid()
        ClearContainerGrid()
        container.ContainerAudio()
        container = null


    if trader:
        if !gameData.tutorial:
            Loader.SaveTrader(trader.traderData.name)

        ResetTrading()
        ClearSupplyGrid()
        trader.PlayTraderEnd()
        trader = null


    Reset()
    ResetInput()
    HideAllUI()
    UpdateStats(false)
    tooltip.hide()
    context.hide()
    highlight.hide()



func UpdateUIDetails():

    for child in inventoryGrid.get_children():
        if child is Item:
            child.UpdateDetails()


    for child in equipment.get_children():
        if child is Slot && child.get_child_count() != 0:
            child.get_child(0).UpdateDetails()

func UpdateStats(updateLabels: bool):

    await get_tree().physics_frame


    currentInventoryCapacity = 0.0
    currentInventoryWeight = 0.0
    currentInventoryValue = 0.0
    currentEquipmentValue = 0.0
    currentContainerWeight = 0.0
    currentContainerValue = 0.0
    currentEquipmentWeight = 0.0
    currentEquipmentValue = 0.0
    currentEquipmentInsulation = 0.0
    currentSupplyValue = 0.0
    inventoryWeightPercentage = 0.0



    for equipmentSlot in equipment.get_children():
        if equipmentSlot is Slot && equipmentSlot.get_child_count() != 0:
            currentEquipmentWeight += equipmentSlot.get_child(0).Weight()
            currentEquipmentValue += equipmentSlot.get_child(0).Value()
            currentInventoryCapacity += equipmentSlot.get_child(0).slotData.itemData.capacity
            currentEquipmentInsulation += equipmentSlot.get_child(0).slotData.itemData.insulation

    currentInventoryCapacity += baseCarryWeight
    insulationMultiplier = 1.0 - (currentEquipmentInsulation / 100.0)
    character.insulation = insulationMultiplier



    for element in inventoryGrid.get_children():
        currentInventoryWeight += element.Weight()
        currentInventoryValue += element.Value()

    if currentInventoryWeight > currentInventoryCapacity:
        if !gameData.overweight:
            character.Overweight(true)
    else:
        character.Overweight(false)

    var combinedWeight = currentInventoryWeight + currentEquipmentWeight

    if combinedWeight > 20:
        character.heavyGear = true
    else:
        character.heavyGear = false



    if container:
        for element in containerGrid.get_children():
            currentContainerWeight += element.Weight()
            currentContainerValue += element.Value()



    if trader:
        for element in supplyGrid.get_children():
            currentSupplyValue += element.Value()



    if updateLabels:

        inventoryWeightPercentage = currentInventoryWeight / currentInventoryCapacity
        inventoryCapacity.text = str("%.1f" % currentInventoryCapacity)
        inventoryWeight.text = str("%.1f" % currentInventoryWeight)
        inventoryValue.text = str(int(round(currentInventoryValue)))

        if inventoryWeightPercentage > 1: inventoryWeight.modulate = Color.RED
        elif inventoryWeightPercentage >= 0.5: inventoryWeight.modulate = Color.YELLOW
        else: inventoryWeight.modulate = Color.GREEN

        equipmentCapacity.text = str(int(round(currentInventoryCapacity))) + "kg"
        equipmentValue.text = str(int(round(currentEquipmentValue)))
        equipmentInsulation.text = str(int(round(currentEquipmentInsulation)))

        if currentEquipmentInsulation <= 25: equipmentInsulation.modulate = Color.RED
        elif currentEquipmentInsulation > 25 && currentEquipmentInsulation <= 50: equipmentInsulation.modulate = Color.YELLOW
        else: equipmentInsulation.modulate = Color.GREEN

        if container:
            containerWeight.text = str("%.1f" % currentContainerWeight)
            containerValue.text = str(int(round(currentContainerValue)))
        if trader:
            supplyValue.text = str(int(round(currentSupplyValue)))

func HideAllUI():
    catalogUI.hide()
    inventoryUI.hide()
    equipmentUI.hide()
    characterUI.hide()
    containerUI.hide()
    traderUI.hide()
    supplyUI.hide()
    tasksUI.hide()
    dealUI.hide()
    toolsUI.hide()



func _on_events_pressed() -> void :

    HideAllTools()
    eventsUI.show()
    settings.SaveDefaultTool(1)


    InitializeEvents()
    PlayClick()

func InitializeEvents():

    for element in eventList.get_children():
        element.queue_free()


    for eventData in events.events:
        var newEvent = event.instantiate()
        eventList.add_child(newEvent)
        newEvent.Initialize(eventData, self)
        currentDay = Simulation.day

func UpdateEvents():
    if eventsUI.visible:
        if currentDay != Simulation.day:
            InitializeEvents()



func _on_crafting_pressed() -> void :

    HideAllTools()
    craftingUI.show()
    settings.SaveDefaultTool(2)


    if defaultType == 1: _on_consumables_pressed()
    elif defaultType == 2: _on_medical_pressed()
    elif defaultType == 3: _on_equipment_pressed()
    elif defaultType == 4: _on_weapons_pressed()
    elif defaultType == 5: _on_electronics_pressed()
    elif defaultType == 6: _on_misc_pressed()
    elif defaultType == 7: _on_furniture_pressed()

func _on_consumables_pressed() -> void :
    ResetInput()
    InitializeRecipes(recipes.consumables)
    settings.SaveDefaultType(1)
    defaultType = 1
    PlayClick()

func _on_medical_pressed() -> void :
    ResetInput()
    InitializeRecipes(recipes.medical)
    settings.SaveDefaultType(2)
    defaultType = 2
    PlayClick()

func _on_equipment_pressed() -> void :
    ResetInput()
    InitializeRecipes(recipes.equipment)
    settings.SaveDefaultType(3)
    defaultType = 3
    PlayClick()

func _on_weapons_pressed() -> void :
    ResetInput()
    InitializeRecipes(recipes.weapons)
    settings.SaveDefaultType(4)
    defaultType = 4
    PlayClick()

func _on_electronics_pressed() -> void :
    ResetInput()
    InitializeRecipes(recipes.electronics)
    settings.SaveDefaultType(5)
    defaultType = 5
    PlayClick()

func _on_misc_pressed() -> void :
    ResetInput()
    InitializeRecipes(recipes.misc)
    settings.SaveDefaultType(6)
    defaultType = 6
    PlayClick()

func _on_furniture_pressed() -> void :
    ResetInput()
    InitializeRecipes(recipes.furniture)
    settings.SaveDefaultType(7)
    defaultType = 7
    PlayClick()

func InitializeRecipes(type):

    for element in recipeList.get_children():
        element.queue_free()


    for craftingRecipe in type:
        var newRecipe = recipe.instantiate()
        recipeList.add_child(newRecipe)
        newRecipe.Initialize(craftingRecipe, self)
        newRecipe.Default()

func UpdateProximity():

    if gameData.heat || gameData.PRX_Heat: heat.modulate = Color.GREEN
    else: heat.modulate = Color8(255, 255, 255, 32)


    if gameData.PRX_Workbench: workbech.modulate = Color.GREEN
    else: workbech.modulate = Color8(255, 255, 255, 32)


    if gameData.shelter: shelter.modulate = Color.GREEN
    else: shelter.modulate = Color8(255, 255, 255, 32)


    if craftingUI.visible && recipeList.get_child_count() != 0:
        for child in recipeList.get_children():
            child.UpdateProximity()

func Craft(recipeData: RecipeData):

    isCrafting = true
    gameData.isOccupied = true


    var newProgress = progressBar.instantiate()
    typeButtons.get_parent().add_child(newProgress)


    typeButtons.hide()
    DisableTools()


    newProgress.Start(recipeData)
    activeProgress = newProgress


    await activeProgress.completed
    if gameData.isDead: return




    if activeProgress:

        Complete(recipeData)


        typeButtons.show()
        EnableTools()


        activeProgress.queue_free()
        activeProgress = null
        gameData.isOccupied = false
        Reset()



func _on_notes_pressed() -> void :

    HideAllTools()
    notesUI.show()
    settings.SaveDefaultTool(3)


    InitializeNotes()
    PlayClick()

func InitializeNotes():

    for element in notesList.get_children():
        element.queue_free()


    var taskNotes = Loader.LoadTaskNotes()


    taskNotes.sort_custom( func(a, b): return a.trader.to_lower() < b.trader.to_lower())


    for taskData in taskNotes:
        var newTask = task.instantiate()
        notesList.add_child(newTask)
        newTask.InitializeNote(taskData, self)
        newTask.Note()


    notesHint.visible = taskNotes.is_empty()
    if gameData.tutorial: notesHint.text = "Task Notes not available (Tutorial)"
    else: notesHint.text = "Task Notes empty"



func Map():

    var mapSlot = equipmentUI.get_child(19)




    if mapSlot.get_child_count() == 0:
        mapHint.show()
        mapElements.hide()
        mapHint.text = "Map not equipped"
        return


    var currentMap = get_tree().current_scene.get_node("/root/Map")


    if currentMap.mapType == "Vostok":
        mapHint.show()
        mapElements.hide()
        mapHint.text = "Map not usable (Vostok)"
        return




    if !mapUI.visible:
        return


    if mapSlot.get_child_count() != 0:
        mapHint.hide()
        mapElements.show()

func _on_map_pressed() -> void :

    HideAllTools()
    mapUI.show()
    settings.SaveDefaultTool(4)


    Map()
    FocusMap()
    PlayClick()

func _on_focus_pressed() -> void :
    FocusMap()
    PlayClick()

func FocusMap():

    var currentMap = get_tree().current_scene.get_node("/root/Map")

    if currentMap.mapType == "Vostok": return
    elif currentMap.mapType == "Shelter": mapScroll.Focus(currentMap.shelterLocation)
    else: mapScroll.Focus(currentMap.mapName)



func CasettePlayer():

    var playerSlot = equipmentUI.get_child(20)




    if playerSlot.get_child_count() == 0:
        ResetCasette()
        casetteHint.show()
        casetteElements.hide()
        casetteHint.text = "Casette Player not equipped"
        return


    if playerSlot.get_child_count() != 0:

        if playerSlot.get_child(0).slotData.condition <= 0:
            ResetCasette()
            casetteHint.show()
            casetteElements.hide()
            casetteHint.text = "Casette Player power 0%, recharge player"
            return


        elif playerSlot.get_child(0).slotData.nested.size() == 0:
            ResetCasette()
            casetteHint.show()
            casetteElements.hide()
            casetteHint.text = "Casette Player empty, insert casette"
            return




    if !casetteUI.visible:
        return


    if playerSlot.get_child_count() != 0:

        if playerSlot.get_child(0).slotData.condition > 0:

            if playerSlot.get_child(0).slotData.nested.size() != 0:

                casetteHint.hide()
                casetteElements.show()


                if casetteData:

                    if casetteData != playerSlot.get_child(0).slotData.nested[0]:
                        casetteData = null
                        ResetCasette()


                if !casetteData:
                    casetteData = playerSlot.get_child(0).slotData.nested[0]
                    InitializeCasette(casetteData)


                var condition = playerSlot.get_child(0).slotData.condition
                casetteCondition.text = "🗲 " + str(int(round(condition))) + "%"
                if condition <= 25: casetteCondition.modulate = Color.RED
                elif condition > 25 && condition <= 50: casetteCondition.modulate = Color.YELLOW
                elif condition > 50: casetteCondition.modulate = Color.GREEN

func _on_casette_pressed() -> void :

    HideAllTools()
    casetteUI.show()
    settings.SaveDefaultTool(5)


    CasettePlayer()
    PlayClick()

func _on_volume_slider_value_changed(value: float) -> void :
    casetteAudio.volume_db = linear_to_db(value)
    settings.SaveCasetteVolume(value)

func _on_override_toggled(toggled_on: bool) -> void :
    if toggled_on:
        settings.SaveCasetteOverride(true)
        overrideButton.text = "Override Ambient Music [ON]"
        casetteOverride = true
        PlayClick()
    else:
        settings.SaveCasetteOverride(false)
        overrideButton.text = "Override Ambient Music [OFF]"
        casetteOverride = false
        PlayClick()

func _on_audio_finished() -> void :
    ResetCasette()

func InitializeCasette(casette: CasetteData):

    casettePreview.texture = casette.preview
    casetteName.text = casette.artist


    if casette.licensed:
        casetteWarning.show()
    else:
        casetteWarning.hide()


    for element in trackList.get_children():
        element.queue_free()


    for trackData in casette.tracks:
        var newTrack = track.instantiate()
        trackList.add_child(newTrack)
        newTrack.Initialize(trackData, self)

    print("Casette Initialized")

func CasetteConsumption(delta):

    var playerSlot = equipmentUI.get_child(20)


    if playerSlot.get_child_count() != 0:

        if playerSlot.get_child(0).slotData.condition > 0:

            playerSlot.get_child(0).slotData.condition -= delta * 0.1

            playerSlot.get_child(0).UpdateDetails()

func PlayCasette(casetteTrack: AudioStreamOggVorbis):
    casetteAudio.stream = casetteTrack
    casetteAudio.play()

func ResetCasette():
    casetteAudio.stream = null
    casetteAudio.stop()


    for element in trackList.get_children():
        element.playButton.set_pressed_no_signal(false)
        element.Default()



func LoadDefaultType(type: int):
    if type == 1:
        defaultType = 1
        consumablesButton.set_pressed_no_signal(true)
        medicalButton.set_pressed_no_signal(false)
        equipmentButton.set_pressed_no_signal(false)
        weaponsButton.set_pressed_no_signal(false)
        electronicsButton.set_pressed_no_signal(false)
        miscButton.set_pressed_no_signal(false)
        furnitureButton.set_pressed_no_signal(false)
    elif type == 2:
        defaultType = 2
        consumablesButton.set_pressed_no_signal(false)
        medicalButton.set_pressed_no_signal(true)
        equipmentButton.set_pressed_no_signal(false)
        weaponsButton.set_pressed_no_signal(false)
        electronicsButton.set_pressed_no_signal(false)
        miscButton.set_pressed_no_signal(false)
        furnitureButton.set_pressed_no_signal(false)
    elif type == 3:
        defaultType = 3
        consumablesButton.set_pressed_no_signal(false)
        medicalButton.set_pressed_no_signal(false)
        equipmentButton.set_pressed_no_signal(true)
        weaponsButton.set_pressed_no_signal(false)
        electronicsButton.set_pressed_no_signal(false)
        miscButton.set_pressed_no_signal(false)
        furnitureButton.set_pressed_no_signal(false)
    elif type == 4:
        defaultType = 4
        consumablesButton.set_pressed_no_signal(false)
        medicalButton.set_pressed_no_signal(false)
        equipmentButton.set_pressed_no_signal(false)
        weaponsButton.set_pressed_no_signal(true)
        electronicsButton.set_pressed_no_signal(false)
        miscButton.set_pressed_no_signal(false)
        furnitureButton.set_pressed_no_signal(false)
    elif type == 5:
        defaultType = 5
        consumablesButton.set_pressed_no_signal(false)
        medicalButton.set_pressed_no_signal(false)
        equipmentButton.set_pressed_no_signal(false)
        weaponsButton.set_pressed_no_signal(false)
        electronicsButton.set_pressed_no_signal(true)
        miscButton.set_pressed_no_signal(false)
        furnitureButton.set_pressed_no_signal(false)
    elif type == 6:
        defaultType = 6
        consumablesButton.set_pressed_no_signal(false)
        medicalButton.set_pressed_no_signal(false)
        equipmentButton.set_pressed_no_signal(false)
        weaponsButton.set_pressed_no_signal(false)
        electronicsButton.set_pressed_no_signal(false)
        miscButton.set_pressed_no_signal(true)
        furnitureButton.set_pressed_no_signal(false)
    elif type == 7:
        defaultType = 7
        consumablesButton.set_pressed_no_signal(false)
        medicalButton.set_pressed_no_signal(false)
        equipmentButton.set_pressed_no_signal(false)
        weaponsButton.set_pressed_no_signal(false)
        electronicsButton.set_pressed_no_signal(false)
        miscButton.set_pressed_no_signal(false)
        furnitureButton.set_pressed_no_signal(true)

func LoadCasetteVolume(value: float):
    casetteSlider.value = value
    casetteAudio.volume_db = linear_to_db(value)

func LoadCasetteOverride(override: bool):
    _on_override_toggled(override)
    overrideButton.set_pressed_no_signal(override)

func LoadDefaultTool(tool: int):
    if tool == 1:
        _on_events_pressed()
        eventsButton.set_pressed_no_signal(true)
        craftingButton.set_pressed_no_signal(false)
        notesButton.set_pressed_no_signal(false)
        mapButton.set_pressed_no_signal(false)
        casetteButton.set_pressed_no_signal(false)
    elif tool == 2:
        _on_crafting_pressed()
        eventsButton.set_pressed_no_signal(false)
        craftingButton.set_pressed_no_signal(true)
        notesButton.set_pressed_no_signal(false)
        mapButton.set_pressed_no_signal(false)
        casetteButton.set_pressed_no_signal(false)
    elif tool == 3:
        _on_notes_pressed()
        eventsButton.set_pressed_no_signal(false)
        craftingButton.set_pressed_no_signal(false)
        notesButton.set_pressed_no_signal(true)
        mapButton.set_pressed_no_signal(false)
        casetteButton.set_pressed_no_signal(false)
    elif tool == 4:
        _on_map_pressed()
        eventsButton.set_pressed_no_signal(false)
        craftingButton.set_pressed_no_signal(false)
        notesButton.set_pressed_no_signal(false)
        mapButton.set_pressed_no_signal(true)
        casetteButton.set_pressed_no_signal(false)
    elif tool == 5:
        _on_casette_pressed()
        eventsButton.set_pressed_no_signal(false)
        craftingButton.set_pressed_no_signal(false)
        notesButton.set_pressed_no_signal(false)
        mapButton.set_pressed_no_signal(false)
        casetteButton.set_pressed_no_signal(true)

func HideAllTools():
    ResetCasette()
    eventsUI.hide()
    craftingUI.hide()
    notesUI.hide()
    mapUI.hide()
    casetteUI.hide()

func DisableTools():
    eventsButton.disabled = true
    craftingButton.disabled = true
    notesButton.disabled = true
    mapButton.disabled = true
    casetteButton.disabled = true
    nomadsButton.disabled = true

func EnableTools():
    eventsButton.disabled = false
    craftingButton.disabled = false
    notesButton.disabled = false
    mapButton.disabled = false
    casetteButton.disabled = false
    nomadsButton.disabled = true



func UpdateContainerGrid():
    containerGrid.CreateContainerGrid(container.containerSize)

func FillContainerGrid():

    if container.storaged:
        for slotData in container.storage:
            LoadGridItem(slotData, containerGrid, slotData.gridPosition)

    else:
        for slotData in container.loot:
            Create(slotData, containerGrid, false)

func ClearContainerGrid():

    containerGrid.ClearGrid()


    for element in containerGrid.get_children():
        element.queue_free()

func StorageContainerGrid():
    container.Storage(containerGrid)



func UpdateTraderInfo():

    traderIcon.texture = trader.traderData.icon
    traderName.text = trader.traderData.name


    var availableTasks = trader.traderData.tasks.size()
    var completedTasks = trader.tasksCompleted.size()
    var baseTax = trader.traderData.tax
    var currentTax = 0.0


    if availableTasks > 0:

        currentTax = baseTax * (1.0 - (float(completedTasks) / float(availableTasks)))

        currentTax = round(currentTax / 10.0) * 10.0


    currentTax = max(0, currentTax)


    traderTasks.text = str(completedTasks) + "/" + str(availableTasks)
    trader.tax = int(currentTax)
    traderTax.text = str(trader.tax) + "%"

func FillSupplyGrid():

    for slotData in trader.supply:
        Create(slotData, supplyGrid, false)

func ClearSupplyGrid():

    supplyGrid.ClearGrid()


    for element in supplyGrid.get_children():
        element.queue_free()

func Resupply():
    ResetTrading()
    ClearSupplyGrid()
    FillSupplyGrid()

func TradeSelection():

    if hoverItem:

        if hoverItem.selected:
            hoverItem.State("Static")
            CalculateDeal()
            PlayClick()

        else:

            if hoverItem.slotData.state == "Jammed" || hoverItem.slotData.state == "Frozen":
                PlayError()
            else:
                hoverItem.State("Selected")
                CalculateDeal()
                PlayClick()

func ResetTrading():

    for element in inventoryGrid.get_children():
        if element.selected:
            element.State("Static")


    for element in supplyGrid.get_children():
        if element.selected:
            element.State("Static")


    requestValue.text = str("0")
    offerValue.text = str("0")


    dealSlider.value = 1.0
    resetButton.disabled = true
    acceptButton.disabled = true

func CalculateDeal():

    var currentRequestValue = 0.0
    var currentOfferValue = 0.0


    for element in supplyGrid.get_children():
        if element.selected:
            currentRequestValue += element.Value() * ((trader.tax * 0.01 + 1))


    for element in inventoryGrid.get_children():
        if element.selected:
            currentOfferValue += element.Value()


    requestValue.text = str(int(round(currentRequestValue)))
    offerValue.text = str(int(round(currentOfferValue)))


    if currentOfferValue == 0 && currentRequestValue == 0:
        resetButton.disabled = true
        acceptButton.disabled = true
        dealSlider.value = 1.0

    elif currentOfferValue == currentRequestValue:
        resetButton.disabled = false
        acceptButton.disabled = false
        dealSlider.value = 1.0

    else:

        if currentOfferValue != 0 && currentRequestValue == 0:
            acceptButton.disabled = true
            resetButton.disabled = false
            dealSlider.value = 2

        elif currentOfferValue == 0 && currentRequestValue != 0:
            acceptButton.disabled = true
            resetButton.disabled = false
            dealSlider.value = 0

        else:

            if currentOfferValue > currentRequestValue:
                acceptButton.disabled = false
                resetButton.disabled = false

            else:
                acceptButton.disabled = true
                resetButton.disabled = false

            var dealPercentage = currentOfferValue / currentRequestValue
            dealSlider.value = dealPercentage

func CompleteDeal():

    for element in inventoryGrid.get_children():
        if element.selected:
            inventoryGrid.Pick(element)
            element.queue_free()


    for element in supplyGrid.get_children():
        if element.selected:

            if element.slotData.itemData.type == "Furniture":
                Create(element.slotData, catalogGrid, false)

                Loader.Message("New Furniture Added [Catalog]", Color.GREEN)


            else:
                Create(element.slotData, inventoryGrid, true)


    for element in supplyGrid.get_children():
        if element.selected:

            trader.RemoveFromSupply(element.slotData.itemData)


            supplyGrid.Pick(element)
            element.queue_free()

func _on_reset_pressed() -> void :
    ResetTrading()
    trader.PlayTraderReset()

func _on_accept_pressed() -> void :
    CompleteDeal()
    ResetTrading()
    trader.PlayTraderTrade()

func _on_supply_pressed() -> void :
    supplyUI.show()
    tasksUI.hide()
    ResetTrading()
    PlayClick()

func _on_tasks_pressed() -> void :
    supplyUI.hide()
    tasksUI.show()
    ResetInput()
    ResetTrading()
    InitializeTasks()
    PlayClick()

func InitializeTasks():

    for element in taskList.get_children():
        element.queue_free()


    var taskNotes = Loader.LoadTaskNotes()


    for taskData in trader.traderData.tasks:
        var newTask = task.instantiate()
        taskList.add_child(newTask)
        newTask.Initialize(taskData, self)


        if taskNotes.has(taskData):
            newTask.noted = true


        if trader.tasksCompleted.has(taskData.name):
            newTask.Completed()
        else:
            newTask.Default()



func StartInput(target):

    ResetInput()


    isInputting = true
    inputTarget = target

func ResetInput():

    for child in inventoryGrid.get_children():
        if child.selected:
            child.State("Static")


    if inputTarget:
        inputTarget.ResetInput()
        inputTarget = null


    isInputting = false

func InputSelection():
    if hoverItem:

        if hoverItem.selected:
            hoverItem.State("Static")
            inputTarget.RemoveInputItem(hoverItem.slotData)
            PlayClick()


        elif inputTarget.CanInput(hoverItem.slotData):

            if hoverItem.slotData.state == "Jammed" || hoverItem.slotData.state == "Frozen":
                PlayError()
            else:
                hoverItem.State("Selected")
                inputTarget.AddInputItem(hoverItem.slotData)
                PlayClick()


        else:
            PlayError()

func Complete(data: Resource):

    if data is TaskData:
        trader.CompleteTask(inputTarget.taskData)
        UpdateTraderInfo()
        DestroyInputItems(data)
        GetOutputItems()
        ResetInput()
    elif data is RecipeData:
        DestroyInputItems(data)
        if data.repair: RepairInputItems()
        if !data.repair: GetOutputItems()
        ResetInput()

func RepairInputItems():

    for child in inventoryGrid.get_children():

        if child.selected && child.slotData.itemData.repairs:
            child.slotData.condition = 100.0
            child.UpdateDetails()

func DestroyInputItems(data: Resource):

    for child in inventoryGrid.get_children():

        if child.selected:

            if data is TaskData:
                inventoryGrid.Pick(child)
                child.queue_free()

            elif data is RecipeData:

                if data.upgrade:
                    inventoryGrid.Pick(child)
                    child.queue_free()

                elif !child.slotData.itemData.tool && !child.slotData.itemData.repairs && !data.upgrade:
                    inventoryGrid.Pick(child)
                    child.queue_free()

func GetOutputItems():

    for child in inputTarget.outputGrid.get_children():
        if child.slotData.itemData.type == "Furniture":

            Create(child.slotData, catalogGrid, false)

            Loader.Message("New Furniture Added [Catalog]", Color.GREEN)
        else:
            if !AutoStack(child.slotData, inventoryGrid):
                Create(child.slotData, inventoryGrid, true)



func LoadGridItem(slotData, targetGrid, gridPosition):

    var newItem = item.instantiate()
    newItem.slotData.Update(slotData)


    targetGrid.add_child(newItem)
    newItem.Initialize(self, slotData)


    if slotData.gridRotated:
        Rotate(newItem)


    newItem.position = gridPosition


    targetGrid.Place(newItem)


    Reset()

func LoadSlotItem(slotData, slotName):

    for equipmentSlot in equipment.get_children():
        if equipmentSlot is Slot && equipmentSlot.name == slotName:

            var newItem = item.instantiate()
            newItem.slotData.Update(slotData)


            add_child(newItem)
            newItem.Initialize(self, slotData)


            Equip(newItem, equipmentSlot)

func Create(slotData, targetGrid, useDrop):

    var newItem = item.instantiate()
    newItem.slotData.Update(slotData)


    add_child(newItem)
    newItem.Initialize(self, slotData)


    if useDrop:
        if AutoPlace(newItem, targetGrid, null, true):
            Reset()
            return true
        else:
            Reset()
            return false


    else:
        if AutoPlace(newItem, targetGrid, null, false):
            Reset()
            return true
        else:
            Reset()
            return false

func AutoStack(slotData, targetGrid):

    if slotData.itemData.stackable:


        if slotData.amount >= slotData.itemData.maxAmount:
            return false


        for element in targetGrid.get_children():

            if element.slotData.itemData.file == slotData.itemData.file:

                var amountFromFullStack = element.slotData.itemData.maxAmount - element.slotData.amount


                if amountFromFullStack == 0: continue


                if slotData.amount <= amountFromFullStack:

                    element.slotData.amount += slotData.amount
                    element.UpdateDetails()
                    PlayStack()


                    return true


                else:

                    var amountToStack = amountFromFullStack
                    element.slotData.amount += amountToStack
                    element.UpdateDetails()
                    PlayStack()


                    var leftovers = slotData.amount - amountToStack
                    slotData.amount = leftovers


                    var newSlotData = SlotData.new()
                    newSlotData.itemData = slotData.itemData
                    newSlotData.amount = leftovers


                    Create(newSlotData, targetGrid, true)


                    return true


    return false

func Grab():

    if canUnequip:
        itemDragged = Unequip(hoverSlot)
        PlayUnequip()
        return


    if hoverItem && hoverGrid:

        itemDragged = hoverGrid.Pick(hoverItem)


        returnSlot = null
        returnGrid = hoverGrid
        returnRotated = itemDragged.rotated
        returnPosition = itemDragged.global_position


        itemOffset = Vector2( - itemDragged.size.x / 2, - itemDragged.size.y / 2)


        itemDragged.reparent(self)
        itemDragged.State("Free")
        PlayClick()

func Release():

    if !itemDragged:
        return


    if canEquip:
        Equip(itemDragged, hoverSlot)
        Reset()
        PlayEquip()
        return


    if canSlotSwap:
        SlotSwap()
        Reset()
        PlayEquip()
        return


    if canGridSwap:
        GridSwap()
        Reset()
        PlayClick()
        return


    if canCombine || canCombineSwap || canCombineLoad || canCombineStack || canCombineCharge:

        if hoverItem:
            Combine(hoverItem)
            PlayClick()
            return

        if hoverSlot:
            Combine(hoverSlot.get_child(0))
            PlayClick()
            return


    if hoverGrid:

        if hoverGrid.Place(itemDragged):
            Reset()
        else:
            Return(itemDragged)
            Reset()

    else:
        if gameData.decor:
            Return(itemDragged)
            Reset()
        else:

            Drop(itemDragged)
            Reset()


    PlayClick()

func Return(target):

    if target.rotated != returnRotated:
        Rotate(target)


    if returnGrid && returnPosition:
        target.global_position = returnPosition
        returnGrid.Place(target)

    elif hoverGrid && !returnPosition && returnSlot:
        Equip(target, returnSlot)

func Rotate(target):

    if target.rotated:
        target.size = Vector2(target.size.y, target.size.x)
        target.rotated = false
        target.UpdateDetails()
        target.UpdateSprite()

    else:
        target.size = Vector2(target.size.y, target.size.x)
        target.rotated = true
        target.UpdateDetails()
        target.UpdateSprite()


    itemOffset = Vector2( - target.size.x / 2, - target.size.y / 2)

func Drop(target):

    var map = get_tree().current_scene.get_node("/root/Map")
    var file = Database.get(target.slotData.itemData.file)


    if !file:
        print("File not found: " + target.slotData.itemData.name)
        target.queue_free()
        PlayDrop()
        return


    var dropDirection
    var dropPosition
    var dropRotation
    var dropForce = 2.5

    if trader:

        if hoverGrid == null:
            dropDirection = trader.global_transform.basis.z
            dropPosition = (trader.global_position + Vector3(0, 1.0, 0)) + dropDirection / 2
            dropRotation = Vector3(-25, trader.rotation_degrees.y + 180 + randf_range(-45, 45), 45)
    else:

        if hoverGrid == null:
            dropDirection = - camera.global_transform.basis.z
            dropPosition = (camera.global_position + Vector3(0, -0.25, 0)) + dropDirection / 2
            dropRotation = Vector3(-25, camera.rotation_degrees.y + 180 + randf_range(-45, 45), 45)


        elif hoverGrid.get_parent().name == "Inventory":
            dropDirection = - camera.global_transform.basis.z
            dropPosition = (camera.global_position + Vector3(0, -0.25, 0)) + dropDirection / 2
            dropRotation = Vector3(-25, camera.rotation_degrees.y + 180 + randf_range(-45, 45), 45)


        elif hoverGrid.get_parent().name == "Container":
            dropDirection = container.global_transform.basis.z
            dropPosition = (container.global_position + Vector3(0, 0.5, 0)) + dropDirection / 2
            dropRotation = Vector3(-25, container.rotation_degrees.y + 180 + randf_range(-45, 45), 45)



    if target.slotData.itemData.stackable:
        var boxSize = target.slotData.itemData.defaultAmount
        var boxesNeeded = ceil(float(target.slotData.amount) / float(boxSize))
        var amountLeft = target.slotData.amount

        for box in boxesNeeded:

            var pickup = file.instantiate()
            map.add_child(pickup)


            pickup.position = dropPosition
            pickup.rotation_degrees = dropRotation
            pickup.linear_velocity = dropDirection * dropForce
            pickup.Unfreeze()


            var newSlotData = SlotData.new()
            newSlotData.itemData = target.slotData.itemData


            if amountLeft > boxSize:
                amountLeft -= boxSize
                newSlotData.amount = boxSize
                pickup.slotData.Update(newSlotData)
            else:
                newSlotData.amount = amountLeft
                pickup.slotData.Update(newSlotData)



    else:

        var pickup = file.instantiate()
        map.add_child(pickup)


        pickup.position = dropPosition
        pickup.rotation_degrees = dropRotation
        pickup.linear_velocity = dropDirection * dropForce
        pickup.Unfreeze()


        pickup.slotData.Update(target.slotData)
        pickup.UpdateAttachments()


    target.reparent(self)
    target.queue_free()
    PlayDrop()


    UpdateStats(true)

func Drag():

    itemDragged.global_position = mousePosition + itemOffset


    if hoverSlot && (canEquip || canSlotSwap):
        itemDragged.equipSlot = hoverSlot
        itemDragged.equipped = true
        itemDragged.UpdateSprite()
    else:
        itemDragged.equipSlot = null
        itemDragged.equipped = false
        itemDragged.UpdateSprite()



func Equip(targetItem, targetSlot):

    if targetItem.rotated:
        Rotate(targetItem)


    targetSlot.hint.hide()
    targetItem.reparent(targetSlot)
    targetItem.State("Static")
    targetItem.position = Vector2.ZERO
    targetItem.size = targetSlot.size
    targetItem.equipSlot = targetSlot
    targetItem.equipped = true


    targetItem.UpdateDetails()
    targetItem.UpdateSprite()


    rigManager.UpdateRig(false)

func Unequip(targetSlot):

    var slotItem = targetSlot.get_child(0)


    targetSlot.hint.show()
    slotItem.reparent(self)
    slotItem.State("Free")
    slotItem.equipSlot = null
    slotItem.equipped = false


    slotItem.size = slotItem.slotData.itemData.size * 64


    slotItem.UpdateDetails()
    slotItem.UpdateSprite()


    itemOffset = Vector2( - slotItem.size.x / 2, - slotItem.size.y / 2)


    returnSlot = targetSlot


    rigManager.UpdateRig(false)


    return slotItem

func GridSwap():

    hoverGrid.Pick(hoverItem)

    var tetrisState = TetrisCheck(hoverItem, itemDragged)


    if tetrisState == 1:

        if (itemDragged.rotated && !hoverItem.rotated) || ( !itemDragged.rotated && hoverItem.rotated):
            Rotate(itemDragged)
        if (hoverItem.rotated && !returnRotated) || ( !hoverItem.rotated && returnRotated):
            Rotate(hoverItem)


    if tetrisState == 2:

        if ( !itemDragged.rotated && !hoverItem.rotated) || (itemDragged.rotated && hoverItem.rotated):
            Rotate(itemDragged)
        if ( !hoverItem.rotated && !returnRotated) || (hoverItem.rotated && returnRotated):
            Rotate(hoverItem)


    itemDragged.global_position = hoverItem.global_position
    hoverGrid.Place(itemDragged)


    hoverItem.global_position = returnPosition
    returnGrid.Place(hoverItem)

func SlotSwap():

    if returnSlot:

        var swapSlot = returnSlot

        var itemEquipped = Unequip(hoverSlot)

        Equip(itemDragged, hoverSlot)


        if itemEquipped.slotData.itemData.slots.has(swapSlot.name):

            Equip(itemEquipped, swapSlot)
        else:

            Drop(itemEquipped)


    else:

        var swapGrid = returnGrid

        var itemEquipped = Unequip(hoverSlot)

        Equip(itemDragged, hoverSlot)

        AutoPlace(itemEquipped, swapGrid, null, true)

func Combine(targetItem):

    var combineItem = itemDragged
    var combineTarget = targetItem



    if canCombineCharge:
        Charge(combineTarget, combineItem)
        PlayClick()
        Reset()



    elif canCombineLoad:
        Load(combineTarget, combineItem)
        PlayClick()
        Reset()



    elif canCombineStack:
        targetItem.slotData.amount += combineItem.slotData.amount
        targetItem.UpdateDetails()
        combineItem.queue_free()
        PlayStack()
        Reset()



    elif canCombineSwap:

        var swapAmmo = combineTarget.slotData.amount

        var swapData = combineTarget.CombineSwap(combineItem)


        var newSlotData = SlotData.new()
        newSlotData.itemData = swapData


        if swapData.subtype == "Magazine":
            print("Swap ammo: " + str(swapAmmo))
            newSlotData.amount = swapAmmo


        if swapData.type == "Armor":
            newSlotData.condition = combineTarget.slotData.condition

        Create(newSlotData, returnGrid, true)

        combineTarget.Combine(combineItem)
        combineItem.queue_free()


        if hoverSlot:
            if swapData.subtype == "Magazine":

                if (hoverSlot.name == "Primary" && gameData.primary) || (hoverSlot.name == "Secondary" && gameData.secondary):
                    rigManager.UpdateRig(true)
                    ChangeMagazine(hoverSlot)
                else:
                    rigManager.UpdateRig(false)
            else:
                rigManager.UpdateRig(false)

        PlayAttach()
        Reset()



    else:

        var combineData = combineItem.slotData.itemData

        combineTarget.Combine(combineItem)
        combineItem.queue_free()


        if hoverSlot:
            if combineData.subtype == "Magazine":

                if (hoverSlot.name == "Primary" && gameData.primary) || (hoverSlot.name == "Secondary" && gameData.secondary):
                    rigManager.UpdateRig(true)
                    ChangeMagazine(hoverSlot)
                else:
                    rigManager.UpdateRig(false)
            else:
                rigManager.UpdateRig(false)

        PlayAttach()
        Reset()

func FastTransfer():

    var targetItem = hoverItem
    var targetGrid = hoverGrid


    if targetGrid && targetItem && container:

        if targetGrid.get_parent().name == "Inventory":
            if AutoStack(targetItem.slotData, containerGrid):
                targetGrid.Pick(targetItem)
                targetItem.queue_free()
                Reset()
                PlayClick()
            elif AutoPlace(targetItem, containerGrid, inventoryGrid, true):
                Reset()
                PlayClick()
            else:
                Reset()
                PlayError()


        elif targetGrid.get_parent().name == "Container":
            if AutoStack(targetItem.slotData, inventoryGrid):
                targetGrid.Pick(targetItem)
                targetItem.queue_free()
                Reset()
                PlayClick()
            elif AutoPlace(targetItem, inventoryGrid, containerGrid, true):
                Reset()
                PlayClick()
            else:
                Reset()
                PlayError()

func FastEquip():

    if hoverGrid && hoverItem:
        var targetSlot
        var swapNeeded = false


        var compatibleSlots = []


        for slot in equipment.get_children():
            if hoverItem.slotData.itemData.slots.has(slot.name):
                compatibleSlots.append(slot)


        if compatibleSlots:

            for slot in compatibleSlots:
                if slot.get_child_count() == 0:
                    targetSlot = slot
                    break


            if !targetSlot:
                targetSlot = compatibleSlots[0]
                swapNeeded = true


        if targetSlot && !swapNeeded:
            hoverGrid.Pick(hoverItem)
            Equip(hoverItem, targetSlot)
            Reset()
            PlayEquip()

        elif targetSlot && swapNeeded:
            hoverGrid.Pick(hoverItem)
            AutoPlace(Unequip(targetSlot), inventoryGrid, null, true)
            Equip(hoverItem, targetSlot)
            Reset()
            PlayEquip()


    elif hoverSlot && hoverSlot.get_child_count() != 0:
        AutoPlace(Unequip(hoverSlot), inventoryGrid, null, true)
        Reset()
        PlayUnequip()

func FastDrop():

    if canUnequip:
        hoverSlot.hint.show()
        Drop(hoverSlot.get_child(0))
        Reset()


        rigManager.UpdateRig(false)


    elif hoverGrid && hoverItem:
        Drop(hoverGrid.Pick(hoverItem))
        Reset()



func ShowContext():

    if hoverItem || hoverSlot:

        if hoverItem:
            contextItem = hoverItem
            contextGrid = hoverGrid
            context.Update(contextItem.slotData)
            context.show()


        elif hoverSlot && hoverSlot.get_child_count() != 0:
            contextItem = hoverSlot.get_child(0)
            contextSlot = hoverSlot
            context.Update(contextItem.slotData)
            context.show()

func HideContext():
    context.hide()

func ContextEquip():

    if contextItem == null || contextGrid == null:
        print("Null: Context Equip")
        return


    var targetSlot
    var swapNeeded = false


    var compatibleSlots = []


    for slot in equipment.get_children():
        if contextItem.slotData.itemData.slots.has(slot.name):
            compatibleSlots.append(slot)


    if compatibleSlots:

        for slot in compatibleSlots:
            if slot.get_child_count() == 0:
                targetSlot = slot
                break


        if !targetSlot:
            targetSlot = compatibleSlots[0]
            swapNeeded = true


    if targetSlot && !swapNeeded:
        contextGrid.Pick(contextItem)
        Equip(contextItem, targetSlot)
        Reset()
        HideContext()
        PlayEquip()

    elif targetSlot && swapNeeded:
        contextGrid.Pick(contextItem)
        AutoPlace(Unequip(targetSlot), inventoryGrid, null, true)
        Equip(contextItem, targetSlot)
        Reset()
        HideContext()
        PlayEquip()

func ContextUnequip():

    if contextSlot == null:
        print("Null: Context Unequip")
        return


    AutoPlace(Unequip(contextSlot), inventoryGrid, null, true)


    Reset()
    HideContext()
    PlayUnequip()

func ContextSplit():

    if contextItem == null || contextGrid == null:
        print("Null: Context Split")
        return


    var splitAmount = round(contextItem.slotData.amount / 2)


    contextItem.slotData.amount -= splitAmount
    contextItem.UpdateDetails()


    var newSlotData = SlotData.new()
    newSlotData.itemData = contextItem.slotData.itemData
    newSlotData.amount = splitAmount


    Create(newSlotData, contextGrid, true)
    HideContext()
    PlayStack()

func ContextTake():

    if contextItem == null || contextGrid == null:
        print("Null: Context Take")
        return


    var takeAmount = contextItem.slotData.itemData.defaultAmount


    contextItem.slotData.amount -= takeAmount
    contextItem.UpdateDetails()


    var newSlotData = SlotData.new()
    newSlotData.itemData = contextItem.slotData.itemData
    newSlotData.amount = takeAmount


    Create(newSlotData, contextGrid, true)
    HideContext()
    PlayStack()

func ContextDrop():

    if contextItem == null || (contextGrid == null && contextSlot == null):
        print("Null: Context Drop")
        return


    if contextGrid:
        Drop(contextGrid.Pick(contextItem))
        HideContext()
        Reset()


    elif contextSlot:
        contextSlot.hint.show()
        Drop(contextSlot.get_child(0))
        HideContext()
        Reset()


        rigManager.UpdateRig(false)

func ContextPlace():

    if contextItem == null || (contextGrid == null && contextSlot == null):
        print("Null: Context Place")
        return


    var map = get_tree().current_scene.get_node("/root/Map")
    var file = Database.get(contextItem.slotData.itemData.file)


    if !file:
        print("File not found: " + contextItem.slotData.itemData.name)


    else:
        var pickup = file.instantiate()
        map.add_child(pickup)


        if !gameData.decor:
            pickup.slotData.Update(contextItem.slotData)
            pickup.UpdateAttachments()


        if gameData.decor && contextItem.slotData.storage.size() != 0:
            pickup.storage = contextItem.slotData.storage
            pickup.storaged = true


        placer.ContextPlace(pickup)


        if contextGrid:
            contextGrid.Pick(contextItem)


        contextItem.reparent(self)
        contextItem.queue_free()


        if contextSlot:
            rigManager.UpdateRig(false)
            contextSlot.hint.show()

        Reset()
        HideContext()
        PlayClick()


        UIManager.ToggleInterface()

func ContextDestroy():

    if contextItem == null || contextGrid == null:
        print("Null: Context Destroy")
        return

    contextGrid.Pick(contextItem)
    contextItem.queue_free()
    HideContext()
    PlayClick()
    PlayDrop()
    Reset()

func ContextTransfer():

    if contextItem == null || contextGrid == null:
        print("Null: Context Transfer")
        return


    var targetItem = contextItem
    var targetGrid = contextGrid


    if targetGrid.get_parent().name == "Inventory":
        if AutoStack(targetItem.slotData, containerGrid):
            targetGrid.Pick(targetItem)
            targetItem.queue_free()
            Reset()
            HideContext()
            PlayClick()
        elif AutoPlace(targetItem, containerGrid, inventoryGrid, true):
            Reset()
            HideContext()
            PlayClick()
        else:
            Reset()
            HideContext()
            PlayError()


    elif targetGrid.get_parent().name == "Container":
        if AutoStack(targetItem.slotData, inventoryGrid):
            targetGrid.Pick(targetItem)
            targetItem.queue_free()
            Reset()
            HideContext()
            PlayClick()
        elif AutoPlace(targetItem, inventoryGrid, containerGrid, true):
            Reset()
            HideContext()
            PlayClick()
        else:
            Reset()
            HideContext()
            PlayError()

func ContextSleep():

    if contextItem == null || contextGrid == null:
        print("Null: Context Sleep")
        return


    var sleepItem = contextItem.slotData.itemData


    contextGrid.Pick(contextItem)
    contextItem.reparent(self)
    contextItem.queue_free()


    HideContext()
    PlayClick()
    Reset()


    UIManager.ToggleInterface()


    Sleep(sleepItem)

func ContextRemove(nestedIndex):

    if contextItem == null || (contextGrid == null && contextSlot == null):
        print("Null: Context Remove")
        return


    var contextAmmo = contextItem.slotData.amount


    var removeItem = contextItem.Remove(nestedIndex)


    var newSlotData = SlotData.new()
    newSlotData.itemData = removeItem


    if removeItem.subtype == "Magazine":
        newSlotData.amount = contextAmmo


    if removeItem.type == "Armor":
        newSlotData.condition = contextItem.slotData.condition
        contextItem.slotData.condition = 100.0


    if contextGrid:
        Create(newSlotData, contextGrid, true)
        HideContext()
        PlayAttach()


    elif contextSlot:

        if removeItem.subtype == "Magazine":

            if (contextSlot.name == "Primary" && gameData.primary) || (contextSlot.name == "Secondary" && gameData.secondary):
                rigManager.UpdateRig(true)
                ChangeMagazine(contextSlot)
            else:
                rigManager.UpdateRig(false)
        else:
            rigManager.UpdateRig(false)


        if removeItem.subtype == "Magazine":

            if rigManager.get_child_count() != 0:

                var rig = rigManager.get_child(0)

                if rig is WeaponRig:

                    rig.UpdateBulletsDetach(contextAmmo)


        Create(newSlotData, inventoryGrid, true)
        HideContext()
        PlayAttach()

func ContextUse():

    if contextItem == null || contextGrid == null:
        print("Null: Context Use")
        return


    Use(contextItem, contextGrid)
    HideContext()
    PlayClick()

func ContextUnload():

    if contextItem == null || contextGrid == null:
        print("Null: Context Unload")
        return


    if contextItem.slotData.itemData.subtype == "Magazine":
        UnloadMagazine(contextItem, contextGrid)
        HideContext()
        PlayClick()

    elif contextItem.slotData.itemData.type == "Weapon":
        UnloadWeapon(contextItem, contextGrid)
        HideContext()
        PlayClick()



func Use(targetItem, targetGrid):

    gameData.isOccupied = true


    PlayUse(targetItem.slotData.itemData)


    var newProgress = progress.instantiate()
    add_child(newProgress)
    newProgress.global_position = targetItem.global_position
    newProgress.size = targetItem.size


    newProgress.Use(4.0)
    activeProgress = newProgress


    await activeProgress.completed
    if gameData.isDead: return




    if activeProgress:

        var consumedItem = targetItem.slotData.itemData


        character.Consume(targetItem.slotData.itemData)
        targetGrid.Pick(targetItem)
        targetItem.queue_free()


        if consumedItem.used.size() != 0:
            for itemData in consumedItem.used:

                var newSlotData = SlotData.new()
                newSlotData.itemData = itemData

                if !AutoStack(newSlotData, targetGrid):
                    Create(newSlotData, targetGrid, true)


        activeProgress.queue_free()
        activeProgress = null
        gameData.isOccupied = false
        Reset()

func Charge(targetItem, sourceItem):

    gameData.isOccupied = true


    sourceItem.queue_free()


    var newProgress = progress.instantiate()
    add_child(newProgress)
    newProgress.global_position = targetItem.global_position
    newProgress.size = targetItem.size


    newProgress.Use(2.0)
    activeProgress = newProgress


    await activeProgress.completed
    if gameData.isDead: return




    if activeProgress:

        targetItem.slotData.condition = 100.0
        targetItem.UpdateDetails()
        PlayAttach()


        activeProgress.queue_free()
        activeProgress = null
        gameData.isOccupied = false
        Reset()

func Load(targetItem, sourceItem):

    gameData.isOccupied = true


    sourceItem.hide()


    var ammoNeeded = targetItem.slotData.itemData.maxAmount - targetItem.slotData.amount
    var ammoProvided = sourceItem.slotData.amount
    var ammoReturn = false
    var ammoToLoad = 0


    var ammoReturnGrid = returnGrid
    var ammoReturnPosition = returnPosition


    if ammoProvided > ammoNeeded:
        ammoReturn = true
        ammoToLoad = ammoNeeded

    else:
        ammoReturn = false
        ammoToLoad = ammoProvided


    var newProgress = progress.instantiate()
    add_child(newProgress)
    newProgress.global_position = targetItem.global_position
    newProgress.size = targetItem.size


    newProgress.Load(ammoToLoad)
    activeProgress = newProgress


    await activeProgress.completed
    if gameData.isDead: return




    if activeProgress:

        if ammoReturn:
            sourceItem.show()
            sourceItem.slotData.amount -= ammoNeeded
            sourceItem.UpdateDetails()
            sourceItem.global_position = ammoReturnPosition
            ammoReturnGrid.Place(sourceItem)

        else:
            sourceItem.queue_free()


        targetItem.slotData.amount += ammoToLoad
        targetItem.UpdateDetails()
        targetItem.UpdateSprite()
        PlayAttach()


        activeProgress.queue_free()
        activeProgress = null
        gameData.isOccupied = false
        Reset()

func UnloadMagazine(targetItem, targetGrid):

    gameData.isOccupied = true


    var ammoData = targetItem.slotData.itemData.compatible[0]
    var ammoToUnload = targetItem.slotData.amount


    var newProgress = progress.instantiate()
    add_child(newProgress)
    newProgress.global_position = targetItem.global_position
    newProgress.size = targetItem.size


    newProgress.Unload(ammoToUnload)
    activeProgress = newProgress


    await activeProgress.completed
    if gameData.isDead: return




    if activeProgress:

        targetItem.slotData.amount = 0
        targetItem.UpdateDetails()
        targetItem.UpdateSprite()


        var newSlotData = SlotData.new()
        newSlotData.itemData = ammoData
        newSlotData.amount = ammoToUnload


        if !AutoStack(newSlotData, targetGrid):
            Create(newSlotData, targetGrid, true)
            PlayStack()


        activeProgress.queue_free()
        activeProgress = null
        gameData.isOccupied = false
        Reset()

func UnloadWeapon(targetItem, targetGrid):

    gameData.isOccupied = true


    var ammoData = targetItem.slotData.itemData.ammo
    var ammoToUnload: int


    if targetItem.slotData.chamber:
        ammoToUnload = targetItem.slotData.amount + 1
    else:
        ammoToUnload = targetItem.slotData.amount


    var newProgress = progress.instantiate()
    add_child(newProgress)
    newProgress.global_position = targetItem.global_position
    newProgress.size = targetItem.size


    newProgress.Unload(ammoToUnload)
    activeProgress = newProgress


    await activeProgress.completed
    if gameData.isDead: return




    if activeProgress:

        targetItem.slotData.amount = 0
        targetItem.slotData.chamber = false
        targetItem.UpdateDetails()


        var newSlotData = SlotData.new()
        newSlotData.itemData = ammoData
        newSlotData.amount = ammoToUnload


        if !AutoStack(newSlotData, targetGrid):
            Create(newSlotData, targetGrid, true)
            PlayStack()


        activeProgress.queue_free()
        activeProgress = null
        gameData.isOccupied = false
        Reset()

func ChangeMagazine(targetSlot):

    gameData.isOccupied = true


    await get_tree().create_timer(0.1, false).timeout;
    var animationLength = rigManager.get_child(0).GetAnimationLength()


    var newProgress = progress.instantiate()
    add_child(newProgress)
    newProgress.global_position = targetSlot.global_position
    newProgress.size = targetSlot.size


    newProgress.Use(animationLength)
    activeProgress = newProgress


    await activeProgress.completed
    if gameData.isDead: return




    if activeProgress:

        activeProgress.queue_free()
        activeProgress = null
        gameData.isOccupied = false



func PlateCheck(penetration: int) -> bool:

    var rigSlot = equipmentUI.get_child(7)

    if rigSlot.get_child_count() != 0:

        var slotData = rigSlot.get_child(0).slotData


        if slotData.nested.size() != 0:
            for itemData in slotData.nested:


                if itemData.type == "Armor" && slotData.condition != 0:



                    if itemData.protection > penetration:

                        slotData.condition -= randi_range(15, 20)

                        if slotData.condition <= 0:
                            slotData.condition = 0
                            PlayArmorBreak()

                        rigSlot.get_child(0).UpdateDetails()


                        return true



                    elif itemData.protection == penetration:

                        slotData.condition -= randi_range(25, 35)

                        if slotData.condition <= 0:
                            slotData.condition = 0
                            PlayArmorBreak()

                        rigSlot.get_child(0).UpdateDetails()

                        return true



                    elif itemData.protection < penetration:

                        slotData.condition = 0
                        PlayArmorBreak()

                        rigSlot.get_child(0).UpdateDetails()

                        return false


    return false

func HelmetCheck(penetration: int) -> bool:

    var helmetSlot = equipmentUI.get_child(8)

    if helmetSlot.get_child_count() != 0:

        var slotData = helmetSlot.get_child(0).slotData


        if slotData.condition != 0:



            if slotData.itemData.protection > penetration:

                slotData.condition -= randi_range(15, 20)

                if slotData.condition <= 0:
                    slotData.condition = 0
                    PlayArmorBreak()

                helmetSlot.get_child(0).UpdateDetails()

                return true



            elif slotData.itemData.protection == penetration:

                slotData.condition -= randi_range(25, 35)

                if slotData.condition <= 0:
                    slotData.condition = 0
                    PlayArmorBreak()

                helmetSlot.get_child(0).UpdateDetails()

                return true



            elif slotData.itemData.protection < penetration:

                slotData.condition = 0
                PlayArmorBreak()

                helmetSlot.get_child(0).UpdateDetails()

                return false


    return false



func ItemEffects(delta):

    if Simulation.season == 1 || gameData.tutorial:
        return


    if Simulation.season == 2:

        if gameData.isSwimming:
            freezeCycle = 5
        else:
            freezeCycle = 30


        if gameData.shelter || gameData.heat:
            Melt(delta)

        else:
            Freeze(delta)

func Freeze(delta):
    freezeTimer += delta


    if freezeTimer > freezeCycle:

        if inventoryGrid.get_child_count() == 0:
            freezeTimer = 0.0
            return


        if !gameData.isSwimming:

            if randi_range(0, 100) > 10:
                freezeTimer = 0.0
                return


        freezables.clear()


        for child in inventoryGrid.get_children():

            if child.slotData.itemData.freezable && child.slotData.state != "Frozen":
                freezables.append(child)


        if freezables.size() != 0:
            var randomItem = freezables.pick_random()
            randomItem.slotData.state = "Frozen"
            randomItem.UpdateDetails()
            print("Item Frozen: " + randomItem.slotData.itemData.name)


        freezeTimer = 0.0

func Melt(delta):
    meltTimer += delta


    if meltTimer > meltCycle:

        if inventoryGrid.get_child_count() == 0:
            meltTimer = 0.0
            return


        meltables.clear()


        for child in inventoryGrid.get_children():

            if child.slotData.state == "Frozen":
                meltables.append(child)


        if meltables.size() != 0:
            var randomItem = meltables.pick_random()
            randomItem.slotData.state = ""
            randomItem.UpdateDetails()
            print("Item Melted: " + randomItem.slotData.itemData.name)


        meltTimer = 0.0



func Hover():

    hoverItem = GetHoverItem()
    hoverGrid = GetHoverGrid()
    hoverSlot = GetHoverSlot()
    hoverEquipment = GetHoverEquipment()
    hoverInfo = GetHoverInfo()



    if itemDragged && hoverGrid && hoverItem && !returnSlot && !canCombine && !canCombineSwap && !canCombineStack && !canCombineLoad:
        var compatibility = TetrisCheck(hoverItem, itemDragged)

        if compatibility == 1 || compatibility == 2:
            canGridSwap = true
        else:
            canGridSwap = false
    else:
        canGridSwap = false



    if itemDragged && hoverSlot && hoverSlot.get_child_count() == 0 && itemDragged.slotData.itemData.slots.has(hoverSlot.name):
        canEquip = true
    else:
        canEquip = false



    if hoverSlot && !itemDragged && hoverSlot.get_child_count() != 0:
        canUnequip = true
    else:
        canUnequip = false



    if itemDragged && hoverSlot && hoverSlot.get_child_count() != 0 && itemDragged.slotData.itemData.slots.has(hoverSlot.name):
        canSlotSwap = true
    else:
        canSlotSwap = false



    if itemDragged && hoverItem:
        var compatibility = CombineCheck(hoverItem, itemDragged)

        if compatibility == 0:
            canCombine = false
            canCombineSwap = false
            canCombineLoad = false
            canCombineStack = false
            canCombineCharge = false
        elif compatibility == 1:
            canCombine = true
            canCombineSwap = false
            canCombineLoad = false
            canCombineStack = false
            canCombineCharge = false
        elif compatibility == 2:
            canCombine = false
            canCombineSwap = true
            canCombineLoad = false
            canCombineStack = false
            canCombineCharge = false
        elif compatibility == 3:
            canCombine = false
            canCombineSwap = false
            canCombineLoad = true
            canCombineStack = false
            canCombineCharge = false
        elif compatibility == 4:
            canCombine = false
            canCombineSwap = false
            canCombineLoad = false
            canCombineStack = true
            canCombineCharge = false
        elif compatibility == 5:
            canCombine = false
            canCombineSwap = false
            canCombineLoad = false
            canCombineStack = true
            canCombineCharge = true



    elif itemDragged && hoverSlot && hoverSlot.get_child_count() != 0:
        var compatibility = CombineCheck(hoverSlot.get_child(0), itemDragged)

        if compatibility == 0:
            canCombine = false
            canCombineSwap = false
            canCombineCharge = false
        elif compatibility == 1:
            canCombine = true
            canCombineSwap = false
            canCombineCharge = false
        elif compatibility == 2:
            canCombine = false
            canCombineSwap = true
            canCombineCharge = false
        elif compatibility == 5:
            canCombine = false
            canCombineCharge = true
    else:
        canCombine = false
        canCombineSwap = false
        canCombineLoad = false
        canCombineStack = false
        canCombineCharge = false

func Highlight():


    if contextItem:
        return

    if !hoverGrid && !hoverSlot:
        highlight.hide()
        return

    if hoverGrid:
        if !itemDragged && !hoverItem:
            highlight.hide()
            return

    if hoverSlot:
        if !canEquip && !canUnequip && !canSlotSwap && !canCombine && !canCombineSwap && !canCombineCharge:
            highlight.hide()
            return



    if canCombine || canCombineSwap:
        highlight.get_child(0).show()
    else:
        highlight.get_child(0).hide()

    if canCombineLoad:
        highlight.get_child(1).show()
    else:
        highlight.get_child(1).hide()

    if canCombineCharge:
        highlight.get_child(2).show()
    else:
        highlight.get_child(2).hide()



    if !itemDragged && hoverItem && hoverGrid:
        highlight.color = hover
        highlight.size = hoverItem.size
        highlight.global_position = hoverItem.global_position
        highlight.show()




    if itemDragged && hoverSlot && (canEquip || canCombine || canCombineSwap):
        highlight.color = valid
        highlight.size = hoverSlot.size
        highlight.global_position = hoverSlot.global_position
        highlight.show()


    if !itemDragged && hoverSlot && canUnequip:
        highlight.color = hover
        highlight.size = hoverSlot.size
        highlight.global_position = hoverSlot.global_position
        highlight.show()


    if itemDragged && hoverSlot && !canEquip && (canSlotSwap || canCombineSwap):
        highlight.color = swap
        highlight.size = hoverSlot.size
        highlight.global_position = hoverSlot.global_position
        highlight.show()


    if itemDragged && hoverSlot && canCombineCharge:
        highlight.color = valid
        highlight.size = hoverSlot.size
        highlight.global_position = hoverSlot.global_position
        highlight.show()



    if itemDragged && hoverGrid:


        if hoverItem && (canCombine || canCombineSwap || canGridSwap || canCombineStack || canCombineLoad):
            highlight.global_position = hoverItem.global_position
            highlight.size = hoverItem.size
            highlight.show()


            if canCombineSwap || canGridSwap:
                highlight.color = swap
            else:
                highlight.color = combine


        else:

            var itemPosition = itemDragged.global_position + Vector2(float(cellSize) / 2, float(cellSize) / 2)
            var gridPosition = hoverGrid.GetGridPosition(itemPosition)
            var itemSize = hoverGrid.GetGridSize(itemDragged)


            highlight.size = itemDragged.size
            highlight.global_position.x = gridPosition.x * cellSize + hoverGrid.global_position.x
            highlight.global_position.y = gridPosition.y * cellSize + hoverGrid.global_position.y
            highlight.show()


            if hoverGrid.CheckGridSpace(gridPosition.x, gridPosition.y, itemSize.x, itemSize.y):
                highlight.color = valid
            else:
                highlight.color = invalid



func AddToCatalog(itemData, storage):

    var newSlotData = SlotData.new()
    newSlotData.itemData = itemData


    if storage:
        newSlotData.storage = storage

    Create(newSlotData, catalogGrid, false)



func DisplayTime():

    var timeSlot = equipmentUI.get_child(18)


    if timeSlot.get_child_count() != 0:

        var hours = int(Simulation.time / 100.0)
        var minutesRaw = int(Simulation.time) % 100
        var minutes = int(floor(float(minutesRaw) / 5.0) * 5)


        if minutes >= 60:
            minutes = 0
            hours += 1


        hours = hours % 24


        timeSlot.get_child(0).condition.show()
        timeSlot.get_child(0).condition.text = "%02d:%02d" % [hours, minutes]

func Sleep(sleepItem):

    var sleepTime = randi_range(6, 12)


    Simulation.simulate = false
    gameData.isSleeping = true
    gameData.freeze = true


    UpdateSimulation(sleepTime * 100)
    PlayTransition()
    PlaySleep()

    await get_tree().create_timer(sleepTime, false).timeout;
    if gameData.isDead: return


    gameData.energy -= 20.0
    gameData.hydration -= 20.0
    gameData.mental += 20.0


    if sleepItem.temperature > 0:
        gameData.temperature += sleepItem.temperature

    elif !gameData.shelter && Simulation.season == 2:
        gameData.temperature -= sleepItem.temperature


    Loader.Message("You slept " + str(sleepTime) + " hours", Color.GREEN)


    Simulation.simulate = true
    gameData.isSleeping = false
    gameData.freeze = false

func UpdateSimulation(sleepTime):

    var currentTime = Simulation.time
    var combinedTime = currentTime + sleepTime
    var wakeTime: float


    if combinedTime >= 2400.0:
        wakeTime = combinedTime - 2400.0
        Simulation.day += 1
        Simulation.time = wakeTime
        Simulation.weatherTime -= sleepTime
        Loader.UpdateProgression()

    else:
        wakeTime = combinedTime
        Simulation.time = wakeTime
        Simulation.weatherTime -= sleepTime

    print("Current time: " + str(int(currentTime)) + " Sleep time: " + str(int(sleepTime)) + " Wake time: " + str(int(wakeTime)))



func Reset():

    itemDragged = null
    returnSlot = null
    returnGrid = null
    returnPosition = null
    returnRotated = false
    contextItem = null
    contextGrid = null
    contextSlot = null
    isInputting = false
    isCrafting = false

func CombineCheck(targetItem, combineItem):



    if combineItem.slotData.itemData.file == targetItem.slotData.itemData.file && targetItem.slotData.itemData.stackable:
        var upcomingStack = combineItem.slotData.amount + targetItem.slotData.amount


        if upcomingStack <= targetItem.slotData.itemData.maxAmount:
            return 4




    for element in targetItem.slotData.itemData.compatible:

        if element.file == combineItem.slotData.itemData.file:



            if element.name == "Batteries" && targetItem.slotData.itemData.type == "Electronics":
                return 5



            if element.type == "Ammo" && targetItem.slotData.itemData.subtype == "Magazine":
                if targetItem.slotData.amount != targetItem.slotData.itemData.maxAmount:
                    return 3
                else:
                    return 0



            for nestedItem in targetItem.slotData.nested:
                if nestedItem.file == combineItem.slotData.itemData.file:
                    return 2



            if targetItem.slotData.itemData.type == "Weapon":
                for nestedItem in targetItem.slotData.nested:
                    if nestedItem.subtype == combineItem.slotData.itemData.subtype:
                        return 2



            if combineItem.slotData.itemData.type == "Electronics":
                for nestedItem in targetItem.slotData.nested:
                    if nestedItem.subtype == "Casette":
                        return 2



            if combineItem.slotData.itemData.type == "Armor":
                for nestedItem in targetItem.slotData.nested:
                    if nestedItem.type == "Armor":
                        return 2




            return 1

    return 0

func TetrisCheck(A, B):
    if A.slotData.itemData.size == B.slotData.itemData.size:
        return 1
    elif A.slotData.itemData.size.x == B.slotData.itemData.size.y && A.slotData.itemData.size.y == B.slotData.itemData.size.x:
        return 2
    else:
        return 0

func GetMagazine(weaponData, weaponSlot, swapMagazine):
    var highestMagazine = null
    var highestAmount = 0


    for magazine in inventoryGrid.get_children():

        if magazine.slotData.itemData.subtype == "Magazine" and magazine.slotData.amount != 0 and weaponData.compatible.has(magazine.slotData.itemData):

            if magazine.slotData.amount > highestAmount:
                highestAmount = magazine.slotData.amount
                highestMagazine = magazine


    if highestMagazine != null:

        var weaponAmmo = weaponSlot.get_child(0).slotData.amount
        var magazineAmmo = highestMagazine.slotData.amount


        if swapMagazine:

            weaponSlot.get_child(0).slotData.amount = magazineAmmo

            highestMagazine.slotData.amount = weaponAmmo
            highestMagazine.UpdateSprite()


            if weaponSlot.get_child(0).slotData.amount != 0 && !weaponSlot.get_child(0).slotData.chamber:
                weaponSlot.get_child(0).slotData.chamber = true
                weaponSlot.get_child(0).slotData.amount -= 1


        else:

            weaponSlot.get_child(0).Combine(highestMagazine)

            inventoryGrid.Pick(highestMagazine)
            highestMagazine.queue_free()


        return true


    return false

func GetAmmo(weaponData):

    for element in inventoryGrid.get_children():

        if element.slotData.itemData.type == "Ammo":

            if element.slotData.itemData.file == weaponData.ammo.file:

                if element.slotData.amount != 0:

                    element.slotData.amount -= 1

                    if element.slotData.amount == 0:
                        inventoryGrid.Pick(element)
                        element.queue_free()


                return true


    return false

func AutoPlace(targetItem, targetGrid, sourceGrid, usedrop):

    if sourceGrid:
        sourceGrid.Pick(targetItem)


    if !targetGrid.Spawn(targetItem):

        Rotate(targetItem)

        if !targetGrid.Spawn(targetItem):

            if sourceGrid:
                Rotate(targetItem)
                sourceGrid.Place(targetItem)
                return false

            else:
                if usedrop:
                    Drop(targetItem)
                    return false
                else:
                    targetItem.queue_free()
                    Reset()
                    return false
    return true

func ItemReturn(target):

    target.Freeze()


    var targetDirection = - camera.global_transform.basis.z
    var targetPosition = (camera.global_position + Vector3(0, -0.25, 0)) + targetDirection / 2
    var targetRotation = Vector3(-25, camera.rotation_degrees.y + 180 + randf_range(-45, 45), 45)
    var targetForce = 2.5


    target.position = targetPosition
    target.rotation_degrees = targetRotation
    target.linear_velocity = targetDirection * targetForce
    target.Unfreeze()

func GetHoverItem():

    if inventoryGrid.is_visible_in_tree():
        for element in inventoryGrid.get_children():
            if element.get_global_rect().has_point(mousePosition) && element is Item && element != itemDragged && !context.visible:
                return element


    if containerGrid.is_visible_in_tree():
        for element in containerGrid.get_children():
            if element.get_global_rect().has_point(mousePosition) && element is Item && element != itemDragged && !context.visible:
                return element


    if catalogGrid.is_visible_in_tree():
        for element in catalogGrid.get_children():
            if element.get_global_rect().has_point(mousePosition) && element is Item && element != itemDragged && !context.visible:
                return element


    if supplyGrid.is_visible_in_tree():
        for element in supplyGrid.get_children():
            if element.get_global_rect().has_point(mousePosition) && element is Item && element != itemDragged && !context.visible:
                return element


    return null

func GetHoverGrid():

    var grids = [inventoryGrid, containerGrid, catalogGrid, supplyGrid]


    for grid in grids:
        if grid.is_visible_in_tree():
            if grid.get_global_rect().has_point(mousePosition) && grid is Grid:
                return grid


    return null

func GetHoverSlot():

    for slot in equipment.get_children():
        if slot.is_visible_in_tree():
            if slot.get_global_rect().has_point(mousePosition) && slot is Slot:
                return slot


    return null

func GetHoverEquipment():

    for slot in equipment.get_children():
        if slot.is_visible_in_tree():
            if slot.get_global_rect().has_point(mousePosition) && slot is Slot:
                if slot.get_child_count() != 0:
                    return slot.get_child(0)


    return null

func GetHoverInfo():

    for info in hoverInfos:
        if info.is_visible_in_tree():
            if info.get_global_rect().has_point(mousePosition):
                return info


    return null



func PlayUse(itemData: ItemData):
    if itemData.audio:
        var use = audioInstance2D.instantiate()
        add_child(use)
        use.PlayInstance(itemData.audio)

func PlayDrop():
    var drop = audioInstance2D.instantiate()
    add_child(drop)
    drop.PlayInstance(audioLibrary.UIDrop)

func PlayClick():
    if gameData.interface:
        var click = audioInstance2D.instantiate()
        add_child(click)
        click.PlayInstance(audioLibrary.UIClick)

func PlayError():
    var error = audioInstance2D.instantiate()
    add_child(error)
    error.PlayInstance(audioLibrary.UIError)

func PlayEquip():
    var equip = audioInstance2D.instantiate()
    add_child(equip)
    equip.PlayInstance(audioLibrary.UIEquip)

func PlayUnequip():
    var unequip = audioInstance2D.instantiate()
    add_child(unequip)
    unequip.PlayInstance(audioLibrary.UIUnequip)

func PlayAttach():
    var attach = audioInstance2D.instantiate()
    add_child(attach)
    attach.PlayInstance(audioLibrary.UIAttach)

func PlayStack():
    var stack = audioInstance2D.instantiate()
    add_child(stack)
    stack.PlayInstance(audioLibrary.UIStack)

func PlayArmorBreak():
    var armorBreak = audioInstance2D.instantiate()
    add_child(armorBreak)
    armorBreak.PlayInstance(audioLibrary.armorBreak)

func PlaySleep():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.sleep)

func PlayTransition():
    var transition = audioInstance2D.instantiate()
    add_child(transition)
    transition.PlayInstance(audioLibrary.transition)
