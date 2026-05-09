@tool
extends Node3D


const flagTransition = preload("res://Terrains/Utility/Flag_Transition.tscn")
const poleGround = preload("res://Terrains/Utility/Pole_Ribbon_Ground.tscn")
const poleWater = preload("res://Terrains/Utility/Pole_Ribbon_Water.tscn")
const ribbonMaterial = preload("res://Terrains/Utility/Files/MT_Ribbon.tres")


@export_flags_3d_physics var layers
@export var generatePoles: bool = false: set = ExecuteGeneratePoles
@export var generateRibbon: bool = false: set = ExecuteGenerateRibbon
@export var generateBlocker: bool = false: set = ExecuteGenerateBlocker
@export var generateBorder: bool = false: set = ExecuteGenerateBorder
@export var generateMerge: bool = false: set = ExecuteMergePoles
@export var clear: bool = false: set = ExecuteClear

func ExecuteGeneratePoles(_value: bool) -> void :
    if !Engine.is_editor_hint() || !is_inside_tree() || !_value:
        return


    var poles = Node3D.new()
    poles.name = "Poles"
    add_child(poles, true)
    poles.set_owner(get_tree().edited_scene_root)


    var playableArea = 400.0
    var totalPerimeter = playableArea * 4.0
    var currentDistance = 0.0


    while currentDistance < totalPerimeter:
        var x: float
        var z: float


        if currentDistance < playableArea:

            x = - playableArea / 2.0 + currentDistance
            z = - playableArea / 2.0
        elif currentDistance < playableArea * 2.0:

            x = playableArea / 2.0
            z = - playableArea / 2.0 + (currentDistance - playableArea)
        elif currentDistance < playableArea * 3.0:

            x = playableArea / 2.0 - (currentDistance - playableArea * 2.0)
            z = playableArea / 2.0
        else:

            x = - playableArea / 2.0
            z = playableArea / 2.0 - (currentDistance - playableArea * 3.0)


        var ray = PhysicsRayQueryParameters3D.create(Vector3(x, 100.0, z), Vector3(x, -100, z), layers)
        var hit = get_world_3d().direct_space_state.intersect_ray(ray)


        var poleSpacing = 10.0

        if hit:

            if hit.collider.surface == "Water":
                var pole = poleWater.instantiate()
                poles.add_child(pole, true)
                pole.set_owner(get_tree().edited_scene_root)
                pole.global_position = hit.position
                poleSpacing = 20.0

            else:
                var pole = poleGround.instantiate()
                poles.add_child(pole, true)
                pole.set_owner(get_tree().edited_scene_root)
                pole.global_position = hit.position
                poleSpacing = 10.0


        var nextCorner = floor((currentDistance / playableArea) + 0.001 + 1.0) * playableArea
        if currentDistance + poleSpacing > nextCorner:
            currentDistance = nextCorner
        else:
            currentDistance += poleSpacing
        if currentDistance >= totalPerimeter: break


    FoldHierarchy(poles)
    generatePoles = false

