extends CharacterBody3D


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")
var gameData = preload("res://Resources/GameData.tres")


var flashVFX = preload("res://Effects/Muzzle_Flash.tscn")
var smokeVFX = preload("res://Effects/Muzzle_Smoke.tscn")
var hitDefault = preload("res://Effects/Hit_Default.tscn")

@export_group("References")
@export var boss = false
@export var spineData: SpineData
@export var eyes: BoneAttachment3D
@export var head: PhysicalBone3D
@export var weapons: Node3D
@export var backpacks: Node3D
@export var skeleton: Skeleton3D
@export var mesh: MeshInstance3D
@export var chest: PhysicalBone3D
@export var animator: AnimationTree
@export var collision: CollisionShape3D
@export var container: Node3D
@export var flash: Flash
@export var clothing: Array[Material]

@export_group("Equipment")
@export var allowClothing = false
@export var allowBackpacks = false

@export_group("Voices")
@export var idleVoices: AudioEvent
@export var combatVoices: AudioEvent
@export var damageVoices: AudioEvent
@export var deathVoices: AudioEvent


@onready var agent: NavigationAgent3D = $Agent
@onready var detector = $Detector
@onready var LOS = $Raycasts / LOS
@onready var fire = $Raycasts / Fire
@onready var below = $Raycasts / Below
@onready var forward = $Raycasts / Forward
@onready var poles = $Poles
@onready var N1 = $Poles / AI_Pole_N1
@onready var N2 = $Poles / AI_Pole_N2
@onready var S1 = $Poles / AI_Pole_S1
@onready var S2 = $Poles / AI_Pole_S2
@onready var gizmo = $Gizmo


enum State{Idle, Wander, Guard, Patrol, Hide, Ambush, Cover, Defend, Shift, Combat, Hunt, Attack, Vantage, Return}
var currentState = State.Idle


var AISpawner
var health = 100
var pause: bool
var dead = false


var speed = 0.0
var turnSpeed = 0.0
var movementSpeed = 0.0
var movementRotation = 0.0
var movementVelocity = 0.0
var lerpToPoint = false


var patrolArea: Node3D
var currentPoint: Node3D
var previousPoint: Node3D
var nearbyPoints: Array


var weapon: Node3D
var backpack: Node3D
var secondary: Node3D
var weaponData: WeaponData
var muzzle: Node3D


var LKL: Vector3
var LKLSpeed = 2.0
var lastKnownLocation: Vector3
var playerVisible = false
var playerPosition: Vector3
var playerDistance3D = 0.0
var playerDistance2D = 0.0
var fireVector = 0.0
var lookVector = 0.0
var headBone = 14


var nearbyTimer = 0.0
var nearbyCycle = 5.0


var sensorActive = false
var sensorTimer = 0.0
var sensorCycle = 0.1


var navigationMap
var map
var world


var fireTime = 1.0
var fireAccuracy = 1.0
var selectorTime = 1.0
var selectorRoll = 0
var fullAuto = false


var voiceTimer = 0.0
var voiceCycle = 30.0
var activeVoice = null


var guardTimer: float
var guardCycle: float
var ambushTimer: float
var ambushCycle: float
var defendTimer: float
var defendCycle: float
var combatTimer: float
var combatCycle: float
var shiftTimer: float
var shiftCycle: float
var shiftCount = 4
var huntTimer: float
var huntCycle: float
var attackTimer: float
var attackCycle: float
var attackReturn = false
var returnPosition: Vector3


var interactionTarget
var interactionTime = 0.2
var interactionTimer = 0.0


var fireDetected = false
var fireDetectionTimer = 0.0
var fireDetectionTime = 5.0
var extraVisibility = 0.0


var spineWeight = 0.0
var spineX = 0.0
var spineY = 0.0
var spineZ = 0.0
var aimSpeed = 1.0
var spineTarget: Vector3


var impact = false
var impulseTime = 0.1
var impulseTimer = 0.0
var recoveryTime = 1.0
var recoveryTimer = 0.0
var impulseTarget: Vector3


var strafeDirection: float
var targetStrafe: float
var north = false
var south = false


var north1 = false
var north2 = false
var south1 = false
var south2 = false
var poleTimer: float
var poleCycle = 0.1


var animationCycle = 1.0 / 60.0
var animationTimer = 0.0


var pathTarget: Vector3
var pathTimer = 0.0
var pathCycle = 0.1



func _ready():
    call_deferred("Initialize")

func Initialize():

    await get_tree().physics_frame


    navigationMap = get_world_3d().get_navigation_map()
    map = get_tree().current_scene.get_node("/root/Map")
    AISpawner = get_tree().current_scene.get_node("/root/Map/AI")


    if boss: health = 300.0
    else: health = 100.0


    DeactivateEquipment()
    DeactivateContainer()


    SelectWeapon()
    if allowBackpacks: SelectBackpack()
    if allowClothing: SelectClothing()


    HideGizmos()


    await get_tree().create_timer(10.0, false).timeout;


    voiceCycle = randf_range(10.0, 60.0)


    sensorActive = true



func _physics_process(delta):

    if pause || dead:
        return


    if sensorActive && !gameData.isDead && !gameData.isFlying && !gameData.isCaching:
        Sensor(delta)
        Parameters(delta)
        FireDetection(delta)


    NearbyPoints(delta)
    Voices(delta)
    Interactor(delta)
    States(delta)
    Movement(delta)
    Rotation(delta)
    Poles()


    Animate(delta)



func ActivateWanderer():
    Activate()
    await get_tree().create_timer(10.0, false).timeout;
    ChangeState("Wander")

func ActivateHider():
    Activate()
    await get_tree().create_timer(10.0, false).timeout;
    ChangeState("Ambush")

func ActivateGuard():
    Activate()
    await get_tree().create_timer(10.0, false).timeout;
    ChangeState("Guard")

func ActivateMinion():
    Activate()
    await get_tree().create_timer(1.0, false).timeout;


    nearbyPoints.clear()

    var points = detector.get_overlapping_areas()

    if points.size() > 0:
        for point in points:
            nearbyPoints.append(point.owner)


    ChangeState("Attack")


    await get_tree().create_timer(randi_range(1, 4), false).timeout;
    if !dead: PlayCombat()

func ActivateBoss():
    Activate()
    await get_tree().create_timer(1.0, false).timeout;


    nearbyPoints.clear()

    var points = detector.get_overlapping_areas()

    if points.size() > 0:
        for point in points:
            nearbyPoints.append(point.owner)


    ChangeState("Attack")


    await get_tree().create_timer(randi_range(1, 4), false).timeout;
    if !dead: PlayCombat()

func Activate():

    show()


    pause = false


    animator.active = true
    skeleton.show_rest_only = false


    detector.monitoring = true
    LOS.enabled = true
    fire.enabled = true
    below.enabled = true
    forward.enabled = true


    process_mode = ProcessMode.PROCESS_MODE_INHERIT
    skeleton.process_mode = ProcessMode.PROCESS_MODE_INHERIT

