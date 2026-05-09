@tool
extends Node3D

@export var atlasOutput: String = "res://Nature/Trees/Files"
@export var atlasName: String = "TX_Tree_Billboard_AL"
@export var atlasSlot: int = 1
@export var resolution: int = 2048
@export var billboardMaterial: Material
@export var shadowMaterial: Material
@export var createAtlas: bool = false
@export var individualRenders: bool = false
@export var render: bool = false: set = ExecuteRender
@export var clear: bool = false: set = ExecuteClear

func ExecuteRender(_value: bool) -> void :
    ExecuteClear(true)
    if individualRenders:
        RenderIndividual()
    else:
        RenderBillboards()
    render = false

func RenderIndividual() -> void :

    var original3DMode = ProjectSettings.get_setting("rendering/scaling_3d/mode")
    var original3DScale = ProjectSettings.get_setting("rendering/scaling_3d/scale")


    ProjectSettings.set_setting("rendering/scaling_3d/mode", Viewport.SCALING_3D_MODE_BILINEAR)
    ProjectSettings.set_setting("rendering/scaling_3d/scale", 1.0)


    var viewport = SubViewport.new()
    add_child(viewport)
    viewport.owner = get_tree().edited_scene_root
    viewport.name = "Viewport"
    viewport.size = Vector2i(resolution, resolution)
    viewport.transparent_bg = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
    viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
    await get_tree().process_frame


    var camera = Camera3D.new()
    viewport.add_child(camera)
    camera.owner = get_tree().edited_scene_root
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    await get_tree().process_frame


    var mesh: MeshInstance3D = get_child(0)
    var aabb: AABB = mesh.get_aabb()
    var center: Vector3 = aabb.get_center()


    var width = max(round(aabb.size.x), 1.0)
    var height = max(round(aabb.size.y), 1.0)
    var depth = max(round(aabb.size.z), 1.0)
    var centerX = round(center.x)
    var centerZ = round(center.z)


    var largestDimension = max(width, height, depth)
    var billboardSize = ceil(largestDimension)


    var cameraHeight = billboardSize / 2.0
    var cameraDistance = max(billboardSize * 2.0, 10.0)
    var orthoSize = billboardSize
    camera.size = orthoSize


    var treeName = mesh.name if mesh.name != "" else "Tree"


    var cameraPosition = Vector3(centerX, cameraHeight, centerZ + cameraDistance)
    var targetPosition = Vector3(centerX, cameraHeight, centerZ)
    camera.global_transform.origin = cameraPosition
    camera.look_at(targetPosition, Vector3.UP)
    viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    await get_tree().process_frame


    var frontRender: Image = viewport.get_texture().get_image()
    var frontPath = atlasOutput.path_join("Front_" + treeName + ".png")
    frontRender.save_png(frontPath)


    cameraPosition = Vector3(centerX + cameraDistance, cameraHeight, centerZ)
    targetPosition = Vector3(centerX, cameraHeight, centerZ)
    camera.global_transform.origin = cameraPosition
    camera.look_at(targetPosition, Vector3.UP)
    viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    await get_tree().process_frame


    var rightRender: Image = viewport.get_texture().get_image()
    var rightPath = atlasOutput.path_join("Right_" + treeName + ".png")
    rightRender.save_png(rightPath)


    viewport.queue_free()
    camera.queue_free()


    ProjectSettings.set_setting("rendering/scaling_3d/mode", original3DMode)
    ProjectSettings.set_setting("rendering/scaling_3d/scale", original3DScale)


    if Engine.is_editor_hint():
        await get_tree().create_timer(0.5).timeout
        EditorInterface.get_resource_filesystem().scan()

