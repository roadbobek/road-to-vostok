extends Control

@onready var info: Label = $Panel / Margin / Info
var fade = false
var opacity = 0.0

func _ready() -> void :

    fade = true
    await get_tree().create_timer(5.0, false).timeout;

    fade = false

    await get_tree().create_timer(5.0, false).timeout;
    queue_free()

func _physics_process(delta: float) -> void :
    if fade: opacity = lerp(opacity, 255.0, delta * 2.0)
    else: opacity = lerp(opacity, 0.0, delta * 2.0)
    modulate = Color8(255, 255, 255, int(opacity))

func Text(message: String, color: Color):
    info.modulate = color
    info.text = message
    print("Message: " + message)
