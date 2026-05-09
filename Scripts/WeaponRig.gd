extends Node3D
class_name WeaponRig


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export_group("References")
@export var data: Resource
@export var animator: AnimationTree
@export var animations: AnimationPlayer
@export var skeleton: Skeleton3D
@export var recoil: Node3D
@export var ejector: Node3D
@export var muzzle: Node3D
@export var raycast: RayCast3D
@export var collision: RayCast3D
@export var arms: MeshInstance3D
@export var cartridge: MeshInstance3D
@export var magazine: MeshInstance3D
@export var bullets: Node3D
@export var attachments: Node3D

@export_group("Dynamic Rig")
@export var dynamicSlide: bool
@export var dynamicSelector: bool
@export var dynamicHammer: bool
@export var slideOptic = false
@export var slideIndex = 0
@export var selectorIndex = 0
@export var hammerIndex = 0
@export var backSightIndex = 0
@export var frontSightIndex = 0


var UIManager
var interface
var rigManager
var weaponSlot
var slotData


var fireRate = 0.0
var fireTimer = 0.0
var fireImpulse = 0.0
var fireImpulseTimer = 0.0


var slideLocked = false
var slideValue = 0.0
var slideOffset: Vector3
var selectorValue = 0.0
var initialSelectorRotation = Vector3.ZERO
var selectorRotation = Vector3.ZERO
var hammerLocked = false
var hammerValue = 0.0


var activeOptic: Node3D
var activeMuzzle: Node3D
var aimOffset = 0.0
var aimPosition: Vector3
var opticOffset: Vector3
var muzzlePosition: Vector3


var reloadPressed = false
var reloadHoldTimer = 0.0


var zoomLevel = 1
var ocularOpacity = 0.0
var reticleSize = 0.1


var currentState

func _ready():

    rigManager = get_parent()


    if gameData.primary:
        weaponSlot = rigManager.primarySlot
        slotData = weaponSlot.get_child(0).slotData
    elif gameData.secondary:
        weaponSlot = rigManager.secondarySlot
        slotData = weaponSlot.get_child(0).slotData


    interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")
    UIManager = get_tree().current_scene.get_node("/root/Map/Core/UI")


    animator.active = true
    animator.set_process_callback(AnimationTree.ANIMATION_PROCESS_PHYSICS)


    gameData.weaponPosition = 1
    gameData.inspectPosition = 1
    gameData.isFiring = false
    gameData.isReloading = false
    gameData.isInspecting = false
    gameData.isChecking = false
    gameData.isInserting = false
    gameData.secondaryOptic = false
    gameData.weaponAction = data.weaponAction


    if muzzle:
        muzzlePosition = muzzle.position


    if bullets:
        bullets.get_child(0).hide()
        bullets.get_child(1).hide()


    if magazine:
        magazine.hide()


    if !slotData.chamber && data.slideLock:
        slideLocked = true


    if slotData.chamber && data.hammerLock:
        hammerLocked = true


    initialSelectorRotation = skeleton.get_bone_pose_rotation(selectorIndex).get_euler()

func _input(event):

    if (gameData.freeze
    || gameData.isPlacing
    || gameData.isReloading
    || gameData.isInserting
    || gameData.isChecking
    || gameData.isCaching
    || gameData.isTransitioning
    || gameData.isFiring):
        return



    if Input.is_action_just_pressed("inspect") && !Input.is_action_pressed("rail_movement"):
        gameData.isInspecting = !gameData.isInspecting


        gameData.isFiring = false


        if gameData.isInspecting:
            gameData.inspectPosition = 1
            PlayInspectStart()
            animator["parameters/conditions/Inspect_Front"] = true
            animator["parameters/conditions/Inspect_Idle"] = false
        else:

            if gameData.inspectPosition == 1:
                PlayInspectEnd()
                animator["parameters/conditions/Inspect_Front"] = false
                animator["parameters/conditions/Inspect_Idle"] = true

            elif gameData.inspectPosition == 2:
                PlayInspectEnd()
                animator["parameters/conditions/Inspect_Back"] = false
                animator["parameters/conditions/Inspect_Idle"] = true
                gameData.inspectPosition = 1


    elif Input.is_action_just_pressed("weapon_high") && !Input.is_action_pressed("rail_movement") && gameData.isInspecting:
        if gameData.inspectPosition == 1:
            PlayInspectRotate()
            animator["parameters/conditions/Inspect_Front"] = false
            animator["parameters/conditions/Inspect_Back"] = true
            gameData.inspectPosition = 2


    elif Input.is_action_just_pressed("weapon_low") && !Input.is_action_pressed("rail_movement") && gameData.isInspecting:
        if gameData.inspectPosition == 2:
            PlayInspectRotate()
            animator["parameters/conditions/Inspect_Front"] = true
            animator["parameters/conditions/Inspect_Back"] = false
            gameData.inspectPosition = 1



    if Input.is_action_pressed("rail_movement"):

        if activeOptic != null && activeOptic.railMovement:
            if event is InputEventMouseButton && event.is_pressed():

                if event.button_index == MOUSE_BUTTON_WHEEL_UP && activeOptic.position.z < activeOptic.maxPosition:
                    activeOptic.position.z += 0.01
                    slotData.position += 0.01
                    PlayRailMove()

                if event.button_index == MOUSE_BUTTON_WHEEL_DOWN && activeOptic.position.z > activeOptic.minPosition:
                    activeOptic.position.z -= 0.01
                    slotData.position -= 0.01
                    PlayRailMove()



    if !Input.is_action_pressed("rail_movement") && !gameData.isInspecting:
        if gameData.isAiming && activeOptic != null && activeOptic.attachmentData.variable:
            if event is InputEventMouseButton && event.is_pressed():
                if event.button_index == MOUSE_BUTTON_WHEEL_UP && slotData.zoom != 3:
                    slotData.zoom += 1
                    PlayRailMove()

                if event.button_index == MOUSE_BUTTON_WHEEL_DOWN && slotData.zoom != 1:
                    slotData.zoom -= 1
                    PlayRailMove()



    if Input.is_action_just_pressed("secondary_optic"):
        if gameData.isAiming && activeOptic != null && activeOptic.attachmentData.secondary && activeOptic.secondary != null:
            gameData.secondaryOptic = !gameData.secondaryOptic
            UpdateAimOffset()

