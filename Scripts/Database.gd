@tool
extends Node



@export var master: LootTable
@export var update: bool = false:
    set = ExecuteUpdate

func ExecuteUpdate(_value: bool) -> void :
    if master:

        master.items.clear()


        var constants = get_script().get_script_constant_map()

        for constantName in constants:

            if constants[constantName] is PackedScene and not "_Rig" in constantName:

                var itemPath = constants[constantName].resource_path
                var itemDataPath = itemPath.replace(".tscn", ".tres")


                if ResourceLoader.exists(itemDataPath):
                    var resource = load(itemDataPath)

                    if resource is ItemData:
                        master.items.append(resource)

        print("Master updated with %d items" % master.items.size())

    update = false



const Potato = preload("res://Items/Consumables/Potato/Potato.tscn")
const Can_Empty = preload("res://Items/Consumables/Can_Empty/Can_Empty.tscn")
const Canned_Meat = preload("res://Items/Consumables/Canned_Meat/Canned_Meat.tscn")
const Canned_Meatballs = preload("res://Items/Consumables/Canned_Meatballs/Canned_Meatballs.tscn")
const Canned_Peaches = preload("res://Items/Consumables/Canned_Peaches/Canned_Peaches.tscn")
const Canned_Pear = preload("res://Items/Consumables/Canned_Pear/Canned_Pear.tscn")
const Canned_Peas = preload("res://Items/Consumables/Canned_Peas/Canned_Peas.tscn")
const Canned_Pea_Soup = preload("res://Items/Consumables/Canned_Pea_Soup/Canned_Pea_Soup.tscn")
const Canned_Pineapple = preload("res://Items/Consumables/Canned_Pineapple/Canned_Pineapple.tscn")
const Canned_Tomatoes = preload("res://Items/Consumables/Canned_Tomatoes/Canned_Tomatoes.tscn")
const Canned_Tuna = preload("res://Items/Consumables/Canned_Tuna/Canned_Tuna.tscn")
const Crackers = preload("res://Items/Consumables/Crackers/Crackers.tscn")
const Energy_Powder = preload("res://Items/Consumables/Energy_Powder/Energy_Powder.tscn")
const Field_Ration = preload("res://Items/Consumables/Field_Ration/Field_Ration.tscn")
const Mustard = preload("res://Items/Consumables/Mustard/Mustard.tscn")
const Salty_Liquorice = preload("res://Items/Consumables/Salty_Liquorice/Salty_Liquorice.tscn")
const Peanuts = preload("res://Items/Consumables/Peanuts/Peanuts.tscn")
const Coffee = preload("res://Items/Consumables/Coffee/Coffee.tscn")
const Sugar = preload("res://Items/Consumables/Sugar/Sugar.tscn")
const Yeast = preload("res://Items/Consumables/Yeast/Yeast.tscn")
const Snus = preload("res://Items/Consumables/Snus/Snus.tscn")
const Cigars = preload("res://Items/Consumables/Cigars/Cigars.tscn")
const Soda_Lemon = preload("res://Items/Consumables/Soda_Lemon/Soda_Lemon.tscn")
const Juice_Orange = preload("res://Items/Consumables/Juice_Orange/Juice_Orange.tscn")
const Juice_Pear = preload("res://Items/Consumables/Juice_Pear/Juice_Pear.tscn")
const Juice_Raspberry = preload("res://Items/Consumables/Juice_Raspberry/Juice_Raspberry.tscn")
const Cat_Food = preload("res://Items/Consumables/Cat_Food/Cat_Food.tscn")
const Cigarettes = preload("res://Items/Consumables/Cigarettes/Cigarettes.tscn")
const Beer = preload("res://Items/Consumables/Beer/Beer.tscn")
const Chocolate_War = preload("res://Items/Consumables/Chocolate_War/Chocolate_War.tscn")
const Water_Bottle = preload("res://Items/Consumables/Water_Bottle/Water_Bottle.tscn")
const Cooked_Pea_Soup = preload("res://Items/Consumables/Cooked_Pea_Soup/Cooked_Pea_Soup.tscn")
const Cooked_Tomato_Soup = preload("res://Items/Consumables/Cooked_Tomato_Soup/Cooked_Tomato_Soup.tscn")
const Cooked_Fish_Soup = preload("res://Items/Consumables/Cooked_Fish_Soup/Cooked_Fish_Soup.tscn")
const Cooked_Meatballs = preload("res://Items/Consumables/Cooked_Meatballs/Cooked_Meatballs.tscn")
const Energy_Drink = preload("res://Items/Consumables/Energy_Drink/Energy_Drink.tscn")
const Coffee_Brewed = preload("res://Items/Consumables/Coffee_Brewed/Coffee_Brewed.tscn")
const Kompot = preload("res://Items/Consumables/Kompot/Kompot.tscn")
const Kilju = preload("res://Items/Consumables/Kilju/Kilju.tscn")