func Pause():

    if !dead:
        hide()


    pause = true


    detector.monitoring = false
    LOS.enabled = false
    fire.enabled = false
    below.enabled = false
    forward.enabled = false


    animator.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
    skeleton.modifier_callback_mode_process = Skeleton3D.MODIFIER_CALLBACK_MODE_PROCESS_MANUAL


    process_mode = ProcessMode.PROCESS_MODE_DISABLED
    skeleton.process_mode = ProcessMode.PROCESS_MODE_WHEN_PAUSED

func Animate(delta):

    if playerDistance3D > 200.0: animationCycle = 1.0 / 5.0
    elif playerDistance3D > 100.0: animationCycle = 1.0 / 15.0
    elif playerDistance3D > 50.0: animationCycle = 1.0 / 30.0
    else: animationCycle = 1.0 / 60.0


    animationTimer += delta


    if animationTimer >= animationCycle:
        var animDelta = animationTimer
        if animator && animator.active:
            Spine(animDelta)
            Aim(animDelta)
            animator.advance(animDelta)
            skeleton.advance(animDelta)


        animationTimer = 0.0



func SelectWeapon():

    if weapons.get_child_count() != 0:


        weapon = weapons.get_child(randi_range(0, weapons.get_child_count() - 1))
        weaponData = weapon.slotData.itemData
        weapon.show()


        for child in weapons.get_children():
            if child != weapon:
                child.queue_free()


        muzzle = weapon.get_node("Muzzle")


        var LOD0: MeshInstance3D = weapon.get_node_or_null("LOD0")
        var LOD1: MeshInstance3D = weapon.get_node_or_null("LOD1")
        if LOD0 && LOD1:
            LOD0.visibility_range_end = 10.0
            LOD1.visibility_range_begin = 9.0
            LOD1.visibility_range_end = 200.0
        else:
            print("AI: Weapon visibility failed")


        var newSlotData = SlotData.new()
        newSlotData.itemData = weapon.slotData.itemData
        newSlotData.condition = randi_range(5, 50)
        newSlotData.amount = randi_range(1, newSlotData.itemData.magazineSize)
        newSlotData.chamber = true
        weapon.slotData = newSlotData


        if newSlotData.itemData.weaponType == "Pistol":
            animator["parameters/conditions/Pistol"] = true
            animator["parameters/conditions/Rifle"] = false
        else:
            animator["parameters/conditions/Pistol"] = false
            animator["parameters/conditions/Rifle"] = true


        if weaponData.weaponAction != "Manual":

            if weaponData.compatible.size() != 0:

                if weaponData.compatible[0].subtype == "Magazine":

                    var magazine = weapon.get_node_or_null("Attachments").get_node_or_null(weaponData.compatible[0].file)
                    var magazineLOD0: MeshInstance3D = magazine.get_node_or_null("LOD0")
                    var magazineLOD1: MeshInstance3D = magazine.get_node_or_null("LOD1")


                    if magazine && magazineLOD0 && magazineLOD1:
                        magazine.show()
                        magazineLOD0.visibility_range_end = 10.0
                        magazineLOD1.visibility_range_begin = 9.0
                        magazineLOD1.visibility_range_end = 200.0
                    else:
                        print("AI: Magazine visibility failed")


                    weapon.slotData.nested.append(weaponData.compatible[0])

func SelectBackpack():

    if backpacks.get_child_count() != 0:


        var backpackRoll = randi_range(0, 100)


        if backpackRoll < 10:

            backpack = backpacks.get_child(randi_range(0, backpacks.get_child_count() - 1))


            for child in backpacks.get_children():
                if child != backpack:
                    child.queue_free()


            var backpackMesh: MeshInstance3D = backpack.get_node_or_null("Mesh")

            if backpack && backpackMesh:
                backpack.show()
                backpackMesh.visibility_range_end = 400.0
            else:
                print("AI: Backpack visibility failed")


            var chestCollider: CollisionShape3D = chest.get_child(0)
            chestCollider.shape.size.z = 0.4
            chestCollider.position.z -= 0.05


        else:
            for child in backpacks.get_children():
                child.queue_free()

func SelectClothing():

    if clothing.size() != 0:

        var randomClothing = randi_range(0, clothing.size() - 1)

        var clothingMaterial = clothing[randomClothing]

        mesh.set_surface_override_material(0, clothingMaterial)

func DeactivateEquipment():

    for child in weapons.get_children():
        child.process_mode = Node.PROCESS_MODE_DISABLED
        child.collision.disabled = true
        child.hide()


    for child in backpacks.get_children():
        child.process_mode = Node.PROCESS_MODE_DISABLED
        child.collision.disabled = true
        child.hide()



func NearbyPoints(delta):
    nearbyTimer += delta


    if nearbyTimer > nearbyCycle:

        nearbyPoints.clear()


        var points = detector.get_overlapping_areas()


        if points.size() > 0:
            for point in points:
                nearbyPoints.append(point.owner)


        nearbyTimer = 0.0

func Parameters(delta):

    LKL = lerp(LKL, lastKnownLocation, delta * LKLSpeed)
    playerPosition = gameData.playerPosition
    playerDistance3D = global_position.distance_to(playerPosition)
    playerDistance2D = Vector2(global_position.x, global_position.z).distance_to(Vector2(playerPosition.x, playerPosition.z))
    fireVector = (global_position - playerPosition).normalized().dot(gameData.playerVector)


    if playerDistance3D < 10 && playerVisible:
        sensorCycle = 0.05
        LKLSpeed = 4.0

    elif playerDistance3D > 10 && playerDistance3D < 50:
        sensorCycle = 0.1
        LKLSpeed = 2.0

    elif playerDistance3D > 50:
        sensorCycle = 0.5
        LKLSpeed = 1.0

func Sensor(delta):

    sensorTimer += delta


    if sensorTimer > sensorCycle:

        if playerDistance3D <= 200.0:
            var directionToPlayer = (eyes.global_position - gameData.cameraPosition).normalized()
            var viewDirection = - eyes.global_transform.basis.z.normalized()
            var viewRadius = viewDirection.dot(directionToPlayer)


            if viewRadius > 0.5:
                LOSCheck(gameData.cameraPosition)

            else:
                playerVisible = false


        else:
            playerVisible = false


        if !playerVisible:
            Hearing()


        sensorTimer = 0.0

func LOSCheck(target: Vector3):

    if gameData.TOD == 4 && !gameData.flashlight && !boss:
        LOS.target_position = Vector3(0, 0, 25 + extraVisibility)

    elif gameData.fog && !boss:
        LOS.target_position = Vector3(0, 0, 100 + extraVisibility)

    else:
        LOS.target_position = Vector3(0, 0, 200)


    LOS.look_at(target, Vector3.UP, true)
    LOS.force_raycast_update()


    if LOS.is_colliding() && LOS.get_collider().is_in_group("Player"):

        lastKnownLocation = playerPosition
        playerVisible = true


        if currentState == State.Wander || currentState == State.Guard || currentState == State.Patrol:
            Decision()

        elif currentState == State.Ambush:
            ChangeState("Combat")
    else:
        playerVisible = false