func _physics_process(delta):

    if (gameData.freeze
    || gameData.isCaching
    || gameData.isPlacing
    || gameData.isDrawing):
        return


    currentState = animator.get("parameters/playback").get_current_node()


    if currentState == "Idle":
        FireInput()
        FireTimer(delta)
        FireImpulse(delta)
        Reload()
        AmmoCheck()


        gameData.isReloading = false


    if data.weaponAction == "Manual":
        Insert()

func _process(delta):

    ADS(delta)
    Firemode()
    Selector(delta)
    Slide(delta)
    Hammer(delta)



func ADS(delta):

    if gameData.isAiming && !gameData.isColliding && activeOptic:



        if activeOptic.attachmentData.scope && !gameData.secondaryOptic:
            if gameData.PIP:
                ocularOpacity = move_toward(ocularOpacity, 1.0, delta * 5.0)
                reticleSize = activeOptic.attachmentData.reticleSizeP.x
                gameData.aimFOV = gameData.baseFOV - 25.0
                activeOptic.camera.fov = 3.0;
                gameData.isScoped = true
            else:
                ocularOpacity = move_toward(ocularOpacity, 1.0, delta * 5.0)
                reticleSize = activeOptic.attachmentData.reticleSize.x
                gameData.aimFOV = 15.0
                gameData.isScoped = true



        elif activeOptic.attachmentData.scope && gameData.secondaryOptic:
            if gameData.PIP:
                ocularOpacity = move_toward(ocularOpacity, 0.0, delta * 5.0)
                reticleSize = activeOptic.attachmentData.reticleSizeP.x
                gameData.aimFOV = gameData.baseFOV
                gameData.isScoped = false
            else:
                ocularOpacity = move_toward(ocularOpacity, 0.0, delta * 5.0)
                reticleSize = activeOptic.attachmentData.reticleSize.x
                gameData.aimFOV = gameData.baseFOV
                gameData.isScoped = false



        elif activeOptic.attachmentData.variable:

            if slotData.zoom == 3:
                if gameData.PIP:
                    ocularOpacity = move_toward(ocularOpacity, 1.0, delta * 5.0)
                    reticleSize = lerp(reticleSize, activeOptic.attachmentData.reticleSizeP.z, delta * 10.0)
                    activeOptic.camera.fov = lerp(activeOptic.camera.fov, 3.0, delta * 10.0);
                    gameData.aimFOV = gameData.baseFOV - 25.0
                    gameData.isScoped = true
                else:
                    ocularOpacity = move_toward(ocularOpacity, 1.0, delta * 5.0)
                    reticleSize = lerp(reticleSize, activeOptic.attachmentData.reticleSize.z, delta * 10.0)
                    gameData.aimFOV = 10.0
                    gameData.isScoped = true


            elif slotData.zoom == 2:
                if gameData.PIP:
                    ocularOpacity = move_toward(ocularOpacity, 1.0, delta * 5.0)
                    reticleSize = lerp(reticleSize, activeOptic.attachmentData.reticleSizeP.y, delta * 10.0)
                    activeOptic.camera.fov = lerp(activeOptic.camera.fov, 10.0, delta * 10.0);
                    gameData.aimFOV = gameData.baseFOV - 25.0
                    gameData.isScoped = true
                else:
                    ocularOpacity = move_toward(ocularOpacity, 1.0, delta * 5.0)
                    reticleSize = lerp(reticleSize, activeOptic.attachmentData.reticleSize.y, delta * 10.0)
                    gameData.aimFOV = 25.0
                    gameData.isScoped = true


            elif slotData.zoom == 1:
                if gameData.PIP:
                    ocularOpacity = move_toward(ocularOpacity, 1.0, delta * 5.0)
                    reticleSize = lerp(reticleSize, activeOptic.attachmentData.reticleSizeP.x, delta * 10.0)
                    activeOptic.camera.fov = lerp(activeOptic.camera.fov, 18.0, delta * 10.0);
                    gameData.aimFOV = gameData.baseFOV - 25.0
                    gameData.isScoped = false
                else:
                    ocularOpacity = move_toward(ocularOpacity, 1.0, delta * 5.0)
                    reticleSize = lerp(reticleSize, activeOptic.attachmentData.reticleSize.x, delta * 10.0)
                    gameData.aimFOV = gameData.baseFOV
                    gameData.isScoped = false



        else:
            ocularOpacity = move_toward(ocularOpacity, 1.0, delta * 5.0)
            reticleSize = activeOptic.attachmentData.reticleSize.x
            gameData.aimFOV = gameData.baseFOV
            gameData.isScoped = false


    else:
        if activeOptic:
            if activeOptic.attachmentData.scope || activeOptic.attachmentData.variable:
                ocularOpacity = move_toward(ocularOpacity, 0.0, delta * 5.0)
            else:
                ocularOpacity = move_toward(ocularOpacity, 1.0, delta * 5.0)

        gameData.aimFOV = gameData.baseFOV
        gameData.isScoped = false


    if activeOptic != null && activeOptic.reticle != null:
        activeOptic.reticle.set_shader_parameter("size", reticleSize)
        activeOptic.reticle.set_shader_parameter("opacity", ocularOpacity)