const Medkit = preload("res://Items/Medical/Medkit/Medkit.tscn")
const IFAK = preload("res://Items/Medical/IFAK/IFAK.tscn")
const AFAK = preload("res://Items/Medical/AFAK/AFAK.tscn")
const Bandage = preload("res://Items/Medical/Bandage/Bandage.tscn")
const Tourniquet = preload("res://Items/Medical/Tourniquet/Tourniquet.tscn")
const Splint = preload("res://Items/Medical/Splint/Splint.tscn")
const Lotion = preload("res://Items/Medical/Lotion/Lotion.tscn")
const Antiseptic = preload("res://Items/Medical/Antiseptic/Antiseptic.tscn")
const Saline = preload("res://Items/Medical/Saline/Saline.tscn")
const Painkillers = preload("res://Items/Medical/Painkillers/Painkillers.tscn")
const Antibiotics = preload("res://Items/Medical/Antibiotics/Antibiotics.tscn")
const Cold_Medicine = preload("res://Items/Medical/Cold_Medicine/Cold_Medicine.tscn")
const Melatonin = preload("res://Items/Medical/Melatonin/Melatonin.tscn")
const Balm = preload("res://Items/Medical/Balm/Balm.tscn")
const Bandage_Improvised = preload("res://Items/Medical/Bandage_Improvised/Bandage_Improvised.tscn")
const Tourniquet_Improvised = preload("res://Items/Medical/Tourniquet_Improvised/Tourniquet_Improvised.tscn")
const Splint_Improvised = preload("res://Items/Medical/Splint_Improvised/Splint_Improvised.tscn")
const Deodorant = preload("res://Items/Medical/Deodorant/Deodorant.tscn")
const Wipes = preload("res://Items/Medical/Wipes/Wipes.tscn")
const Tissues = preload("res://Items/Medical/Tissues/Tissues.tscn")
const Thermal_Blanket = preload("res://Items/Medical/Thermal_Blanket/Thermal_Blanket.tscn")
const Gum = preload("res://Items/Medical/Gum/Gum.tscn")



const Batteries = preload("res://Items/Electronics/Batteries/Batteries.tscn")
const Battery_Cables = preload("res://Items/Electronics/Battery_Cables/Battery_Cables.tscn")
const Polaris = preload("res://Items/Electronics/Polaris/Polaris.tscn")
const Battery = preload("res://Items/Electronics/Battery/Battery.tscn")
const Hotplate = preload("res://Items/Electronics/Hotplate/Hotplate.tscn")
const Inverter = preload("res://Items/Electronics/Inverter/Inverter.tscn")
const Casette_Player = preload("res://Items/Electronics/Casette_Player/Casette_Player.tscn")
const Coffeemaster = preload("res://Items/Electronics/Coffeemaster/Coffeemaster.tscn")
const PV7 = preload("res://Items/Electronics/PV7/PV7.tscn")
const Narva = preload("res://Items/Electronics/Narva/Narva.tscn")
const Alarm_Clock = preload("res://Items/Electronics/Alarm_Clock/Alarm_Clock.tscn")
const Casette_Electrofolk = preload("res://Items/Electronics/Casette_Electrofolk/Casette_Electrofolk.tscn")
const Casette_Symphony = preload("res://Items/Electronics/Casette_Symphony/Casette_Symphony.tscn")
const Casette_OST = preload("res://Items/Electronics/Casette_OST/Casette_OST.tscn")
const Casette_Radio = preload("res://Items/Electronics/Casette_Radio/Casette_Radio.tscn")
const Cooking_Station = preload("res://Items/Electronics/Cooking_Station/Cooking_Station.tscn")



