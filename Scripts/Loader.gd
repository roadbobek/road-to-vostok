extends CanvasLayer


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
const message = preload("res://UI/Elements/Message.tscn")


var ID = "Taikuri"


@onready var screen = $Screen
@onready var overlay = $Overlay
@onready var animation = $Animation
@onready var label = $Screen / Label
@onready var circle = $Screen / Circle


var scenePath: String
const Menu = "res://Scenes/Menu.tscn"
const Intro = "res://Scenes/Intro.tscn"
const Death = "res://Scenes/Death.tscn"
const Tutorial = "res://Scenes/Tutorial.tscn"
const Cabin = "res://Scenes/Cabin.tscn"
const Attic = "res://Scenes/Attic.tscn"
const Classroom = "res://Scenes/Classroom.tscn"
const Tent = "res://Scenes/Tent.tscn"
const Bunker = "res://Scenes/Bunker.tscn"
const Village = "res://Scenes/Village.scn"
const School = "res://Scenes/School.scn"
const Highway = "res://Scenes/Highway.scn"
const Outpost = "res://Scenes/Outpost.scn"
const Minefield = "res://Scenes/Minefield.scn"
const Apartments = "res://Scenes/Apartments.scn"
const Terminal = "res://Scenes/Terminal.scn"
const Template = "res://Scenes/Template.scn"
var randomScenes = [School, Highway, Outpost]
var randomWeathers = ["Neutral", "Overcast", "Rain", "Storm"]
const shelters = ["Cabin", "Attic", "Classroom", "Tent", "Bunker"]


var intro = 1


@export var startingKits: Array[LootTable]


@onready var messages: VBoxContainer = $Messages


var masterBus = AudioServer.get_bus_index("Master")
var masterAmplify: AudioEffectAmplify = AudioServer.get_bus_effect(0, 1)
var masterValue = 0.0
var masterActive = false

func _ready():
    masterAmplify.volume_db = linear_to_db(0)



func CreateValidator():

    var validator: Validator = Validator.new()

    validator.ID = ID

    ResourceSaver.save(validator, "user://Validator.tres")
    print("Validator created: " + ID)

func ValidateID() -> bool:

    if !FileAccess.file_exists("user://Validator.tres"):
        print("Validator missing -> Format all")
        return false


    else:

        var validator = load("user://Validator.tres") as Validator

        if validator.ID == ID:

            print("ID valid")
            return true


    print("ID invalid -> Format all")
    return false

func ValidateShelter() -> String:

    var directory = DirAccess.open("user://")


    if !directory:
        print("Error accessing user:// directory")
        return ""


    directory.list_dir_begin()
    var lastVisit = 0
    var lastShelter = ""
    var file = directory.get_next()



    while file != "":

        if file.ends_with(".tres"):

            var filePath = "user://" + file

            var resource = load(filePath)

            if resource is ShelterSave:

                if resource.lastVisit > lastVisit:

                    lastShelter = file.replace(".tres", "")
                    lastVisit = resource.lastVisit

        file = directory.get_next()


    directory.list_dir_end()


    if lastShelter == "":
        print("Shelter missing -> Load disabled")
        return ""


    else:
        print("Shelter available (" + lastShelter + ") -> Load available")
        return lastShelter

func FormatAll():

    var directory = DirAccess.open("user://")


    if !directory:
        print("Error accessing user:// directory")
        return


    directory.list_dir_begin()
    var file = directory.get_next()


    while file != "":

        if file.ends_with(".tres"):

            var filePath = "user://" + file

            var removal = directory.remove(filePath)

            if removal == OK:
                print("File removed: " + file)

            else:
                print("File removal failed: " + file)


        file = directory.get_next()


    directory.list_dir_end()


    var preferences: Preferences = Preferences.new()
    ResourceSaver.save(preferences, "user://Preferences.tres")
    print("Preferences resetted")

func FormatSave():

    var directory = DirAccess.open("user://")


    if !directory:
        print("Error accessing user:// directory")
        return


    directory.list_dir_begin()
    var file = directory.get_next()


    while file != "":

        if file.ends_with(".tres") && file != "Validator.tres" && file != "Preferences.tres":

            var filePath = "user://" + file

            var removal = directory.remove(filePath)

            if removal == OK:
                print("File removed: " + file)

            else:
                print("File removal failed: " + file)


        file = directory.get_next()


    directory.list_dir_end()