func FireTimer(delta):
    if fireTimer < fireRate:
        fireTimer += delta

func Firemode():

    if Input.is_action_just_pressed("firemode"):

        if data.weaponAction == "Semi-Auto":

            if slotData.mode == 1:
                slotData.mode = 2
                gameData.firemode = 2
                PlayFiremode()

            elif slotData.mode == 2:
                slotData.mode = 1
                gameData.firemode = 1
                PlayFiremode()

func FireInput():
    if !gameData.weaponPosition == 2 && !gameData.isAiming && !gameData.isCanted:
        return
    if !slotData.chamber:
        return
    if slotData.state == "Jammed":
        return


    if slotData.mode == 1:
        if Input.is_action_just_pressed(("fire")):
            FireEvent()
            fireImpulse = 0.1
            fireRate = 0.1

    elif slotData.mode == 2:
        if Input.is_action_pressed(("fire")):
            FireEvent()
            fireImpulse = data.fireRate
            fireRate = data.fireRate

func FireEvent():

    if fireTimer < fireRate:
        return


    if Malfunction():
        return


    if data.weaponType == "Shotgun":
        for ray in 6:
            Raycast(1.0)
            raycast.force_raycast_update()

    else: Raycast(0.0)


    if data.weaponAction == "Manual" || data.weaponAction == "Single":
        slotData.casing = true

    else:
        slotData.casing = true
        CasingEject()


    recoil.ApplyRecoil()


    MuzzleEffect()
    PlayFire()
    PlayTail()


    if slotData.amount == 0 || data.weaponAction == "Manual" || data.weaponAction == "Single":
        slotData.chamber = false

    if slotData.amount != 0 && data.weaponAction != "Manual":
        slotData.amount -= 1

    if slotData.condition != 0:
        if randi_range(0, 100) < 10:
            slotData.condition -= 1

    if !slotData.chamber && data.slideLock:
        slideLocked = true

    if !slotData.chamber && hammerLocked:
        hammerLocked = false


    UpdateBullets()


    fireTimer = 0.0

func Malfunction() -> bool:
    var malfunctionRoll = randi_range(1, 100)
    var malfunctionThreshold = 0


    if slotData.condition == 0:
        malfunctionThreshold = 100

    elif slotData.condition < 10:
        malfunctionThreshold = 10

    elif slotData.condition < 25:
        malfunctionThreshold = 5

    elif slotData.condition < 50:
        malfunctionThreshold = 2

    elif slotData.condition >= 50:
        malfunctionThreshold = 0


    if malfunctionRoll <= malfunctionThreshold:
        slotData.state = "Jammed"
        PlayMalfunction()
        return true

    else:
        return false

