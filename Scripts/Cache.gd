extends Node3D


@onready var spot = $Lights / Spot
@onready var omni = $Lights / Omni
@onready var flashlight = $Lights / Flashlight
@onready var particles = $Particles
@onready var raycast = $Raycaster / Raycast
var decals: Array[Node3D]


var lightTimer = 0.0
var lightCycle = 0.2


var raycastTimer = 0.0
var raycastCycle = 0.2


var hitDefault = preload("res://Effects/Hit_Default.tscn")
var hitBlood = preload("res://Effects/Hit_Blood.tscn")
var hitKnife = preload("res://Effects/Hit_Knife.tscn")

func _ready():

    for particle in particles.get_children():
        particle.one_shot = false
        particle.emitting = true;

func _physics_process(delta):

    rotation.y += delta

    lightTimer += delta
    raycastTimer += delta


    if lightTimer > lightCycle:
        spot.visible = !spot.visible
        omni.visible = !omni.visible
        flashlight.visible = !flashlight.visible
        lightTimer = 0.0


    if raycastTimer > raycastCycle:

        raycast.rotation_degrees.x = randf_range(-90, 90)

        if raycast.is_colliding():
            var hitCollider = raycast.get_collider()
            var hitPoint = raycast.get_collision_point()
            var bulletDecal = hitDefault.instantiate()
            var bloodDecal = hitBlood.instantiate()
            var knifeDecal = hitKnife.instantiate()
            decals.append(bulletDecal)
            decals.append(bloodDecal)
            decals.append(knifeDecal)
            hitCollider.add_child(bulletDecal)
            hitCollider.add_child(bloodDecal)
            hitCollider.add_child(knifeDecal)
            bulletDecal.global_position = hitPoint
            bloodDecal.global_position = hitPoint
            knifeDecal.global_position = hitPoint
            bulletDecal.Emit()
            bloodDecal.Emit()
        raycastTimer = 0.0

func HideDecals():

    if decals.size() != 0:

        for decal in decals:
            if is_instance_valid(decal):
                decal.hide()
