extends Node3D
class_name Trader


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")
var LT_Master: LootTable = preload("res://Loot/LT_Master.tres")


@export_group("References")
@export var traderData: TraderData
@export var skeleton: Skeleton3D
@export var animations: AnimationPlayer
@export var timer: Timer
@export var display: Node3D

@export_group("Debug")
@export var force: bool


var tasksCompleted: Array[String]
var shelterUnlocked = false
var supply: Array[SlotData]
var tax = 100.0


var voiceTimer = 0.0
var voiceCycle = 60.0
var activeVoice = null


var animationCycle = 1.0 / 60.0
var animationTimer = 0.0

var UIManager
var interface


var traderBucket: Array[ItemData]

func _ready():

    timer.wait_time = traderData.resupply * 60
    timer.start()


    await get_tree().create_timer(randi_range(0, 4), false).timeout;
    animations.play("Trader_Idle")


    UIManager = get_tree().current_scene.get_node("/root/Map/Core/UI")
    interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")


    animations.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
    skeleton.modifier_callback_mode_process = Skeleton3D.MODIFIER_CALLBACK_MODE_PROCESS_MANUAL


    FillTraderBucket()
    CreateSupply()


    if !force: Deactivate()

func Activate():
    process_mode = ProcessMode.PROCESS_MODE_INHERIT
    if display: display.show()
    show()

func Deactivate():
    process_mode = ProcessMode.PROCESS_MODE_DISABLED
    if display: display.hide()
    hide()

func _physics_process(delta):
    SupplyTimer()
    Voices(delta)
    Animate(delta)

func Animate(delta):

    var playerDistance3D = global_position.distance_to(gameData.playerPosition)


    if playerDistance3D > 50: animationCycle = 1.0 / 1.0
    elif playerDistance3D > 25.0: animationCycle = 1.0 / 15.0
    else: animationCycle = 1.0 / 60.0


    animationTimer += delta


    if animationTimer >= animationCycle:
        var animDelta = animationTimer
        if animations && animations.active:
            animations.advance(animDelta)
            skeleton.advance(animDelta)


        animationTimer = 0.0

func SupplyTimer():

    if interface && gameData.isTrading:
        var timeLeft = timer.time_left
        var minutes = floor(timeLeft / 60)
        var seconds = int(timeLeft) % 60
        interface.traderResupply.text = "%02d:%02d" % [minutes, seconds]


    if timer.is_stopped():

        CreateSupply()


        if gameData.isTrading:
            interface.Resupply()
            PlayTraderReset()


        timer.start()

func FillTraderBucket():
    if LT_Master.items.size() != 0:
        for item in LT_Master.items:
            if traderData.name == "Generalist" && item.generalist:
                traderBucket.append(item)
            elif traderData.name == "Doctor" && item.doctor:
                traderBucket.append(item)
            elif traderData.name == "Gunsmith" && item.gunsmith:
                traderBucket.append(item)

func CreateSupply():

    supply.clear()


    for index in 40:
        var newSlotData = SlotData.new()
        newSlotData.itemData = traderBucket.pick_random()


        if newSlotData.itemData.defaultAmount != 0 && newSlotData.itemData.subtype != "Magazine":
            newSlotData.amount = newSlotData.itemData.defaultAmount

        supply.append(newSlotData)

func RemoveFromSupply(item: ItemData):
    for slotData in supply:
        if slotData.itemData.name == item.name:
            supply.erase(slotData)
            break

func Interact():
    UIManager.OpenTrader(self)

func UpdateTooltip():
    gameData.tooltip = str(traderData.name)

func CompleteTask(taskData: TaskData):

    var taskString: String
    taskString = taskData.name


    tasksCompleted.append(taskString)
    PlayTraderTask()


    Loader.Message("Task Completed: " + taskData.name, Color.GREEN)


    if !gameData.tutorial:
        Loader.SaveTrader(traderData.name)
        Loader.UpdateProgression()

func Voices(delta):

    if !is_instance_valid(activeVoice):
        voiceTimer += delta


        var playerDistance = global_position.distance_to(gameData.playerPosition)


        if voiceTimer > voiceCycle && playerDistance < 20.0:
            PlayTraderRandom()


            voiceCycle = randf_range(30.0, 60.0)
            voiceTimer = 0.0



func PlayTraderStart():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.UITraderOpen)

    var audioRoll = randi_range(0, 1)
    if audioRoll == 0: return

    if !is_instance_valid(activeVoice) && traderData.startVoices:
        var voice = audioInstance3D.instantiate()
        add_child(voice)
        voice.position = Vector3(0, 1.7, 0)
        voice.PlayInstance(traderData.startVoices, 10, 100)
        activeVoice = voice

func PlayTraderEnd():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.UITraderClose)

    var audioRoll = randi_range(0, 1)
    if audioRoll == 0: return

    if !is_instance_valid(activeVoice) && traderData.endVoices:
        var voice = audioInstance3D.instantiate()
        add_child(voice)
        voice.position = Vector3(0, 1.7, 0)
        voice.PlayInstance(traderData.endVoices, 10, 100)
        activeVoice = voice

func PlayTraderRandom():
    var audioRoll = randi_range(0, 1)
    if audioRoll == 0: return

    if !is_instance_valid(activeVoice) && traderData.randomVoices:
        var voice = audioInstance3D.instantiate()
        add_child(voice)
        voice.position = Vector3(0, 1.7, 0)
        voice.PlayInstance(traderData.randomVoices, 10, 100)
        activeVoice = voice

func PlayTraderReset():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.UITraderReset)

func PlayTraderTrade():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.UITraderTrade)

    if !is_instance_valid(activeVoice) && traderData.tradeVoices:
        var voice = audioInstance3D.instantiate()
        add_child(voice)
        voice.position = Vector3(0, 1.7, 0)
        voice.PlayInstance(traderData.tradeVoices, 10, 100)
        activeVoice = voice

func PlayTraderTask():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.UITraderTask)

    if !is_instance_valid(activeVoice) && traderData.taskVoices:
        var voice = audioInstance3D.instantiate()
        add_child(voice)
        voice.position = Vector3(0, 1.7, 0)
        voice.PlayInstance(traderData.taskVoices, 10, 100)
        activeVoice = voice