func FireImpulse(delta):
    if fireImpulseTimer < fireImpulse:
        gameData.isFiring = true
        fireImpulseTimer += delta
    else:
        gameData.isFiring = false
        fireImpulseTimer = 0.0
        fireImpulse = 0.0

func Raycast(spread: float):

    raycast.rotation_degrees.x = randf_range( - spread, spread)
    raycast.rotation_degrees.y = randf_range( - spread, spread)


    if raycast.is_colliding():

        var hitCollider = raycast.get_collider()
        var hitPoint = raycast.get_collision_point()
        var hitNormal = raycast.get_collision_normal()
        var hitSurface = raycast.get_collider().get("surface")


        if hitCollider is Hitbox:
            hitCollider.ApplyDamage(data.damage)
            BloodEffect(hitCollider, hitPoint, hitNormal)
            return


        elif hitCollider.owner is Mine:
            hitCollider.owner.InstantDetonate()
            return


        elif hitCollider is Grenade:
            hitCollider.Detonate()
            return


        elif hitCollider is Pickup:
            if hitCollider.slotData.itemData.type == "Grenade":
                hitCollider.Explode()
                return


        HitEffect(hitCollider, hitPoint, hitNormal, hitSurface)

func Reload():
    if Input.is_action_just_pressed("reload"):

        if gameData.isOccupied: return


        gameData.isFiring = false



        if slotData.state == "Jammed":
            if !gameData.isClearing:
                gameData.isClearing = true
                PlayMalfunctionClear()
                await get_tree().create_timer(2.0, false).timeout;
                gameData.isClearing = false
                slotData.state = ""
                return
            return



        if data.weaponAction == "Manual" && !gameData.isInserting:

            if slotData.amount != 0 && !slotData.chamber:
                PlayReload()
                gameData.isReloading = true
                animator["parameters/conditions/Reload"] = true
                await get_tree().create_timer(0.1, false).timeout;
                animator["parameters/conditions/Reload"] = false
                slotData.chamber = true
                slotData.amount -= 1
                UpdateBullets()
                return
            return



        if data.weaponAction == "Single" && !gameData.isInserting:

            if interface.GetAmmo(data):

                if !slotData.chamber && !slotData.casing:
                    PlayReloadEmpty()
                    cartridge.show()
                    gameData.isReloading = true
                    animator["parameters/conditions/Reload_Empty"] = true
                    await get_tree().create_timer(0.1, false).timeout;
                    animator["parameters/conditions/Reload_Empty"] = false
                    slotData.chamber = true
                    return

                elif !slotData.chamber && slotData.casing:
                    PlayReloadTactical()
                    cartridge.show()
                    gameData.isReloading = true
                    animator["parameters/conditions/Reload_Tactical"] = true
                    await get_tree().create_timer(0.1, false).timeout;
                    animator["parameters/conditions/Reload_Tactical"] = false
                    slotData.casing = false
                    slotData.chamber = true
                    return
            return




        if !magazine.visible && !slotData.chamber:
            if interface.GetMagazine(data, weaponSlot, false):
                PlayMagazineAttachEmpty()
                gameData.isReloading = true
                animator["parameters/conditions/Magazine_Attach_Empty"] = true
                await get_tree().create_timer(0.1, false).timeout;
                animator["parameters/conditions/Magazine_Attach_Empty"] = false
                slotData.chamber = true
                magazine.show()
                UpdateBullets()
                return




        if !magazine.visible && slotData.chamber:
            if interface.GetMagazine(data, weaponSlot, false):
                PlayMagazineAttachTactical()
                gameData.isReloading = true
                animator["parameters/conditions/Magazine_Attach_Tactical"] = true
                await get_tree().create_timer(0.1, false).timeout;
                animator["parameters/conditions/Magazine_Attach_Tactical"] = false
                magazine.show()
                UpdateBullets()
                return




        if magazine.visible && !slotData.chamber:
            if interface.GetMagazine(data, weaponSlot, true):
                PlayReloadEmpty()
                gameData.isReloading = true
                animator["parameters/conditions/Reload_Empty"] = true
                await get_tree().create_timer(0.1, false).timeout;
                animator["parameters/conditions/Reload_Empty"] = false
                slotData.chamber = true
                return




        if magazine.visible && slotData.chamber:
            if interface.GetMagazine(data, weaponSlot, true):
                PlayReloadTactical()
                gameData.isReloading = true
                animator["parameters/conditions/Reload_Tactical"] = true
                await get_tree().create_timer(0.1, false).timeout;
                animator["parameters/conditions/Reload_Tactical"] = false
                return

