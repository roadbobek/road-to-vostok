@tool
extends Node3D
class_name Furniture


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


const furnitureMaterial = preload("res://Modular/Materials/MT_Furniture.tres")
var sourceMaterials: Array[Material]


@export var itemData: ItemData
@export var mesh: MeshInstance3D
@export var colliderR: MeshInstance3D
@export var colliderP: MeshInstance3D
@export var wallElement = false
@export var canOverlap = false


@onready var indicator = $Indicator
@onready var area = $Area
@onready var parenter = $Parenter
@onready var rays = $Rays
@onready var hint = $Hint


@export var initialize: bool = false:
    set = ExecuteInitialize


var isMoving = false
var areaValid = false
var raysValid = false


var processTimer = 0.0
var processCycle = 0.1


var items: Array[RigidBody3D]

func ExecuteInitialize(_value: bool) -> void :



    if !mesh || !colliderR:
        print("Missing key components!")
        return


    colliderR.get_child(0).add_to_group("Furniture", true)


    indicator.show()
    hint.show()
    indicator.position = mesh.get_aabb().get_center()
    indicator.scale = Vector3.ONE / owner.scale




    if area.get_child_count() != 0:
        for child in area.get_children():
            area.remove_child(child)
            child.queue_free()


    var areaMeshInstance = MeshInstance3D.new()
    area.add_child(areaMeshInstance, true)
    areaMeshInstance.set_owner(get_tree().edited_scene_root);
    areaMeshInstance.position = mesh.get_aabb().get_center()
    areaMeshInstance.hide()


    var areaMesh = BoxMesh.new()
    areaMesh.size = mesh.get_aabb().size
    areaMesh.size.x -= 0.05
    areaMesh.size.y -= 0.05
    areaMesh.size.z -= 0.05
    areaMeshInstance.mesh = areaMesh


    areaMeshInstance.create_convex_collision()

    var areaCollisionShape = areaMeshInstance.get_child(0).get_child(0)
    areaCollisionShape.reparent(area)

    var areaStaticBody = areaMeshInstance.get_child(0)
    areaStaticBody.queue_free()

    areaMeshInstance.queue_free()




    if parenter.get_child_count() != 0:
        for child in parenter.get_children():
            parenter.remove_child(child)
            child.queue_free()


    var parenterMeshInstance = MeshInstance3D.new()
    parenter.add_child(parenterMeshInstance, true)
    parenterMeshInstance.set_owner(get_tree().edited_scene_root);
    parenterMeshInstance.position = mesh.get_aabb().get_center()
    parenterMeshInstance.hide()


    var parenterMesh = BoxMesh.new()
    parenterMesh.size = mesh.get_aabb().size
    parenterMesh.size.x += 0.05
    parenterMesh.size.y += 0.05
    parenterMesh.size.z += 0.05
    parenterMeshInstance.mesh = parenterMesh


    parenterMeshInstance.create_convex_collision()

    var parenterCollisionShape = parenterMeshInstance.get_child(0).get_child(0)
    parenterCollisionShape.reparent(parenter)

    var parenterStaticBody = parenterMeshInstance.get_child(0)
    parenterStaticBody.queue_free()

    parenterMeshInstance.queue_free()




    if wallElement:
        hint.rotation_degrees.x = 90.0
        hint.mesh.size.x = mesh.get_aabb().size.x
        hint.mesh.size.y = mesh.get_aabb().size.y
        hint.position = mesh.get_aabb().get_center()
        hint.position.z = mesh.position.z
    else:
        hint.mesh.size.x = mesh.get_aabb().size.x
        hint.mesh.size.y = mesh.get_aabb().size.z
        hint.position = mesh.get_aabb().get_center()
        hint.position.y = mesh.position.y




    var aabb = areaMeshInstance.get_aabb()
    var center
    var topLeft
    var topRight
    var bottomLeft
    var bottomRight


    if wallElement:
        center = aabb.size / 2 - Vector3(aabb.size.x / 2, aabb.size.y / 2, aabb.size.z)
        topLeft = aabb.size / 2 - Vector3(aabb.size.x, 0, aabb.size.z)
        topRight = aabb.size / 2 - Vector3(0, 0, aabb.size.z)
        bottomLeft = aabb.size / 2 - Vector3(0, aabb.size.y, aabb.size.z)
        bottomRight = aabb.size / 2 - Vector3(aabb.size.x, aabb.size.y, aabb.size.z)

        for ray in rays.get_children():
            ray.target_position = Vector3(0, 0, -0.2)
    else:
        center = aabb.size / 2 - Vector3(aabb.size.x / 2, aabb.size.y, aabb.size.z / 2)
        topLeft = aabb.size / 2 - Vector3(0, aabb.size.y, 0)
        topRight = aabb.size / 2 - Vector3(aabb.size.x, aabb.size.y, 0)
        bottomLeft = aabb.size / 2 - Vector3(0, aabb.size.y, aabb.size.z)
        bottomRight = aabb.size / 2 - Vector3(aabb.size.x, aabb.size.y, aabb.size.z)

        for ray in rays.get_children():
            ray.target_position = Vector3(0, -0.2, 0)


    rays.position = areaCollisionShape.position
    rays.get_child(0).position = center
    rays.get_child(1).position = topLeft
    rays.get_child(2).position = topRight
    rays.get_child(3).position = bottomLeft
    rays.get_child(4).position = bottomRight

    initialize = false

