extends RigidBody3D


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")
var gameData = preload("res://Resources/GameData.tres")


var muzzleFlash = preload("res://Effects/Muzzle_Flash.tscn")
var muzzleSmoke = preload("res://Effects/Muzzle_Smoke.tscn")
var smokeCartridge = preload("res://Assets/BTR/BTR_Smoke.tscn")
var smokeShield = preload("res://Effects/Smoke_Shield.tscn")
var hitDefault = preload("res://Effects/Hit_Default.tscn")


@onready var flash: OmniLight3D = $Chassis / Tower / Turret / Flash
@onready var LOS: RayCast3D = $Chassis / Tower / Turret / LOS
@onready var fire: RayCast3D = $Chassis / Tower / Turret / Fire
@onready var idleAudio: AudioStreamPlayer3D = $Audio / Idle
@onready var driveAudio: AudioStreamPlayer3D = $Audio / Drive
@onready var roadAudio: AudioStreamPlayer3D = $Audio / Road
@onready var startAudio: AudioStreamPlayer3D = $Audio / Start
@onready var endAudio: AudioStreamPlayer3D = $Audio / End

@export_group("Main")
@export var speed = 10.0
@export var turnSpeed = 5.0
var maxSteerAngle = 60.0
var steerSmoothness = 2.0

@export_group("Weapons")
@export var tower: MeshInstance3D
@export var turret: MeshInstance3D
@export var muzzle: Node3D

@export_group("Launcher")
@export var POD1: Node3D
@export var POD2: Node3D
@export var POD3: Node3D
@export var POD4: Node3D
@export var POD5: Node3D

@export_group("Tires")
@export var Tire_FL1: MeshInstance3D
@export var Tire_FL2: MeshInstance3D
@export var Tire_RL1: MeshInstance3D
@export var Tire_RL2: MeshInstance3D
@export var Tire_FR1: MeshInstance3D
@export var Tire_FR2: MeshInstance3D
@export var Tire_RR1: MeshInstance3D
@export var Tire_RR2: MeshInstance3D

@export_group("Suspension")
@export var chassis: MeshInstance3D
@export var suspensionRay = 0.65
@export var suspensionMovement = 0.3
@export var suspensionSpeed = 5.0
@export var tiltMaxAngle = 10.0
@export var tiltSpeed = 2.0

@export_group("Audio")
@export var fireSemiClose: AudioEvent
@export var fireSemiNear: AudioEvent
@export var fireAutoNear: AudioEvent
@export var fireAutoClose: AudioEvent
@export var fireFar: AudioEvent
@export var fireTail: AudioEvent
@export var smokeLaunch: AudioEvent
@export var smokeExplode: AudioEvent


enum State{Idle, Drive, Fast, Suppress, Smoke}
var currentState = State.Idle


var originalChassisHeight = 0.0
var originalTireHeight = 0.0
var steeringAngle = 0.0
var wobbleAmplitude = 0.01
var wobbleFrequency1 = 2.0
var wobbleFrequency2 = 2.5
var wobbleTime = 0.0
var wobbleOffset = 0.0


var selectedPath: Node3D
var inversePath = false
var waypoints: Array[Node3D] = []
var waypointThreshold = 2.5
var waypointIndex = 0
var pathEnding = false


var sensorTimer = 0.0
var sensorCycle = 1.0


var mixerTimer = 30.0


var fireTime = 1.0
var fireAccuracy = 1.0
var playerDistance: float
var playerVisible = false
var lastKnownLocation: Vector3
var fullAuto = false
var autoRounds = 20
var towerTarget = 0.0
var turretAligned = false


var masterVolume = 0.0
var idleVolume = 0.0
var driveVolume = 0.0
var roadVolume = 0.0
var driveStart = true
var driveEnd = true

func _ready():

    originalTireHeight = Tire_FL1.position.y
    originalChassisHeight = chassis.position.y


    await get_tree().create_timer(0.1, false).timeout;


    for waypoint in selectedPath.get_children():
        waypoints.append(waypoint)


    if inversePath:
        waypoints.reverse()


    idleAudio.play()
    driveAudio.play()
    roadAudio.play()


    currentState = State.Drive



func _physics_process(delta):
    Mixer(delta)
    Sensor(delta)
    Fire(delta)
    States(delta)
    Turret(delta)
    Tires(delta)
    Suspension(delta)
    Audio(delta)