func Magazine(attach: bool, animate: bool):

    if !magazine:
        return


    if !animate:
        if attach:
            magazine.show()
            return
        else:
            magazine.hide()
            return





    if attach && data.slideLock && slideLocked && slotData.amount != 0:



        if !magazine.visible:
            PlayMagazineAttachEmpty()
            animator["parameters/conditions/Magazine_Attach_Empty"] = true
            await get_tree().create_timer(0.1, false).timeout;
            animator["parameters/conditions/Magazine_Attach_Empty"] = false
            magazine.show()
            slotData.chamber = true
            weaponSlot.get_child(0).UpdateDetails()
            UpdateBullets()
            return




        if magazine.visible:
            PlayReloadEmpty()
            animator["parameters/conditions/Reload_Empty"] = true
            await get_tree().create_timer(0.1, false).timeout;
            animator["parameters/conditions/Reload_Empty"] = false
            slotData.chamber = true
            weaponSlot.get_child(0).UpdateDetails()
            return





    if attach && !magazine.visible && !slotData.chamber:
        if slotData.amount == 0:
            PlayMagazineAttachTactical()
            animator["parameters/conditions/Magazine_Attach_Tactical"] = true
            await get_tree().create_timer(0.1, false).timeout;
            animator["parameters/conditions/Magazine_Attach_Tactical"] = false
            magazine.show()
            UpdateBullets()
            return





    if attach && !magazine.visible && slotData.chamber:
        PlayMagazineAttachTactical()
        animator["parameters/conditions/Magazine_Attach_Tactical"] = true
        await get_tree().create_timer(0.1, false).timeout;
        animator["parameters/conditions/Magazine_Attach_Tactical"] = false
        magazine.show()
        UpdateBullets()
        return





    if attach && !magazine.visible && !slotData.chamber:
        if slotData.amount != 0:
            PlayMagazineAttachEmpty()
            animator["parameters/conditions/Magazine_Attach_Empty"] = true
            await get_tree().create_timer(0.1, false).timeout;
            animator["parameters/conditions/Magazine_Attach_Empty"] = false
            magazine.show()
            slotData.chamber = true
            slotData.amount -= 1
            weaponSlot.get_child(0).UpdateDetails()
            UpdateBullets()
            return





    if attach && magazine.visible && slotData.chamber:
        PlayReloadTactical()
        animator["parameters/conditions/Reload_Tactical"] = true
        await get_tree().create_timer(0.1, false).timeout;
        animator["parameters/conditions/Reload_Tactical"] = false
        weaponSlot.get_child(0).UpdateDetails()
        return





    if attach && magazine.visible && !slotData.chamber:
        if slotData.amount == 0:
            PlayReloadTactical()
            animator["parameters/conditions/Reload_Tactical"] = true
            await get_tree().create_timer(0.1, false).timeout;
            animator["parameters/conditions/Reload_Tactical"] = false
            weaponSlot.get_child(0).UpdateDetails()
            return





    if attach && magazine.visible && !slotData.chamber:
        if slotData.amount != 0:
            PlayReloadEmpty()
            animator["parameters/conditions/Reload_Empty"] = true
            await get_tree().create_timer(0.1, false).timeout;
            animator["parameters/conditions/Reload_Empty"] = false
            slotData.chamber = true
            slotData.amount -= 1
            weaponSlot.get_child(0).UpdateDetails()
            return





    if !attach && magazine.visible:
        PlayMagazineDetach()
        animator["parameters/conditions/Magazine_Detach"] = true
        await get_tree().create_timer(0.1, false).timeout;
        animator["parameters/conditions/Magazine_Detach"] = false
        slotData.amount = 0
        weaponSlot.get_child(0).UpdateDetails()
        await get_tree().create_timer(1.5, false).timeout;
        magazine.hide()
        return

func Insert():

    if gameData.isInspecting || gameData.isReloading || gameData.isFiring || gameData.isClearing:
        return



    if Input.is_action_just_pressed(("prepare")):

        if !gameData.isInserting && currentState == "Idle":
            PlayInsertStart()
            animator["parameters/conditions/Insert_Start"] = true
            animator["parameters/conditions/Insert_End"] = false
            gameData.isInserting = true
            return

        if gameData.isInserting && currentState == "Insert_Idle":
            PlayInsertEnd()
            animator["parameters/conditions/Insert_Start"] = false
            animator["parameters/conditions/Insert_End"] = true
            gameData.isInserting = false


            if data.weaponType == "Bolt":
                if slotData.amount != 0 && !slotData.chamber:
                    slotData.chamber = true
                    slotData.amount -= 1
            return



    if Input.is_action_just_pressed(("insert")) && gameData.isInserting && currentState == "Insert_Idle":

        if slotData.amount == data.maxAmount:
            return

        if interface.GetAmmo(data):
            PlayInsert()
            animator["parameters/conditions/Insert"] = true
            await get_tree().create_timer(0.1, false).timeout;
            animator["parameters/conditions/Insert"] = false
            slotData.amount += 1