const Mess_Kit = preload("res://Items/Misc/Mess_Kit/Mess_Kit.tscn")
const Happy_Stove = preload("res://Items/Misc/Happy_Stove/Happy_Stove.tscn")
const Toolbox = preload("res://Items/Misc/Toolbox/Toolbox.tscn")
const Jerry_Can = preload("res://Items/Misc/Jerry_Can/Jerry_Can.tscn")
const Matches = preload("res://Items/Misc/Matches/Matches.tscn")
const Toilet_Paper = preload("res://Items/Misc/Toilet_Paper/Toilet_Paper.tscn")
const Bucket = preload("res://Items/Misc/Bucket/Bucket.tscn")
const Duct_Tape = preload("res://Items/Misc/Duct_Tape/Duct_Tape.tscn")
const Nails = preload("res://Items/Misc/Nails/Nails.tscn")
const Mattress = preload("res://Items/Misc/Mattress/Mattress.tscn")
const Board_Game = preload("res://Items/Misc/Board_Game/Board_Game.tscn")
const Sleeping_Bag = preload("res://Items/Misc/Sleeping_Bag/Sleeping_Bag.tscn")
const Map = preload("res://Items/Misc/Map/Map.tscn")
const Map_Tactical = preload("res://Items/Misc/Map_Tactical/Map_Tactical.tscn")
const Water_Lock = preload("res://Items/Misc/Water_Lock/Water_Lock.tscn")
const Lumber = preload("res://Items/Misc/Lumber/Lumber.tscn")
const Tackle_Box = preload("res://Items/Misc/Tackle_Box/Tackle_Box.tscn")
const Pillow = preload("res://Items/Misc/Pillow/Pillow.tscn")
const Blanket = preload("res://Items/Misc/Blanket/Blanket.tscn")
const Coffee_Filter = preload("res://Items/Misc/Coffee_Filter/Coffee_Filter.tscn")
const Weapon_Repair_Kit = preload("res://Items/Misc/Weapon_Repair_Kit/Weapon_Repair_Kit.tscn")
const Sticks = preload("res://Items/Misc/Sticks/Sticks.tscn")
const Rags = preload("res://Items/Misc/Rags/Rags.tscn")
const Oil_Filter = preload("res://Items/Misc/Oil_Filter/Oil_Filter.tscn")



const Patient_Report = preload("res://Items/Lore/Patient_Report/Patient_Report.tscn")
const Oil_Sample = preload("res://Items/Lore/Oil_Sample/Oil_Sample.tscn")
const Cat = preload("res://Items/Lore/Cat/Cat.tscn")



const Key_Attic = preload("res://Items/Keys/Key_Attic.tscn")
const Key_Bunker = preload("res://Items/Keys/Key_Bunker.tscn")
const Key_Cellar = preload("res://Items/Keys/Key_Cellar.tscn")
const Key_Classroom = preload("res://Items/Keys/Key_Classroom.tscn")
const Key_Gymnasium = preload("res://Items/Keys/Key_Gymnasium.tscn")
const Key_Tunnel = preload("res://Items/Keys/Key_Tunnel.tscn")



const Guitar = preload("res://Items/Instruments/Guitar/Guitar.tscn")
const Guitar_Rig = preload("res://Items/Instruments/Guitar/Guitar_Rig.tscn")
const Harmonica = preload("res://Items/Instruments/Harmonica/Harmonica.tscn")
const Harmonica_Rig = preload("res://Items/Instruments/Harmonica/Harmonica_Rig.tscn")



const Book_Children = preload("res://Items/Books/Book_Children.tscn")
const Book_Cooking = preload("res://Items/Books/Book_Cooking.tscn")
const Book_Fishing = preload("res://Items/Books/Book_Fishing.tscn")
const Book_Religion = preload("res://Items/Books/Book_Religion.tscn")