func RenderBillboards() -> void :

    var original3DMode = ProjectSettings.get_setting("rendering/scaling_3d/mode")
    var original3DScale = ProjectSettings.get_setting("rendering/scaling_3d/scale")


    ProjectSettings.set_setting("rendering/scaling_3d/mode", Viewport.SCALING_3D_MODE_BILINEAR)
    ProjectSettings.set_setting("rendering/scaling_3d/scale", 1.0)


    var viewport = SubViewport.new()
    add_child(viewport)
    viewport.owner = get_tree().edited_scene_root
    viewport.name = "Viewport"
    viewport.size = Vector2i(resolution / 4, resolution / 4)
    viewport.transparent_bg = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
    viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
    await get_tree().process_frame


    var camera = Camera3D.new()
    viewport.add_child(camera)
    camera.owner = get_tree().edited_scene_root
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    await get_tree().process_frame


    var renders: Array[Image] = []


    var mesh: MeshInstance3D = get_child(0)
    var aabb: AABB = mesh.get_aabb()
    var center: Vector3 = aabb.get_center()


    var width = max(round(aabb.size.x), 1.0)
    var height = max(round(aabb.size.y), 1.0)
    var depth = max(round(aabb.size.z), 1.0)
    var centerX = round(center.x)
    var centerZ = round(center.z)


    var largestDimension = max(width, height, depth)
    var billboardSize = ceil(largestDimension)


    var cameraHeight = billboardSize / 2.0
    var cameraDistance = max(billboardSize * 2.0, 10.0)
    var orthoSize = billboardSize
    camera.size = orthoSize


    var cameraPosition = Vector3(centerX, cameraHeight, centerZ + cameraDistance)
    var targetPosition = Vector3(centerX, cameraHeight, centerZ)
    camera.global_transform.origin = cameraPosition
    camera.look_at(targetPosition, Vector3.UP)
    viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    await get_tree().process_frame


    var frontRender: Image = viewport.get_texture().get_image()
    renders.append(frontRender)


    cameraPosition = Vector3(centerX + cameraDistance, cameraHeight, centerZ)
    targetPosition = Vector3(centerX, cameraHeight, centerZ)
    camera.global_transform.origin = cameraPosition
    camera.look_at(targetPosition, Vector3.UP)
    viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    await get_tree().process_frame


    var rightRender: Image = viewport.get_texture().get_image()
    renders.append(rightRender)


    viewport.queue_free()
    camera.queue_free()


    ProjectSettings.set_setting("rendering/scaling_3d/mode", original3DMode)
    ProjectSettings.set_setting("rendering/scaling_3d/scale", original3DScale)


    var filesToReimport: Array[String] = []


    var UVData: Array[Dictionary] = []

    var atlas: Image
    var atlasPath = atlasOutput.path_join(atlasName + ".png")

    if createAtlas or not ResourceLoader.exists(atlasPath):
        atlas = Image.create(resolution, resolution, false, renders[0].get_format())
    else:
        var texture = load(atlasPath)
        if texture is Texture2D:
            atlas = texture.get_image()
            if atlas.is_compressed():
                atlas.decompress()
        else:
            push_error("Failed to load existing atlas as Texture2D.")
            return


    for i in range(renders.size()):
        var typeIndex = i / 2
        var viewIndex = i % 2
        var row: int
        var col: int


        if atlasSlot == 1:
            row = 0
            col = 0
        elif atlasSlot == 2:
            row = 0
            col = 1
        elif atlasSlot == 3:
            row = 2
            col = 0
        elif atlasSlot == 4:
            row = 2
            col = 1


        col = col * 2 + viewIndex


        var xOffset = col * resolution / 4
        var yOffset = row * resolution / 4


        var blank = Image.create(resolution / 4, resolution / 4, false, renders[i].get_format())
        blank.fill(Color(0, 0, 0, 0))
        atlas.blit_rect(blank, Rect2i(0, 0, resolution / 4, resolution / 4), Vector2i(xOffset, yOffset))


        atlas.blit_rect(renders[i], Rect2i(0, 0, resolution / 4, resolution / 4), Vector2i(xOffset, yOffset))


        var UVStart = Vector2(float(xOffset) / resolution, float(yOffset) / resolution)
        var UVEnd = UVStart + Vector2(float(resolution / 4) / resolution, float(resolution / 4) / resolution)
        UVData.append({"typeIndex": typeIndex, "viewIndex": viewIndex, "UVStart": UVStart, "UVEnd": UVEnd})


    var err = atlas.save_png(atlasPath)


    filesToReimport.append(atlasPath)


    var frontUV = UVData.filter( func(uv): return uv.viewIndex == 0)
    var rightUV = UVData.filter( func(uv): return uv.viewIndex == 1)
    frontUV = frontUV[0]
    rightUV = rightUV[0]


    var billboardMesh = ArrayMesh.new()
    var arrays = []
    arrays.resize(Mesh.ARRAY_MAX)


    var vertices = PackedVector3Array([

        Vector3( - billboardSize / 2.0, 0.0, 0.0), 
        Vector3(billboardSize / 2.0, 0.0, 0.0), 
        Vector3(billboardSize / 2.0, billboardSize, 0.0), 
        Vector3( - billboardSize / 2.0, billboardSize, 0.0), 

        Vector3(0.0, 0.0, - billboardSize / 2.0), 
        Vector3(0.0, 0.0, billboardSize / 2.0), 
        Vector3(0.0, billboardSize, billboardSize / 2.0), 
        Vector3(0.0, billboardSize, - billboardSize / 2.0), 
    ])


    var frontUVxStart = frontUV.UVStart.x
    var frontUVxEnd = frontUV.UVEnd.x
    var frontUVyStart = frontUV.UVStart.y
    var frontUVyEnd = frontUV.UVEnd.y

    var rightUVxStart = rightUV.UVStart.x
    var rightUVxEnd = rightUV.UVEnd.x
    var rightUVyStart = rightUV.UVStart.y
    var rightUVyEnd = rightUV.UVEnd.y


    var uvs = PackedVector2Array([

        Vector2(frontUVxStart, frontUVyEnd), 
        Vector2(frontUVxEnd, frontUVyEnd), 
        Vector2(frontUVxEnd, frontUVyStart), 
        Vector2(frontUVxStart, frontUVyStart), 

        Vector2(rightUVxEnd, rightUVyEnd), 
        Vector2(rightUVxStart, rightUVyEnd), 
        Vector2(rightUVxStart, rightUVyStart), 
        Vector2(rightUVxEnd, rightUVyStart), 
    ])


    var normals = PackedVector3Array([
        Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0), 
        Vector3(1.0, 0.0, 0.0), Vector3(1.0, 0.0, 0.0), Vector3(1.0, 0.0, 0.0), Vector3(1.0, 0.0, 0.0), 
    ])


    var indices = PackedInt32Array([
        0, 1, 2, 0, 2, 3, 
        4, 5, 6, 4, 6, 7, 
    ])


    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_NORMAL] = normals
    arrays[Mesh.ARRAY_TEX_UV] = uvs
    arrays[Mesh.ARRAY_INDEX] = indices


    billboardMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)


    var billboard = MeshInstance3D.new()
    add_child(billboard)
    billboard.owner = get_tree().edited_scene_root
    billboard.mesh = billboardMesh
    billboard.name = "Billboard"
    billboard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    billboard.set_surface_override_material(0, billboardMaterial)
    billboard.global_position = Vector3.ZERO
    billboard.visibility_range_begin = 40.0


    var shadow1 = MeshInstance3D.new()
    add_child(shadow1)
    shadow1.owner = get_tree().edited_scene_root
    shadow1.mesh = billboardMesh
    shadow1.name = "Shadow_01"
    shadow1.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
    shadow1.set_surface_override_material(0, shadowMaterial)
    shadow1.global_position = Vector3.ZERO


    var shadow2 = shadow1.duplicate() as MeshInstance3D
    add_child(shadow2)
    shadow2.owner = get_tree().edited_scene_root
    shadow2.name = "Shadow_02"
    shadow2.rotate_y(deg_to_rad(45))
    shadow2.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
    shadow2.set_surface_override_material(0, shadowMaterial)
    shadow2.global_position = Vector3.ZERO


    var combinedShadow = MeshInstance3D.new()
    add_child(combinedShadow)
    combinedShadow.owner = get_tree().edited_scene_root
    combinedShadow.name = "Shadow"
    combinedShadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
    combinedShadow.global_position = Vector3.ZERO


    var mergedMesh: ArrayMesh
    var surfaceTool = SurfaceTool.new()
    surfaceTool.append_from(shadow1.mesh, 0, shadow1.transform)
    surfaceTool.append_from(shadow2.mesh, 0, shadow2.transform)
    mergedMesh = surfaceTool.commit()
    combinedShadow.mesh = ArrayMesh.new()
    combinedShadow.mesh = mergedMesh
    combinedShadow.set_surface_override_material(0, shadowMaterial)


    shadow1.queue_free()
    shadow2.queue_free()


    if Engine.is_editor_hint():
        await get_tree().create_timer(0.5).timeout
        EditorInterface.get_resource_filesystem().scan()

func ExecuteClear(_value: bool) -> void :
    var childCount = get_child_count()

    if childCount != 0:
        for child in get_children():
            if child.name != "Mesh":
                remove_child(child)
                child.queue_free()
    clear = false
