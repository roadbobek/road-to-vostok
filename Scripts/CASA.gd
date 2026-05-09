extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")
const parachuteMaterial = preload("res://Assets/Airdrop/Files/MT_Parachute.tres")


@onready var leftPropeller = $Propeller_L
@onready var rightPropeller = $Propeller_R
@onready var audio = $Audio
@onready var airdrop = $Airdrop
var ray


var passed = false
var dropped = false
var released = false
var collided = false


var audioThreshold = 1800.0
var dropThreshold = 250.0
var flyHeight = 250.0
var flySpeed = 100.0
var parachuteProgress = -1.0
var dropTimer = 0.0

func _ready():

    var randomPosition = randf_range(-2000, 2000)
    var randomDirection = randi_range(0, 1)


    if randomDirection == 0:
        global_position = Vector3(2000, flyHeight, randomPosition)
    else:
        global_position = Vector3(-2000, flyHeight, randomPosition)


    look_at(Vector3(0, flyHeight, 0), Vector3.UP, true)


    InitializeDrop()

func InitializeDrop():
    dropThreshold = randf_range(0, 300)
    ray = airdrop.get_node("Ray")
    airdrop.sleeping = true
    airdrop.can_sleep = true
    airdrop.freeze = true
    airdrop.hide()


    airdrop.body_entered.connect(self.Collided)
    airdrop.continuous_cd = true
    airdrop.contact_monitor = true
    airdrop.max_contacts_reported = 1

func _physics_process(delta):

    leftPropeller.rotation.z += delta * 20.0
    rightPropeller.rotation.z += delta * 20.0
    global_position += transform.basis.z * delta * flySpeed

    Sequence(delta)
    Parachute(delta)
    DistanceClear()

func Sequence(delta):

    var distanceToCenter = global_position.distance_to(Vector3(0, flyHeight, 0))


    if distanceToCenter < audioThreshold && !passed:
        audio.play()
        passed = true


    if distanceToCenter < dropThreshold && !dropped:

        var currentMap = get_tree().current_scene.get_node("/root/Map")
        airdrop.reparent(currentMap)
        airdrop.show()
        airdrop.linear_velocity = transform.basis.z * flySpeed
        airdrop.sleeping = false
        airdrop.can_sleep = false
        airdrop.freeze = false
        dropped = true


    if dropped && !released:
        dropTimer += delta


    if (ray.is_colliding() && dropped && !released) || dropTimer > 30.0:
        airdrop.gravity_scale = 2.0
        airdrop.angular_velocity = Vector3(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
        released = true
        PlayRelease()

func Parachute(delta):

    if dropped && !released:
        parachuteProgress = lerp(parachuteProgress, 0.0, delta)

    elif released:
        parachuteProgress = lerp(parachuteProgress, 2.0, delta * 2.0)


    parachuteMaterial.set_shader_parameter("progress", parachuteProgress)

func Collided(body: Node3D):

    PlayBounce()


    var AISpawner = get_tree().current_scene.get_node("/root/Map/AI")
    AISpawner.CreateHotspot(airdrop.global_position, false)


    airdrop.body_entered.disconnect(self.Collided)
    airdrop.continuous_cd = false
    collided = true
    print("Airdrop Collided: " + body.name)

func DistanceClear():

    var distanceToCenter = global_position.distance_to(Vector3(0, flyHeight, 0))


    if distanceToCenter > 1000.0 && collided && parachuteProgress > 1.5:
        print("CASA: Distance cleared")
        queue_free()


    if distanceToCenter > 10000.0:
        print("CASA: Distance cleared (Fail safe)")
        queue_free()



func PlayRelease():
    var releaseAudio = audioInstance3D.instantiate()
    airdrop.add_child(releaseAudio)
    releaseAudio.PlayInstance(audioLibrary.airdropRelease, 20, 100)

func PlayBounce():
    var bounceAudio = audioInstance3D.instantiate()
    airdrop.add_child(bounceAudio)
    bounceAudio.PlayInstance(audioLibrary.airdropBounce, 20, 100)
