extends Control
class_name Inspect


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export var slot: PackedScene


@onready var activeMuzzle = $Muzzle / Panel / Active
@onready var activeOptic = $Optic / Panel / Active

@onready var availableMuzzles = $Muzzle / Panel / Available
@onready var availableOptics = $Optic / Panel / Available


@onready var muzzle = $Muzzle
@onready var optic = $Optic
@onready var stats = $Stats
@onready var ammo = $Ammo


@onready var condition = $Stats / Panel / Values / Condition
@onready var damage = $Stats / Panel / Values / Damage
@onready var verticalRecoil = $Stats / Panel / Values / V_Recoil
@onready var horizontalRecoil = $Stats / Panel / Values / H_Recoil
@onready var kick = $Stats / Panel / Values / Kick
@onready var weight = $Stats / Panel / Values / Weight


@onready var ammoCount = $Ammo / Panel / Count


@onready var interface = $"../Interface"
@onready var weapons = $"../../Camera/Weapons"


var weapon


var available: Array[ItemData]
var recentlyActivated: ItemData

func _ready():
    HideWeaponUI()

func ShowWeaponUI():
    ClearAvailableAttachments()
    ClearActiveAttachments()
    GetCurrentWeaponRig()
    GetAvailableAttachments()
    GetActiveAttachments()
    GetWeaponStats()
    GetAmmoCount()

    if weapon.weaponData.muzzleSlot:
        muzzle.show()
    if weapon.weaponData.opticSlot:
        optic.show()
    if weapon.weaponData.statsSlot:
        stats.show()
    if weapon.weaponData.ammoSlot:
        ammo.show()

func HideWeaponUI():
    ClearAvailableAttachments()
    ClearActiveAttachments()
    muzzle.hide()
    optic.hide()
    stats.hide()
    ammo.hide()

func GetAvailableAttachments():

    for inventorySlot in interface.inventoryGrid.get_children():


        if inventorySlot.slotData.itemData:


            if inventorySlot.slotData.itemData is AttachmentData:
                var attachmentData: AttachmentData = inventorySlot.slotData.itemData


                for attachment in weapon.weaponData.attachments:


                    if attachment.file == attachmentData.file:


                        if attachmentData.category == attachmentData.Category.Muzzle:
                            var attachmentSlot = slot.instantiate()
                            availableMuzzles.add_child(attachmentSlot)
                            attachmentSlot.SetSlotData(inventorySlot.slotData)
                            attachmentSlot.ConnectInspect(self)
                            attachmentSlot.type = attachmentSlot.SlotType.Attachment


                        if attachmentData.category == attachmentData.Category.Optic:
                            var attachmentSlot = slot.instantiate()
                            availableOptics.add_child(attachmentSlot)
                            attachmentSlot.SetSlotData(inventorySlot.slotData)
                            attachmentSlot.ConnectInspect(self)
                            attachmentSlot.type = attachmentSlot.SlotType.Attachment

