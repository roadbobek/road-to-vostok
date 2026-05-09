extends Node3D


var gameData = preload("res://Resources/GameData.tres")


var data: Resource
var collision: RayCast3D


var targetPosition = Vector3.ZERO
var targetRotation = Vector3.ZERO
var handlingSpeed = 7.5


var aimToggle = false
var canted = false
var offset = 0.0

func _ready():

    data = owner.data
    collision = owner.collision


    position = Vector3(0.0, -0.5, -0.5)

func _physics_process(delta):

    if data && data is WeaponData:
        WeaponPosition()
        WeaponHandling(delta)


    if data && data is KnifeData || data is GrenadeData || data is FishingData:
        BasicHandling(delta)

func WeaponPosition():

    if gameData.freeze || gameData.isAiming || gameData.isInspecting || gameData.isPlacing || Input.is_action_pressed("rail_movement"):
        return


    if Input.is_action_just_pressed("weapon_high"):
        gameData.weaponPosition = 2


    if Input.is_action_just_pressed("weapon_low"):
        gameData.weaponPosition = 1

func WeaponHandling(delta):

    if gameData.freeze:
        return


    position = lerp(position, Vector3( - targetPosition.x, targetPosition.y, - targetPosition.z), delta * handlingSpeed)
    rotation_degrees.x = lerp(rotation_degrees.x, targetRotation.x, delta * handlingSpeed)
    rotation_degrees.y = lerp(rotation_degrees.y, targetRotation.y, delta * handlingSpeed)
    rotation_degrees.z = lerp(rotation_degrees.z, targetRotation.z, delta * handlingSpeed)


    if gameData.isClearing:
        targetPosition = data.collisionPosition
        targetRotation = data.collisionRotation
        return


    if collision.is_colliding():
        targetPosition = data.collisionPosition
        targetRotation = data.collisionRotation
        gameData.isColliding = true
        gameData.isAiming = false
        gameData.isCanted = false
        return
    else:
        gameData.isColliding = false


    if gameData.isPlacing:
        gameData.weaponPosition = 1
        targetPosition = data.lowPosition
        targetRotation = data.lowRotation
        return


    if gameData.isInspecting:
        targetPosition = data.inspectPosition
        targetRotation = data.inspectRotation
        return


    if gameData.isRunning || gameData.isChecking || (gameData.isReloading && data.weaponAction != "Manual"):

        if gameData.weaponPosition == 1:
            aimToggle = false
            gameData.isAiming = false
            gameData.isCanted = false
            targetPosition = data.lowPosition
            targetRotation = data.lowRotation
            return

        elif gameData.weaponPosition == 2:
            aimToggle = false
            gameData.isAiming = false
            gameData.isCanted = false
            targetPosition = data.highPosition
            targetRotation = data.highRotation
            return


    if gameData.aimMode == 1:

        if Input.is_action_pressed(("aim")):

            if Input.is_action_just_pressed(("canted")) && !gameData.interaction:
                canted = !canted


            if canted:
                gameData.isCanted = true
                gameData.isAiming = false
                targetPosition = data.cantedPosition
                targetRotation = data.cantedRotation

            else:
                gameData.isCanted = false
                gameData.isAiming = true


                if get_parent().activeOptic: targetPosition = Vector3(0.0, 0.0 - get_parent().aimOffset, data.aimPosition.z)
                else: targetPosition = data.aimPosition
                targetRotation = data.aimRotation


                if gameData.isScoped && !gameData.PIP:
                    targetPosition -= Vector3(0.0, 0.0, 0.1)


        elif !gameData.isColliding:

            gameData.isAiming = false
            gameData.isCanted = false


            if gameData.weaponPosition == 2:
                targetPosition = data.highPosition
                targetRotation = data.highRotation

            elif gameData.weaponPosition == 1:
                targetPosition = data.lowPosition
                targetRotation = data.lowRotation


    elif gameData.aimMode == 2:

        if Input.is_action_just_pressed(("aim")):
            aimToggle = !aimToggle


        if aimToggle:

            if Input.is_action_just_pressed(("canted")) && !gameData.interaction:
                canted = !canted


            if canted:
                gameData.isCanted = true
                gameData.isAiming = false
                targetPosition = data.cantedPosition
                targetRotation = data.cantedRotation

            else:
                gameData.isCanted = false
                gameData.isAiming = true


                if get_parent().activeOptic: targetPosition = Vector3(0.0, 0.0 - get_parent().aimOffset, data.aimPosition.z)
                else: targetPosition = data.aimPosition
                targetRotation = data.aimRotation
                targetRotation = data.aimRotation


                if gameData.isScoped && !gameData.PIP:
                    targetPosition -= Vector3(0.0, 0.0, 0.1)


        else:

            gameData.isAiming = false
            gameData.isCanted = false


            if gameData.weaponPosition == 2:
                targetPosition = data.highPosition
                targetRotation = data.highRotation

            elif gameData.weaponPosition == 1:
                targetPosition = data.lowPosition
                targetRotation = data.lowRotation

func BasicHandling(delta):
    position = lerp(position, Vector3( - targetPosition.x, targetPosition.y, - targetPosition.z), delta * handlingSpeed)
    rotation_degrees.x = lerp(rotation_degrees.x, targetRotation.x, delta * handlingSpeed)
    rotation_degrees.y = lerp(rotation_degrees.y, targetRotation.y, delta * handlingSpeed)
    rotation_degrees.z = lerp(rotation_degrees.z, targetRotation.z, delta * handlingSpeed)


    if collision.is_colliding():
        targetPosition = data.collisionPosition
        targetRotation = data.collisionRotation
        gameData.isColliding = true
        return
    else:
        gameData.isColliding = false


    if gameData.isInspecting:
        targetPosition = data.inspectPosition
        targetRotation = data.inspectRotation
        return


    if gameData.isPlacing || gameData.isRunning:
        targetPosition = data.lowPosition
        targetRotation = data.lowRotation
        return


    targetPosition = data.highPosition
    targetRotation = data.highRotation
    return