func ExecuteGenerateRibbon(_value: bool) -> void :
    if !Engine.is_editor_hint() || !is_inside_tree() || !_value:
        return


    var poles = get_node("Poles").get_children()


    var flags = Node3D.new()
    flags.name = "Flags"
    add_child(flags, true)
    flags.set_owner(get_tree().edited_scene_root)


    var output = MeshInstance3D.new()
    output.name = "Ribbon"
    add_child(output, true)
    output.set_owner(get_tree().edited_scene_root)


    var ST = SurfaceTool.new()
    ST.begin(Mesh.PRIMITIVE_TRIANGLES)
    ST.set_material(ribbonMaterial)


    var ribbonWidth = 0.05
    var crossSection = [Vector3(0, ribbonWidth, 0), Vector3(0, - ribbonWidth, 0)]


    var vertexCount = 0


    for i in poles.size():

        var currentPole = poles[i]
        var nextPole = poles[(i + 1) % poles.size()]


        var currentRibbonHeight = 1.0
        var nextRibbonHeight = 1.0


        if currentPole.name.contains("Ground"):
            currentRibbonHeight = 1.4
        elif currentPole.name.contains("Water"):
            currentRibbonHeight = 0.9


        if currentPole.name.contains("Break"):
            continue
        elif nextPole.name.contains("Ground"):
            nextRibbonHeight = 1.4
            if currentPole.name.contains("Flag"):
                var flag = flagTransition.instantiate()
                flags.add_child(flag, true)
                flag.set_owner(get_tree().edited_scene_root)
                flag.global_position = currentPole.global_position + Vector3(0.0, 1.5, 0.0)
        elif currentPole.name.contains("Water"):
            nextRibbonHeight = 0.9
            if currentPole.name.contains("Flag"):
                var flag = flagTransition.instantiate()
                flags.add_child(flag, true)
                flag.set_owner(get_tree().edited_scene_root)
                flag.global_position = currentPole.global_position + Vector3(0.0, 1.0, 0.0)

        var polePosition = currentPole.global_position + Vector3(0, currentRibbonHeight, 0)
        var nextPolePosition = nextPole.global_position + Vector3(0, nextRibbonHeight, 0)


        var curve = Curve3D.new()
        var points = 10


        for index in range(points + 1):
            var progress = float(index) / points
            var point = polePosition.lerp(nextPolePosition, progress)
            point.y -= 1.0 * progress * (1.0 - progress)
            curve.add_point(point)


        var density = 0.5
        var length = curve.get_baked_length()
        var steps = int(length * density) + 1
        var stepSize = length / steps if steps > 0 else length


        for index in range(steps + 1):
            var point = curve.sample_baked(index * stepSize)
            var nextPoint = curve.sample_baked(min((index + 1) * stepSize, length))
            var forward = (nextPoint - point).normalized() if index < steps else (point - curve.sample_baked((index - 1) * stepSize)).normalized()
            var up = Vector3.UP
            var right = forward.cross(up).normalized()


            var uCoord = index * stepSize / length if length > 0 else 0.0


            for cornerIndex in range(2):
                var crossPoint = crossSection[cornerIndex]
                var vertex = point + up * crossPoint.y
                var vCoord = 0.0 if cornerIndex == 0 else 1.0
                ST.set_uv(Vector2(uCoord, vCoord))
                ST.set_normal(right)
                ST.add_vertex(vertex)
                vertexCount += 1


            if index > 0:
                var idx = vertexCount - 2
                var idxPrev = vertexCount - 4
                var idxNext = vertexCount - 1
                var idxPrevNext = vertexCount - 3
                ST.add_index(idxPrev)
                ST.add_index(idx)
                ST.add_index(idxNext)
                ST.add_index(idxPrev)
                ST.add_index(idxNext)
                ST.add_index(idxPrevNext)


    if vertexCount > 0:
        ST.generate_tangents()
        output.mesh = ST.commit()
        output.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


    FoldHierarchy(flags)
    generateRibbon = false

func ExecuteGenerateBlocker(_value: bool) -> void :
    if !Engine.is_editor_hint() || !is_inside_tree() || !_value:
        return


    var poles = get_node("Poles").get_children()


    var output = MeshInstance3D.new()
    output.name = "Blocker"
    add_child(output, true)
    output.set_owner(get_tree().edited_scene_root)


    var ST = SurfaceTool.new()
    ST.begin(Mesh.PRIMITIVE_TRIANGLES)


    var colliderWidth = 5.0
    var crossSection = [Vector3( - colliderWidth / 2.0, 0, 0), Vector3(colliderWidth / 2.0, 0, 0)]


    var vertexCount = 0


    for i in poles.size():

        var currentPole = poles[i]
        var nextPole = poles[(i + 1) % poles.size()]


        var colliderHeight = 1.5
        var polePosition = currentPole.global_position + Vector3(0, colliderHeight, 0)
        var nextPolePosition = nextPole.global_position + Vector3(0, colliderHeight, 0)


        var curve = Curve3D.new()
        var points = 10


        for index in range(points + 1):
            var progress = float(index) / points
            var point = polePosition.lerp(nextPolePosition, progress)
            curve.add_point(point)


        var density = 0.1
        var length = curve.get_baked_length()
        var steps = int(length * density) + 1
        var stepSize = length / steps if steps > 0 else length


        for index in range(steps + 1):
            var point = curve.sample_baked(index * stepSize)
            var nextPoint = curve.sample_baked(min((index + 1) * stepSize, length))
            var forward = (nextPoint - point).normalized() if index < steps else (point - curve.sample_baked((index - 1) * stepSize)).normalized()
            var up = Vector3.UP
            var right = forward.cross(up).normalized()


            for cornerIndex in range(2):
                var crossPoint = crossSection[cornerIndex]
                var vertex = point + right * crossPoint.x
                ST.add_vertex(vertex)
                vertexCount += 1


            if index > 0:
                var idx = vertexCount - 2
                var idxPrev = vertexCount - 4
                var idxNext = vertexCount - 1
                var idxPrevNext = vertexCount - 3
                ST.add_index(idxPrev)
                ST.add_index(idx)
                ST.add_index(idxNext)
                ST.add_index(idxPrev)
                ST.add_index(idxNext)
                ST.add_index(idxPrevNext)


    if vertexCount > 0:
        output.mesh = ST.commit()
        output.set_layer_mask_value(1, false)

        output.create_trimesh_collision()
        output.get_child(0).name = "StaticBody3D"
        output.get_child(0).set_collision_layer_value(1, false)
        output.get_child(0).set_collision_layer_value(31, true)
        output.get_child(0).set_collision_mask_value(1, false)
        output.get_child(0).set_script(Surface)
        output.get_child(0).surface = "Border"


    FoldHierarchy(output)
    generateBlocker = false

