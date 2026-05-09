extends OmniLight3D

@export var maxEnergy = 1.0
@export var minEnergy = 1.0
@export var frequency = 0.1
@export var multiplier = 1.0

var flickerTimer = 0.0
var targetEnergy = 0.0
var flicker = false

func _process(delta):

    if !flicker: return


    flickerTimer += delta

    if flickerTimer > frequency:
        targetEnergy = randf_range(minEnergy, maxEnergy)
        flickerTimer = 0.0

    light_energy = lerpf(light_energy, targetEnergy * multiplier, delta * 4.0)
