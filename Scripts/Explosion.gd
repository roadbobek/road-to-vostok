extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")


@onready var particles = $Particles
@onready var light = $Light
@onready var area: Area3D = $Area
@onready var detector: Area3D = $Detector
@onready var alert: Area3D = $Alert
@onready var LOS = $LOS


var size = 10.0
var indoor = false

func Explode():

    await get_tree().create_timer(0.1, false).timeout


    particles.draw_pass_1.size = Vector2(size, size)


    Emit()
    Light()


    CheckIndoor()
    CheckOverlap()
    CheckAlert()
    PlayExplosion()


    await get_tree().create_timer(1.0, false).timeout
    queue_free()



func Emit():
    particles = get_child(0)
    particles.one_shot = true
    particles.emitting = true

func Light():
    light.omni_range = 10
    light.light_energy = 20
    await get_tree().create_timer(0.1, false).timeout
    light.omni_range = 0.0



func CheckIndoor():

    var areas = detector.get_overlapping_areas()


    if areas.size() > 0:
        for target in areas:

            if target is Area && target.type == "Indoor":
                indoor = true

func CheckOverlap():

    var bodies = area.get_overlapping_bodies()


    if bodies.size() > 0:

        for target in bodies:
            CheckLOS(target)

func CheckLOS(target):

    LOS.look_at(target.head.global_position, Vector3.UP, true)
    LOS.force_raycast_update()


    if LOS.is_colliding():

        if LOS.get_collider().is_in_group("AI"):
            target.ExplosionDamage(LOS.global_basis.z)

        if LOS.get_collider().is_in_group("Player"):
            target.get_child(0).ExplosionDamage()

func CheckAlert():

    var bodies = area.get_overlapping_bodies()


    if bodies.size() > 0:

        for target in bodies:

            if target.is_in_group("AI"):
                target.lastKnownLocation = global_position
                target.Decision()



func PlayExplosion():

    var audio = audioInstance3D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.position = global_position


    var distance = global_position.distance_to(gameData.playerPosition)


    if distance < 10:
        if indoor:
            PlayTinnitus()
            audio.PlayInstance(audioLibrary.grenadeExplosionIndoorClose, 50, 400)
        else:
            PlayTinnitus()
            audio.PlayInstance(audioLibrary.grenadeExplosionOutdoorClose, 50, 400)

    elif distance < 50:
        if indoor:
            audio.PlayInstance(audioLibrary.grenadeExplosionIndoorNear, 50, 400)
        else:
            audio.PlayInstance(audioLibrary.grenadeExplosionOutdoorNear, 50, 400)

    else:
        if indoor:
            audio.PlayInstance(audioLibrary.grenadeExplosionIndoorFar, 50, 200)
        else:
            audio.PlayInstance(audioLibrary.grenadeExplosionOutdoorFar, 50, 200)

func PlayTinnitus():

    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.grenadeExplosionTinnitus)