func ExecuteGenerateBorder(_value: bool) -> void :
    if !Engine.is_editor_hint() || !is_inside_tree() || !_value:
        return


    var poles = get_node("Poles").get_children()


    var output = MeshInstance3D.new()
    output.name = "Border"
    add_child(output, true)
    output.set_owner(get_tree().edited_scene_root)


    var ST = SurfaceTool.new()
    ST.begin(Mesh.PRIMITIVE_TRIANGLES)


    var topHeight = 100.0
    var bottomHeight = -100.0


    for i in poles.size():

        var nextIDX = (i + 1) % poles.size()


        var p1 = poles[i].global_position
        var p2 = poles[nextIDX].global_position


        var vBottomL = Vector3(p1.x, bottomHeight, p1.z)
        var vBottomR = Vector3(p2.x, bottomHeight, p2.z)
        var vTopL = Vector3(p1.x, topHeight, p1.z)
        var vTopR = Vector3(p2.x, topHeight, p2.z)


        var start_idx = i * 4
        ST.add_vertex(vBottomL)
        ST.add_vertex(vBottomR)
        ST.add_vertex(vTopL)
        ST.add_vertex(vTopR)


        ST.add_index(start_idx + 0)
        ST.add_index(start_idx + 2)
        ST.add_index(start_idx + 1)
        ST.add_index(start_idx + 1)
        ST.add_index(start_idx + 2)
        ST.add_index(start_idx + 3)


    output.mesh = ST.commit()
    output.set_layer_mask_value(1, false)

    output.create_trimesh_collision()
    output.get_child(0).name = "StaticBody3D"
    output.get_child(0).set_collision_layer_value(1, false)
    output.get_child(0).set_collision_layer_value(32, true)
    output.get_child(0).set_collision_mask_value(1, false)


    FoldHierarchy(output)
    generateBorder = false

func ExecuteMergePoles(_value: bool) -> void :
    if !Engine.is_editor_hint() || !is_inside_tree() || !_value:
        return


    var poles = get_node("Poles")


    var outputMesh = MeshInstance3D.new()
    var mergedMesh = ArrayMesh.new()
    var ST = SurfaceTool.new()


    var outputMaterial: Material
    var materialFound = false


    ST.begin(Mesh.PRIMITIVE_TRIANGLES)


    for pole in poles.get_children():

        for element in pole.get_children():

            if element is MeshInstance3D:

                if element.name == "Mesh" || element.name == "LOD0":

                    var mesh = element.mesh
                    if !mesh: continue


                    ST.append_from(mesh, 0, pole.transform)


                    if !materialFound:
                        outputMaterial = element.get_surface_override_material(0)
                        materialFound = true


    var output = Node3D.new()
    output.name = "Poles [M]"
    add_child(output, true)
    move_child(output, 1)
    output.owner = get_tree().edited_scene_root


    mergedMesh = ST.commit()
    outputMesh.mesh = mergedMesh
    outputMesh.name = "Mesh"
    output.add_child(outputMesh, true)
    outputMesh.set_owner(get_tree().edited_scene_root)


    if materialFound:
        outputMesh.set_surface_override_material(0, outputMaterial)


    poles.hide()
    poles.process_mode = Node.PROCESS_MODE_DISABLED


    FoldHierarchy(output)
    generateMerge = false

func ExecuteClear(_value: bool) -> void :
    if !Engine.is_editor_hint() || !is_inside_tree() || !_value:
        return


    var childCount = get_child_count()


    if childCount != 0 && childCount < 10:
        for child in get_children():
            remove_child(child)
            child.queue_free()

    clear = false

func FoldHierarchy(node: Node) -> void :
    node.set_display_folded(true)
    for child in node.get_children():
        FoldHierarchy(child)
