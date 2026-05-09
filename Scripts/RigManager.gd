extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


var muzzleFlash = preload("res://Effects/Muzzle_Flash.tscn")
var muzzleSmoke = preload("res://Effects/Muzzle_Smoke.tscn")
var casingPistol = preload("res://Effects/Casing_Pistol.tscn")
var casingRifle = preload("res://Effects/Casing_Rifle.tscn")
var casingShotgun = preload("res://Effects/Casing_Shotgun.tscn")
var hitDefault = preload("res://Effects/Hit_Default.tscn")
var hitBlood = preload("res://Effects/Hit_Blood.tscn")
var hitKnife = preload("res://Effects/Hit_Knife.tscn")


var defaultGloves = preload("res://Items/Clothing/Gloves_Leather/Files/MT_Gloves_Leather.tres")
var defaultSleeves = preload("res://Items/Clothing/Jacket_M62/Files/MT_Jacket_M62_Sleeves.tres")


@onready var interface = $"../../UI/Interface"


@onready var worldLight = $"../Flash/World"
@onready var FPSLight = $"../Flash/FPS"
var flash = false
var flashTimer = 0.0


var drawTime = 0.2
var drawTimer = 0.0


var primarySlot
var secondarySlot
var knifeSlot
var torsoSlot
var handsSlot
var grenade1Slot
var grenade2Slot

func _ready():

    primarySlot = interface.equipmentUI.get_child(1)
    secondarySlot = interface.equipmentUI.get_child(2)
    knifeSlot = interface.equipmentUI.get_child(3)
    grenade1Slot = interface.equipmentUI.get_child(4)
    grenade2Slot = interface.equipmentUI.get_child(5)
    torsoSlot = interface.equipmentUI.get_child(10)
    handsSlot = interface.equipmentUI.get_child(14)

func _physics_process(delta):

    if Engine.get_physics_frames() % 20:
        Malfunction()


    if (gameData.freeze
    || gameData.isInspecting
    || gameData.isReloading
    || gameData.isInserting
    || gameData.isChecking
    || gameData.isClearing
    || gameData.isSwimming
    || gameData.isSubmerged):
        return


    if Input.is_action_just_pressed(("primary")) && !gameData.isReloading && !gameData.isDrawing && primarySlot.get_child_count() != 0:
        DrawPrimary(primarySlot.get_child(0).slotData)


    if Input.is_action_just_pressed(("secondary")) && !gameData.isReloading && !gameData.isDrawing && secondarySlot.get_child_count() != 0:
        DrawSecondary(secondarySlot.get_child(0).slotData)


    if Input.is_action_just_pressed(("knife")) && !gameData.isReloading && !gameData.isDrawing && knifeSlot.get_child_count() != 0:
        DrawKnife(knifeSlot.get_child(0).slotData)


    if Input.is_action_just_pressed(("grenade_1")) && !gameData.isReloading && !gameData.isDrawing && grenade1Slot.get_child_count() != 0:
        DrawGrenade1(grenade1Slot.get_child(0).slotData)


    if Input.is_action_just_pressed(("grenade_2")) && !gameData.isReloading && !gameData.isDrawing && grenade2Slot.get_child_count() != 0:
        DrawGrenade2(grenade2Slot.get_child(0).slotData)


    if gameData.isDrawing:
        drawTimer += delta

        if drawTimer > drawTime:
            gameData.isDrawing = false
            drawTimer = 0.0


    MuzzleFlash(delta)



func DrawPrimary(slotData):

    var state = gameData.primary
    gameData.isDrawing = true


    ClearRig()


    if !state:
        gameData.primary = true
        var primary = Database.get(str(slotData.itemData.file + "_Rig")).instantiate()
        add_child(primary)
        UpdateRig(false)
        PlayEquip()

    else:
        PlayUnequip()

func DrawSecondary(slotData):

    var state = gameData.secondary
    gameData.isDrawing = true


    ClearRig()


    if !state:
        gameData.secondary = true
        var secondary = Database.get(str(slotData.itemData.file + "_Rig")).instantiate()
        add_child(secondary)
        UpdateRig(false)
        PlayEquip()

    else:
        PlayUnequip()

func DrawKnife(slotData):

    var state = gameData.knife
    gameData.isDrawing = true


    ClearRig()


    if !state:
        gameData.knife = true
        var knife = Database.get(str(slotData.itemData.file + "_Rig")).instantiate()
        add_child(knife)
        UpdateRig(false)
        PlayEquip()

    else:
        PlayUnequip()

func DrawGrenade1(slotData):

    var state = gameData.grenade1
    gameData.isDrawing = true


    ClearRig()


    if !state:
        gameData.grenade1 = true
        var grenade = Database.get(str(slotData.itemData.file + "_Rig")).instantiate()
        add_child(grenade)
        UpdateRig(false)
        PlayEquip()

    else:
        ClearRig()

func DrawGrenade2(slotData):

    var state = gameData.grenade2
    gameData.isDrawing = true


    ClearRig()


    if !state:
        gameData.grenade2 = true
        var grenade = Database.get(str(slotData.itemData.file + "_Rig")).instantiate()
        add_child(grenade)
        UpdateRig(false)
        PlayEquip()

    else:
        ClearRig()



func MuzzleFlash(delta):

    if flash:
        flashTimer += delta


        FPSLight.omni_range = 2.0
        worldLight.omni_range = 10.0


        if gameData.TOD == 4:
            FPSLight.light_energy = 1.0
            worldLight.light_energy = 1.0

        else:
            FPSLight.light_energy = 0.5
            worldLight.light_energy = 0.5


        if flashTimer > 0.05:
            FPSLight.omni_range = 0.0
            FPSLight.light_energy = 0.0
            worldLight.omni_range = 0.0
            worldLight.light_energy = 0.0

            flashTimer = 0.0
            flash = false



