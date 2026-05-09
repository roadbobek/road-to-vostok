extends Control


var gameData = preload("res://Resources/GameData.tres")


var interface


@onready var panel = $Panel
@onready var title = $Panel / Margin / Elements / Title
@onready var rarity = $Panel / Margin / Elements / Type / Rarity
@onready var type = $Panel / Margin / Elements / Type
@onready var separator = $Panel / Margin / Elements / Separator
@onready var info = $Panel / Margin / Elements / Info
@onready var condition = $Panel / Margin / Elements / Condition
@onready var weight = $Panel / Margin / Elements / Weight
@onready var value = $Panel / Margin / Elements / Value
@onready var damage = $Panel / Margin / Elements / Damage
@onready var penetration = $Panel / Margin / Elements / Penetration
@onready var protection = $Panel / Margin / Elements / Protection
@onready var caliber = $Panel / Margin / Elements / Caliber
@onready var capacity = $Panel / Margin / Elements / Capacity
@onready var insulation = $Panel / Margin / Elements / Insulation
@onready var nested = $Panel / Margin / Elements / Nested
@onready var equipment = $Panel / Margin / Elements / Equipment
@onready var health = $Panel / Margin / Elements / Health
@onready var energy = $Panel / Margin / Elements / Energy
@onready var hydration = $Panel / Margin / Elements / Hydration
@onready var mental = $Panel / Margin / Elements / Mental
@onready var temperature = $Panel / Margin / Elements / Temperature
@onready var cures = $Panel / Margin / Elements / Cures
@onready var overweight = $Panel / Margin / Elements / Cures / Icons / Overweight
@onready var starvation = $Panel / Margin / Elements / Cures / Icons / Starvation
@onready var dehydration = $Panel / Margin / Elements / Cures / Icons / Dehydration
@onready var bleeding = $Panel / Margin / Elements / Cures / Icons / Bleeding
@onready var fracture = $Panel / Margin / Elements / Cures / Icons / Fracture
@onready var burn = $Panel / Margin / Elements / Cures / Icons / Burn
@onready var hypothermia = $Panel / Margin / Elements / Cures / Icons / Hypothermia
@onready var insanity = $Panel / Margin / Elements / Cures / Icons / Insanity
@onready var poisoning = $Panel / Margin / Elements / Cures / Icons / Poisoning
@onready var rupture = $Panel / Margin / Elements / Cures / Icons / Rupture
@onready var headshot = $Panel / Margin / Elements / Cures / Icons / Headshot
@onready var subpanel = $Panel / Margin / Elements / Subpanel
@onready var compatible = $Panel / Margin / Elements / Subpanel / Margin / Elements / Compatible
@onready var compatibleList = $Panel / Margin / Elements / Subpanel / Margin / Elements / List

func _ready():
    interface = owner
    Reset()

func Reset():

    title.hide()
    rarity.hide()
    type.hide()
    info.hide()
    separator.hide()
    equipment.hide()
    condition.hide()
    weight.hide()
    value.hide()
    damage.hide()
    penetration.hide()
    protection.hide()
    caliber.hide()
    capacity.hide()
    insulation.hide()
    health.hide()
    energy.hide()
    hydration.hide()
    mental.hide()
    temperature.hide()
    nested.hide()
    cures.hide()
    overweight.hide()
    starvation.hide()
    dehydration.hide()
    bleeding.hide()
    fracture.hide()
    hypothermia.hide()
    burn.hide()
    poisoning.hide()
    insanity.hide()
    rupture.hide()
    headshot.hide()
    subpanel.hide()
    compatible.hide()
    compatibleList.hide()


    panel.size = Vector2(0, 0)
    interface.tooltipOffset = panel.size.y

