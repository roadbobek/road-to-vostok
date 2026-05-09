extends Control


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export var chosen = false
@export var initial = false
@onready var fill = $Fill
@onready var select = $Select

var normal = Color(0.0, 0.0, 0.0, 0.0)
var selected = Color(1.0, 1.0, 1.0, 0.1)

func _ready():
    if initial:
        chosen = true
        fill.color = selected
        select.text = "Selected"

func _on_select_toggled(toggled_on):
    if toggled_on:
        fill.color = selected
        select.text = "Selected"
        chosen = true
        PlayClick()
    else:
        fill.color = normal
        select.text = "Select"
        chosen = false
        PlayClick()

func PlayClick():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.UIClick)
