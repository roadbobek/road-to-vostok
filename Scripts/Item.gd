extends Panel
class_name Item


var gameData = preload("res://Resources/GameData.tres")


@export var slotData: SlotData


@onready var fill = $Fill
@onready var icon = $Icon
@onready var details = $Details
@onready var abbreviation = $Details / Abbreviation
@onready var condition = $Details / Condition
@onready var amount = $Details / Amount
@onready var frost = $Details / Frost
@onready var error = $Details / Error


@onready var symbols = $Details / Symbols
@onready var modded = $Details / Symbols / Modded
@onready var furniture = $Details / Symbols / Furniture
@onready var returns = $Details / Symbols / Returns
@onready var malfunction = $Details / Symbols / Malfunction
@onready var frozen = $Details / Symbols / Frozen


var interface
var sprite: Sprite2D


var equipSlot = null
var equipped = false
var rotated = false
var optic = false
var magazine = false
var suppressor = false
var selected = false

func Initialize(source, data):

    interface = source


    slotData.Update(data)


    name = slotData.itemData.file
    size = slotData.itemData.size * 64


    var itemSprite = slotData.itemData.tetris.instantiate()
    add_child(itemSprite)
    move_child(itemSprite, 1)
    sprite = itemSprite
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS


    UpdateDetails()
    UpdateAttachments()
    UpdateSprite()

func Display(source, data, showReturns: bool):

    State("Display")


    interface = source


    slotData.Update(data)


    name = slotData.itemData.file
    icon.texture = slotData.itemData.icon


    condition.hide()
    amount.hide()


    for symbol in symbols.get_children():
        symbol.hide()


    abbreviation.text = slotData.itemData.display
    abbreviation.show()


    if interface.trader:
        if slotData.itemData.showAmount && slotData.itemData.subtype != "Magazine":
            amount.text = str(slotData.amount)
            amount.show()


    if slotData.itemData.type == "Furniture":
        furniture.show()


    if showReturns:
        if slotData.itemData.tool || slotData.itemData.repairs || slotData.itemData.returns:
            returns.show()

func Remove(nestedIndex):

    var removeItem = slotData.nested[nestedIndex]


    slotData.nested.remove_at(nestedIndex)


    if removeItem.subtype == "Magazine":

        slotData.amount = 0


    if removeItem.subtype == "Optic":
        slotData.position = 0.0


    UpdateDetails()
    UpdateAttachments()
    UpdateSprite()

    return removeItem

func Combine(itemDragged):

    slotData.nested.append(itemDragged.slotData.itemData)


    if itemDragged.slotData.itemData.subtype == "Magazine":

        if itemDragged.slotData.amount == 0:
            slotData.amount = 0

        elif itemDragged.slotData.amount != 0 && slotData.chamber:
            slotData.amount = itemDragged.slotData.amount

        elif itemDragged.slotData.amount != 0 && !slotData.chamber:
            slotData.amount = itemDragged.slotData.amount - 1
            slotData.chamber = true


    if itemDragged.slotData.itemData.type == "Armor":

        slotData.condition = itemDragged.slotData.condition


    UpdateDetails()
    UpdateAttachments()
    UpdateSprite()

func CombineSwap(itemDragged):

    for nested in slotData.nested:

        if nested.file == itemDragged.slotData.itemData.file:
            slotData.nested.erase(nested)
            return nested


        elif nested.type == itemDragged.slotData.itemData.type && slotData.itemData.type == "Rig":
            slotData.nested.erase(nested)
            return nested


        elif nested.subtype == itemDragged.slotData.itemData.subtype && nested.subtype == "Casette":
            slotData.nested.erase(nested)
            return nested


        elif nested.subtype == itemDragged.slotData.itemData.subtype && slotData.itemData.type == "Weapon":

            if nested.subtype == "Optic":
                slotData.position = 0.0

            slotData.nested.erase(nested)
            return nested