const Hat_Sauna = preload("res://Items/Clothing/Hat_Sauna/Hat_Sauna.tscn")
const Hat_Mosquito = preload("res://Items/Clothing/Hat_Mosquito/Hat_Mosquito.tscn")
const Beanie_Flame = preload("res://Items/Clothing/Beanie_Flame/Beanie_Flame.tscn")
const Cap_M62 = preload("res://Items/Clothing/Cap_M62/Cap_M62.tscn")
const Jacket_M62 = preload("res://Items/Clothing/Jacket_M62/Jacket_M62.tscn")
const Hoodie_Gray = preload("res://Items/Clothing/Hoodie_Gray/Hoodie_Gray.tscn")
const Fleece_Tactical_Brown = preload("res://Items/Clothing/Fleece_Tactical_Brown/Fleece_Tactical_Brown.tscn")
const Fleece_Tactical_Green = preload("res://Items/Clothing/Fleece_Tactical_Green/Fleece_Tactical_Green.tscn")
const Windbreaker_Black = preload("res://Items/Clothing/Windbreaker_Black/Windbreaker_Black.tscn")
const Windbreaker_Green = preload("res://Items/Clothing/Windbreaker_Green/Windbreaker_Green.tscn")
const Jacket_Winter_Blue = preload("res://Items/Clothing/Jacket_Winter_Blue/Jacket_Winter_Blue.tscn")
const Jacket_Winter_Red = preload("res://Items/Clothing/Jacket_Winter_Red/Jacket_Winter_Red.tscn")
const Jacket_Santa = preload("res://Items/Clothing/Jacket_Santa/Jacket_Santa.tscn")
const Jeans_Black = preload("res://Items/Clothing/Jeans_Black/Jeans_Black.tscn")
const Pants_Hiking = preload("res://Items/Clothing/Pants_Hiking/Pants_Hiking.tscn")
const Boots_Combat = preload("res://Items/Clothing/Boots_Combat/Boots_Combat.tscn")
const Gloves_Leather = preload("res://Items/Clothing/Gloves_Leather/Gloves_Leather.tscn")
const Gloves_Work = preload("res://Items/Clothing/Gloves_Work/Gloves_Work.tscn")
const Hoodie_Border_Zone = preload("res://Items/Clothing/Hoodie_Border_Zone/Hoodie_Border_Zone.tscn")



const Duffel_Retro = preload("res://Items/Backpacks/Duffel_Retro/Duffel_Retro.tscn")
const Backpack_Nomad = preload("res://Items/Backpacks/Backpack_Nomad/Backpack_Nomad.tscn")
const Backpack_Patrol = preload("res://Items/Backpacks/Backpack_Patrol/Backpack_Patrol.tscn")
const Backpack_Jaeger_Black = preload("res://Items/Backpacks/Backpack_Jaeger/Backpack_Jaeger_Black.tscn")
const Backpack_Jaeger_Brown = preload("res://Items/Backpacks/Backpack_Jaeger/Backpack_Jaeger_Brown.tscn")
const Backpack_Jaeger_Green = preload("res://Items/Backpacks/Backpack_Jaeger/Backpack_Jaeger_Green.tscn")
const Backpack_Jaeger_M05 = preload("res://Items/Backpacks/Backpack_Jaeger/Backpack_Jaeger_M05.tscn")



const Vest_Fishing = preload("res://Items/Rigs/Vest_Fishing/Vest_Fishing.tscn")
const K19 = preload("res://Items/Rigs/K19/K19.tscn")
const LVPC_Green = preload("res://Items/Rigs/LVPC/LVPC_Green.tscn")
const LVPC_M05 = preload("res://Items/Rigs/LVPC/LVPC_M05.tscn")
const LVPC_Winter = preload("res://Items/Rigs/LVPC/LVPC_Winter.tscn")



const SSh_39 = preload("res://Items/Helmets/SSh-39/SSh-39.tscn")
const Helmet_Police = preload("res://Items/Helmets/Helmet_Police/Helmet_Police.tscn")



const Kukkaro_Black = preload("res://Items/Belts/Kukkaro/Kukkaro_Black.tscn")
const Kukkaro_Brown = preload("res://Items/Belts/Kukkaro/Kukkaro_Brown.tscn")
const Kukkaro_Green = preload("res://Items/Belts/Kukkaro/Kukkaro_Green.tscn")
const Kukkaro_M05 = preload("res://Items/Belts/Kukkaro/Kukkaro_M05.tscn")



