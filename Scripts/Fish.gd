extends Node3D
class_name Fish

@export var slotData: SlotData
@export var hookOffset = 0.0
@onready var sensor: Area3D = $Sensor

var waypoint: Vector3
var sensorTimer = 0.0
var sensorCycle = 1.0
var active = false
var attracted = false
var hooked = false
var lure

func _ready():
    active = false
    GetRandomWaypoint()

func _physics_process(delta):
    if active:
        if lure && lure.is_inside_tree():
            if attracted && !hooked:
                Attract(delta)

        elif !hooked:
            Swim(delta)
            Sensor(delta)

func Sensor(delta):
    sensorTimer += delta


    if sensorTimer > sensorCycle:
        var overlaps = sensor.get_overlapping_areas()
        if overlaps.size() > 0:
            for overlap in overlaps:
                if overlap is Area:
                    if overlap.type == "Lure":
                        if !overlap.owner.hooked:
                            lure = overlap.owner
                            lure.hooked = true
                            attracted = true

func Attract(delta):

    var directionToLure = (lure.global_position - global_position).normalized()
    var distanceToLure = global_position.distance_to(lure.global_position)


    if lure.global_position.y > -2.0:
        attracted = false
        lure.hooked = false
        lure = null


    elif distanceToLure > 0.1:
        var targetTransform = global_transform.looking_at(lure.global_position, Vector3.UP, true).orthonormalized()
        global_transform.basis = global_transform.basis.slerp(targetTransform.basis, delta * 2.0).orthonormalized()
        global_position += directionToLure * delta * 2.0


    elif !hooked:
        print("Fish: Hooked")
        reparent(lure, true)
        lure.owner.PlayHooked()
        global_transform = lure.global_transform
        position += transform.basis.z * hookOffset
        hooked = true

func Swim(delta):

    var directionToWaypoint = (waypoint - global_position).normalized()
    var distanceToWaypoint = global_position.distance_to(waypoint)


    if distanceToWaypoint > 0.1:
        var targetTransform = global_transform.looking_at(waypoint, Vector3.UP, true).orthonormalized()
        global_transform.basis = global_transform.basis.slerp(targetTransform.basis, delta * 2.0).orthonormalized()
        global_position += directionToWaypoint * delta / 2.0


    else:

        GetRandomWaypoint()

func GetRandomWaypoint():
    var pool = get_parent()
    var bounds = pool.get_aabb()
    var minPos = bounds.position + pool.global_transform.origin
    var maxPos = minPos + bounds.size
    waypoint = Vector3(randf_range(minPos.x, maxPos.x), randf_range(minPos.y, maxPos.y), randf_range(minPos.z, maxPos.z))