func UpdateSprite():

    if rotated:
        sprite.rotation_degrees = -90
    else:
        sprite.rotation_degrees = 0


    sprite.position = Vector2(size.x / 2, size.y / 2)

    var currentScale = 0.5




    if slotData.itemData.subtype == "Magazine":

        for element in sprite.get_children():

            if element.name == "Cartridge":

                if slotData.amount != 0:
                    element.show()
                else:
                    element.hide()



    if magazine && !optic && !suppressor:
        sprite.scale = Vector2(slotData.itemData.magazineScale, slotData.itemData.magazineScale)

        if rotated:
            sprite.position.x -= slotData.itemData.magazineOffset
        else:
            sprite.position.y -= slotData.itemData.magazineOffset

        currentScale = sprite.scale



    if !magazine && optic && !suppressor:
        sprite.scale = Vector2(slotData.itemData.opticScale, slotData.itemData.opticScale)
        if rotated:
            sprite.position.x -= slotData.itemData.opticOffset
        else:
            sprite.position.y -= slotData.itemData.opticOffset

        currentScale = sprite.scale



    elif !magazine && !optic && suppressor:
        sprite.scale = Vector2(slotData.itemData.suppressorScale, slotData.itemData.suppressorScale)
        if rotated:
            sprite.position.y -= slotData.itemData.suppressorOffset
        else:
            sprite.position.x += slotData.itemData.suppressorOffset

        currentScale = sprite.scale



    elif magazine && optic && !suppressor:
        sprite.scale = Vector2(slotData.itemData.magazineOpticScale, slotData.itemData.magazineOpticScale)
        if rotated:
            sprite.position.x -= slotData.itemData.magazineOpticOffset
        else:
            sprite.position.y -= slotData.itemData.magazineOpticOffset

        currentScale = sprite.scale



    elif magazine && !optic && suppressor:
        sprite.scale = Vector2(slotData.itemData.magazineSuppressorScale, slotData.itemData.magazineSuppressorScale)
        if rotated:
            sprite.position.x -= slotData.itemData.magazineSuppressorOffset.y
            sprite.position.y -= slotData.itemData.magazineSuppressorOffset.x
        else:
            sprite.position.x += slotData.itemData.magazineSuppressorOffset.x
            sprite.position.y -= slotData.itemData.magazineSuppressorOffset.y

        currentScale = sprite.scale



    elif !magazine && optic && suppressor:
        sprite.scale = Vector2(slotData.itemData.opticSuppressorScale, slotData.itemData.opticSuppressorScale)
        if rotated:
            sprite.position.x -= slotData.itemData.opticSuppressorOffset.y
            sprite.position.y -= slotData.itemData.opticSuppressorOffset.x
        else:
            sprite.position.x += slotData.itemData.opticSuppressorOffset.x
            sprite.position.y -= slotData.itemData.opticSuppressorOffset.y

        currentScale = sprite.scale



    elif magazine && optic && suppressor:
        sprite.scale = Vector2(slotData.itemData.fullyModdedScale, slotData.itemData.fullyModdedScale)
        if rotated:
            sprite.position.x -= slotData.itemData.fullyModdedOffset.y
            sprite.position.y -= slotData.itemData.fullyModdedOffset.x
        else:
            sprite.position.x += slotData.itemData.fullyModdedOffset.x
            sprite.position.y -= slotData.itemData.fullyModdedOffset.y

        currentScale = sprite.scale



    if !equipped && !suppressor && !magazine && !optic:
        sprite.scale = Vector2(0.5, 0.5)
        currentScale = sprite.scale



    if equipped:
        var slotSizeX = equipSlot.size.x
        var slotSizeY = equipSlot.size.y
        var spriteSizeX = slotData.itemData.size.x * 64
        var spriteSizeY = slotData.itemData.size.y * 64
        var scalePercentage = currentScale / 0.5


        if spriteSizeX >= spriteSizeY:

            if spriteSizeX > slotSizeX:
                var equipScale = slotSizeX / (spriteSizeX * 2)
                sprite.scale = Vector2(equipScale, equipScale) * scalePercentage
            else:
                sprite.scale = Vector2(0.5, 0.5) * scalePercentage


        elif spriteSizeX < spriteSizeY:

            if spriteSizeY > slotSizeY:
                var equipScale = slotSizeY / (spriteSizeY * 2)
                sprite.scale = Vector2(equipScale, equipScale) * scalePercentage
            else:
                sprite.scale = Vector2(0.5, 0.5) * scalePercentage


        else:
            sprite.scale = Vector2(0.5, 0.5) * scalePercentage