const Armor_Plate_II = preload("res://Items/Armor/Armor_Plate_II.tscn")
const Armor_Plate_IIIA = preload("res://Items/Armor/Armor_Plate_IIIA.tscn")
const Armor_Plate_III = preload("res://Items/Armor/Armor_Plate_III.tscn")
const Armor_Plate_III_Plus = preload("res://Items/Armor/Armor_Plate_III+.tscn")
const Armor_Plate_IV = preload("res://Items/Armor/Armor_Plate_IV.tscn")



const Fishing_Rod = preload("res://Items/Fishing/Fishing_Rod/Fishing_Rod.tscn")
const Fishing_Rod_Rig = preload("res://Items/Fishing/Fishing_Rod/Fishing_Rod_Rig.tscn")
const Bream = preload("res://Items/Fishing/Bream/Bream.tscn")
const Perch = preload("res://Items/Fishing/Perch/Perch.tscn")
const Pike = preload("res://Items/Fishing/Pike/Pike.tscn")
const Roach = preload("res://Items/Fishing/Roach/Roach.tscn")



const Freezer = preload("res://Assets/Freezer/Freezer_F.tscn")
const Crate_Military = preload("res://Assets/Crate_Military/Crate_Military_F.tscn")
const Cupboard = preload("res://Assets/Cupboard/Cupboard_F.tscn")
const Dartboard = preload("res://Assets/Dartboard/Dartboard_F.tscn")
const Fridge = preload("res://Assets/Fridge/Fridge_F.tscn")
const Locker = preload("res://Assets/Locker/Locker_F.tscn")
const Nightstand = preload("res://Assets/Nightstand/Nightstand_F.tscn")
const Painting_Lake = preload("res://Assets/Painting/Painting_Lake_F.tscn")
const Rack_Coat = preload("res://Assets/Rack_Coat/Rack_Coat_F.tscn")
const Sofa_Leather = preload("res://Assets/Sofa_Leather/Sofa_Leather_F.tscn")
const Cabinet_Medical = preload("res://Assets/Cabinet_Medical/Cabinet_Medical_F.tscn")
const Cabinet_Wood = preload("res://Assets/Cabinet_Wood/Cabinet_Wood_F.tscn")
const Stool_Padded = preload("res://Assets/Stool_Padded/Stool_Padded_F.tscn")
const Carpet_Rag = preload("res://Assets/Carpet/Carpet_Rag_F.tscn")
const Carpet_Persian = preload("res://Assets/Carpet/Carpet_Persian_F.tscn")
const Table_Cabin = preload("res://Assets/Table_Cabin/Table_Cabin_F.tscn")
const Stool_Military = preload("res://Assets/Stool_Military/Stool_Military_F.tscn")
const Stove = preload("res://Assets/Stove/Stove_F.tscn")
const Rya_Maria = preload("res://Assets/Rya/Rya_Maria_F.tscn")
const Curtain_Long = preload("res://Assets/Curtains/Curtain_Long_F.tscn")
const Curtain_Mini = preload("res://Assets/Curtains/Curtain_Mini_F.tscn")
const Shelf_Wood = preload("res://Assets/Shelf_Wood/Shelf_Wood_F.tscn")
const Shelf_Wall = preload("res://Assets/Shelf_Wall/Shelf_Wall_F.tscn")
const Bed_Civilian = preload("res://Assets/Bed_Civilian/Bed_Civilian_F.tscn")
const Table_Canteen = preload("res://Assets/Table_Canteen/Table_Canteen_F.tscn")
const Weapon_Display = preload("res://Assets/Weapon_Display/Weapon_Display_F.tscn")
const Table_Kitchen = preload("res://Assets/Table_Kitchen/Table_Kitchen_F.tscn")
const Crate_Special = preload("res://Assets/Crate_Special/Crate_Special_F.tscn")
const Chair_Office = preload("res://Assets/Chair_Office/Chair_Office_F.tscn")
const Television = preload("res://Assets/Television/Television_F.tscn")
const Pallet = preload("res://Assets/Pallet/Pallet_F.tscn")
const Cabinet_Office = preload("res://Assets/Cabinet_Office/Cabinet_Office_F.tscn")
const Table_Office = preload("res://Assets/Table_Office/Table_Office_F.tscn")
const Shelf_Metal = preload("res://Assets/Shelf_Metal/Shelf_Metal_F.tscn")
const Target_Stand = preload("res://Assets/Target_Stand/Target_Stand_F.tscn")
const Sign_Border_Zone = preload("res://Assets/Sign_Border_Zone/Sign_Border_Zone_F.tscn")
const Bed_Nomad = preload("res://Assets/Bed_Nomad/Bed_Nomad_F.tscn")
const Trolley_Short = preload("res://Assets/Trolley/Trolley_Short_F.tscn")
const Trolley_Tall = preload("res://Assets/Trolley/Trolley_Tall_F.tscn")
const Poster_Posture = preload("res://Assets/Posters/Poster_Posture_F.tscn")
const Chair_School = preload("res://Assets/Chair_School/Chair_School_F.tscn")