func Hearing():
    if (playerDistance3D < 20 && gameData.isRunning) || (playerDistance3D < 5 && gameData.isWalking):

        if currentState != State.Ambush:
            lastKnownLocation = playerPosition

        if currentState == State.Wander || currentState == State.Guard || currentState == State.Patrol:
            Decision()

func FireDetection(delta):

    if gameData.isFiring && !playerVisible:

        if fireVector > 0.95:

            lastKnownLocation = playerPosition

            if currentState == State.Wander || currentState == State.Guard || currentState == State.Patrol:
                Decision()

            elif currentState == State.Ambush:
                ChangeState("Combat")


            fireDetected = true
            extraVisibility = 50.0


        elif playerDistance3D < 50:

            if currentState != State.Ambush:
                lastKnownLocation = playerPosition

            if currentState == State.Wander || currentState == State.Guard || currentState == State.Patrol:
                Decision()


            fireDetected = true
            extraVisibility = 50.0


    if fireDetected:
        fireDetectionTimer += delta


        if fireDetectionTimer > fireDetectionTime:
            extraVisibility = 0.0
            fireDetectionTimer = 0.0
            fireDetected = false



func Interactor(delta):
    forward.global_rotation.y = atan2(velocity.x, velocity.z)
    interactionTimer += delta

    if interactionTimer > interactionTime:
        if forward.is_colliding():
            interactionTarget = forward.get_collider()

            if interactionTarget.is_in_group("Interactable"):

                if interactionTarget.owner is Door && !interactionTarget.owner.isOpen:

                    if interactionTarget.owner.locked: return
                    if interactionTarget.owner.jammed: return

                    interactionTarget.owner.Interact()
                    interactionTarget.owner.isOccupied = true

        interactionTimer = 0.0



func Movement(delta):
    movementSpeed = move_toward(movementSpeed, speed, delta * 5.0)
    movementRotation = move_toward(movementRotation, turnSpeed, delta * 5.0)
    animator["parameters/Rifle/Movement/blend_position"] = movementSpeed
    animator["parameters/Pistol/Movement/blend_position"] = movementSpeed

    if currentState == State.Guard || currentState == State.Ambush || currentState == State.Defend:
        if velocity != Vector3.ZERO:
            velocity = lerp(velocity, Vector3.ZERO, delta * 2.0)
    else:

        if speed < 2.0: pathCycle = 0.2
        else: pathCycle = 0.05

        pathTimer += delta

        if pathTimer > pathCycle:
            pathTarget = agent.get_next_path_position()
            pathTimer = 0.0

        var moveDirection: Vector3 = (pathTarget - global_position).normalized()
        velocity = lerp(velocity, moveDirection * movementSpeed, delta * movementVelocity)
        move_and_slide()

func Rotation(delta):

    if (currentState == State.Wander
    || currentState == State.Patrol
    || currentState == State.Cover
    || currentState == State.Vantage
    || currentState == State.Hide
    || currentState == State.Attack
    || currentState == State.Return
    || currentState == State.Shift):
        rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), delta * movementRotation)


    elif currentState == State.Guard || currentState == State.Ambush:
        rotation.y = lerp_angle(rotation.y, currentPoint.global_rotation.y, delta * movementRotation)
        animator["parameters/Rifle/Hunt/blend_position"] = 0.0
        animator["parameters/Pistol/Hunt/blend_position"] = 0.0


    elif currentState == State.Defend:
        var playerDirection = global_position - Vector3(LKL.x, 0.0, LKL.z)
        var targetAngle = atan2( - playerDirection.x, - playerDirection.z)
        rotation.y = lerp_angle(rotation.y, targetAngle, delta * movementRotation)
        var turnDirection = angle_difference(rotation.y, targetAngle)
        animator["parameters/Rifle/Defend/blend_position"] = - turnDirection * 10.0
        animator["parameters/Pistol/Defend/blend_position"] = - turnDirection * 10.0


    elif currentState == State.Combat || currentState == State.Hunt:
        poleTimer += delta


        if poleTimer > poleCycle:
            var nearestPole = GetNearestPole()
            if nearestPole == N1:
                north = true
                north1 = true
            elif nearestPole == N2:
                north = true
                north2 = true
            elif nearestPole == S1:
                south = true
                south1 = true
            elif nearestPole == S2:
                south = true
                south2 = true
            poleTimer = 0.0


        if north1:
            var N1Dir = global_position - Vector3(N1.global_position.x, 0.0, N1.global_position.z)
            rotation.y = lerp_angle(rotation.y, atan2( - N1Dir.x, - N1Dir.z), delta * 2)
            targetStrafe = 1.0
        elif north2:
            var N2Dir = global_position - Vector3(N2.global_position.x, 0.0, N2.global_position.z)
            rotation.y = lerp_angle(rotation.y, atan2( - N2Dir.x, - N2Dir.z), delta * 2)
            targetStrafe = 1.0
        elif south1:
            var S1Dir = global_position - Vector3(S1.global_position.x, 0.0, S1.global_position.z)
            rotation.y = lerp_angle(rotation.y, atan2( - S1Dir.x, - S1Dir.z), delta * 2)
            targetStrafe = -1.0
        elif south2:
            var S2Dir = global_position - Vector3(S2.global_position.x, 0.0, S2.global_position.z)
            rotation.y = lerp_angle(rotation.y, atan2( - S2Dir.x, - S2Dir.z), delta * 2)
            targetStrafe = -1.0

        strafeDirection = move_toward(strafeDirection, targetStrafe, delta * 2)
        animator["parameters/Rifle/Combat/blend_position"] = strafeDirection
        animator["parameters/Rifle/Hunt/blend_position"] = strafeDirection
        animator["parameters/Pistol/Combat/blend_position"] = strafeDirection
        animator["parameters/Pistol/Hunt/blend_position"] = strafeDirection

func Poles():

    if velocity == Vector3.ZERO: poles.rotation.y = 0.0

    else: poles.global_rotation.y = atan2(velocity.x, velocity.z)



func Spine(delta):

    if currentState == State.Defend || currentState == State.Combat || currentState == State.Hunt || currentState == State.Attack || currentState == State.Shift:
        spineWeight = move_toward(spineWeight, spineData.weight, delta)
    else:
        spineWeight = move_toward(spineWeight, 0.0, delta * 10.0)


    var spinePose: Transform3D = skeleton.get_bone_global_pose_no_override(spineData.bone)
    var spineAimPose = spinePose.looking_at( - skeleton.to_local(LKL) + Vector3(0, 1, 0), Vector3.UP)
    spineAimPose.basis = spineAimPose.basis.rotated(spineAimPose.basis.x, deg_to_rad(spineTarget.x))
    spineAimPose.basis = spineAimPose.basis.rotated(spineAimPose.basis.y, deg_to_rad(spineTarget.y))
    spineAimPose.basis = spineAimPose.basis.rotated(spineAimPose.basis.z, deg_to_rad(spineTarget.z))


    skeleton.set_bone_global_pose_override(spineData.bone, spineAimPose, spineWeight, true)