func AmmoCheck():

    if gameData.isInspecting || gameData.isReloading || gameData.isFiring || gameData.isClearing:
        return

    if Input.is_action_just_pressed("ammo_check"):

        if data.weaponAction != "Manual" && data.weaponAction != "Single":
            if !magazine.visible:
                return


        gameData.isFiring = false


        UpdateBullets()
        UpdateHUD()
        PlayAmmoCheck()
        gameData.isChecking = true
        gameData.weaponPosition = 2
        animator["parameters/conditions/Ammo_Check"] = true
        await get_tree().create_timer(0.5, false).timeout;
        animator["parameters/conditions/Ammo_Check"] = false
        await get_tree().create_timer(1.5, false).timeout;
        gameData.isChecking = false



func Selector(delta):

    if !dynamicSelector: return


    if slotData.mode == 1:
        selectorValue = move_toward(selectorValue, deg_to_rad(data.selectorRotation.x), 5.0 / delta)
    elif slotData.mode == 2:
        selectorValue = move_toward(selectorValue, deg_to_rad(data.selectorRotation.y), 5.0 / delta)


    var currentPose = skeleton.get_bone_global_pose_no_override(selectorIndex)
    var updatedPose: Transform3D


    if data.selectorDirection == 0:
        updatedPose = currentPose.rotated_local(Vector3.RIGHT, selectorValue)
    elif data.selectorDirection == 1:
        updatedPose = currentPose.rotated_local(Vector3.UP, selectorValue)
    else:
        updatedPose = currentPose.rotated_local(Vector3.FORWARD, selectorValue)


    skeleton.set_bone_global_pose_override(selectorIndex, updatedPose, 1.0, true)

func Slide(delta):

    if !dynamicSlide: return


    if gameData.isFiring || slideLocked:
        slideValue = move_toward(slideValue, data.slideMovement, delta * data.slideSpeed)
    else:
        slideValue = move_toward(slideValue, data.slideDefault, delta * data.slideSpeed)


    var currentPose = skeleton.get_bone_global_pose_no_override(slideIndex)
    var updatedPose: Transform3D


    if data.slideDirection == 0:
        updatedPose = currentPose.translated_local(Vector3(slideValue, 0, 0))
    elif data.slideDirection == 1:
        updatedPose = currentPose.translated_local(Vector3(0, slideValue, 0))
    else:
        updatedPose = currentPose.translated_local(Vector3(0, 0, slideValue))


    skeleton.set_bone_global_pose_override(slideIndex, updatedPose, 1.0, true)


    if activeOptic != null && activeOptic.slideFollow:
        var slideTransform = skeleton.get_bone_global_pose(slideIndex)
        var slidePosition = skeleton.to_global(slideTransform.origin + slideTransform.basis.y * activeOptic.slideOffsetY + slideTransform.basis.z * activeOptic.slideOffsetZ)
        activeOptic.global_position = slidePosition

func Hammer(delta):

    if !dynamicHammer: return


    if !hammerLocked:
        hammerValue = move_toward(hammerValue, deg_to_rad(data.hammerRotation.x), 5.0 / delta)
    elif hammerLocked:
        hammerValue = move_toward(hammerValue, deg_to_rad(data.hammerRotation.y), 5.0 / delta)


    var currentPose = skeleton.get_bone_global_pose_no_override(hammerIndex)
    var updatedPose: Transform3D


    if data.hammerDirection == 0:
        updatedPose = currentPose.rotated_local(Vector3.RIGHT, hammerValue)
    elif data.hammerDirection == 1:
        updatedPose = currentPose.rotated_local(Vector3.UP, hammerValue)
    else:
        updatedPose = currentPose.rotated_local(Vector3.FORWARD, hammerValue)


    skeleton.set_bone_global_pose_override(hammerIndex, updatedPose, 1.0, true)



func HitEffect(hitCollider, hitPoint, hitNormal, hitSurface):

    var hit = rigManager.hitDefault.instantiate()
    hitCollider.add_child(hit)
    hit.global_position = hitPoint
    hit.scale = Vector3.ONE / hitCollider.global_transform.basis.get_scale()


    if hitNormal == Vector3(0, 1, 0): hit.look_at(hitPoint + hitNormal, Vector3.RIGHT)
    elif hitNormal == Vector3(0, -1, 0): hit.look_at(hitPoint + hitNormal, Vector3.RIGHT)
    else: hit.look_at(hitPoint + hitNormal, Vector3.DOWN)


    hit.global_rotation.z = randf_range(-360, 360)


    hit.Emit()
    hit.PlayHit(hitSurface)