func UpdateDetails():

    abbreviation.hide()
    condition.hide()
    amount.hide()
    frost.hide()
    error.hide()


    for symbol in symbols.get_children():
        symbol.hide()



    if equipped:
        abbreviation.text = slotData.itemData.equipment
        abbreviation.show()
    elif rotated:
        abbreviation.text = slotData.itemData.rotated
        abbreviation.show()
    else:
        abbreviation.text = slotData.itemData.inventory
        abbreviation.show()

    if slotData.itemData.file == "Cat" && gameData.catDead: abbreviation.text += " (RIP)"



    if slotData.itemData.type == "Weapon":
        condition.text = str(int(round(slotData.condition))) + "%"
        condition.show()

        if slotData.chamber && !slotData.casing:
            amount.text = str(slotData.amount) + " + 1"
            amount.show()
        else:
            amount.text = str(slotData.amount) + " + 0"
            amount.show()



    elif slotData.itemData.type == "Armor" || slotData.itemData.type == "Helmet":
        condition.text = str(int(round(slotData.condition))) + "%"
        amount.text = slotData.itemData.rating
        condition.show()
        amount.show()

    elif slotData.itemData.type == "Rig" && slotData.nested.size() != 0:
        for nested in slotData.nested:
            if nested.type == "Armor":
                condition.text = str(int(round(slotData.condition))) + "%"
                amount.text = nested.rating
                condition.show()
                amount.show()



    elif slotData.itemData.showCondition:
        condition.text = str(int(round(slotData.condition))) + "%"
        condition.show()

    elif slotData.itemData.showAmount:
        amount.text = str(slotData.amount)
        amount.show()



    if slotData.nested.size() != 0:
        modded.show()



    if slotData.itemData.type == "Furniture":
        furniture.show()

        if slotData.storage.size() != 0:
            amount.text = "Items: " + str(slotData.storage.size())
            amount.show()



    if slotData.state == "Jammed":
        error.show()
        malfunction.show()



    if slotData.state == "Frozen":
        frost.show()
        frozen.show()



    if condition.visible:
        if slotData.condition > 50: condition.modulate = Color.GREEN
        elif slotData.condition > 25: condition.modulate = Color.YELLOW
        else: condition.modulate = Color.RED

func UpdateAttachments():
    suppressor = false
    magazine = false
    optic = false


    for attachment in sprite.get_children():
        attachment.hide()


    for attachment in sprite.get_children():

        for nestedItem in slotData.nested:

            if attachment.name == nestedItem.file:


                attachment.show()


                if nestedItem.subtype == "Muzzle":
                    suppressor = true


                if nestedItem.subtype == "Magazine":
                    magazine = true


                if nestedItem.subtype == "Optic":
                    optic = true

func Value() -> int:

    var value = slotData.itemData.value


    if slotData.itemData.type == "Ammo" || slotData.itemData.file == "Matches":
        var percentage = float(slotData.amount) / float(slotData.itemData.defaultAmount)
        value *= percentage


    if slotData.itemData.subtype == "Magazine":

        if slotData.amount != 0:

            var ammoData = slotData.itemData.compatible[0]

            var valuePerRound = float(ammoData.value) / float(ammoData.defaultAmount)

            var totalAmmoValue = valuePerRound * slotData.amount

            value += totalAmmoValue


    if slotData.itemData.type == "Weapon":
        if slotData.amount != 0 || slotData.chamber:

            var ammoData = slotData.itemData.ammo

            var valuePerRound = float(ammoData.value) / float(ammoData.defaultAmount)

            var totalAmmoValue = valuePerRound * slotData.amount

            if slotData.chamber: totalAmmoValue += valuePerRound

            value += totalAmmoValue


    if slotData.itemData.type != "Electronics":
        value *= (slotData.condition * 0.01)


    if slotData.itemData.file == "Cat" && gameData.catDead:
        value = 0;


    if slotData.nested.size() != 0:
        for nested in slotData.nested:
            value += nested.value


    return int(roundf(value))

func Weight() -> float:

    var weight = slotData.itemData.weight


    if slotData.itemData.type == "Ammo":
        var percentage = float(slotData.amount) / float(slotData.itemData.defaultAmount)
        weight *= percentage


    if slotData.itemData.subtype == "Magazine":

        if slotData.amount != 0:

            var ammoData = slotData.itemData.compatible[0]

            var weightPerRound = float(ammoData.weight) / float(ammoData.defaultAmount)

            var totalAmmoWeight = weightPerRound * slotData.amount

            weight += totalAmmoWeight


    if slotData.itemData.type == "Weapon":
        if slotData.amount != 0 || slotData.chamber:

            var ammoData = slotData.itemData.ammo

            var weightPerRound = float(ammoData.weight) / float(ammoData.defaultAmount)

            var totalAmmoWeight = weightPerRound * slotData.amount

            if slotData.chamber: totalAmmoWeight += weightPerRound

            weight += totalAmmoWeight


    if slotData.nested.size() != 0:
        for nested in slotData.nested:
            weight += nested.weight


    return float(snappedf(weight, 0.01))

func State(state):
    if state == "Static":
        fill.color = Color8(255, 255, 255, 16)
        fill.show()
        details.show()
        selected = false

    elif state == "Free":
        fill.color = Color8(255, 255, 255, 16)
        fill.hide()
        details.hide()
        selected = false

    elif state == "Display":
        self_modulate = Color8(255, 255, 255, 255)
        fill.color = Color8(0, 0, 0, 0)
        fill.hide()
        details.show()
        selected = false

    elif state == "Selected":
        fill.color = Color8(0, 255, 0, 32)
        fill.show()
        details.show()
        selected = true
