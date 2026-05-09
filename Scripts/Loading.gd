extends Control

@onready var screen = $Screen
@onready var background = $Screen / Background
@onready var label = $Screen / Label
@onready var animation = $Fader / Animation

func LoadingShaders():
    screen.visible = true
    label.text = str("Loading shaders...")

func LoadingFinished():
    animation.play("Fade")

func Hide():
    screen.visible = false