func BloodEffect(hitCollider, hitPoint, hitNormal):

    var hit = rigManager.hitBlood.instantiate()
    hitCollider.add_child(hit)
    hit.global_position = hitPoint


    if hitNormal == Vector3(0, 1, 0): hit.look_at(hitPoint + hitNormal, Vector3.RIGHT)
    elif hitNormal == Vector3(0, -1, 0): hit.look_at(hitPoint + hitNormal, Vector3.RIGHT)
    else: hit.look_at(hitPoint + hitNormal, Vector3.DOWN)


    hit.global_rotation.z = randf_range(-360, 360)


    hit.Emit()

func MuzzleEffect():

    if activeMuzzle == null && !data.nativeSuppressor:

        rigManager.flash = true


        var flash = rigManager.muzzleFlash.instantiate()
        muzzle.add_child(flash)
        flash.Emit(true, 0.06)


    var smoke = rigManager.muzzleSmoke.instantiate()
    muzzle.add_child(smoke)
    smoke.Emit(true, 0.2)

func CasingEject():

    if data.casing == 1 && slotData.casing:
        var casing = rigManager.casingPistol.instantiate()
        ejector.add_child(casing)
        casing.Emit(false, 1.0)
        slotData.casing = false
        PlayCasingDrop()


    elif data.casing == 2 && slotData.casing:
        var casing = rigManager.casingRifle.instantiate()
        ejector.add_child(casing)
        casing.Emit(false, 1.0)
        slotData.casing = false
        PlayCasingDrop()


    elif data.casing == 3 && slotData.casing:
        var casing = rigManager.casingShotgun.instantiate()
        ejector.add_child(casing)
        casing.Emit(false, 1.0)
        slotData.casing = false
        PlayCasingDrop()



func HammerLock(state: bool):
    if state:
        hammerLocked = true
    else:
        hammerLocked = false

func SlideLock(state: bool):
    if state:
        slideLocked = true
    else:
        slideLocked = false



func UpdateMuzzlePosition():
    if activeMuzzle != null:
        muzzle.position = muzzle.position + Vector3(0, 0, 0.2)
    else:
        muzzle.position = muzzlePosition

func UpdateAimOffset():

    if activeOptic != null:

        if gameData.secondaryOptic && activeOptic.secondary:
            aimOffset = activeOptic.position.y + activeOptic.secondary.position.y
        else:
            aimOffset = activeOptic.position.y

        if data.foldSights:
            skeleton.set_bone_pose_rotation(backSightIndex, Quaternion.from_euler(Vector3(data.foldSightsRotation, 0, 0)))
            skeleton.set_bone_pose_rotation(frontSightIndex, Quaternion.from_euler(Vector3(data.foldSightsRotation, 0, 0)))


    else:
        aimOffset = 0.0

        if data.foldSights:
            skeleton.set_bone_pose_rotation(backSightIndex, Quaternion.from_euler(Vector3(0, 0, 0)))
            skeleton.set_bone_pose_rotation(frontSightIndex, Quaternion.from_euler(Vector3(0, 0, 0)))

func ResetOpticPosition():
    if activeOptic != null:
        activeOptic.position.z = activeOptic.defaultPosition
        gameData.secondaryOptic = false

func UpdateBullets():

    if bullets:
        if slotData.amount == 0:
            bullets.get_child(0).hide()
            bullets.get_child(1).hide()
        elif slotData.amount == 1:
            bullets.get_child(0).hide()
            bullets.get_child(1).show()
        elif slotData.amount > 1:
            bullets.get_child(0).show()
            bullets.get_child(1).show()


    if cartridge:
        if slotData.chamber:
            cartridge.show()
        else:
            cartridge.hide()

func UpdateBulletsDetach(amount):
    if bullets:
        if amount == 0:
            bullets.get_child(0).hide()
            bullets.get_child(1).hide()
        elif amount == 1:
            bullets.get_child(0).hide()
            bullets.get_child(1).show()
        elif amount > 1:
            bullets.get_child(0).show()
            bullets.get_child(1).show()

func UpdateHUD():
    var HUD = get_tree().current_scene.get_node("/root/Map/Core/UI/HUD")

    HUD.chamber.get_child(0).get_child(0).text = str(int(slotData.chamber))

    if magazine || data.weaponAction == "Manual":
        HUD.magazine.get_child(0).get_child(0).text = str(slotData.amount)

func GetAnimationLength():
    var activeState = animator.get("parameters/playback").get_current_node()
    var animationNode = animator.tree_root.get_node(activeState) as AnimationNodeAnimation
    var animationName = animationNode.animation
    var animation = animations.get_animation(animationName)
    var animationLength = animation.length
    return animationLength



func PlayFire():

    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)


    if activeMuzzle != null:
        audio.PlayInstance(data.fireSuppressed)

    else:

        if slotData.mode == 1: audio.PlayInstance(data.fireSemi)
        elif slotData.mode == 2: audio.PlayInstance(data.fireAuto)