func States(delta):

    if currentState == State.Idle || currentState == State.Suppress:
        speed = lerp(speed, 0.0, delta)
        physics_material_override.friction = move_toward(physics_material_override.friction, 1.0, delta / 2.0)

    elif currentState == State.Drive:
        speed = lerp(speed, 10.0, delta)
        physics_material_override.friction = move_toward(physics_material_override.friction, 0.0, delta * 2.0)
        Drive(delta)
        Wobble(delta)

    elif currentState == State.Fast:
        speed = lerp(speed, 20.0, delta)
        physics_material_override.friction = move_toward(physics_material_override.friction, 0.0, delta * 2.0)
        Drive(delta)
        Wobble(delta)

func Mixer(delta):

    mixerTimer -= delta


    if mixerTimer <= 0:
        var state = randi_range(1, 4)

        if state == 1:
            currentState = State.Idle
        elif state == 2:
            currentState = State.Drive
        elif state == 3:
            currentState = State.Fast
        elif state == 4 && lastKnownLocation != Vector3.ZERO:
            currentState = State.Suppress
        else:
            currentState = State.Drive


        mixerTimer = randf_range(10.0, 30.0)



func Drive(delta):

    var waypoint = waypoints[waypointIndex]
    var direction = (waypoint.global_position - global_position).normalized()


    var distance = global_position.distance_to(waypoint.global_position)


    pathEnding = (waypointIndex == waypoints.size() - 1)


    if distance < waypointThreshold:

        waypointIndex += 1

        if waypointIndex >= waypoints.size():
            print("BTR: Path ended")
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

func Tires(delta):

    var forward_velocity = linear_velocity.dot(global_transform.basis.z)
    var wheel_rotation_speed = forward_velocity


    Tire_FL1.rotation.y = steeringAngle
    Tire_FL2.rotation.y = steeringAngle
    Tire_FR1.rotation.y = steeringAngle
    Tire_FR2.rotation.y = steeringAngle


    Tire_FL1.rotation.x += wheel_rotation_speed * delta
    Tire_FL2.rotation.x += wheel_rotation_speed * delta
    Tire_RL1.rotation.x += wheel_rotation_speed * delta
    Tire_RL2.rotation.x += wheel_rotation_speed * delta
    Tire_FR1.rotation.x += wheel_rotation_speed * delta
    Tire_FR2.rotation.x += wheel_rotation_speed * delta
    Tire_RR1.rotation.x += wheel_rotation_speed * delta
    Tire_RR2.rotation.x += wheel_rotation_speed * delta

func Suspension(delta):

    var tires = [Tire_FL1, Tire_FL2, Tire_RL1, Tire_RL2, Tire_FR1, Tire_FR2, Tire_RR1, Tire_RR2]
    var space_state = get_world_3d().direct_space_state

    for tire in tires:
        var ray_origin = tire.global_position
        var ray_direction = - global_transform.basis.y.normalized()
        var ray_end = ray_origin + ray_direction * suspensionRay

        var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
        query.exclude = [self]
        var result = space_state.intersect_ray(query)

        var target_height = originalTireHeight

        if not result:
            target_height = originalTireHeight - suspensionMovement


        tire.position.y = lerp(tire.position.y, target_height, delta * suspensionSpeed)

func Wobble(delta):

    wobbleTime += delta


    var wobble_1 = sin(wobbleTime * wobbleFrequency1 * TAU)
    var wobble_2 = sin(wobbleTime * wobbleFrequency2 * TAU)
    var wobble = (wobble_1 + wobble_2) * 0.5 * wobbleAmplitude


    chassis.position.y = originalChassisHeight + wobble


    var target_tilt_deg = steeringAngle * tiltMaxAngle
    chassis.rotation.z = lerp(chassis.rotation.z, deg_to_rad(target_tilt_deg), delta * tiltSpeed)



func Turret(delta):
    if playerVisible:

        var playerDirection = (gameData.cameraPosition - tower.global_position).normalized()


        var localDirection = global_transform.basis.inverse() * playerDirection
        var targetAngleY = atan2(localDirection.x, localDirection.z)


        var angleDifference = abs(angle_difference(tower.rotation.y, targetAngleY))


        tower.rotation.y = lerp_angle(tower.rotation.y, targetAngleY, delta * 2.0)


        if angleDifference < deg_to_rad(10):
            var turretLocalDirection = tower.global_transform.basis.inverse() * playerDirection
            var targetAngleX = atan2( - turretLocalDirection.y, turretLocalDirection.z)
            turret.rotation.x = lerp_angle(turret.rotation.x, targetAngleX, delta * 2.0)
            turret.rotation.x = clamp(turret.rotation.x, deg_to_rad(-45), deg_to_rad(15))


        var directionToPlayer = (turret.global_position - gameData.cameraPosition).normalized()
        var turretForward = - turret.global_transform.basis.z.normalized()
        turretAligned = turretForward.dot(directionToPlayer) > 0.99

    else:

        var angleDifference = abs(angle_difference(tower.rotation.y, towerTarget))


        if angleDifference < deg_to_rad(10):
            towerTarget = randf_range(-45, 45)


        tower.rotation.y = lerp_angle(tower.rotation.y, towerTarget, delta / 5.0)
        turret.rotation.x = lerp_angle(turret.rotation.x, deg_to_rad(0), delta / 5.0)