func ExecuteHideIndicators(_value: bool) -> void :
    indicator.hide()
    hint.hide()

func Catalog():

    var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")


    if isMoving && items.size() > 0:
        DropParentedItems()


    if owner is LootContainer:
        if owner.storage.size() != 0:
            interface.AddToCatalog(itemData, owner.storage)
            PlayPickup()
            hint.reparent(self)
            owner.queue_free()
            return


    interface.AddToCatalog(itemData, null)
    PlayPickup()
    hint.reparent(self)
    owner.queue_free()

func _ready() -> void :
    if !Engine.is_editor_hint():


        sourceMaterials.clear()


        for material in mesh.get_surface_override_material_count():
            sourceMaterials.append(mesh.get_surface_override_material(material))

        indicator.position = mesh.get_aabb().get_center()
        indicator.scale = Vector3.ONE / owner.scale
        indicator.hide()
        hint.hide()


        area.set_collision_layer_value(1, true)
        area.set_collision_mask_value(1, true)
        area.set_collision_mask_value(2, true)
        area.set_collision_mask_value(3, true)
        area.set_collision_mask_value(4, true)
        area.set_collision_mask_value(5, true)
        area.set_collision_mask_value(6, false)
        area.set_collision_mask_value(14, true)


        for ray in rays.get_children():
            ray.set_collision_mask_value(1, true)
            ray.set_collision_mask_value(6, true)

func _physics_process(delta):
    if !Engine.is_editor_hint():
        if isMoving:

            processTimer += delta

            if processTimer > processCycle:
                CheckOverlap()
                CheckRays()
                CanPlace()
                HintPosition()
                processTimer = 0.0

func StartMove():

    isMoving = true
    indicator.hide()


    if colliderR:
        colliderR.get_child(0).get_child(0).disabled = true
    if colliderP:
        colliderP.get_child(0).get_child(0).disabled = true

    furnitureMaterial.set_shader_parameter("Valid", false)


    for material in mesh.get_surface_override_material_count():
        mesh.set_surface_override_material(material, furnitureMaterial)

    ActivateRays()
    ParentItems()
    FreeHint()