func LoadScene(scene: String):

    FadeInLoading()
    gameData.freeze = true


    if scene == "Menu" || scene == "Death":
        label.hide()
        circle.hide()
    else:
        label.show()
        circle.show()

    if label.visible:
        label.text = "Loading " + scene + "..."



    if scene == "Menu":
        scenePath = Menu

    elif scene == "Intro":
        scenePath = Intro

    elif scene == "Death":
        scenePath = Death

    elif scene == "Tutorial":
        scenePath = Tutorial
        gameData.menu = false
        gameData.shelter = false
        gameData.permadeath = false
        gameData.tutorial = true



    elif scene == "Cabin":
        scenePath = Cabin
        gameData.menu = false
        gameData.shelter = true
        gameData.permadeath = false
        gameData.tutorial = false

    elif scene == "Attic":
        scenePath = Attic
        gameData.menu = false
        gameData.shelter = true
        gameData.permadeath = false
        gameData.tutorial = false

    elif scene == "Classroom":
        scenePath = Classroom
        gameData.menu = false
        gameData.shelter = true
        gameData.permadeath = false
        gameData.tutorial = false

    elif scene == "Tent":
        scenePath = Tent
        gameData.menu = false
        gameData.shelter = true
        gameData.permadeath = false
        gameData.tutorial = false

    elif scene == "Bunker":
        scenePath = Bunker
        gameData.menu = false
        gameData.shelter = true
        gameData.permadeath = false
        gameData.tutorial = false



    elif scene == "Village":
        scenePath = Village
        gameData.menu = false
        gameData.shelter = false
        gameData.permadeath = false
        gameData.tutorial = false

    elif scene == "Highway":
        scenePath = Highway
        gameData.menu = false
        gameData.shelter = false
        gameData.permadeath = false
        gameData.tutorial = false

    elif scene == "School":
        scenePath = School
        gameData.menu = false
        gameData.shelter = false
        gameData.permadeath = false
        gameData.tutorial = false

    elif scene == "Outpost":
        scenePath = Outpost
        gameData.menu = false
        gameData.shelter = false
        gameData.permadeath = false
        gameData.tutorial = false



    elif scene == "Minefield":
        scenePath = Minefield
        gameData.menu = false
        gameData.shelter = false
        gameData.permadeath = false
        gameData.tutorial = false



    elif scene == "Apartments":
        scenePath = Apartments
        gameData.menu = false
        gameData.shelter = false
        gameData.permadeath = true
        gameData.tutorial = false

    elif scene == "Terminal":
        scenePath = Terminal
        gameData.menu = false
        gameData.shelter = false
        gameData.permadeath = true
        gameData.tutorial = false



    elif scene == "Template":
        scenePath = Template
        gameData.menu = false
        gameData.shelter = false
        gameData.permadeath = false
        gameData.tutorial = true



    await get_tree().create_timer(2.0).timeout;
    get_tree().change_scene_to_file(scenePath)

func LoadSceneRandom():

    FadeInLoading()
    gameData.freeze = true


    scenePath = randomScenes.pick_random()


    label.show()
    circle.show()
    label.text = "Loading..."



    gameData.menu = false
    gameData.shelter = false
    gameData.permadeath = false
    gameData.tutorial = false

    await get_tree().create_timer(2.0).timeout;
    get_tree().change_scene_to_file(scenePath)



