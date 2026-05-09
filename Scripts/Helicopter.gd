extends Node3D


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")
var gameData = preload("res://Resources/GameData.tres")


@onready var audio: AudioStreamPlayer3D = $Audio
@onready var searchlight: Node3D = $Searchlight
@onready var spot: SpotLight3D = $Searchlight / Spot
@onready var omni: OmniLight3D = $Searchlight / Omni


@export_group("Main")
@export var parts: Node3D
@export var mainRotor: Node3D
@export var tailRotor: Node3D

@export_group("Rockets")
@export var podL: Node3D
@export var podR: Node3D
@export var rocket: PackedScene
@export var rocketLaunch: AudioEvent

@export_group("Searchlight")
@export var searchlightSpeed = 0.5
@export_range(0, 180, 1) var minAngleX = 45.0
@export_range(0, 180, 1) var maxAngleX = 90.0
@export_range(-180, 180, 1) var minAngleY = -90.0
@export_range(-180, 180, 1) var maxAngleY = 90.0


var flySpeed = 75.0
var flyHeight = 200.0
var rotationSpeed = 0.4
var distanceToWaypoint = 0.0
var waypoint: Vector3
var rotationTime = 10.0
var rotationTimer = 0.0
var isRotating = false
var isPulling = false


var searchlightTarget: Vector3
var searchlightTimer = 0.0
var spotted = false
var originalPosition: Vector3


var sensorTimer = 0.0
var sensorCycle = 1.0


var attackPhase = 1
var attackTimer = 0.0


enum State{Idle, Flyby, Patrol, Attack}
var currentState = State.Idle

func _ready():

    var randomPosition = randf_range(-1000, 1000)
    var randomDirection = randi_range(0, 1)


    if randomDirection == 0:
        global_position = Vector3(1000, flyHeight, randomPosition)
    else:
        global_position = Vector3(-1000, flyHeight, randomPosition)


    look_at(Vector3(0, flyHeight, 0), Vector3.UP, true)


    var stateRoll = randi_range(1, 2)
    stateRoll = 2

    if stateRoll == 1:
        DeactivateSearchlight()
        currentState = State.Flyby
    elif stateRoll == 2:
        SetWaypoint()
        SetSearchlightTarget()
        DeactivateSearchlight()
        currentState = State.Patrol
        isRotating = true



func _physics_process(delta):
    RotorBlades(delta)
    DistanceClear()

    if currentState == State.Flyby:
        Flyby(delta)
    elif currentState == State.Patrol:
        Patrol(delta)
        Sensor(delta)
        Searchlight(delta)
    elif currentState == State.Attack:
        Attack(delta)



func RotorBlades(delta):
    mainRotor.rotation.y += delta * 20.0
    tailRotor.rotation.x += delta * 20.0

func Flyby(delta):
    flySpeed = lerp(flySpeed, 75.0, delta)
    parts.rotation_degrees.x = lerp(parts.rotation_degrees.x, 10.0, delta)
    global_position += transform.basis.z * delta * flySpeed

func Patrol(delta):

    if !isRotating:

        if spotted:

            flySpeed = lerp(flySpeed, 0.0, delta)
            parts.rotation_degrees.x = lerp(parts.rotation_degrees.x, 0.0, delta)

        else:

            global_position = global_position.move_toward(waypoint, delta * flySpeed)
            parts.rotation_degrees.x = lerp(parts.rotation_degrees.x, 10.0, delta)
            distanceToWaypoint = global_position.distance_to(waypoint)


            if distanceToWaypoint < 50.0:
                flySpeed = lerp(flySpeed, 5.0, delta)
            else:
                flySpeed = lerp(flySpeed, 40.0, delta)


            if distanceToWaypoint < 1.0:

                var playerDistance2D = Vector2(global_position.x, global_position.z).distance_to(Vector2(gameData.playerPosition.x, gameData.playerPosition.z))

                if playerDistance2D > 100.0 && playerDistance2D < 400.0 && randi_range(1, 100) < 10:
                    currentState = State.Attack

                else:
                    isRotating = true
                    SetWaypoint()


    if isRotating:

        flySpeed = lerp(flySpeed, 0.0, delta)
        parts.rotation_degrees.x = lerp(parts.rotation_degrees.x, 0.0, delta)


        var waypointDirection = Vector3(waypoint.x, 0.0, waypoint.z) - global_position
        rotation.y = lerp_angle(rotation.y, atan2(waypointDirection.x, waypointDirection.z), delta * rotationSpeed)
        rotationTimer += delta


        if rotationTimer >= rotationTime:
            rotationTimer = 0.0
            isRotating = false


            if randi_range(1, 100) < 10:
                currentState = State.Flyby
                print("Helicopter: Patrol ended")

