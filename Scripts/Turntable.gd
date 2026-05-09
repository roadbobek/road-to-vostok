extends Node3D

var spin: bool

func _ready():
    Loader.hide()
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func _input(event):
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        spin = true

func _physics_process(delta):
    if spin:
        rotation_degrees.y += delta * -120

        if rotation_degrees.y <= -360:
            spin = false
            rotation_degrees.y = 0