const Jaeger_140 = preload("res://Items/Knives/Jaeger_140/Jaeger_140.tscn")
const Jaeger_140_Rig = preload("res://Items/Knives/Jaeger_140/Jaeger_140_Rig.tscn")
const Skrama_200 = preload("res://Items/Knives/Skrama_200/Skrama_200.tscn")
const Skrama_200_Rig = preload("res://Items/Knives/Skrama_200/Skrama_200_Rig.tscn")
const Skrama_240 = preload("res://Items/Knives/Skrama_240/Skrama_240.tscn")
const Skrama_240_Rig = preload("res://Items/Knives/Skrama_240/Skrama_240_Rig.tscn")

const Makarov = preload("res://Items/Weapons/Makarov/Makarov.tscn")
const Makarov_Magazine = preload("res://Items/Weapons/Makarov/Makarov_Magazine.tscn")
const Makarov_Rig = preload("res://Items/Weapons/Makarov/Makarov_Rig.tscn")
const Colt_1911 = preload("res://Items/Weapons/Colt_1911/Colt_1911.tscn")
const Colt_1911_Magazine = preload("res://Items/Weapons/Colt_1911/Colt_1911_Magazine.tscn")
const Colt_1911_Rig = preload("res://Items/Weapons/Colt_1911/Colt_1911_Rig.tscn")
const Glock_17 = preload("res://Items/Weapons/Glock_17/Glock_17.tscn")
const Glock_17_Magazine = preload("res://Items/Weapons/Glock_17/Glock_17_Magazine.tscn")
const Glock_17_Rig = preload("res://Items/Weapons/Glock_17/Glock_17_Rig.tscn")
const P320 = preload("res://Items/Weapons/P320/P320.tscn")
const P320_Magazine = preload("res://Items/Weapons/P320/P320_Magazine.tscn")
const P320_Rig = preload("res://Items/Weapons/P320/P320_Rig.tscn")

const MP5 = preload("res://Items/Weapons/MP5/MP5.tscn")
const MP5_Magazine = preload("res://Items/Weapons/MP5/MP5_Magazine.tscn")
const MP5_Rig = preload("res://Items/Weapons/MP5/MP5_Rig.tscn")
const MP5K = preload("res://Items/Weapons/MP5K/MP5K.tscn")
const MP5K_Rig = preload("res://Items/Weapons/MP5K/MP5K_Rig.tscn")
const MP5SD = preload("res://Items/Weapons/MP5SD/MP5SD.tscn")
const MP5SD_Rig = preload("res://Items/Weapons/MP5SD/MP5SD_Rig.tscn")
const MP7 = preload("res://Items/Weapons/MP7/MP7.tscn")
const MP7_Magazine = preload("res://Items/Weapons/MP7/MP7_Magazine.tscn")
const MP7_Rig = preload("res://Items/Weapons/MP7/MP7_Rig.tscn")
const KP_31 = preload("res://Items/Weapons/KP-31/KP-31.tscn")
const KP_31_Drum = preload("res://Items/Weapons/KP-31/KP-31_Drum.tscn")
const KP_31_Rig = preload("res://Items/Weapons/KP-31/KP-31_Rig.tscn")

