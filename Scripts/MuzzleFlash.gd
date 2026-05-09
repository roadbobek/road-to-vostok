extends OmniLight3D
class_name Flash

var flash = false
var flashTimer = 0.0
const flashDuration = 0.05

func _ready():
    Reset()

func _physics_process(delta: float):
    if flash:
        flashTimer += delta
        if flashTimer > flashDuration:
            Reset()

func Activate():
    light_energy = 1.0
    omni_range = 5.0
    flash = true

func Reset():
    omni_range = 0.0
    light_energy = 0.0
    flashTimer = 0.0
    flash = false