func NewGame(difficulty, season):


    FormatSave()



    var world: WorldSave = WorldSave.new()
    world.difficulty = difficulty
    world.season = season
    world.day = 1


    if difficulty == 1:
        world.time = 800
        world.weather = "Neutral"


    if difficulty != 1:
        world.time = randi_range(0, 2400)
        world.weather = randomWeathers.pick_random()

    ResourceSaver.save(world, "user://World.tres")



    var character: CharacterSave = CharacterSave.new()


    if difficulty == 1:

        character.initialSpawn = true


        if startingKits.size() != 0:
            var randomKit = startingKits.pick_random()
            if randomKit.items.size() != 0:
                character.startingKit = randomKit
                print("Loader: Starting kit set")


    if difficulty != 1:
        character.health = randi_range(25, 100)
        character.hydration = randi_range(25, 100)
        character.energy = randi_range(25, 100)
        character.mental = randi_range(25, 100)
        character.temperature = randi_range(25, 100)

    ResourceSaver.save(character, "user://Character.tres")



    var traders: TraderSave = TraderSave.new()
    ResourceSaver.save(traders, "user://Traders.tres")



    var cabin: ShelterSave = ShelterSave.new()
    cabin.initialVisit = true
    ResourceSaver.save(cabin, "user://Cabin.tres")

    var tent: ShelterSave = ShelterSave.new()
    tent.initialVisit = true
    ResourceSaver.save(tent, "user://Tent.tres")

    print("Loader: New Game (" + str(difficulty) + " / " + str(season) + ")")

func ResetCharacter():

    var character: CharacterSave = CharacterSave.new()


    character.cat = gameData.cat
    character.catFound = gameData.catFound
    character.catDead = gameData.catDead


    ResourceSaver.save(character, "user://Character.tres")
    print("Loader: Reset Character")



func SaveCharacter():

    var character: CharacterSave = CharacterSave.new()


    character.initialSpawn = false
    character.startingKit = null


    var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")


    character.health = gameData.health
    character.energy = gameData.energy
    character.hydration = gameData.hydration
    character.mental = gameData.mental
    character.temperature = gameData.temperature
    character.bodyStamina = gameData.bodyStamina
    character.armStamina = gameData.armStamina
    character.overweight = gameData.overweight
    character.starvation = gameData.starvation
    character.dehydration = gameData.dehydration
    character.bleeding = gameData.bleeding
    character.fracture = gameData.fracture
    character.burn = gameData.burn
    character.frostbite = gameData.frostbite
    character.insanity = gameData.insanity
    character.rupture = gameData.rupture
    character.headshot = gameData.headshot


    character.cat = gameData.cat
    character.catFound = gameData.catFound
    character.catDead = gameData.catDead


    character.primary = gameData.primary
    character.secondary = gameData.secondary
    character.knife = gameData.knife
    character.grenade1 = gameData.grenade1
    character.grenade2 = gameData.grenade2
    character.flashlight = gameData.flashlight
    character.NVG = gameData.NVG


    character.inventory.clear()
    character.equipment.clear()
    character.catalog.clear()


    for item in interface.inventoryGrid.get_children():

        var newSlotData = SlotData.new()
        newSlotData.Update(item.slotData)

        newSlotData.GridSave(item.position, item.rotated)

        character.inventory.append(newSlotData)


    for equipmentSlot in interface.equipment.get_children():
        if equipmentSlot is Slot && equipmentSlot.get_child_count() != 0:

            var slotItem = equipmentSlot.get_child(0)

            var newSlotData = SlotData.new()
            newSlotData.Update(slotItem.slotData)

            newSlotData.SlotSave(equipmentSlot.name)

            character.equipment.append(newSlotData)


    for item in interface.catalogGrid.get_children():

        var newSlotData = SlotData.new()
        newSlotData.Update(item.slotData)

        newSlotData.GridSave(item.position, item.rotated)


        if item.slotData.storage.size() != 0:
            newSlotData.storage = item.slotData.storage


        character.catalog.append(newSlotData)


    ResourceSaver.save(character, "user://Character.tres")
    print("SAVE: Character")