func Aim(delta):

    if impulseTimer < impulseTime:
        impulseTimer += delta
        spineTarget = lerp(spineTarget, impulseTarget, delta / impulseTime)

    else:

        if recoveryTimer < recoveryTime:
            recoveryTimer += delta
            aimSpeed = impulseTime

        else:
            aimSpeed = 1.0
            impact = false


        if animator["parameters/conditions/Rifle"]:

            if currentState == State.Defend:
                spineTarget = lerp(spineTarget, spineData.rifleDefend, delta / aimSpeed)

            elif currentState == State.Combat:
                if north:
                    spineTarget = lerp(spineTarget, spineData.rifleCombatN, delta / aimSpeed)
                elif south:
                    spineTarget = lerp(spineTarget, spineData.rifleCombatS, delta / aimSpeed)

            elif currentState == State.Hunt:
                if north:
                    spineTarget = lerp(spineTarget, spineData.rifleHuntN, delta / aimSpeed)
                elif south:
                    spineTarget = lerp(spineTarget, spineData.rifleHuntS, delta / aimSpeed)

            elif currentState == State.Attack || currentState == State.Shift:
                spineTarget = lerp(spineTarget, spineData.rifleAttackN, delta / aimSpeed)


        elif animator["parameters/conditions/Pistol"]:

            if currentState == State.Defend:
                spineTarget = lerp(spineTarget, spineData.pistolDefend, delta / aimSpeed)

            elif currentState == State.Combat:
                if north:
                    spineTarget = lerp(spineTarget, spineData.pistolCombatN, delta / aimSpeed)
                elif south:
                    spineTarget = lerp(spineTarget, spineData.pistolCombatS, delta / aimSpeed)

            elif currentState == State.Hunt:
                if north:
                    spineTarget = lerp(spineTarget, spineData.pistolHuntN, delta / aimSpeed)
                elif south:
                    spineTarget = lerp(spineTarget, spineData.pistolHuntS, delta / aimSpeed)

            elif currentState == State.Attack || currentState == State.Shift:
                spineTarget = lerp(spineTarget, spineData.pistolAttackN, delta / aimSpeed)



func ChangeState(state):
    match state:
        "Idle":
            speed = 0.0
            turnSpeed = 1.0
            movementVelocity = 1.0
            agent.target_desired_distance = 1.0
            currentState = State.Idle

        "Guard":
            speed = 0.0
            turnSpeed = 1.0
            movementVelocity = 1.0
            guardTimer = 0.0
            guardCycle = randf_range(4, 20)
            agent.target_desired_distance = 0.2
            currentState = State.Guard

            ResetLKL()
            ResetAnimator()
            animator["parameters/Rifle/conditions/Guard"] = true
            animator["parameters/Pistol/conditions/Guard"] = true

        "Patrol":
            if GetPatrolPoint():
                speed = 1.0
                turnSpeed = 5.0
                movementVelocity = 5.0
                agent.target_desired_distance = 0.2
                currentState = State.Patrol

                ResetLKL()
                ResetAnimator()
                animator["parameters/Rifle/conditions/Movement"] = true
                animator["parameters/Pistol/conditions/Movement"] = true
            else:
                print("AI: No available patrol points -> Wander")
                ChangeState("Wander")

        "Wander":
            if GetWanderWaypoint():
                speed = 1.0
                turnSpeed = 5.0
                movementVelocity = 5.0
                agent.target_desired_distance = 1.0
                currentState = State.Wander

                ResetAnimator()
                animator["parameters/Rifle/conditions/Movement"] = true
                animator["parameters/Pistol/conditions/Movement"] = true
            else:
                print("AI: No available wander points -> Idle")
                ChangeState("Idle")

        "Defend":
            speed = 0.0
            turnSpeed = 10.0
            movementVelocity = 1.0
            defendTimer = 0.0
            defendCycle = randf_range(4, 10)
            agent.target_desired_distance = 1.0
            currentState = State.Defend

            ResetAnimator()
            animator["parameters/Rifle/conditions/Defend"] = true
            animator["parameters/Pistol/conditions/Defend"] = true

        "Combat":
            if GetCombatWaypoint():
                speed = 1.0
                turnSpeed = 4.0
                movementVelocity = 5.0
                combatTimer = 0.0
                combatCycle = randf_range(4, 10)
                agent.target_desired_distance = 1.0
                currentState = State.Combat

                ResetAnimator()
                animator["parameters/Rifle/conditions/Combat"] = true
                animator["parameters/Pistol/conditions/Combat"] = true
            else:
                print("AI: No available combat points -> Idle")
                ChangeState("Idle")

        "Shift":
            if GetShiftWaypoint():
                speed = 3.0
                turnSpeed = 10.0
                movementVelocity = 8.0
                shiftTimer = 0.0
                shiftCycle = randf_range(1, 4)
                shiftCount = randi_range(4, 5)
                agent.target_desired_distance = 2.0
                currentState = State.Shift

                ResetAnimator()
                animator["parameters/Rifle/conditions/Movement"] = true
                animator["parameters/Pistol/conditions/Movement"] = true
            else:
                print("AI: No available shift points -> Combat")
                ChangeState("Combat")

        "Attack":
            GetAttackWaypoint()
            speed = 3.0
            turnSpeed = 10.0
            movementVelocity = 8.0
            attackTimer = 0.0
            attackCycle = 1.0
            agent.target_desired_distance = 2.0
            returnPosition = global_position
            currentState = State.Attack

            ResetAnimator()
            animator["parameters/Rifle/conditions/Movement"] = true
            animator["parameters/Pistol/conditions/Movement"] = true

        "Cover":
            if GetCoverPoint():
                speed = 5.0
                turnSpeed = 5.0
                movementVelocity = 8.0
                agent.target_desired_distance = 0.2
                currentState = State.Cover

                ResetAnimator()
                animator["parameters/Rifle/conditions/Movement"] = true
                animator["parameters/Pistol/conditions/Movement"] = true
            else:
                print("AI: No available cover points -> Combat")
                ChangeState("Combat")

        "Return":
            MoveToPoint(returnPosition)
            speed = 5.0
            turnSpeed = 5.0
            movementVelocity = 8.0
            agent.target_desired_distance = 1.0
            currentState = State.Return

            ResetAnimator()
            animator["parameters/Rifle/conditions/Movement"] = true
            animator["parameters/Pistol/conditions/Movement"] = true

        "Hunt":
            GetAttackWaypoint()
            speed = 1.0
            turnSpeed = 4.0
            movementVelocity = 4.0
            huntTimer = 0.0
            huntCycle = 1.0
            agent.target_desired_distance = 2.0
            currentState = State.Hunt

            ResetAnimator()
            animator["parameters/Rifle/conditions/Hunt"] = true
            animator["parameters/Pistol/conditions/Hunt"] = true

        "Hide":
            if GetHidePoint():
                speed = 5.0
                turnSpeed = 5.0
                movementVelocity = 8.0
                agent.target_desired_distance = 0.2
                currentState = State.Hide

                ResetAnimator()
                animator["parameters/Rifle/conditions/Movement"] = true
                animator["parameters/Pistol/conditions/Movement"] = true
            else:
                print("AI: No available hide points")
                ChangeState("Combat")

        "Ambush":
            speed = 0.0
            turnSpeed = 1.0
            movementVelocity = 2.0
            ambushTimer = 0.0
            ambushCycle = randf_range(120, 360)
            agent.target_desired_distance = 0.2
            currentState = State.Ambush

            ResetLKL()
            ResetAnimator()
            animator["parameters/Rifle/conditions/Hunt"] = true
            animator["parameters/Pistol/conditions/Hunt"] = true

        "Vantage":
            if GetVantagePoint():
                speed = 5.0
                turnSpeed = 5.0
                movementVelocity = 8.0
                agent.target_desired_distance = 0.2
                currentState = State.Vantage

                ResetAnimator()
                animator["parameters/Rifle/conditions/Movement"] = true
                animator["parameters/Pistol/conditions/Movement"] = true
            else:
                print("AI: No available vantage points -> Combat")
                ChangeState("Combat")