func ResetMove():

    isMoving = false
    indicator.show()
    hint.hide()


    if colliderR:
        colliderR.get_child(0).get_child(0).disabled = false
    if colliderP:
        colliderP.get_child(0).get_child(0).disabled = false

    furnitureMaterial.set_shader_parameter("Valid", false)


    for material in mesh.get_surface_override_material_count():
        mesh.set_surface_override_material(material, sourceMaterials[material])

    var originDifferenceX = owner.global_position.x - rays.get_child(1).global_position.x
    var originDifferenceY = owner.global_position.y - rays.get_child(1).global_position.y
    var originDifferenceZ = owner.global_position.z - rays.get_child(1).global_position.z

    owner.global_position.x = snappedf(rays.get_child(1).get_collision_point().x + originDifferenceX, 0.1)
    owner.global_position.y = snappedf(rays.get_child(1).get_collision_point().y + originDifferenceY, 0.1)
    owner.global_position.z = snappedf(rays.get_child(1).get_collision_point().z + originDifferenceZ, 0.1)

    if wallElement:
        owner.global_rotation_degrees.y = snappedf(owner.global_rotation_degrees.y, 90.0)
    else:
        owner.global_rotation_degrees.y = snappedf(owner.global_rotation_degrees.y, 15.0)

    if canOverlap:
        owner.scale.y = randf_range(0.8, 1.0)

    PlayFurniture()
    DeactivateRays()
    FreeItems()
    ParentHint()

func HintPosition():
    if CanPlace():
        hint.global_position.x = snappedf(rays.get_child(0).get_collision_point().x, 0.1)
        hint.global_position.y = snappedf(rays.get_child(0).get_collision_point().y, 0.1)
        hint.global_position.z = snappedf(rays.get_child(0).get_collision_point().z, 0.1)

        if wallElement:
            hint.global_rotation_degrees.y = snappedf(global_rotation_degrees.y, 90.0)
        else:
            hint.global_rotation_degrees.y = snappedf(global_rotation_degrees.y, 15.0)

func DeactivateRays():

    for ray in rays.get_children():
        ray.enabled = false

func ActivateRays():

    for ray in rays.get_children():
        ray.enabled = true

func CheckOverlap():

    var overlaps = area.get_overlapping_bodies()


    if overlaps.size() > 0:

        if canOverlap:

            for overlap in overlaps:
                if !overlap.is_in_group("Furniture"):
                    areaValid = false
                    break
                else:
                    areaValid = true

        else:
            areaValid = false
    else:
        areaValid = true

func CheckRays():
    for ray in rays.get_children():

        if !ray.is_colliding():
            raysValid = false
            return


        elif ray.is_colliding():

            if ray.get_collider().is_in_group("Transition"):
                raysValid = false
                return


    raysValid = true

func GetSnapData() -> Dictionary:
    var center_ray = rays.get_child(0)
    if center_ray.is_colliding():
        return {"point": center_ray.get_collision_point(), "normal": center_ray.get_collision_normal(), "valid": true}
    return {"point": global_position, "normal": Vector3.UP, "valid": false}

func CanPlace():
    if raysValid && areaValid:
        hint.show()
        furnitureMaterial.set_shader_parameter("valid", true)
        return true
    else:
        hint.hide()
        furnitureMaterial.set_shader_parameter("valid", false)
        return false

func ParentItems():
    items.clear()

    var overlaps = parenter.get_overlapping_bodies()

    for overlap in overlaps:
        if overlap is Pickup:
            items.append(overlap)

    for item in items:
        item.Freeze()
        item.reparent(owner)
        item.collision.disabled = true

func FreeItems():
    if items.size() > 0:
        for item in items:
            item.Freeze()
            item.collision.disabled = false
            var map = get_tree().current_scene.get_node("/root/Map")
            item.reparent(map)

        items.clear()

func DropParentedItems():
    if items.size() > 0:
        for item in items:
            item.Unfreeze()
            item.collision.disabled = false
            var map = get_tree().current_scene.get_node("/root/Map")
            item.reparent(map)

        items.clear()

func ParentHint():
    hint.reparent(self)

func FreeHint():
    var map = get_tree().current_scene.get_node("/root/Map")
    hint.reparent(map)

func UpdateTooltip():
    gameData.tooltip = itemData.name

func PlayFurniture():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.UIFurniture)

func PlayPickup():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(audioLibrary.pickup)