func LoadCharacter():

    await get_tree().create_timer(0.1).timeout;


    if !FileAccess.file_exists("user://Character.tres"):
        return


    var character: CharacterSave = load("user://Character.tres") as CharacterSave


    var rigManager = get_tree().current_scene.get_node("/root/Map/Core/Camera/Manager")
    var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")
    var flashlight = get_tree().current_scene.get_node("/root/Map/Core/Camera/Flashlight")
    var NVG = get_tree().current_scene.get_node("/root/Map/Core/UI/NVG")


    if character.initialSpawn && character.startingKit:
        for item in character.startingKit.items:
            var newSlotData = SlotData.new()
            newSlotData.itemData = item

            if newSlotData.itemData.stackable:
                newSlotData.amount = newSlotData.itemData.defaultAmount

            interface.Create(newSlotData, interface.inventoryGrid, false)


    for slotData in character.inventory:
        interface.LoadGridItem(slotData, interface.inventoryGrid, slotData.gridPosition)


    for slotData in character.equipment:
        interface.LoadSlotItem(slotData, slotData.slot)


    for slotData in character.catalog:
        interface.LoadGridItem(slotData, interface.catalogGrid, slotData.gridPosition)


    interface.UpdateStats(false)


    gameData.health = character.health
    gameData.energy = character.energy
    gameData.hydration = character.hydration
    gameData.mental = character.mental
    gameData.temperature = character.temperature
    gameData.bodyStamina = character.bodyStamina
    gameData.armStamina = character.armStamina
    gameData.overweight = character.overweight
    gameData.starvation = character.starvation
    gameData.dehydration = character.dehydration
    gameData.bleeding = character.bleeding
    gameData.fracture = character.fracture
    gameData.burn = character.burn
    gameData.frostbite = character.frostbite
    gameData.insanity = character.insanity
    gameData.rupture = character.rupture
    gameData.headshot = character.headshot


    gameData.cat = character.cat
    gameData.catFound = character.catFound
    gameData.catDead = character.catDead


    gameData.primary = character.primary
    gameData.secondary = character.secondary
    gameData.knife = character.knife
    gameData.grenade1 = character.grenade1
    gameData.grenade2 = character.grenade2
    gameData.flashlight = character.flashlight
    gameData.NVG = character.NVG


    if gameData.primary:
        rigManager.LoadPrimary()
        gameData.weaponPosition = character.weaponPosition
    elif gameData.secondary:
        rigManager.LoadSecondary()
        gameData.weaponPosition = character.weaponPosition
    elif gameData.knife:
        rigManager.LoadKnife()
    elif gameData.grenade1:
        rigManager.LoadGrenade1()
    elif gameData.grenade2:
        rigManager.LoadGrenade2()


    if gameData.flashlight:
        flashlight.Load()
    if gameData.NVG:
        NVG.Load()


    UpdateProgression()

    print("LOAD: Character")



func SaveWorld():

    var world: WorldSave = WorldSave.new()


    world.season = Simulation.season
    world.time = Simulation.time
    world.day = Simulation.day
    world.weather = Simulation.weather
    world.weatherTime = Simulation.weatherTime


    world.difficulty = gameData.difficulty


    ResourceSaver.save(world, "user://World.tres")
    print("SAVE: World")

func LoadWorld():

    if !FileAccess.file_exists("user://World.tres"):
        return


    var world: WorldSave = load("user://World.tres") as WorldSave


    Simulation.season = world.season
    Simulation.time = world.time
    Simulation.day = world.day
    Simulation.weather = world.weather
    Simulation.weatherTime = world.weatherTime


    if world.difficulty == 3 && !gameData.tutorial:
        gameData.difficulty = 3
        gameData.permadeath = true

    print("LOAD: World")



func SaveShelter(targetShelter):

    var shelter: ShelterSave = ShelterSave.new()


    shelter.initialVisit = false



    shelter.lastVisit = (Simulation.day * 10000) + Simulation.time




    var furnitures = get_tree().get_nodes_in_group("Furniture")


    for furniture in furnitures:

        var furnitureComponent: Furniture


        for child in furniture.owner.get_children():
            if child is Furniture:
                furnitureComponent = child


        if furnitureComponent:

            var furnitureSave = FurnitureSave.new()
            furnitureSave.name = furnitureComponent.itemData.name
            furnitureSave.itemData = furnitureComponent.itemData
            furnitureSave.position = furniture.owner.global_position
            furnitureSave.rotation = furniture.owner.global_rotation
            furnitureSave.scale = furniture.owner.scale


            if furniture.owner is LootContainer:

                if furniture.owner.storage.size() != 0:
                    furnitureSave.storage = furniture.owner.storage


            shelter.furnitures.append(furnitureSave)




    var items = get_tree().get_nodes_in_group("Item")


    for item in items:

        if !item.global_position.is_finite() || !item.global_rotation.is_finite():
            print("Invalid transform: " + item.slotData.itemData.file)
            continue


        if item.global_position.y < -10.0:
            print("Falled item: " + item.slotData.itemData.file)
            continue


        var itemSave = ItemSave.new()
        itemSave.name = item.slotData.itemData.name
        itemSave.slotData = item.slotData
        itemSave.position = item.global_position
        itemSave.rotation = item.global_rotation

        shelter.items.append(itemSave)




    var switches = get_tree().get_nodes_in_group("Switch")


    for switch in switches:

        var switchSave = SwitchSave.new()
        switchSave.name = switch.name
        switchSave.active = switch.active

        shelter.switches.append(switchSave)




    ResourceSaver.save(shelter, "user://" + targetShelter + ".tres")
    print("SAVE: " + targetShelter)