func States(delta):
    if currentState == State.Guard: Guard(delta)
    elif currentState == State.Patrol: Patrol(delta)
    elif currentState == State.Cover: Cover(delta)
    elif currentState == State.Vantage: Vantage(delta)
    elif currentState == State.Hide: Hide(delta)
    elif currentState == State.Ambush: Ambush(delta)
    elif currentState == State.Defend: Defend(delta)
    elif currentState == State.Wander: Wander(delta)
    elif currentState == State.Combat: Combat(delta)
    elif currentState == State.Shift: Shift(delta)
    elif currentState == State.Hunt: Hunt(delta)
    elif currentState == State.Attack: Attack(delta)
    elif currentState == State.Return: Return()

func Decision():

    if playerDistance3D > 20:
        var decision = randi_range(1, 9)

        if decision == 1:
            ChangeState("Combat")
        elif decision == 2 && !AISpawner.noHiding:
            ChangeState("Hide")
        elif decision == 3:
            ChangeState("Cover")
        elif decision == 4:
            ChangeState("Vantage")
        elif decision == 5:
            ChangeState("Defend")
        elif decision == 6 && playerVisible && playerDistance3D < 100 && !gameData.isTrading:
            ChangeState("Hunt")
        elif decision == 7 && playerVisible && playerDistance3D < 100 && !gameData.isTrading:
            ChangeState("Shift")
        elif decision == 8 && playerVisible && playerDistance3D < 100 && !gameData.isTrading && (weaponData.weaponAction != "Manual"):
            ChangeState("Attack")
        else:
            ChangeState("Combat")


    else:
        var decision = randi_range(1, 4)

        if decision == 1:
            ChangeState("Combat")
        elif decision == 2:
            ChangeState("Defend")
        elif decision == 3 && playerVisible && !gameData.isTrading:
            ChangeState("Hunt")
        elif decision == 4 && playerVisible && !gameData.isTrading && (weaponData.weaponAction != "Manual"):
            ChangeState("Attack")
        else:
            ChangeState("Combat")



func Guard(delta):

    guardTimer += delta


    if guardTimer > guardCycle:
        ChangeState("Patrol")

func Patrol(_delta):

    if global_transform.origin.distance_to(agent.target_position) < 2.0:
        speed = 1.0
        turnSpeed = 1.0


    if agent.is_target_reached() || agent.is_navigation_finished():
        ChangeState("Guard")

func Defend(delta):

    defendTimer += delta


    if playerVisible:
        Fire(delta)


    if defendTimer > defendCycle:
        ChangeState("Combat")

func Ambush(delta):
    ambushTimer += delta


    if ambushTimer > ambushCycle:
        ChangeState("Wander")

func Hide(_delta):

    if global_transform.origin.distance_to(agent.target_position) < 2.0:
        speed = 1.0
        turnSpeed = 2.0
    elif global_transform.origin.distance_to(agent.target_position) < 4.0:
        speed = 3.0
        turnSpeed = 5.0


    if agent.is_target_reached() || agent.is_navigation_finished():
        ChangeState("Ambush")


    if playerDistance3D < 10:
        ChangeState("Combat")

func Cover(_delta):

    if global_transform.origin.distance_to(agent.target_position) < 2.0:
        speed = 1.0
        turnSpeed = 2.0
    elif global_transform.origin.distance_to(agent.target_position) < 4.0:
        speed = 3.0
        turnSpeed = 5.0


    if agent.is_target_reached() || agent.is_navigation_finished():
        ChangeState("Combat")


    if playerDistance3D < 10:
        ChangeState("Combat")

func Vantage(_delta):

    if global_transform.origin.distance_to(agent.target_position) < 2.0:
        speed = 1.0
        turnSpeed = 2.0
    elif global_transform.origin.distance_to(agent.target_position) < 4.0:
        speed = 3.0
        turnSpeed = 5.0


    if agent.is_target_reached() || agent.is_navigation_finished():
        ChangeState("Defend")


    if playerDistance3D < 10:
        ChangeState("Combat")

func Wander(_delta):

    if agent.is_target_reached() || agent.is_navigation_finished():
        GetWanderWaypoint()

func Combat(delta):

    combatTimer += delta


    if playerVisible:
        Fire(delta)


    if combatTimer > combatCycle || agent.is_target_reached() || agent.is_navigation_finished():
        Decision()

func Shift(delta):

    shiftTimer += delta


    if playerVisible:
        Fire(delta)


    if shiftTimer > shiftCycle:
        shiftCount -= 1
        shiftTimer = 0.0

        if !GetShiftWaypoint():

            ChangeState("Combat")


    if shiftCount == 0:
        ChangeState("Combat")


    if playerDistance3D < 10 || agent.is_target_reached() || agent.is_navigation_finished():
        ChangeState("Combat")

func Hunt(delta):

    huntTimer += delta


    if playerVisible:
        Fire(delta)


    if huntTimer > huntCycle:
        GetHuntWaypoint()
        huntTimer = 0.0


    if agent.is_target_reached() || agent.is_navigation_finished() || gameData.isTrading:
        ChangeState("Combat")

