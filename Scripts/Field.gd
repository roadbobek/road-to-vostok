@tool
extends Node3D


const poleField = preload("res://Terrains/Utility/Pole_Ribbon_Field.tscn")
const ribbonMaterial = preload("res://Terrains/Utility/Files/MT_Ribbon_Field.tres")


@export var generatePoles: bool = false: set = ExecuteGeneratePoles
@export var generateRibbon: bool = false: set = ExecuteGenerateRibbon
@export var generateCollider: bool = false: set = ExecuteGenerateCollider
@export var generateMerge: bool = false: set = ExecuteMergePoles
@export var clear: bool = false: set = ExecuteClear

func ExecuteGeneratePoles(_value: bool) -> void :

    var poles = Node3D.new()
    poles.name = "Poles"
    add_child(poles, true)
    poles.set_owner(get_tree().edited_scene_root)


    var poleSpacing = 5.0


    var corners = []
    for child in get_node("Corners").get_children():
        corners.append(child)


    var posePositions: Array[Vector2] = []


    for i in corners.size():

        var start = corners[i]
        var end = corners[(i + 1) % corners.size()]
        var startXZ = Vector2(start.global_position.x, start.global_position.z)
        var endXZ = Vector2(end.global_position.x, end.global_position.z)
        var segmentVector = endXZ - startXZ
        var segmentLength = segmentVector.length()
        var direction = segmentVector.normalized()
        var count = max(1, round(segmentLength / poleSpacing))
        var spacing = segmentLength / count


        for j in range(count):
            posePositions.append(startXZ + direction * (spacing * j))


    for xz in posePositions:

        xz.x += 0.1
        xz.y += 0.05
        var ray = PhysicsRayQueryParameters3D.create(Vector3(xz.x, 100.0, xz.y), Vector3(xz.x, -100, xz.y))
        var hit = get_world_3d().direct_space_state.intersect_ray(ray)

        if hit:

            var pole = poleField.instantiate()
            poles.add_child(pole, true)
            pole.set_owner(get_tree().edited_scene_root)
            pole.global_position = Vector3(xz.x, hit.position.y, xz.y)


            if randi_range(1, 100) < 10:
                pole.name = pole.name + "_Break"

    FoldHierarchy(poles)
    generatePoles = false

func ExecuteGenerateRibbon(_value: bool) -> void :

    var poles = get_node("Poles").get_children()


    var output = MeshInstance3D.new()
    output.name = "Ribbon"
    add_child(output, true)
    output.set_owner(get_tree().edited_scene_root)


    var ST = SurfaceTool.new()
    ST.begin(Mesh.PRIMITIVE_TRIANGLES)
    ST.set_material(ribbonMaterial)


    var ribbonWidth = 0.02
    var crossSection = [Vector3(0, ribbonWidth, 0), Vector3(0, - ribbonWidth, 0)]


    var vertexCount = 0


    for i in poles.size():

        var currentPole = poles[i]
        var nextPole = poles[(i + 1) % poles.size()]


        var currentRibbonHeight = 1.2
        var nextRibbonHeight = 1.2


        if currentPole.name.contains("Break"):
            continue


        var polePosition = currentPole.global_position + Vector3(0, currentRibbonHeight, 0)
        var nextPolePosition = nextPole.global_position + Vector3(0, nextRibbonHeight, 0)


        var curve = Curve3D.new()
        var points = 10


        for index in range(points + 1):
            var progress = float(index) / points
            var point = polePosition.lerp(nextPolePosition, progress)
            point.y -= 0.5 * progress * (1.0 - progress)
            curve.add_point(point)


        var density = 1.0
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

    generateRibbon = false

func ExecuteGenerateCollider(_value: bool) -> void :

    var output = MeshInstance3D.new()
    output.name = "Collider"
    add_child(output, true)
    output.set_owner(get_tree().edited_scene_root)


    var poles = get_node("Poles").get_children()


    var ST = SurfaceTool.new()
    ST.begin(Mesh.PRIMITIVE_TRIANGLES)


    var height = 1.2
    var thickness = 0.2
    var vertices = 0


    for i in range(poles.size()):
        var currentPole = poles[i]
        var nextPole = poles[(i + 1) % poles.size()]


        if currentPole.name.contains("Break"):
            continue

        var p1 = currentPole.global_position
        var p2 = nextPole.global_position
        var dir = (p2 - p1).normalized()
        var right = Vector3.UP.cross(dir).normalized() * (thickness / 2.0)


        var bfl = p1 + right
        var bfr = p1 - right
        var bbl = p2 + right
        var bbr = p2 - right
        var tfl = bfl + Vector3(0, height, 0)
        var tfr = bfr + Vector3(0, height, 0)
        var tbl = bbl + Vector3(0, height, 0)
        var tbr = bbr + Vector3(0, height, 0)


        var faces = [[bfl, bbl, tfl, tbl], 
            [bbr, bfr, tbr, tfr], 
            [tfl, tbl, tfr, tbr], 
            [bfr, bfl, tfr, tfl], 
            [bbl, bbr, tbl, tbr]
        ]


        for face in faces:
            ST.add_vertex(face[0])
            ST.add_vertex(face[1])
            ST.add_vertex(face[2])
            ST.add_vertex(face[3])
            ST.add_index(vertices + 0)
            ST.add_index(vertices + 1)
            ST.add_index(vertices + 2)
            ST.add_index(vertices + 1)
            ST.add_index(vertices + 3)
            ST.add_index(vertices + 2)
            vertices += 4


    output.mesh = ST.commit()
    output.set_layer_mask_value(1, false)

    output.create_trimesh_collision()
    output.get_child(0).name = "StaticBody3D"
    output.get_child(0).set_collision_layer_value(1, false)
    output.get_child(0).set_collision_layer_value(6, true)
    output.get_child(0).get_child(0).set_script(Surface)
    output.get_child(0).get_child(0).surface = "Wood"

    FoldHierarchy(output)
    generateCollider = false

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
    move_child(output, 2)
    output.owner = get_tree().edited_scene_root


    mergedMesh = ST.commit()
    outputMesh.mesh = mergedMesh
    outputMesh.name = "Mesh"
    output.add_child(outputMesh, true)
    outputMesh.set_owner(get_tree().edited_scene_root)


    output.get_child(0).create_trimesh_collision()
    output.get_child(0).get_child(0).name = "StaticBody3D"
    output.get_child(0).get_child(0).set_script(Surface)
    output.get_child(0).get_child(0).surface = "Wood"


    if materialFound:
        outputMesh.set_surface_override_material(0, outputMaterial)


    poles.hide()
    poles.process_mode = Node.PROCESS_MODE_DISABLED


    FoldHierarchy(output)
    generateMerge = false

func ExecuteClear(_value: bool) -> void :

    if get_child_count() != 0:
        for child in get_children():
            if child.name != "Corners":
                remove_child(child)
                child.queue_free()

    clear = false

func FoldHierarchy(node: Node) -> void :
    node.set_display_folded(true)
    for child in node.get_children():
        FoldHierarchy(child)