func LoadShelter(targetShelter):

    await get_tree().create_timer(0.1).timeout;


    if !FileAccess.file_exists("user://" + targetShelter + ".tres"):
        return


    var shelter: ShelterSave = load("user://" + targetShelter + ".tres") as ShelterSave
    print("LOAD: " + targetShelter)




    if shelter.initialVisit:
        UpdateProgression()


    if !shelter.initialVisit:
        var furnitures = get_tree().get_nodes_in_group("Furniture")
        for furniture in furnitures:
            furniture.owner.global_position.y = -100.0
            furniture.queue_free()




    for furnitureSave in shelter.furnitures:

        var file = Database.get(furnitureSave.itemData.file)
        if !file:
            print("File missing: " + furnitureSave.itemData.file)
            continue


        var furniture = Database.get(furnitureSave.itemData.file).instantiate()
        var map = get_tree().current_scene.get_node("/root/Map")
        map.add_child(furniture)


        furniture.name = furnitureSave.name
        furniture.global_position = furnitureSave.position
        furniture.global_rotation = furnitureSave.rotation
        furniture.scale = furnitureSave.scale


        if furniture is LootContainer:

            if furnitureSave.storage.size() != 0:
                furniture.storage = furnitureSave.storage
                furniture.storaged = true




    for item in shelter.items:

        var file = Database.get(item.slotData.itemData.file)
        if !file:
            print("File missing: " + item.slotData.itemData.file)
            continue


        if !item.position.is_finite() || !item.rotation.is_finite():
            print("Invalid transform: " + item.slotData.itemData.file)
            continue


        if item.position.y < -10.0:
            print("Falled item: " + item.slotData.itemData.file)
            continue


        var pickup = Database.get(item.slotData.itemData.file).instantiate()
        var map = get_tree().current_scene.get_node("/root/Map")
        map.add_child(pickup)


        pickup.slotData.Update(item.slotData)
        pickup.name = item.name
        pickup.global_position = item.position
        pickup.global_rotation = item.rotation
        pickup.Freeze()
        pickup.UpdateAttachments()




    var switches = get_tree().get_nodes_in_group("Switch")


    for switch in switches:
        for switchSave in shelter.switches:

            if switchSave.name == switch.name:

                if switchSave.active:
                    switch.Activate()
                else:
                    switch.Deactivate()

func CheckShelterState(targetShelter) -> bool:

    if FileAccess.file_exists("user://" + targetShelter + ".tres"):
        return true
    else:
        return false

func UnlockShelter(targetShelter):

    var shelter: ShelterSave = ShelterSave.new()
    shelter.initialVisit = true
    ResourceSaver.save(shelter, "user://" + targetShelter + ".tres")
    print("Shelter Unlocked: " + targetShelter)

    UpdateProgression()



func SaveTrader(trader: String):

    if !FileAccess.file_exists("user://Traders.tres"):
        return


    var traders = load("user://Traders.tres") as TraderSave


    var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")


    if trader == "Generalist": traders.generalist.clear()
    elif trader == "Doctor": traders.doctor.clear()
    elif trader == "Gunsmith": traders.gunsmith.clear()
    elif trader == "Grandma": traders.grandma.clear()


    for taskString in interface.trader.tasksCompleted:
        if trader == "Generalist": traders.generalist.append(taskString)
        elif trader == "Doctor": traders.doctor.append(taskString)
        elif trader == "Gunsmith": traders.gunsmith.append(taskString)
        elif trader == "Grandma": traders.grandma.append(taskString)


    ResourceSaver.save(traders, "user://Traders.tres")
    print("SAVE: Traders " + "(" + trader + ")")

