extends RigidBody3D
class_name Grenade


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")
var grenadeExplosion = preload("res://Effects/Explosion.tscn")
var grenadeSmoke = preload("res://Effects/Grenade_Smoke.tscn")


@export var frag = false
@export var smoke = false


var handle = null


var fuseTime = 3.0
var fuseTimer = 0.0

func _ready():

    body_entered.connect(self.Collided)
    continuous_cd = true
    contact_monitor = true
    max_contacts_reported = 1

func _physics_process(delta):
    fuseTimer += delta

    if fuseTimer > fuseTime:
        Detonate()



func Detonate():

    if frag:
        var effect = grenadeExplosion.instantiate()
        get_tree().get_root().add_child(effect)
        effect.position = global_position + Vector3(0, 0.5, 0)
        effect.Explode()


    if smoke:
        var effect = grenadeSmoke.instantiate()
        get_tree().get_root().add_child(effect)
        effect.position = global_position
        effect.Emit()


    if handle: handle.queue_free()
    queue_free()

func Collided(body: Node3D):

    body_entered.disconnect(self.Collided)


    var surface = body.get("surface")
    PlayBounce(surface)



func PlayBounce(surface):

    var audio = audioInstance3D.instantiate()
    add_child(audio)


    if surface == "Grass":
        audio.PlayInstance(audioLibrary.grenadeBounceGrass, 10, 50)

    elif surface == "Dirt":
        audio.PlayInstance(audioLibrary.grenadeBounceDirt, 10, 50)

    elif surface == "Wood":
        audio.PlayInstance(audioLibrary.grenadeBounceWood, 10, 50)

    elif surface == "Metal":
        audio.PlayInstance(audioLibrary.grenadeBounceMetal, 10, 50)
    else:
        audio.PlayInstance(audioLibrary.grenadeBounceConcrete, 10, 50)