func Attack(delta):

    attackTimer += delta


    if playerVisible:
        Fire(delta)


    if attackTimer > attackCycle:
        GetAttackWaypoint()
        attackTimer = 0.0


    if agent.is_target_reached() || agent.is_navigation_finished() || gameData.isTrading:
        if attackReturn && !playerVisible:
            ChangeState("Return")
        else:
            ChangeState("Combat")

func Return():

    if global_transform.origin.distance_to(agent.target_position) < 2.0:
        speed = 1.0
        turnSpeed = 2.0
    elif global_transform.origin.distance_to(agent.target_position) < 4.0:
        speed = 3.0
        turnSpeed = 5.0


    if agent.is_target_reached() || agent.is_navigation_finished():
        ChangeState("Combat")


    if playerDistance3D < 10:
        ChangeState("Combat")



func Fire(delta):
    if impact || gameData.isTrading:
        return


    if LKL.distance_to(playerPosition) > 4.0:
        return


    if weaponData.weaponAction == "Semi-Auto":
        Selector(delta)

    fireTime -= delta

    if fireTime <= 0:
        Raycast()
        PlayFire()
        PlayTail()
        MuzzleVFX()


        impulseTime = spineData.impulse / 2
        impulseTimer = 0.0


        recoveryTime = spineData.impulse
        recoveryTimer = 0.0


        if fullAuto:
            var impulseX = spineTarget.x - spineData.recoil / 10.0
            var impulseY = spineTarget.y
            var impulseZ = spineTarget.z
            impulseTarget = Vector3(impulseX, impulseY, impulseZ)
        else:
            var impulseX = spineTarget.x - spineData.recoil
            var impulseY = spineTarget.y
            var impulseZ = spineTarget.z
            impulseTarget = Vector3(impulseX, impulseY, impulseZ)


        flash.global_position = muzzle.global_position
        flash.Activate()


        FireFrequency()


        if playerDistance3D > 50:
            await get_tree().create_timer(0.1, false).timeout;
            PlayCrack()

func Selector(delta):
    selectorTime -= delta


    if selectorTime <= 0:

        if currentState == State.Attack:
            selectorRoll = 0

        else:
            selectorRoll = randi_range(0, 100)


        if selectorRoll <= 10 && !fullAuto:
            selectorTime = randf_range(1.0, 2.0)
            fullAuto = true
        else:
            selectorTime = randf_range(1.0, 5.0)
            fullAuto = false

func Raycast():
    fire.look_at(FireAccuracy(), Vector3.UP, true)
    fire.force_raycast_update()

    if fire.is_colliding():
        var hitCollider = fire.get_collider()


        if hitCollider.is_in_group("Player"):
            if boss: hitCollider.get_child(0).WeaponDamage(weaponData.damage * 2.0, weaponData.penetration)
            else: hitCollider.get_child(0).WeaponDamage(weaponData.damage, weaponData.penetration)

        else:
            var hitPoint = fire.get_collision_point()
            var hitNormal = fire.get_collision_normal()
            var hitSurface = hitCollider.get("surface")
            BulletDecal(hitCollider, hitPoint, hitNormal, hitSurface)


    elif playerDistance3D > 50:
        await get_tree().create_timer(0.1, false).timeout;
        PlayFlyby()

func FireFrequency():

    if weaponData.weaponAction == "Semi-Auto" && fullAuto:
        fireTime = weaponData.fireRate


    elif (weaponData.weaponAction == "Semi-Auto" || weaponData.weaponAction == "Semi") && !fullAuto:
        if playerDistance3D < 10:
            fireTime = randf_range(0.1, 0.5)
        elif playerDistance3D > 10 && playerDistance3D < 50:
            fireTime = randf_range(0.1, 1.0)
        else:
            fireTime = randf_range(0.1, 4.0)


    elif weaponData.weaponAction == "Pump" || weaponData.weaponAction == "Bolt":
        if playerDistance3D < 10:
            fireTime = randf_range(1.0, 2.0)
        elif playerDistance3D > 10 && playerDistance3D < 50:
            fireTime = randf_range(1.0, 2.0)
        else:
            fireTime = randf_range(1.0, 4.0)


    else:
        fireTime = randf_range(1.0, 4.0)

func FireAccuracy() -> Vector3:

    var fireDirection = playerPosition + Vector3(0, 1.0, 0)
    var spreadMultiplier = 1.0
    var offset = Vector3.ZERO


    if fullAuto && !boss:
        spreadMultiplier = 2.0


    if playerDistance3D < 10 || boss:
        offset.x = randf_range(-0.1, 0.1) * spreadMultiplier
        offset.y = randf_range(-0.1, 0.1) * spreadMultiplier

    elif playerDistance3D > 10 && playerDistance3D < 50:
        offset.x = randf_range(-1.0, 1.0) * spreadMultiplier
        offset.y = randf_range(-1.0, 1.0) * spreadMultiplier

    else:
        offset.x = randf_range(-2.0, 2.0) * spreadMultiplier
        offset.y = randf_range(-2.0, 2.0) * spreadMultiplier


    var aimBasis = global_transform.basis * offset


    return fireDirection + aimBasis



func BulletDecal(hitCollider, hitPoint, hitNormal, hitSurface):
    var bulletDecal = hitDefault.instantiate()
    hitCollider.add_child(bulletDecal)
    bulletDecal.global_transform.origin = hitPoint

    var surfaceDirUp = Vector3(0, 1, 0)
    var surfaceDirDown = Vector3(0, -1, 0)

    if hitNormal == surfaceDirUp:
        bulletDecal.look_at(hitPoint + hitNormal, Vector3.RIGHT)
    elif hitNormal == surfaceDirDown:
        bulletDecal.look_at(hitPoint + hitNormal, Vector3.RIGHT)
    else:
        bulletDecal.look_at(hitPoint + hitNormal, Vector3.DOWN)

    bulletDecal.global_rotation.z = randf_range(-360, 360)

    bulletDecal.PlayHit(hitSurface)

func MuzzleVFX():
    var newFlash = flashVFX.instantiate()
    muzzle.add_child(newFlash)
    newFlash.Emit(true, 0.05)

    var newSmoke = smokeVFX.instantiate()
    muzzle.add_child(newSmoke)
    newSmoke.Emit(true, 0.5)



