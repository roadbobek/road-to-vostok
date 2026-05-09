extends Node3D


@onready var audio: AudioStreamPlayer2D = $Audio
@onready var camera: Camera3D = $Camera
@onready var hint: Label = $UI / Hint
@onready var logo: Sprite2D = $UI / Logo / Logo
var logoOpacity = 0.0
var hintOpacity = 1.0


var finished = false
var audioTimer = 0.0
var audioStart = 0.0


var lines = 0.1
var brightness = 1.5
const introMaterial = preload("res://UI/Effects/MT_Intro.tres")

func _ready() -> void :

    Loader.FadeOutLoading()
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


    if Loader.intro == 1: hint.text = "Skip Intro [SPACE]"
    elif Loader.intro == 2: hint.text = "Skip Intro [SPACE]"
    elif Loader.intro == 3: hint.text = "Skip Intro [SPACE]"


    audioStart = 0.0
    audio.play(audioStart)
    audioTimer = audioStart

func _input(event):

    if event is InputEventKey && event.pressed && event.keycode == KEY_SPACE && !event.is_echo():
        if !finished: Continue()

func _physics_process(delta):

    if audio.playing:
        audioTimer += delta


    if audioTimer > 178.5:
        brightness = move_toward(brightness, 0.0, delta * 10.0)
        hintOpacity = move_toward(hintOpacity, 0.0, delta * 10.0)

    if audioTimer > 190.0 && audioTimer < 200.0:
        logoOpacity = move_toward(logoOpacity, 1.0, delta * 0.5)

    if audioTimer > 200.0:
        logoOpacity = move_toward(logoOpacity, 0.0, delta * 0.5)


    if audioTimer > 178.5 && audioTimer < 185.5:
        lines = move_toward(lines, 10.0, delta * 10.0)
    else:
        lines = move_toward(lines, 0.1, delta * 5.0)


    introMaterial.set_shader_parameter("noiseLines", lines)
    introMaterial.set_shader_parameter("brightness", brightness)
    logo.modulate.a = logoOpacity
    hint.modulate.a = hintOpacity

func _on_audio_finished() -> void :

    if !finished: Continue()

func Continue():

    finished = true


    if Loader.intro == 1:
        Loader.LoadScene("Cabin")

    else:
        Loader.LoadSceneRandom()