func GetActiveAttachments():
    if gameData.primary:
        var primarySlot = interface.equipmentGrid.get_child(0)


        if primarySlot.slotData.muzzle:


            var attachmentSlot = slot.instantiate()
            activeMuzzle.add_child(attachmentSlot)
            attachmentSlot.ConnectInspect(self)
            attachmentSlot.type = attachmentSlot.SlotType.Attachment


            var slotData = SlotData.new()
            slotData.itemData = primarySlot.slotData.muzzle
            attachmentSlot.SetSlotData(slotData)
            attachmentSlot.SetActiveAttachment()


        if primarySlot.slotData.optic:


            var attachmentSlot = slot.instantiate()
            activeOptic.add_child(attachmentSlot)
            attachmentSlot.ConnectInspect(self)
            attachmentSlot.type = attachmentSlot.SlotType.Attachment


            var slotData = SlotData.new()
            slotData.itemData = primarySlot.slotData.optic
            attachmentSlot.SetSlotData(slotData)
            attachmentSlot.SetActiveAttachment()

    elif gameData.secondary:
        var secondarySlot = interface.equipmentGrid.get_child(1)


        if secondarySlot.slotData.muzzle:


            var attachmentSlot = slot.instantiate()
            activeMuzzle.add_child(attachmentSlot)
            attachmentSlot.ConnectInspect(self)
            attachmentSlot.type = attachmentSlot.SlotType.Attachment


            var slotData = SlotData.new()
            slotData.itemData = secondarySlot.slotData.muzzle
            attachmentSlot.SetSlotData(slotData)
            attachmentSlot.SetActiveAttachment()


        if secondarySlot.slotData.optic:


            var attachmentSlot = slot.instantiate()
            activeOptic.add_child(attachmentSlot)
            attachmentSlot.ConnectInspect(self)
            attachmentSlot.type = attachmentSlot.SlotType.Attachment


            var slotData = SlotData.new()
            slotData.itemData = secondarySlot.slotData.optic
            attachmentSlot.SetSlotData(slotData)
            attachmentSlot.SetActiveAttachment()

func ClearAvailableAttachments():
    if availableMuzzles.get_child_count() != 0:
        for muzzleSlot in availableMuzzles.get_children():
            availableMuzzles.remove_child(muzzleSlot)
            muzzleSlot.queue_free()

    if availableOptics.get_child_count() != 0:
        for opticSlot in availableOptics.get_children():
            availableOptics.remove_child(opticSlot)
            opticSlot.queue_free()

func ClearActiveAttachments():
    if activeMuzzle.get_child_count() != 0:
        for muzzleSlot in activeMuzzle.get_children():
            activeMuzzle.remove_child(muzzleSlot)
            muzzleSlot.queue_free()

    if activeOptic.get_child_count() != 0:
        for opticSlot in activeOptic.get_children():
            activeOptic.remove_child(opticSlot)
            opticSlot.queue_free()

func GetCurrentWeaponRig():
    weapon = weapons.get_child(0)

func GetWeaponStats():
    var slotData = interface.equipmentGrid.get_child(0).slotData

    if slotData.condition <= 25:
        condition.add_theme_color_override("font_color", Color.RED)
    elif slotData.condition <= 50 && slotData.condition > 25:
        condition.add_theme_color_override("font_color", Color.YELLOW)
    else:
        condition.add_theme_color_override("font_color", Color.GREEN)

    condition.text = str(slotData.condition) + "%"

    if weapon.isUpgraded:
        damage.text = str(weapon.weaponData.upgrade.damage)
        verticalRecoil.text = str(weapon.weaponData.upgrade.verticalRecoil * 10)
        horizontalRecoil.text = str(weapon.weaponData.upgrade.horizontalRecoil * 10)
        kick.text = str(weapon.weaponData.upgrade.kick * 10)
        weight.text = str(weapon.weaponData.upgrade.weight)
    else:
        damage.text = str(weapon.weaponData.damage)
        verticalRecoil.text = str(weapon.weaponData.verticalRecoil * 10)
        horizontalRecoil.text = str(weapon.weaponData.horizontalRecoil * 10)
        kick.text = str(weapon.weaponData.kick * 10)
        weight.text = str(weapon.weaponData.weight)

func GetAmmoCount():
    if gameData.primary:
        ammoCount.text = str(interface.equipmentGrid.get_child(0).slotData.ammo)
    elif gameData.secondary:
        ammoCount.text = str(interface.equipmentGrid.get_child(1).slotData.ammo)