func Sensor(delta):

    if gameData.isFlying:
        return


    playerDistance = global_position.distance_to(gameData.playerPosition)


    sensorTimer += delta


    if sensorTimer > sensorCycle:

        if playerDistance <= 100.0:
            var directionToPlayer = (tower.global_position - gameData.cameraPosition).normalized()
            var viewDirection = - tower.global_transform.basis.z.normalized()
            var viewRadius = viewDirection.dot(directionToPlayer)


            if viewRadius > 0.5:
                LOSCheck(gameData.cameraPosition)

            else:
                playerVisible = false

        else:
            playerVisible = false


        sensorTimer = 0.0

func LOSCheck(target: Vector3):

    LOS.target_position = Vector3(0, 0, 200)
    LOS.look_at(target, Vector3.UP, true)
    LOS.force_raycast_update()


    if LOS.is_colliding() && LOS.get_collider().is_in_group("Player"):
        playerVisible = true
        lastKnownLocation = gameData.playerPosition
    else:
        playerVisible = false

func Fire(delta):

    if playerVisible && turretAligned:

        if currentState == State.Idle || currentState == State.Drive || currentState == State.Fast:
            fireTime -= delta
            if fireTime <= 0:
                fullAuto = false
                PlayFire()
                PlayTail()
                Muzzle()
                Raycast()
                fireTime = randf_range(0.1, 0.5)


                if playerDistance > 50:
                    await get_tree().create_timer(0.1, false).timeout;
                    PlayCrack()


    if currentState == State.Suppress:
        fireTime -= delta
        if fireTime <= 0:
            fullAuto = true
            autoRounds -= 1
            PlayFire()
            PlayTail()
            Muzzle()
            Raycast()
            fireTime = 0.1


            if playerDistance > 50:
                await get_tree().create_timer(0.1, false).timeout;
                PlayCrack()


            if autoRounds <= 0:
                currentState = State.Drive
                autoRounds = randi_range(10, 30)

func Raycast():

    fire.look_at(Accuracy(), Vector3.UP, true)
    fire.force_raycast_update()


    if fire.is_colliding():

        var collider = fire.get_collider()


        if collider.is_in_group("Player"):
            collider.get_child(0).WeaponDamage(50.0, 10)

        else:
            var hitCollider = fire.get_collider()
            var hitPoint = fire.get_collision_point()
            var hitNormal = fire.get_collision_normal()
            var hitSurface = fire.get_collider().get("surface")
            Hit(hitCollider, hitPoint, hitNormal, hitSurface)


    elif playerDistance > 50:
        await get_tree().create_timer(0.2, false).timeout;
        PlayFlyby()

func Accuracy() -> Vector3:

    var fireDirection = lastKnownLocation + Vector3(0, 1.0, 0)


    var spreadMultiplier = 1.0
    if fullAuto: spreadMultiplier = 2.0


    if playerDistance < 10:
        fireDirection.x += randf_range(-0.1, 0.1) * spreadMultiplier
        fireDirection.y += randf_range(-0.1, 0.1) * spreadMultiplier

    elif playerDistance > 10 && playerDistance < 50:
        fireDirection.x += randf_range(-0.5, 0.5) * spreadMultiplier
        fireDirection.y += randf_range(-0.5, 0.5) * spreadMultiplier

    else:
        fireDirection.x += randf_range(-1.0, 1.0) * spreadMultiplier
        fireDirection.y += randf_range(-1.0, 1.0) * spreadMultiplier

    return fireDirection

func Hit(hitCollider, hitPoint, hitNormal, hitSurface):

    var decal = hitDefault.instantiate()
    hitCollider.add_child(decal)
    decal.global_transform.origin = hitPoint


    var surfaceDirUp = Vector3(0, 1, 0)
    var surfaceDirDown = Vector3(0, -1, 0)
    if hitNormal == surfaceDirUp: decal.look_at(hitPoint + hitNormal, Vector3.RIGHT)
    elif hitNormal == surfaceDirDown: decal.look_at(hitPoint + hitNormal, Vector3.RIGHT)
    else: decal.look_at(hitPoint + hitNormal, Vector3.DOWN)


    decal.global_rotation.z = randf_range(-360, 360)


    decal.PlayHit(hitSurface)