func UpdateRig(animate):

    if get_child_count() == 0:
        return


    var rig = get_child(get_child_count() - 1)



    if gameData.primary && primarySlot.get_child_count() == 0:
        ClearRig()
        return
    elif gameData.secondary && secondarySlot.get_child_count() == 0:
        ClearRig()
        return
    elif gameData.knife && knifeSlot.get_child_count() == 0:
        ClearRig()
        return
    elif gameData.grenade1 && grenade1Slot.get_child_count() == 0:
        ClearRig()
        return
    elif gameData.grenade2 && grenade2Slot.get_child_count() == 0:
        ClearRig()
        return




    var arms = rig.arms


    if torsoSlot.get_child_count() != 0:
        arms.set_surface_override_material(0, torsoSlot.get_child(0).slotData.itemData.material)
    else:
        arms.set_surface_override_material(0, defaultSleeves)


    if handsSlot.get_child_count() != 0:
        arms.set_surface_override_material(1, handsSlot.get_child(0).slotData.itemData.material)
    else:
        arms.set_surface_override_material(1, defaultGloves)




    if rig is not WeaponRig:
        return


    var slotData: SlotData


    if gameData.primary:
        slotData = primarySlot.get_child(0).slotData
    elif gameData.secondary:
        slotData = secondarySlot.get_child(0).slotData


    for attachment in rig.attachments.get_children():
        attachment.hide()


    rig.activeMuzzle = null
    rig.activeOptic = null
    rig.UpdateMuzzlePosition()
    rig.UpdateAimOffset()


    var muzzle: ItemData
    var optic: ItemData
    var magazine: ItemData
    var laser: ItemData


    for nestedItem in slotData.nested:

        if nestedItem.subtype == "Muzzle":
            muzzle = nestedItem

        if nestedItem.subtype == "Optic":
            optic = nestedItem

        if nestedItem.subtype == "Magazine":
            magazine = nestedItem

        if nestedItem.subtype == "Laser":
            laser = nestedItem


    if magazine && animate:
        rig.Magazine(true, true)
    elif magazine && !animate:
        rig.Magazine(true, false)
    elif !magazine && animate:
        rig.Magazine(false, true)
    elif !magazine && !animate:
        rig.Magazine(false, false)


    if muzzle && rig.attachments.get_child_count() != 0:

        var targetMuzzle = rig.attachments.get_node(muzzle.file)


        if targetMuzzle:
            rig.activeMuzzle = targetMuzzle
            rig.UpdateMuzzlePosition()
            targetMuzzle.show()


    if laser && rig.attachments.get_child_count() != 0:

        var targetLaser = rig.attachments.get_node(laser.file)


        if targetLaser:
            targetLaser.show()


    if optic && rig.attachments.get_child_count() != 0:

        var targetOptic = rig.attachments.get_node(optic.file)


        if targetOptic:
            rig.activeOptic = targetOptic
            rig.activeOptic.position.z = rig.activeOptic.defaultPosition
            rig.activeOptic.position.z += slotData.position
            rig.UpdateAimOffset()
            targetOptic.show()


        if rig.data.useMount && !optic.hasMount:

            var targetMount = rig.attachments.get_node("Mount")


            if targetMount:
                targetMount.show()

func ClearRig():

    if get_child_count() != 0:
        for rig in get_children():
            remove_child(rig)
            rig.queue_free()

    gameData.primary = false
    gameData.secondary = false
    gameData.knife = false
    gameData.grenade1 = false
    gameData.grenade2 = false
    gameData.isDrawing = false
    gameData.isReloading = false
    gameData.isInspecting = false
    gameData.isInserting = false
    gameData.isChecking = false
    gameData.isAiming = false
    gameData.isScoped = false
    gameData.aimFOV = gameData.baseFOV

func Malfunction():

    if get_child_count() != 0:

        var rig = get_child(get_child_count() - 1)

        if rig is WeaponRig:

            var slotData = get_child(get_child_count() - 1).slotData
            if slotData.state == "Jammed": gameData.jammed = true
            else: gameData.jammed = false
        else:
            gameData.jammed = false
    else:
        gameData.jammed = false



func LoadPrimary():
    var primary = Database.get(str(primarySlot.get_child(0).slotData.itemData.file + "_Rig")).instantiate()
    add_child(primary)
    UpdateRig(false)

func LoadSecondary():
    var secondary = Database.get(str(secondarySlot.get_child(0).slotData.itemData.file + "_Rig")).instantiate()
    add_child(secondary)
    UpdateRig(false)

func LoadKnife():
    var knife = Database.get(str(knifeSlot.get_child(0).slotData.itemData.file + "_Rig")).instantiate()
    add_child(knife)
    UpdateRig(false)

func LoadGrenade1():
    var grenade1 = Database.get(str(grenade1Slot.get_child(0).slotData.itemData.file + "_Rig")).instantiate()
    add_child(grenade1)
    UpdateRig(false)

func LoadGrenade2():
    var grenade2 = Database.get(str(grenade2Slot.get_child(0).slotData.itemData.file + "_Rig")).instantiate()
    add_child(grenade2)
    UpdateRig(false)



func PlayEquip():
    var equip = audioInstance2D.instantiate()
    get_tree().get_root().add_child(equip)
    equip.PlayInstance(audioLibrary.equip)

func PlayUnequip():
    var unequip = audioInstance2D.instantiate()
    get_tree().get_root().add_child(unequip)
    unequip.PlayInstance(audioLibrary.unequip)
