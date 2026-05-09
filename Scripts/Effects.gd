extends Control


var gameData = preload("res://Resources/GameData.tres")


@onready var impact = $Impact
@onready var damage = $Damage
@onready var health = $Health
@onready var submerged = $Submerged
@onready var sleeping = $Sleeping


var healthMaterial = preload("res://UI/Effects/MT_Health.tres")
var healthOpacity = 0.0


var impactMaterial = preload("res://UI/Effects/MT_Impact.tres")
var impactOpacity = 0.0


var damageMaterial = preload("res://UI/Effects/MT_Damage.tres")
var damageOpacity = 0.0


var sleepingMaterial = preload("res://UI/Effects/MT_Sleeping.tres")
var sleepingOpacity = 0.0


var submergedMaterial = preload("res://UI/Effects/MT_Submerged.tres")

func _ready():
    impactMaterial.set_shader_parameter("opacity", 0.0)
    damageMaterial.set_shader_parameter("opacity", 0.0)
    healthMaterial.set_shader_parameter("opacity", 0.0)
    sleepingMaterial.set_shader_parameter("opacity", 0.0)
    impact.hide()
    damage.hide()
    health.hide()
    submerged.hide()
    sleeping.hide()

func _physics_process(delta):
    if Engine.get_physics_frames() % 2 == 0:
        ImpactEffect(delta)
        DamageEffect(delta)
        HealthEffect(delta)
        SleepingEffect(delta)
        SubmergedEffect()

func ImpactEffect(delta):
    if gameData.impact:
        impactOpacity = lerp(impactOpacity, 10.0, delta * 2)
        impactMaterial.set_shader_parameter("opacity", impactOpacity)
    else:
        impactOpacity = lerp(impactOpacity, 0.0, delta * 2)
        impactMaterial.set_shader_parameter("opacity", impactOpacity)

    if impactOpacity > 5.0:
        gameData.impact = false


    if impactOpacity > 0.01:
        impact.show()
    else:
        impact.hide()

func DamageEffect(delta):
    if gameData.damage:
        damageOpacity = lerp(damageOpacity, 1.0, delta * 2)
        damageMaterial.set_shader_parameter("opacity", damageOpacity)
    else:
        damageOpacity = lerp(damageOpacity, 0.0, delta * 2)
        damageMaterial.set_shader_parameter("opacity", damageOpacity)

    if damageOpacity > 0.5:
        gameData.damage = false


    if damageOpacity > 0.01:
        damage.show()
    else:
        damage.hide()

func SleepingEffect(delta):
    if gameData.isSleeping:
        sleepingOpacity = lerp(sleepingOpacity, 1.0, delta / 2.0)
        sleepingMaterial.set_shader_parameter("opacity", sleepingOpacity)
    else:
        sleepingOpacity = lerp(sleepingOpacity, 0.0, delta)
        sleepingMaterial.set_shader_parameter("opacity", sleepingOpacity)


    if sleepingOpacity > 0.0001:
        sleeping.show()
    else:
        sleeping.hide()

func HealthEffect(delta):
    if gameData.health < 50:
        var healthInversion = inverse_lerp(100, 0, gameData.health)
        healthOpacity = lerp(healthOpacity, healthInversion, delta)
        healthMaterial.set_shader_parameter("opacity", healthOpacity)
    else:
        healthOpacity = lerp(healthOpacity, 0.0, delta)
        healthMaterial.set_shader_parameter("opacity", healthOpacity)


    if healthOpacity > 0.01:
        health.show()
    else:
        health.hide()

func SubmergedEffect():
    if gameData.isSubmerged:
        submerged.show()
    else:
        submerged.hide()
