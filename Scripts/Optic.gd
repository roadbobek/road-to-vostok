@tool
extends Node3D


var gameData = preload("res://Resources/GameData.tres")

@export var attachmentData: AttachmentData
@export var reticle: Material
@export var secondary: Node3D

@export var calculate: bool = false:
    set = ExecuteCalculate

@export_group("PIP")
@export var mesh: MeshInstance3D
@export var viewport: SubViewport
@export var camera: Camera3D
@export var PIP: Material
@export var mask: Material
@export var maskIndex: int

@export_group("Abilities")
@export var railMovement = false
@export var slideFollow = false

@export_group("Rail")
@export var minPosition = 0.0
@export var maxPosition = 0.0

@export_group("Values")
@export var defaultPosition = 0.0
@export var slideOffsetY = 0.0
@export var slideOffsetZ = 0.0

var processCycle: int

func ExecuteCalculate(_value: bool) -> void :
    defaultPosition = position.z

    if slideFollow:
        var skeleton = owner.skeleton
        var slideTransform = skeleton.get_bone_global_pose(owner.slideIndex)
        var slidePosition = skeleton.to_global(slideTransform.origin)
        slideOffsetY = position.y - slidePosition.y
        slideOffsetZ = position.z - slidePosition.z

    calculate = false

func _physics_process(_delta) -> void :

    if Engine.is_editor_hint():
        return


    if !viewport:
        return


    if visible: processCycle = 10
    else: processCycle = 100


    if Engine.get_physics_frames() % processCycle == 0:

        if visible:

            if gameData.PIP:

                mesh.set_surface_override_material(maskIndex, PIP)

                if gameData.isAiming && !gameData.secondaryOptic:
                    viewport.disable_3d = false
                    camera.set_cull_mask_value(1, true)
                    camera.set_cull_mask_value(2, false)
                    camera.set_cull_mask_value(3, true)
                    camera.set_cull_mask_value(4, true)
                    PIP.set_shader_parameter("active", true)

                else:
                    PIP.set_shader_parameter("active", false)
                    viewport.disable_3d = true
                    camera.cull_mask = 0

            else:

                mesh.set_surface_override_material(maskIndex, mask)

                PIP.set_shader_parameter("active", false)
                viewport.disable_3d = true
                camera.cull_mask = 0


        else:

            PIP.set_shader_parameter("active", false)
            viewport.disable_3d = true
            camera.cull_mask = 0