func WeaponDamage(hitbox: String, damage: float):
    if dead: return


    health -= damage


    impact = true
    impulseTime = spineData.impulse
    impulseTimer = 0.0


    recoveryTime = spineData.impulse
    recoveryTimer = 0.0


    if hitbox == "Head" || hitbox == "Torso":
        var impulseX = randf_range(spineTarget.x - spineData.impact / 2, spineTarget.x - spineData.impact)
        var impulseY = randf_range(spineTarget.y - spineData.impact, spineTarget.y + spineData.impact)
        var impulseZ = randf_range(spineTarget.z - spineData.impact, spineTarget.z + spineData.impact)
        impulseTarget = Vector3(impulseX, impulseY, impulseZ)
    elif hitbox == "Leg_L":
        var impulseX = randf_range(spineTarget.x + spineData.impact / 2, spineTarget.x + spineData.impact)
        var impulseY = randf_range(spineTarget.y + spineData.impact / 2, spineTarget.y + spineData.impact)
        var impulseZ = randf_range(spineTarget.z - spineData.impact, spineTarget.z + spineData.impact)
        impulseTarget = Vector3(impulseX, impulseY, impulseZ)
    elif hitbox == "Leg_R":
        var impulseX = randf_range(spineTarget.x + spineData.impact / 2, spineTarget.x + spineData.impact)
        var impulseY = randf_range(spineTarget.y - spineData.impact / 2, spineTarget.y - spineData.impact)
        var impulseZ = randf_range(spineTarget.z - spineData.impact, spineTarget.z + spineData.impact)
        impulseTarget = Vector3(impulseX, impulseY, impulseZ)


    if health <= 0:

        if is_instance_valid(activeVoice):
            activeVoice.queue_free()
            activeVoice = null


        if hitbox != "Head":
            PlayDeath()


        Death(gameData.playerVector, 40)


    else:

        if !is_instance_valid(activeVoice):
            PlayDamage()

func ExplosionDamage(direction):

    Death(direction, 100)

func Death(direction, force):
    dead = true


    flash.Reset()


    detector.monitoring = false
    LOS.enabled = false
    fire.enabled = false
    below.enabled = false
    forward.enabled = false


    animator.active = false


    collision.disabled = true


    agent.velocity = Vector3.ZERO


    ActivateContainer()


    if weapon:
        weapon.collision.disabled = false
        weapon.process_mode = Node.PROCESS_MODE_INHERIT
    if backpack:
        backpack.collision.disabled = false
        backpack.process_mode = Node.PROCESS_MODE_INHERIT
    if secondary:
        secondary.collision.disabled = false
        secondary.process_mode = Node.PROCESS_MODE_INHERIT


    skeleton.modifier_callback_mode_process = Skeleton3D.MODIFIER_CALLBACK_MODE_PROCESS_IDLE
    skeleton.Activate(direction, force)


    skeleton.set_bone_global_pose_override(spineData.bone, skeleton.get_bone_pose(spineData.bone), 0.0, true)


    AISpawner.activeAgents -= 1


    if boss: Loader.Message("Boss Killed", Color.GREEN)


    HideGizmos()



func ActivateContainer():
    container.get_child(0).get_child(0).disabled = false

func DeactivateContainer():
    container.get_child(0).get_child(0).disabled = true



func Voices(delta):

    if !is_instance_valid(activeVoice):
        voiceTimer += delta


        if voiceTimer > voiceCycle:

            if currentState == State.Wander || currentState == State.Guard || currentState == State.Patrol:
                PlayIdle()

            elif currentState == State.Combat || currentState == State.Attack || currentState == State.Shift || currentState == State.Vantage:
                PlayCombat()


            voiceCycle = randf_range(10.0, 60.0)
            voiceTimer = 0.0



func GetPatrolPoint() -> bool:

    var validPoints: Array[Node3D]


    var pointParent = currentPoint.get_parent()


    if pointParent && pointParent.name == "AI":

        for point in pointParent.get_children():

            if point.is_in_group("AI_PP"):

                if point != currentPoint:

                    validPoints.append(point)


    if validPoints.size() != 0:

        var patrolPoint = validPoints.pick_random()

        currentPoint = patrolPoint

        MoveToPoint(patrolPoint.global_position)
        return true
    else:
        return false

func GetHidePoint() -> bool:

    var validPoints: Array[Node3D]


    if nearbyPoints.size() != 0:

        for point in nearbyPoints:

            if point.is_in_group("AI_HP"):
                var distanceToAI = global_position.distance_to(point.global_position)
                var distantoToPlayer = point.global_position.distance_to(playerPosition)


                if distanceToAI < 40 && distanceToAI < distantoToPlayer:

                    if point != currentPoint:
                        validPoints.append(point)


    if validPoints.size() != 0:

        var hidePoint = validPoints.pick_random()

        currentPoint = hidePoint

        MoveToPoint(hidePoint.global_position)
        return true
    else:
        return false

func GetVantagePoint() -> bool:

    var validPoints: Array[Node3D]


    if nearbyPoints.size() != 0:

        for point in nearbyPoints:

            if point.is_in_group("AI_PP"):
                var distanceToAI = global_position.distance_to(point.global_position)
                var distantoToPlayer = point.global_position.distance_to(playerPosition)


                if distanceToAI < 40 && distanceToAI < distantoToPlayer:
                    var direction = (playerPosition - point.global_position).normalized()
                    var vector = direction.dot(point.global_transform.basis.z)


                    if vector > 0.9:

                        if point != currentPoint:
                            validPoints.append(point)


    if validPoints.size() != 0:

        var vantage = validPoints.pick_random()

        currentPoint = vantage

        MoveToPoint(vantage.global_position)
        return true
    else:
        return false

func GetCoverPoint() -> bool:

    var validPoints: Array[Node3D]


    if nearbyPoints.size() != 0:

        for point in nearbyPoints:

            if point.is_in_group("AI_CP"):
                var distanceToAI = global_position.distance_to(point.global_position)
                var distantoToPlayer = point.global_position.distance_to(playerPosition)


                if distanceToAI < 40 && distanceToAI < distantoToPlayer:
                    var direction = (playerPosition - point.global_position).normalized()
                    var vector = direction.dot(point.global_transform.basis.z)


                    if vector < -0.8:

                        if point != currentPoint:
                            validPoints.append(point)


    if validPoints.size() != 0:

        var cover = validPoints.pick_random()

        currentPoint = cover

        MoveToPoint(cover.global_position)
        return true
    else:
        return false

func GetWanderWaypoint():

    var validPoints: Array[Node3D]


    if nearbyPoints.size() != 0:

        for point in nearbyPoints:

            if point.is_in_group("AI_WP"):

                if point != currentPoint:
                    validPoints.append(point)


    if validPoints.size() != 0:

        var waypoint = validPoints.pick_random()

        currentPoint = waypoint

        MoveToPoint(waypoint.global_position)
        return true
    else:

        var waypoint = get_tree().get_nodes_in_group("AI_SP").pick_random()

        currentPoint = waypoint

        MoveToPoint(waypoint.global_position)
        print("AI Wander: Fallback to spawn point")
        return true

func GetCombatWaypoint():

    var validPoints: Array[Node3D]


    if nearbyPoints.size() != 0:

        for point in nearbyPoints:

            if point.is_in_group("AI_WP"):

                if point != currentPoint:
                    validPoints.append(point)


    if validPoints.size() != 0:

        var waypoint = validPoints.pick_random()

        currentPoint = waypoint

        MoveToPoint(waypoint.global_position)
        return true
    else:

        var waypoint = get_tree().get_nodes_in_group("AI_SP").pick_random()

        currentPoint = waypoint

        MoveToPoint(waypoint.global_position)
        print("AI Combat: Fallback to spawn point")
        return true

