@tool
extends Node3D


const borderPole = preload("res://Terrains/Utility/Pole_Ribbon_Field.tscn")
const wireMaterial = preload("res://Terrains/Utility/Files/MT_Wire.tres")

@export var terrain: Mesh
@export var generatePoles: bool = false: set = ExecuteGeneratePoles
@export var generateWires: bool = false: set = ExecuteGenerateWires
@export var generateCollider: bool = false: set = ExecuteGenerateCollider
@export var generateMerge: bool = false: set = ExecuteMergePoles
@export var clear: bool = false: set = ExecuteClear


const density = 5.0
const wireWidth = 0.05

func ExecuteClear(_value: bool) -> void :

    for child in get_children():
        child.queue_free()

func ExecuteGeneratePoles(_value: bool) -> void :

    ExecuteClear(true)


    if !terrain:
        print("Terrain not assigned!")
        return
    if !borderPole:
        print("Pole not assigned!")
        return


    var poles = Node3D.new()
    poles.name = "Poles"
    add_child(poles, true)
    poles.set_owner(get_tree().edited_scene_root)


    var MDT = MeshDataTool.new()
    MDT.create_from_surface(terrain, 0)


    var zStart = -300.0
    var zEnd = 300.0
    var xFin = -10.0
    var xRus = 10.0


    var totalDistance = abs(zEnd - zStart)
    var steps = int(totalDistance / density)


    for i in range(steps + 1):

        var currentZ = zStart + (i * density)
        var currentY = GetTerrainHeight(xFin, currentZ, MDT)


        var pole = borderPole.instantiate()
        poles.add_child(pole, true)
        pole.owner = get_tree().edited_scene_root
        pole.global_position = Vector3(xFin, currentY, currentZ)


        if randi_range(1, 100) < 10: pole.name += "_Break"
        if i == steps: pole.name += "_Break"


    for i in range(steps + 1):

        var currentZ = zStart + (i * density)
        var currentY = GetTerrainHeight(xRus, currentZ, MDT)


        var pole = borderPole.instantiate()
        poles.add_child(pole, true)
        pole.owner = get_tree().edited_scene_root
        pole.global_position = Vector3(xRus, currentY, currentZ)


        if randi_range(1, 100) < 10: pole.name += "_Break"
        if i == steps: pole.name += "_Break"


    FoldHierarchy(poles)
    generatePoles = false

func ExecuteGenerateWires(_value: bool) -> void :

    var poles = get_node("Poles").get_children()


    var output = MeshInstance3D.new()
    output.name = "Wires"
    add_child(output, true)
    output.set_owner(get_tree().edited_scene_root)


    var ST = SurfaceTool.new()
    ST.begin(Mesh.PRIMITIVE_TRIANGLES)
    ST.set_material(wireMaterial)


    var vertexCount = 0


    var wireHeights = [1.2, 0.8, 0.4]


    const wireFrequency = 1.0
    const wireAmplitude = 0.1


    for i in range(poles.size() - 1):

        var currentPole = poles[i]
        var nextPole = poles[i + 1]


        if currentPole.name.contains("_Break"):
            continue


        for height in range(wireHeights.size()):

            var currentHeight = wireHeights[height]
            var currentTarget = to_local(currentPole.global_position) + Vector3(0, currentHeight, 0)
            var nextTarget = to_local(nextPole.global_position) + Vector3(0, currentHeight, 0)
            var targetDistance = currentTarget.distance_to(nextTarget)
            var segments = max(1, int(targetDistance))


            for segment in range(segments):

                var wireStart = sin(float(segment) / segments * PI)
                var wireEnd = sin(float(segment + 1) / segments * PI)


                var frequency = wireFrequency * (1.0 + (height * 0.3))
                var phase = height * 2.0


                var startOffset = Vector3(
                    sin(float(segment) / segments * frequency * PI + phase) * wireAmplitude * wireStart, 
                    cos(float(segment) / segments * frequency * PI + phase * 1.5) * wireAmplitude * wireStart, 
                    0
                )
                var endOffset = Vector3(
                    sin(float(segment + 1) / segments * frequency * PI + phase) * wireAmplitude * wireEnd, 
                    cos(float(segment + 1) / segments * frequency * PI + phase * 1.5) * wireAmplitude * wireEnd, 
                    0
                )


                var v1 = currentTarget.lerp(nextTarget, float(segment) / segments) + startOffset + Vector3(0, - wireWidth, 0)
                var v2 = currentTarget.lerp(nextTarget, float(segment) / segments) + startOffset + Vector3(0, wireWidth, 0)
                var v3 = currentTarget.lerp(nextTarget, float(segment + 1) / segments) + endOffset + Vector3(0, - wireWidth, 0)
                var v4 = currentTarget.lerp(nextTarget, float(segment + 1) / segments) + endOffset + Vector3(0, wireWidth, 0)


                ST.set_uv(Vector2(0, 1));ST.add_vertex(v1)
                ST.set_uv(Vector2(0, 0));ST.add_vertex(v2)
                ST.set_uv(Vector2(1, 1));ST.add_vertex(v3)
                ST.set_uv(Vector2(1, 0));ST.add_vertex(v4)


                ST.add_index(vertexCount + 0);
                ST.add_index(vertexCount + 1);
                ST.add_index(vertexCount + 2)
                ST.add_index(vertexCount + 1);
                ST.add_index(vertexCount + 3);
                ST.add_index(vertexCount + 2)
                vertexCount += 4


    if vertexCount > 0:
        ST.generate_normals()
        output.mesh = ST.commit()
        output.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


    generateWires = false

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
    move_child(output, 1)
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

func GetTerrainHeight(targetX: float, targetZ: float, dataTool: MeshDataTool) -> float:
    var closestY = 0.0
    var minDistance = INF
    for i in range(dataTool.get_vertex_count()):
        var v_pos = dataTool.get_vertex(i)
        var v_dist = Vector2(v_pos.x, v_pos.z).distance_to(Vector2(targetX, targetZ))
        if v_dist < minDistance:
            minDistance = v_dist
            closestY = v_pos.y
    return closestY

func FoldHierarchy(node: Node) -> void :
    node.set_display_folded(true)
    for child in node.get_children():
        FoldHierarchy(child)
