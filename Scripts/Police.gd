extends RigidBody3D


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")
var gameData = preload("res://Resources/GameData.tres")

@export_group("Main")
@export var speed = 10.0
@export var turnSpeed = 5.0
var maxSteerAngle = 60.0
var steerSmoothness = 2.0

@export_group("Tires")
@export var Tire_FL: MeshInstance3D
@export var Tire_FR: MeshInstance3D
@export var Tire_RL: MeshInstance3D
@export var Tire_RR: MeshInstance3D

@export_group("Suspension")
@export var chassis: MeshInstance3D
@export var suspensionRay = 0.65
@export var suspensionMovement = 0.3
@export var suspensionSpeed = 5.0
@export var tiltMaxAngle = 10.0
@export var tiltSpeed = 2.0

@onready var idleAudio: AudioStreamPlayer3D = $Audio / Idle
@onready var driveAudio: AudioStreamPlayer3D = $Audio / Drive
@onready var roadAudio: AudioStreamPlayer3D = $Audio / Road
@onready var startAudio: AudioStreamPlayer3D = $Audio / Start
@onready var endAudio: AudioStreamPlayer3D = $Audio / End
@onready var doorAudio: AudioStreamPlayer3D = $Audio / Door
@onready var musicExteriorAudio: AudioStreamPlayer3D = $Audio / Music_Exterior
@onready var musicInteriorAudio: AudioStreamPlayer3D = $Audio / Music_Interior
@onready var sirenAudio: AudioStreamPlayer3D = $Audio / Siren


@onready var lights = $Lights
@onready var headlight = $Lights / Headlight
@onready var police: SpotLight3D = $Lights / Police


enum State{Idle, Drive, Boss, Stop, Spawn}
var currentState = State.Idle


var originalChassisHeight = 0.0
var originalTireHeight = 0.0
var wobbleAmplitude = 0.005
var wobbleFrequency1 = 2.0
var wobbleFrequency2 = 2.5
var steeringAngle = 0.0
var wobbleTime = 0.0
var wobbleOffset = 0.0


var selectedPath: Node3D
var inversePath = false
var waypoints: Array[Node3D] = []
var waypointThreshold = 2.5
var waypointIndex = 0
var pathEnding = false


var driveStart = true
var driveEnd = true
var stopped = false


var masterVolume = 0.0
var idleVolume = 0.0
var driveVolume = 0.0
var roadVolume = 0.0
var musicExteriorVolume = 0.0
var musicInteriorVolume = 0.0
var sirenVolume = 0.0


var AISpawner

func _ready():

    originalTireHeight = Tire_FL.position.y
    originalChassisHeight = chassis.position.y


    await get_tree().create_timer(0.1, false).timeout;


    AISpawner = get_tree().current_scene.get_node("/root/Map/AI")


    for waypoint in selectedPath.get_children():
        waypoints.append(waypoint)


    if inversePath:
        waypoints.reverse()


    idleAudio.play()
    driveAudio.play()
    roadAudio.play()
    musicExteriorAudio.play()
    musicInteriorAudio.play()


    var stateRoll = randi_range(1, 2)


    if stateRoll == 1:
        currentState = State.Drive
        DeactivateLights()

    elif stateRoll == 2:
        currentState = State.Boss
        ActivateLights()

func DeactivateLights():
    sirenAudio.stop()
    lights.hide()
    headlight.spot_range = 0.0
    headlight.light_energy = 0.0
    police.spot_range = 0.0
    police.light_energy = 0.0
    chassis.get_surface_override_material(0).set_shader_parameter("glow", false)

func ActivateLights():
    sirenAudio.play()
    lights.show()
    headlight.spot_range = 40.0
    headlight.light_energy = 20.0
    police.spot_range = 40.0
    police.light_energy = 40.0
    chassis.get_surface_override_material(0).set_shader_parameter("glow", true)



func _physics_process(delta):
    Detection()
    States(delta)
    Tires(delta)
    Suspension(delta)
    Audio(delta)

func States(delta):
    if currentState == State.Drive:
        speed = lerp(speed, 25.0, delta)
        physics_material_override.friction = move_toward(physics_material_override.friction, 0.0, delta * 2.0)
        Drive(delta)
        Wobble(delta)

    elif currentState == State.Boss:
        speed = lerp(speed, 25.0, delta)
        physics_material_override.friction = move_toward(physics_material_override.friction, 0.0, delta * 2.0)
        Drive(delta)
        Wobble(delta)
        police.rotation.y += delta * 20.0

    elif currentState == State.Stop || currentState == State.Spawn:
        speed = lerp(speed, 0.0, delta)
        physics_material_override.friction = move_toward(physics_material_override.friction, 1.0, delta / 2.0)
        police.rotation.y += delta * 20.0

func Drive(delta):

    var waypoint = waypoints[waypointIndex]
    var direction = (waypoint.global_position - global_position).normalized()


    var distance = global_position.distance_to(waypoint.global_position)


    pathEnding = (waypointIndex == waypoints.size() - 1)


    if distance < waypointThreshold:

        waypointIndex += 1

        if waypointIndex >= waypoints.size():
            currentState = State.Stop
            stopped = true
            print("Police: Path ended")
            queue_free()


    var currentForward = global_transform.basis.z
    var newRotation = currentForward.slerp(direction, delta * turnSpeed)
    var torque = currentForward.cross(newRotation).y * turnSpeed
    apply_torque_impulse(Vector3(0, torque, 0))


    var targetSteer = atan2(direction.x, direction.z) - atan2(currentForward.x, currentForward.z)
    steeringAngle = lerp_angle(steeringAngle, targetSteer, delta * steerSmoothness)
    steeringAngle = clamp(steeringAngle, - deg_to_rad(maxSteerAngle), deg_to_rad(maxSteerAngle))


    var force = global_transform.basis.z * speed
    apply_central_force(force)


    var lateralVelocity = Vector3(linear_velocity.x, 0, linear_velocity.z).dot(global_transform.basis.x)
    apply_central_force( - global_transform.basis.x * lateralVelocity * 50.0)