func GetShiftWaypoint():

    var validPoints: Array[Node3D]


    if nearbyPoints.size() != 0:

        for point in nearbyPoints:

            if point.is_in_group("AI_WP"):
                var distanceToAI = global_position.distance_to(point.global_position)
                var directionToPlayer = (playerPosition - global_position).normalized()
                var directionToPoint = (point.global_position - global_position).normalized()


                if directionToPoint.dot(directionToPlayer) > 0 && distanceToAI < global_position.distance_to(playerPosition):

                    if point != currentPoint:
                        validPoints.append(point)


    if validPoints.size() != 0:

        var shift = validPoints.pick_random()

        currentPoint = shift

        MoveToPoint(shift.global_position)
        return true
    else:
        return false

func GetHuntWaypoint():
    MoveToPoint(lastKnownLocation)

func GetAttackWaypoint():
    MoveToPoint(lastKnownLocation)

func MoveToPoint(origin: Vector3):
    var closestPosition = NavigationServer3D.map_get_closest_point(navigationMap, origin)
    agent.target_position = closestPosition

func GetNearestPole():
    var minimumDistance = 1000
    var closestPoint: Node3D


    north = false
    south = false
    north1 = false
    north2 = false
    south1 = false
    south2 = false


    for point in poles.get_children():

        var distance = LKL.distance_to(point.global_position)


        if distance < minimumDistance:

            minimumDistance = distance

            closestPoint = point

    return closestPoint

func ShowGizmos():
    gizmo.show()
    agent.debug_enabled = true

func HideGizmos():
    gizmo.hide()
    agent.debug_enabled = false

func ResetLKL():
    if currentPoint:
        lastKnownLocation = currentPoint.global_position + Vector3(0, 1, 0) + currentPoint.basis.z * 2.0
    else:
        lastKnownLocation = global_position + Vector3(0, 1, 0) + basis.z * 2.0

    fireTime = 0.2

func ResetAnimator():
    animator["parameters/Rifle/conditions/Movement"] = false
    animator["parameters/Pistol/conditions/Movement"] = false
    animator["parameters/Rifle/conditions/Combat"] = false
    animator["parameters/Pistol/conditions/Combat"] = false
    animator["parameters/Rifle/conditions/Guard"] = false
    animator["parameters/Pistol/conditions/Guard"] = false
    animator["parameters/Rifle/conditions/Defend"] = false
    animator["parameters/Pistol/conditions/Defend"] = false
    animator["parameters/Rifle/conditions/Hunt"] = false
    animator["parameters/Pistol/conditions/Hunt"] = false
    animator["parameters/Rifle/conditions/Group"] = false
    animator["parameters/Pistol/conditions/Group"] = false



func PlayIdle():

    if idleVoices:
        var voice = audioInstance3D.instantiate()
        eyes.add_child(voice)
        voice.PlayInstance(idleVoices, 5, 100)
        activeVoice = voice

func PlayCombat():

    if combatVoices:
        var voice = audioInstance3D.instantiate()
        eyes.add_child(voice)
        voice.PlayInstance(combatVoices, 5, 100)
        activeVoice = voice

func PlayDamage():

    if damageVoices:
        var voice = audioInstance3D.instantiate()
        eyes.add_child(voice)
        voice.PlayInstance(damageVoices, 5, 100)
        activeVoice = voice

func PlayDeath():

    if deathVoices:
        var voice = audioInstance3D.instantiate()
        eyes.add_child(voice)
        voice.PlayInstance(deathVoices, 5, 100)
        activeVoice = voice

func PlayFootstep():

    if below.is_colliding() && playerDistance3D < 50.0:

        var surface = below.get_collider().get("surface")

        var footstepAudio = audioInstance3D.instantiate()
        add_child(footstepAudio)


        var loudness: float
        if currentState == State.Hunt: loudness = 3
        elif movementSpeed < 2: loudness = 5
        else: loudness = 8


        if gameData.season == 1:
            if surface == "Grass": footstepAudio.PlayInstance(audioLibrary.footstepGrass, loudness, 50)
            elif surface == "Dirt": footstepAudio.PlayInstance(audioLibrary.footstepDirt, loudness, 50)
            elif surface == "Asphalt": footstepAudio.PlayInstance(audioLibrary.footstepAsphalt, loudness, 50)
            elif surface == "Rock": footstepAudio.PlayInstance(audioLibrary.footstepRock, loudness, 50)
            elif surface == "Wood": footstepAudio.PlayInstance(audioLibrary.footstepWood, loudness, 50)
            elif surface == "Metal": footstepAudio.PlayInstance(audioLibrary.footstepMetal, loudness, 50)
            elif surface == "Concrete": footstepAudio.PlayInstance(audioLibrary.footstepConcrete, loudness, 50)
            elif surface == "Generic": footstepAudio.PlayInstance(audioLibrary.footstepGeneric, loudness, 50)
            else: footstepAudio.PlayInstance(audioLibrary.footstepGeneric, loudness, 50)
        elif gameData.season == 2:
            if surface == "Grass": footstepAudio.PlayInstance(audioLibrary.footstepSnowHard, loudness, 50)
            elif surface == "Dirt": footstepAudio.PlayInstance(audioLibrary.footstepSnowHard, loudness, 50)
            elif surface == "Asphalt": footstepAudio.PlayInstance(audioLibrary.footstepAsphalt, loudness, 50)
            elif surface == "Rock": footstepAudio.PlayInstance(audioLibrary.footstepRock, loudness, 50)
            elif surface == "Wood": footstepAudio.PlayInstance(audioLibrary.footstepWood, loudness, 50)
            elif surface == "Metal": footstepAudio.PlayInstance(audioLibrary.footstepMetal, loudness, 50)
            elif surface == "Concrete": footstepAudio.PlayInstance(audioLibrary.footstepConcrete, loudness, 50)
            elif surface == "Generic": footstepAudio.PlayInstance(audioLibrary.footstepGeneric, loudness, 50)
            else: footstepAudio.PlayInstance(audioLibrary.footstepGeneric, loudness, 50)

func PlayFire():

    if weaponData.weaponAction == "Semi-Auto" && fullAuto:
        var fireAudio = audioInstance3D.instantiate()
        add_child(fireAudio)
        fireAudio.position = Vector3(0, 1.0, 0)
        fireAudio.PlayInstance(weaponData.fireAuto, 50, 400)

    else:
        var fireAudio = audioInstance3D.instantiate()
        add_child(fireAudio)
        fireAudio.PlayInstance(weaponData.fireSemi, 50, 400)

func PlayTail():
    var tail = audioInstance3D.instantiate()
    add_child(tail)
    tail.position = Vector3(0, 1.0, 0)
    tail.PlayInstance(weaponData.tailOutdoor, 100, 400)

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