const AKS_74U = preload("res://Items/Weapons/AKS-74U/AKS-74U.tscn")
const AKS_74U_Magazine = preload("res://Items/Weapons/AKS-74U/AKS-74U_Magazine.tscn")
const AKS_74U_Rig = preload("res://Items/Weapons/AKS-74U/AKS-74U_Rig.tscn")
const AKM = preload("res://Items/Weapons/AKM/AKM.tscn")
const AKM_Magazine = preload("res://Items/Weapons/AKM/AKM_Magazine.tscn")
const AKM_Rig = preload("res://Items/Weapons/AKM/AKM_Rig.tscn")
const AK_12 = preload("res://Items/Weapons/AK-12/AK-12.tscn")
const AK_12_Magazine = preload("res://Items/Weapons/AK-12/AK-12_Magazine.tscn")
const AK_12_Rig = preload("res://Items/Weapons/AK-12/AK-12_Rig.tscn")
const KAR_21_Barrel = preload("res://Items/Weapons/KAR-21/KAR-21_Barrel.tscn")
const KAR_21_223 = preload("res://Items/Weapons/KAR-21/KAR-21_223.tscn")
const KAR_21_223_Magazine = preload("res://Items/Weapons/KAR-21/KAR-21_223_Magazine.tscn")
const KAR_21_223_Rig = preload("res://Items/Weapons/KAR-21/KAR-21_223_Rig.tscn")
const KAR_21_308 = preload("res://Items/Weapons/KAR-21/KAR-21_308.tscn")
const KAR_21_308_Magazine = preload("res://Items/Weapons/KAR-21/KAR-21_308_Magazine.tscn")
const KAR_21_308_Rig = preload("res://Items/Weapons/KAR-21/KAR-21_308_Rig.tscn")
const SVD = preload("res://Items/Weapons/SVD/SVD.tscn")
const SVD_Magazine = preload("res://Items/Weapons/SVD/SVD_Magazine.tscn")
const SVD_Rig = preload("res://Items/Weapons/SVD/SVD_Rig.tscn")
const VSS = preload("res://Items/Weapons/VSS/VSS.tscn")
const VSS_Magazine = preload("res://Items/Weapons/VSS/VSS_Magazine.tscn")
const VSS_Rig = preload("res://Items/Weapons/VSS/VSS_Rig.tscn")
const M78 = preload("res://Items/Weapons/M78/M78.tscn")
const M78_Magazine = preload("res://Items/Weapons/M78/M78_Magazine.tscn")
const M78_Rig = preload("res://Items/Weapons/M78/M78_Rig.tscn")
const M4A1 = preload("res://Items/Weapons/M4A1/M4A1.tscn")
const STANAG_Magazine = preload("res://Items/Weapons/M4A1/STANAG_Magazine.tscn")
const M4A1_Rig = preload("res://Items/Weapons/M4A1/M4A1_Rig.tscn")
const MK18 = preload("res://Items/Weapons/MK18/MK18.tscn")
const MK18_Rig = preload("res://Items/Weapons/MK18/MK18_Rig.tscn")
const HK416 = preload("res://Items/Weapons/HK416/HK416.tscn")
const HK416_Rig = preload("res://Items/Weapons/HK416/HK416_Rig.tscn")
const RK_62 = preload("res://Items/Weapons/RK-62/RK-62.tscn")
const RK_Magazine = preload("res://Items/Weapons/RK-62/RK_Magazine.tscn")
const RK_62_Rig = preload("res://Items/Weapons/RK-62/RK-62_Rig.tscn")
const RK_62M = preload("res://Items/Weapons/RK-62/RK-62M.tscn")
const RK_62M_Rig = preload("res://Items/Weapons/RK-62/RK-62M_Rig.tscn")
const RK_95 = preload("res://Items/Weapons/RK-95/RK-95.tscn")
const RK_95_Rig = preload("res://Items/Weapons/RK-95/RK-95_Rig.tscn")
const Mosin = preload("res://Items/Weapons/Mosin/Mosin.tscn")
const Mosin_Rig = preload("res://Items/Weapons/Mosin/Mosin_Rig.tscn")
const Remington_870 = preload("res://Items/Weapons/Remington_870/Remington_870.tscn")
const Remington_870_Rig = preload("res://Items/Weapons/Remington_870/Remington_870_Rig.tscn")