func LoadTrader(trader: String):

    await get_tree().create_timer(0.1).timeout;


    if !FileAccess.file_exists("user://Traders.tres"):
        return


    var traders = load("user://Traders.tres") as TraderSave
    print("LOAD: Traders " + "(" + trader + ")")


    var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")


    interface.trader.tasksCompleted.clear()


    if trader == "Generalist":
        for taskString in traders.generalist:
            interface.trader.tasksCompleted.append(taskString)
    elif trader == "Doctor":
        for taskString in traders.doctor:
            interface.trader.tasksCompleted.append(taskString)
    elif trader == "Gunsmith":
        for taskString in traders.gunsmith:
            interface.trader.tasksCompleted.append(taskString)
    elif trader == "Grandma":
        for taskString in traders.grandma:
            interface.trader.tasksCompleted.append(taskString)


    interface.UpdateTraderInfo()



func SaveTaskNotes(task: TaskData, add: bool):

    if !FileAccess.file_exists("user://Traders.tres"):
        return


    var traders = load("user://Traders.tres") as TraderSave


    if add:

        if traders.taskNotes.size() == 0 || !traders.taskNotes.has(task):
            traders.taskNotes.append(task)


    if !add:

        if traders.taskNotes.has(task):
            traders.taskNotes.erase(task)


    ResourceSaver.save(traders, "user://Traders.tres")

func LoadTaskNotes() -> Array[TaskData]:

    if !FileAccess.file_exists("user://Traders.tres"):
        return []


    var traders = load("user://Traders.tres") as TraderSave


    return traders.taskNotes



func UpdateProgression():

    if gameData.tutorial: return


    var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")




    interface.day.text = str("%02d" % Simulation.day)




    if FileAccess.file_exists("user://Traders.tres"):

        var traders = load("user://Traders.tres") as TraderSave

        var completedTasks = (
            traders.generalist.size() + 
            traders.doctor.size() + 
            traders.gunsmith.size() + 
            traders.grandma.size()
        )


        interface.tasks.text = str("%02d" % completedTasks)




    var shelterCount = 0


    var directory = DirAccess.open("user://")


    if !directory:
        print("Error accessing user:// directory")
        return


    directory.list_dir_begin()
    var file = directory.get_next()


    while file != "":

        if file.ends_with(".tres"):

            var fileName = file.get_basename()

            if fileName in shelters:
                shelterCount += 1

        file = directory.get_next()


    directory.list_dir_end()


    interface.shelters.text = str("%02d" % shelterCount)



func Message(text: String, color: Color):
    var newMessage = message.instantiate()
    messages.add_child(newMessage)
    newMessage.Text(text, color)



func _physics_process(delta):
    if masterActive:
        masterValue = move_toward(masterValue, 1.0, delta / 2.0)
    else:
        masterValue = move_toward(masterValue, 0.0, delta / 2.0)

    masterAmplify.volume_db = linear_to_db(masterValue)



func FadeIn():
    HideCursor()
    PlayTransition()
    animation.play("Fade_In")
    masterActive = false

func FadeOut():
    ShowCursor()
    animation.play("Fade_Out")
    await get_tree().create_timer(1).timeout;
    masterActive = true

func FadeInLoading():
    HideCursor()
    PlayTransition()
    animation.play("Fade_In_Loading")
    masterActive = false

func FadeOutLoading():
    ShowCursor()
    animation.play("Fade_Out_Loading")
    await get_tree().create_timer(1).timeout;
    masterActive = true

func ShowLoadingScreen():
    screen.show()

func HideLoadingScreen():
    screen.hide()

func ShowOverlay():
    overlay.show()

func HideOverlay():
    overlay.hide()



func PlayTransition():
    var transition = audioInstance2D.instantiate()
    add_child(transition)
    transition.PlayInstance(audioLibrary.transition)

func HideCursor():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func ShowCursor():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func Quit():
    FadeIn()
    HideCursor()
    await get_tree().create_timer(2.0).timeout;
    get_tree().quit()