func Muzzle():

    var flashVFX = muzzleFlash.instantiate()
    muzzle.add_child(flashVFX)
    flashVFX.Emit(true, 1.0)


    var smokeVFX = muzzleSmoke.instantiate()
    muzzle.add_child(smokeVFX)
    smokeVFX.Emit(true, 4.0)


    flash.global_position = muzzle.global_position
    flash.light_energy = 2.0
    flash.omni_range = 10.0
    await get_tree().create_timer(0.1, false).timeout;
    flash.omni_range = 0.0
    flash.light_energy = 0.0



func Smoke():
    PlaySmokeLaunch()
    var centerCartridge
    var cartridges: Array
    var podIndex = 1

    for element in 5:

        var launchDirection
        var launchPosition
        var launchRotation

        if podIndex == 1:
            launchDirection = POD1.global_transform.basis.z
            launchPosition = POD1.global_position
            launchRotation = Vector3(0, global_rotation_degrees.y, 0)
        elif podIndex == 2:
            launchDirection = POD2.global_transform.basis.z
            launchPosition = POD2.global_position
            launchRotation = Vector3(0, global_rotation_degrees.y, 0)
        elif podIndex == 3:
            launchDirection = POD3.global_transform.basis.z
            launchPosition = POD3.global_position
            launchRotation = Vector3(0, global_rotation_degrees.y, 0)
        elif podIndex == 4:
            launchDirection = POD4.global_transform.basis.z
            launchPosition = POD4.global_position
            launchRotation = Vector3(0, global_rotation_degrees.y, 0)
        elif podIndex == 5:
            launchDirection = POD5.global_transform.basis.z
            launchPosition = POD5.global_position
            launchRotation = Vector3(0, global_rotation_degrees.y, 0)


        var smoke = smokeCartridge.instantiate()
        get_tree().get_root().add_child(smoke)
        cartridges.append(smoke)

        if podIndex == 3:
            centerCartridge = smoke


        smoke.position = launchPosition
        smoke.rotation_degrees = launchRotation
        smoke.linear_velocity = launchDirection * 20
        podIndex += 1

    await get_tree().create_timer(2.0).timeout;
    var shield = smokeShield.instantiate()
    get_tree().get_root().add_child(shield)
    shield.position = centerCartridge.global_position
    shield.Emit()
    PlaySmokeExplode()
    for cartridge in cartridges:
        cartridge.queue_free()



func Audio(delta):

    if currentState == State.Idle || currentState == State.Suppress:
        idleVolume = move_toward(idleVolume, 1.0, delta)
        driveVolume = move_toward(driveVolume, 0.01, delta)
        roadVolume = move_toward(roadVolume, 0.01, delta)

        if driveEnd:
            endAudio.play()
            driveStart = true
            driveEnd = false


    elif currentState == State.Drive || currentState == State.Fast:
        idleVolume = move_toward(idleVolume, 0.01, delta)
        driveVolume = move_toward(driveVolume, 1.0, delta)
        roadVolume = move_toward(roadVolume, 1.0, delta)

        if driveStart:
            startAudio.play()
            driveStart = false
            driveEnd = true


    if pathEnding: masterVolume = move_toward(masterVolume, 0.0, delta * 2.0)
    else: masterVolume = move_toward(masterVolume, 1.0, delta / 2.0)


    idleAudio.volume_db = linear_to_db(idleVolume * masterVolume)
    driveAudio.volume_db = linear_to_db(driveVolume * masterVolume)
    roadAudio.volume_db = linear_to_db(roadVolume * masterVolume)

func PlayFire():

    if fullAuto:
        var audio = audioInstance3D.instantiate()
        add_child(audio)
        audio.PlayInstance(fireAutoNear, 100, 400)

    else:
        var audio = audioInstance3D.instantiate()
        add_child(audio)
        audio.PlayInstance(fireSemiNear, 100, 400)

func PlayTail():
    var audio = audioInstance3D.instantiate()
    add_child(audio)
    audio.PlayInstance(fireTail, 50, 200)

func PlayCrack():
    var crackRoll = randi_range(0, 1)
    if crackRoll == 0: return

    var crack = audioInstance2D.instantiate()
    add_child(crack)
    crack.PlayInstance(audioLibrary.bulletCrack)

func PlayFlyby():
    var flybyRoll = randi_range(0, 1)
    if flybyRoll == 0: return

    var flyby = audioInstance2D.instantiate()
    add_child(flyby)
    flyby.PlayInstance(audioLibrary.bulletFlyby)

func PlaySmokeLaunch():
    var audio = audioInstance3D.instantiate()
    add_child(audio)
    audio.PlayInstance(smokeLaunch, 50, 200)

func PlaySmokeExplode():
    var audio = audioInstance3D.instantiate()
    add_child(audio)
    audio.PlayInstance(smokeExplode, 50, 200)
