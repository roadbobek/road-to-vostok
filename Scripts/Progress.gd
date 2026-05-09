extends ColorRect


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@onready var wheel = $Wheel
@onready var timer: Timer = $Timer

signal completed
var progressTime = 0
var progressTimer = 0
var audioCycle = 0.0
var audioTimer = 0

func Use(time):

    timer.wait_time = time
    timer.start()


    wheel.material.set_shader_parameter("value", 0)


    progressTime = float(time)
    audioCycle = 1000

func Load(time):

    timer.wait_time = time / 5.0
    timer.start()


    wheel.material.set_shader_parameter("value", 0)


    progressTime = float(time / 5.0)
    audioCycle = 1.0 / 5.0

func Unload(time):

    timer.wait_time = time / 5.0
    timer.start()


    wheel.material.set_shader_parameter("value", 0)


    progressTime = float(time / 5.0)
    audioCycle = 1.0 / 5.0

func _physics_process(delta):
    progressTimer += delta / progressTime
    wheel.material.set_shader_parameter("value", progressTimer)

    audioTimer += delta

    if audioTimer > audioCycle:
        PlayAmmoLoad()
        audioTimer = 0

func PlayAmmoLoad():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.ammoLoad)

func _on_timer_timeout() -> void :
    emit_signal("completed")