func Detection():
    if currentState == State.Boss:

        var distanceToCenter = global_position.distance_to(Vector3.ZERO)
        var distanceToPlayer = global_position.distance_to(gameData.playerPosition)


        if distanceToCenter < 190.0 && distanceToPlayer < 50.0 && !stopped:
            currentState = State.Stop
            sirenAudio.stop()
            stopped = true
            Spawn()

func Spawn():

    await get_tree().create_timer(5.0, false).timeout;
    currentState = State.Spawn
    doorAudio.play()

    await get_tree().create_timer(1.0, false).timeout;


    AISpawner.SpawnMinion(GetHiddenSpawn())

    await get_tree().create_timer(1.0, false).timeout;


    AISpawner.SpawnMinion(GetHiddenSpawn())

    await get_tree().create_timer(2.0, false).timeout;


    AISpawner.SpawnBoss(GetHiddenSpawn())


    await get_tree().create_timer(2.0, false).timeout;
    DeactivateLights()
    currentState = State.Drive
    doorAudio.play()

func Audio(delta):

    if currentState == State.Drive || currentState == State.Boss:
        idleVolume = move_toward(idleVolume, 0.01, delta)
        driveVolume = move_toward(driveVolume, 1.0, delta)
        roadVolume = move_toward(roadVolume, 1.0, delta)
        musicExteriorVolume = move_toward(musicExteriorVolume, 1.0, delta / 2.0)
        musicInteriorVolume = move_toward(musicInteriorVolume, 0.01, delta / 2.0)

        if driveStart:
            startAudio.play()
            driveStart = false
            driveEnd = true


    elif currentState == State.Stop:
        idleVolume = move_toward(idleVolume, 1.0, delta)
        driveVolume = move_toward(driveVolume, 0.01, delta)
        roadVolume = move_toward(roadVolume, 0.01, delta)

        if driveEnd:
            endAudio.play()
            driveStart = true
            driveEnd = false


    elif currentState == State.Spawn:
        idleVolume = move_toward(idleVolume, 1.0, delta)
        driveVolume = move_toward(driveVolume, 0.01, delta)
        roadVolume = move_toward(roadVolume, 0.01, delta)
        musicExteriorVolume = move_toward(musicExteriorVolume, 0.01, delta / 2.0)
        musicInteriorVolume = move_toward(musicInteriorVolume, 1.0, delta / 2.0)


    if pathEnding: masterVolume = move_toward(masterVolume, 0.0, delta * 2.0)
    else: masterVolume = move_toward(masterVolume, 1.0, delta / 2.0)


    idleAudio.volume_db = linear_to_db(idleVolume * masterVolume)
    driveAudio.volume_db = linear_to_db(driveVolume * masterVolume)
    roadAudio.volume_db = linear_to_db(roadVolume * masterVolume)
    musicExteriorAudio.volume_db = linear_to_db(musicExteriorVolume * masterVolume)
    musicInteriorAudio.volume_db = linear_to_db(musicInteriorVolume * masterVolume)
    sirenAudio.volume_db = linear_to_db(masterVolume)

func Tires(delta):

    var forwardVelocity = linear_velocity.dot(global_transform.basis.z)
    var wheelSpeed = forwardVelocity


    Tire_FL.rotation.y = steeringAngle
    Tire_FR.rotation.y = steeringAngle


    Tire_FL.rotation.x += wheelSpeed * delta
    Tire_FR.rotation.x += wheelSpeed * delta
    Tire_RL.rotation.x += wheelSpeed * delta
    Tire_RR.rotation.x += wheelSpeed * delta

func Suspension(delta):

    var tires = [Tire_FL, Tire_FR, Tire_RL, Tire_RR]
    var space_state = get_world_3d().direct_space_state

    for tire in tires:
        var ray_origin = tire.global_position
        var ray_direction = - global_transform.basis.y.normalized()
        var ray_end = ray_origin + ray_direction * suspensionRay

        var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
        query.exclude = [self]
        var result = space_state.intersect_ray(query)

        var targetHeight = originalTireHeight

        if !result:
            targetHeight = originalTireHeight - suspensionMovement


        tire.position.y = lerp(tire.position.y, targetHeight, delta * suspensionSpeed)

func Wobble(delta):

    wobbleTime += delta


    var wobble1 = sin(wobbleTime * wobbleFrequency1 * TAU)
    var wobble2 = sin(wobbleTime * wobbleFrequency2 * TAU)
    var wobble = (wobble1 + wobble2) * 0.5 * wobbleAmplitude


    chassis.position.y = originalChassisHeight + wobble


    var targetTilt = steeringAngle * tiltMaxAngle
    chassis.rotation.z = lerp(chassis.rotation.z, deg_to_rad(targetTilt), delta * tiltSpeed)

func GetHiddenSpawn() -> Vector3:

    var directionToPlayer = (global_position - gameData.playerPosition).normalized()
    var spawnDistance = 4.0
    var spawnPosition = global_position + (directionToPlayer * spawnDistance)
    spawnPosition += Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))


    var rayStart = spawnPosition + Vector3(0, 5.0, 0)
    var rayEnd = spawnPosition + Vector3(0, -5.0, 0)
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(rayStart, rayEnd)
    var result = space_state.intersect_ray(query)


    if result:
        spawnPosition = result.position

    else:
        spawnPosition.y = global_position.y + 0.5

    return spawnPosition