func ActivateAttachment(slotData: SlotData, index: int):

    var attachmentData: AttachmentData = slotData.itemData


    interface.RemoveAttachment(attachmentData)


    interface.AddActiveAttachment(attachmentData)
    recentlyActivated = attachmentData




    if weapon.attachments.get_child_count() != 0:
        for attachment in weapon.attachments.get_children():
            if attachment.name == attachmentData.file:


                if attachmentData.category == attachmentData.Category.Muzzle:
                    weapon.activeMuzzle = attachment
                    weapon.UpdateMuzzlePosition()


                elif attachmentData.category == attachmentData.Category.Optic:
                    weapon.activeOptic = attachment
                    weapon.ResetOpticPosition()
                    weapon.UpdateAimOffset()

                attachment.visible = true
                AttachAudio()




    if attachmentData.category == attachmentData.Category.Muzzle:

        if activeMuzzle.get_child_count() != 0:
            ResetActiveAttachment(activeMuzzle.get_child(0).slotData)


        availableMuzzles.get_child(index).reparent(activeMuzzle)
        activeMuzzle.get_child(0).SetActiveAttachment()


    elif attachmentData.category == attachmentData.Category.Optic:

        if activeOptic.get_child_count() != 0:
            ResetActiveAttachment(activeOptic.get_child(0).slotData)


        availableOptics.get_child(index).reparent(activeOptic)
        activeOptic.get_child(0).SetActiveAttachment()




    if weapon.weaponData.useMount && attachmentData.category == attachmentData.Category.Optic && !attachmentData.hasMount:
        for attachment in weapon.attachments.get_children():
            if attachment.name == "Mount":
                attachment.visible = true

func DeactivateAttachment(slotData: SlotData, index: int):

    var attachmentData: AttachmentData = slotData.itemData


    var newSlotData = SlotData.new()
    newSlotData.itemData = attachmentData




    if interface.ReturnAttachment(newSlotData):


        interface.RemoveActiveAttachment(attachmentData)


        if weapon.attachments.get_child_count() != 0:
            for attachment in weapon.attachments.get_children():
                if attachment.name == attachmentData.file:
                    attachment.visible = false
                    AttachAudio()


                    if attachmentData.category == attachmentData.Category.Muzzle:
                        weapon.activeMuzzle = null
                        weapon.UpdateMuzzlePosition()


                    elif attachmentData.category == attachmentData.Category.Optic:
                        weapon.ResetOpticPosition()
                        weapon.activeOptic = null
                        weapon.UpdateAimOffset()




        if attachmentData.category == attachmentData.Category.Muzzle:
            activeMuzzle.get_child(index).SetAvailableAttachment()
            activeMuzzle.get_child(index).reparent(availableMuzzles)


        elif attachmentData.category == attachmentData.Category.Optic:
            activeOptic.get_child(index).SetAvailableAttachment()
            activeOptic.get_child(index).reparent(availableOptics)




        if weapon.weaponData.useMount && attachmentData.category == attachmentData.Category.Optic:
            for attachment in weapon.attachments.get_children():
                if attachment.name == "Mount":
                    attachment.visible = false

func ResetActiveAttachment(slotData: SlotData):

    var attachmentData: AttachmentData = slotData.itemData


    var newSlotData = SlotData.new()
    newSlotData.itemData = attachmentData




    interface.ReturnAttachment(newSlotData)




    if recentlyActivated.file != attachmentData.file:

        if weapon.attachments.get_child_count() != 0:
            for attachment in weapon.attachments.get_children():
                if attachment.name == attachmentData.file:
                    attachment.visible = false




    if attachmentData.category == attachmentData.Category.Muzzle:
        activeMuzzle.get_child(0).SetAvailableAttachment()
        activeMuzzle.get_child(0).reparent(availableMuzzles)


    elif attachmentData.category == attachmentData.Category.Optic:
        activeOptic.get_child(0).SetAvailableAttachment()
        activeOptic.get_child(0).reparent(availableOptics)




    if weapon.weaponData.useMount && attachmentData.category == attachmentData.Category.Optic && !attachmentData.hasMount:
        for attachment in weapon.attachments.get_children():
            if attachment.name == "Mount":
                attachment.visible = false

func AttachAudio():
    var attach = audioInstance2D.instantiate()
    add_child(attach)
    attach.PlayInstance(audioLibrary.UIAttach)