func Update(item: Item):

    Reset()


    var slotData: SlotData = item.slotData
    var itemData: ItemData = item.slotData.itemData



    title.show()
    rarity.show()
    type.show()
    separator.show()



    title.text = itemData.name
    if itemData.file == "Cat" && gameData.catDead: title.text += " (RIP)"

    rarity.text = str(itemData.Rarity.find_key(itemData.rarity))
    if itemData.rarity == itemData.Rarity.Common: rarity.modulate = Color.GREEN
    elif itemData.rarity == itemData.Rarity.Rare: rarity.modulate = Color.RED
    elif itemData.rarity == itemData.Rarity.Legendary: rarity.modulate = Color.DARK_VIOLET
    else: rarity.hide()

    type.text = itemData.type



    if itemData.showCondition:
        condition.show()
        condition.get_child(0).text = str(int(slotData.condition)) + "%"

        if slotData.condition <= 25: condition.get_child(0).modulate = Color.RED
        elif slotData.condition > 25 && slotData.condition <= 50: condition.get_child(0).modulate = Color.YELLOW
        elif slotData.condition > 50: condition.get_child(0).modulate = Color.GREEN

    if itemData.type != "Furniture":
        weight.show()
        weight.get_child(0).text = str(item.Weight()) + "kg"

    value.show()
    value.get_child(0).text = str(item.Value()) + "€"



    if itemData.type == "Weapon":
        if itemData.damage != 0:
            damage.show()
            damage.get_child(0).text = str(int(itemData.damage))
        if itemData.penetration != 0:
            penetration.show()
            penetration.get_child(0).text = "Level " + str(int(itemData.penetration))
        if itemData.caliber:
            caliber.show()
            caliber.get_child(0).text = itemData.caliber



    if itemData.capacity > 0:
        capacity.show()
        capacity.get_child(0).text = "+" + str(int(itemData.capacity)) + "kg"



    if itemData.insulation > 0:
        insulation.show()
        insulation.get_child(0).text = "+" + str(int(itemData.insulation))



    if itemData.type == "Armor" || itemData.type == "Helmet":
        protection.show()
        protection.get_child(0).text = "Level " + str(int(itemData.protection))

    if itemData.type == "Rig" && slotData.nested.size() != 0:
        for nestedItem in slotData.nested:
            if nestedItem.type == "Armor":
                condition.show()
                condition.get_child(0).text = str(slotData.condition) + "%"
                protection.show()
                protection.get_child(0).text = "Level " + str(int(nestedItem.protection))



    if itemData.slots.size() != 0:
        equipment.show()
        equipment.get_child(0).text = CreateEquipmentString(slotData)



    if itemData.usable && itemData.health != 0:
        health.show()
        if itemData.health > 0:
            health.get_child(0).text = "+" + str(int(itemData.health))
            health.get_child(0).modulate = Color.GREEN
        else:
            health.get_child(0).text = str(int(itemData.health))
            health.get_child(0).modulate = Color.RED

    if itemData.usable && itemData.energy != 0:
        energy.show()
        if itemData.energy > 0:
            energy.get_child(0).text = "+" + str(int(itemData.energy))
            energy.get_child(0).modulate = Color.GREEN
        else:
            energy.get_child(0).text = str(int(itemData.energy))
            energy.get_child(0).modulate = Color.RED

    if itemData.usable && itemData.hydration != 0:
        hydration.show()
        if itemData.hydration > 0:
            hydration.get_child(0).text = "+" + str(int(itemData.hydration))
            hydration.get_child(0).modulate = Color.GREEN
        else:
            hydration.get_child(0).text = str(int(itemData.hydration))
            hydration.get_child(0).modulate = Color.RED

    if itemData.usable && itemData.mental != 0:
        mental.show()
        if itemData.mental > 0:
            mental.get_child(0).text = "+" + str(int(itemData.mental))
            mental.get_child(0).modulate = Color.GREEN
        else:
            mental.get_child(0).text = str(int(itemData.mental))
            mental.get_child(0).modulate = Color.RED

    if itemData.usable && itemData.temperature != 0:
        temperature.show()
        if itemData.temperature > 0:
            temperature.get_child(0).text = "+" + str(int(itemData.temperature))
            temperature.get_child(0).modulate = Color.GREEN
        else:
            temperature.get_child(0).text = str(int(itemData.temperature))
            temperature.get_child(0).modulate = Color.RED



    if itemData.bleeding:
        cures.show()
        bleeding.show()
    if itemData.fracture:
        cures.show()
        fracture.show()
    if itemData.burn:
        cures.show()
        burn.show()
    if itemData.insanity:
        cures.show()
        insanity.show()
    if itemData.rupture:
        cures.show()
        rupture.show()
    if itemData.headshot:
        cures.show()
        headshot.show()



    if slotData.nested.size() != 0:
        nested.show()
        nested.get_child(0).text = CreateNestedString(slotData)



    if slotData.itemData.compatible.size() != 0:
        subpanel.show()
        compatible.show()
        compatibleList.show()
        compatibleList.text = CreateCompatibleString(slotData)


    panel.size = Vector2(256, 0)
    interface.tooltipOffset = panel.size.y / 2.0

func CreateNestedString(slotData: SlotData) -> String:
    var string = ""
    var stringSize = slotData.nested.size()

    for element in slotData.nested:
        string += String(element.display)
        stringSize -= 1

        if stringSize > 0:
            string += ", "

    return string

func CreateCompatibleString(slotData: SlotData) -> String:
    var string = ""
    var stringSize = slotData.itemData.compatible.size()

    for element in slotData.itemData.compatible:

        if element.type != "Armor":
            string += String(element.name)
            stringSize -= 1

            if stringSize > 0:
                string += ", "


    if slotData.itemData.carrier:
        string += String("Armor Plates")

    return string

func CreateEquipmentString(slotData: SlotData) -> String:
    var string = ""
    var stringSize = slotData.itemData.slots.size()

    for element in slotData.itemData.slots:
        string += String(element)
        stringSize -= 1

        if stringSize > 0:
            string += " / "

    if slotData.itemData.type == "Grenade":
        return "Grenade"
    else:
        return string

func Info(hoverInfo):

    Reset()

    title.show()
    type.show()
    separator.show()
    info.show()

    title.text = hoverInfo.title
    type.text = hoverInfo.type
    info.text = hoverInfo.info

    panel.size = Vector2(256, 0)
    interface.tooltipOffset = panel.size.y