const RMR = preload("res://Items/Attachments/RMR/RMR.tscn")
const Vudu = preload("res://Items/Attachments/Vudu/Vudu.tscn")
const ACOG = preload("res://Items/Attachments/ACOG/ACOG.tscn")
const EXPS = preload("res://Items/Attachments/EXPS/EXPS.tscn")
const PBS = preload("res://Items/Attachments/PBS/PBS.tscn")
const Hybrid = preload("res://Items/Attachments/Hybrid/Hybrid.tscn")
const Rider = preload("res://Items/Attachments/Rider/Rider.tscn")
const PU = preload("res://Items/Attachments/PU/PU.tscn")
const Salvo = preload("res://Items/Attachments/Salvo/Salvo.tscn")
const HMR = preload("res://Items/Attachments/HMR/HMR.tscn")
const Kobra = preload("res://Items/Attachments/Kobra/Kobra.tscn")
const Leopard = preload("res://Items/Attachments/Leopard/Leopard.tscn")
const Micro = preload("res://Items/Attachments/Micro/Micro.tscn")
const Monster = preload("res://Items/Attachments/Monster/Monster.tscn")
const MRO = preload("res://Items/Attachments/MRO/MRO.tscn")
const Navy = preload("res://Items/Attachments/Navy/Navy.tscn")
const POSP = preload("res://Items/Attachments/POSP/POSP.tscn")
const PRO = preload("res://Items/Attachments/PRO/PRO.tscn")
const PTN = preload("res://Items/Attachments/PTN/PTN.tscn")
const SOCOM = preload("res://Items/Attachments/SOCOM/SOCOM.tscn")
const SRO = preload("res://Items/Attachments/SRO/SRO.tscn")
const Thor = preload("res://Items/Attachments/Thor/Thor.tscn")
const OZ5 = preload("res://Items/Attachments/OZ5/OZ5.tscn")
const ANPEQ = preload("res://Items/Attachments/ANPEQ/ANPEQ.tscn")



const Ammo_9x18 = preload("res://Items/Ammo/Ammo_9x18/Ammo_9x18.tscn")
const Ammo_9x19 = preload("res://Items/Ammo/Ammo_9x19/Ammo_9x19.tscn")
const Ammo_45ACP = preload("res://Items/Ammo/Ammo_45ACP/Ammo_45ACP.tscn")
const Ammo_9x39 = preload("res://Items/Ammo/Ammo_9x39/Ammo_9x39.tscn")
const Ammo_46x30 = preload("res://Items/Ammo/Ammo_46x30/Ammo_46x30.tscn")
const Ammo_223 = preload("res://Items/Ammo/Ammo_223/Ammo_223.tscn")
const Ammo_308 = preload("res://Items/Ammo/Ammo_308/Ammo_308.tscn")
const Ammo_545x39 = preload("res://Items/Ammo/Ammo_545x39/Ammo_545x39.tscn")
const Ammo_762x39 = preload("res://Items/Ammo/Ammo_762x39/Ammo_762x39.tscn")
const Ammo_762x54R = preload("res://Items/Ammo/Ammo_762x54R/Ammo_762x54R.tscn")
const Ammo_12x70 = preload("res://Items/Ammo/Ammo_12x70/Ammo_12x70.tscn")



const F1 = preload("res://Items/Grenades/F1/F1.tscn")
const F1_Rig = preload("res://Items/Grenades/F1/F1_Rig.tscn")
const RGD_5 = preload("res://Items/Grenades/RGD-5/RGD-5.tscn")
const RGD_5_Rig = preload("res://Items/Grenades/RGD-5/RGD-5_Rig.tscn")
const M50 = preload("res://Items/Grenades/M50/M50.tscn")
const M50_Rig = preload("res://Items/Grenades/M50/M50_Rig.tscn")
const M43 = preload("res://Items/Grenades/M43/M43.tscn")
const M43_Rig = preload("res://Items/Grenades/M43/M43_Rig.tscn")
