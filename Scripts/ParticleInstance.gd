extends GPUParticles3D

@export var duration = 1.0
@export var fading = false
var fadeTimer = 0.0

@export_group("Flash")
@export var flash: OmniLight3D
@export var flashTime = 0.1
@export var flashRange = 10.0
@export var flashEnergy = 1.0

func _physics_process(delta):
    if fading:
        fadeTimer += delta
        if fadeTimer > duration / 1.5: emitting = false

func Emit(quad: bool, size: float):

    if quad: draw_pass_1.size = Vector2(size, size)


    emitting = true;
    await get_tree().create_timer(duration, false).timeout;
    queue_free();

func Flash():
    if flash:
        flash.omni_range = flashRange
        flash.light_energy = flashEnergy

        await get_tree().create_timer(flashTime, false).timeout;
        flash.omni_range = 0.0

func Cache():
    one_shot = false
    emitting = true;