func PlayTail():

    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)


    if activeMuzzle != null:

        if gameData.indoor && data.tailIndoorSuppressed:
            audio.PlayInstance(data.tailIndoorSuppressed)

        elif data.tailOutdoorSuppressed:
            audio.PlayInstance(data.tailOutdoorSuppressed)

    else:

        if gameData.indoor && data.tailIndoor:
            audio.PlayInstance(data.tailIndoor)

        elif data.tailOutdoor:
            audio.PlayInstance(data.tailOutdoor)

func PlayCharge():
    if data.charge:
        var audio = audioInstance2D.instantiate()
        add_child(audio)
        audio.PlayInstance(data.charge)

func PlayMagazineAttachEmpty():
    if data.magazineAttachEmpty:
        var audio = audioInstance2D.instantiate()
        add_child(audio)
        audio.PlayInstance(data.magazineAttachEmpty)

func PlayMagazineAttachTactical():
    if data.magazineAttachTactical:
        var audio = audioInstance2D.instantiate()
        add_child(audio)
        audio.PlayInstance(data.magazineAttachTactical)

func PlayMagazineDetach():
    if data.magazineDetach:
        var audio = audioInstance2D.instantiate()
        add_child(audio)
        audio.PlayInstance(data.magazineDetach)

func PlayAmmoCheck():
    if data.ammoCheck:
        var audio = audioInstance2D.instantiate()
        add_child(audio)
        audio.PlayInstance(data.ammoCheck)

func PlayReloadEmpty():
    if data.reloadEmpty:
        var audio = audioInstance2D.instantiate()
        add_child(audio)
        audio.PlayInstance(data.reloadEmpty)

func PlayReloadTactical():
    if data.reloadTactical:
        var audio = audioInstance2D.instantiate()
        add_child(audio)
        audio.PlayInstance(data.reloadTactical)

func PlayInsertStart():
    if data.insertStart:
        var audio = audioInstance2D.instantiate()
        add_child(audio)
        audio.PlayInstance(data.insertStart)

func PlayInsertEnd():
    if data.insertEnd:
        var audio = audioInstance2D.instantiate()
        add_child(audio)
        audio.PlayInstance(data.insertEnd)

func PlayInsert():
    if data.insert:
        var audio = audioInstance2D.instantiate()
        add_child(audio)
        audio.PlayInstance(data.insert)

func PlayReload():
    if data.reload:
        var audio = audioInstance2D.instantiate()
        add_child(audio)
        audio.PlayInstance(data.reload)

func PlayMalfunction():
    var malfunction = audioInstance2D.instantiate()
    add_child(malfunction)
    malfunction.PlayInstance(audioLibrary.malfunction)

func PlayMalfunctionClear():
    var malfunction = audioInstance2D.instantiate()
    add_child(malfunction)
    malfunction.PlayInstance(audioLibrary.malfunctionClearRifle)

func PlayInspectStart():
    var inspectStart = audioInstance2D.instantiate()
    add_child(inspectStart)
    inspectStart.PlayInstance(audioLibrary.inspectStart)

func PlayInspectRotate():
    var inspectRotate = audioInstance2D.instantiate()
    add_child(inspectRotate)
    inspectRotate.PlayInstance(audioLibrary.inspectRotate)

func PlayInspectEnd():
    var inspectEnd = audioInstance2D.instantiate()
    add_child(inspectEnd)
    inspectEnd.PlayInstance(audioLibrary.inspectEnd)

func PlayFiremode():

    if slotData.mode == 1:
        var firemode = audioInstance2D.instantiate()
        add_child(firemode)
        firemode.PlayInstance(audioLibrary.firemodeSemi)

    elif slotData.mode == 2:
        var firemode = audioInstance2D.instantiate()
        add_child(firemode)
        firemode.PlayInstance(audioLibrary.firemodeAuto)

func PlayRailMove():
    var firemode = audioInstance2D.instantiate()
    add_child(firemode)
    firemode.PlayInstance(audioLibrary.UIClick)

func PlayCasingDrop():

    await get_tree().create_timer(0.5, false).timeout;


    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)


    if gameData.surface == "Grass" || gameData.surface == "Dirt":
        if data.casing == 3:
            audio.PlayInstance(audioLibrary.shellDropSoft)
        else:
            audio.PlayInstance(audioLibrary.casingDropSoft)


    elif gameData.surface == "Wood":
        if data.casing == 3:
            audio.PlayInstance(audioLibrary.shellDropHard)
        else:
            audio.PlayInstance(audioLibrary.casingDropWood)


    else:
        if data.casing == 3:
            audio.PlayInstance(audioLibrary.shellDropHard)
        else:
            audio.PlayInstance(audioLibrary.casingDropHard)