func Attack(delta):

    parts.rotation_degrees.x = lerp(parts.rotation_degrees.x, 0.0, delta)


    if attackPhase > 1:
        attackTimer += delta
        flySpeed = lerp(flySpeed, 50.0, delta)
        global_position += transform.basis.z * delta * flySpeed

    match attackPhase:
        1:
            var directionToPlayer = (global_position - gameData.playerPosition).normalized()
            var targetBasis = Basis.looking_at(directionToPlayer, Vector3.UP)
            transform.basis = transform.basis.slerp(targetBasis, delta * 2.0)


            if transform.basis.z.dot( - directionToPlayer) > 0.999:
                look_at(gameData.playerPosition, Vector3.UP, true)
                attackTimer = 0.0
                attackPhase = 2

        2:
            if attackTimer > 2.0:
                FireRockets()
                attackPhase = 3

        3:
            if attackTimer > 3.0:
                attackPhase = 4

        4:
            rotation_degrees.x = lerp(rotation_degrees.x, -20.0, delta)

func SetWaypoint():
    waypoint = Vector3(randf_range(-500, 500), flyHeight, randf_range(-500, 500))

func DistanceClear():

    var distanceToCenter = global_position.distance_to(Vector3(0, flyHeight, 0))


    if distanceToCenter > 2000:
        print("Helicopter: Distance cleared")
        queue_free()



func FireRockets():
    var podIndex = 1


    for element in 8:

        var instance = rocket.instantiate()
        get_tree().get_root().add_child(instance)


        if podIndex == 1:
            instance.global_transform = podL.global_transform
            podIndex = 2
        elif podIndex == 2:
            instance.global_transform = podR.global_transform
            podIndex = 1


        PlayRocket()
        await get_tree().create_timer(0.2).timeout;



func Searchlight(delta):

    if gameData.TOD == 4:

        ActivateSearchlight()


        searchlightTimer += delta


        if searchlightTimer > 5.0:
            SetSearchlightTarget()
            searchlightTimer = 0.0


        searchlight.rotation_degrees = searchlight.rotation_degrees.lerp(searchlightTarget, searchlightSpeed * delta)

    else:
        DeactivateSearchlight()

func ActivateSearchlight():
    searchlight.show()
    spot.spot_range = 400.0
    omni.omni_range = 5.0

func DeactivateSearchlight():
    searchlight.hide()
    spot.spot_range = 0.0
    omni.omni_range = 0.0

func SetSearchlightTarget():
    var targetRotationX = randf_range(minAngleX, maxAngleX)
    var targetRotationY = randf_range(minAngleY, maxAngleY)
    searchlightTarget = Vector3(targetRotationX, targetRotationY, 0)



func Sensor(delta):

    sensorTimer += delta


    if sensorTimer > sensorCycle:

        var playerDistance = global_position.distance_to(gameData.playerPosition)


        if playerDistance < 300.0:
            var directionToPlayer = (searchlight.global_position - gameData.cameraPosition).normalized()
            var viewDirection = - searchlight.global_transform.basis.z.normalized()
            var viewRadius = viewDirection.dot(directionToPlayer)


            if viewRadius > 0.99 && !spotted:
                Spotted()


        sensorTimer = 0.0

func Spotted():

    spotted = true


    var AISpawner = get_tree().current_scene.get_node("/root/Map/AI")
    AISpawner.CreateHotspot(gameData.playerPosition, true)


    Loader.Message("You have been spotted!", Color.RED)


    await get_tree().create_timer(10.0, false).timeout;
    spotted = false



func PlayRocket():
    var rocketAudio = audioInstance3D.instantiate()
    add_child(rocketAudio)
    rocketAudio.PlayInstance(rocketLaunch, 100, 1000)
