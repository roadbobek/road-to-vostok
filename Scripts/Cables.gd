@tool
extends Node3D


const cableMaterial = preload("res://Modular/Materials/MT_Cable.tres")


@export var poles: Node3D
@export var generate: bool = false: set = ExecuteGenerate
@export var clear: bool = false: set = ExecuteClear

func ExecuteGenerate(_value: bool) -> void :

    if poles:
        ExecuteClear(true)
        ExecuteGenerateCables(true)
        ExecuteGenerateBlocker(true)
    generate = false

func ExecuteGenerateCables(_value: bool) -> void :

    var output = MeshInstance3D.new()
    output.name = "Mesh"
    add_child(output, true)
    output.set_owner(get_tree().edited_scene_root)


    var ST = SurfaceTool.new()
    ST.begin(Mesh.PRIMITIVE_TRIANGLES)
    ST.set_material(cableMaterial)


    var cableThickness = 0.02
    var crossSection = [
        Vector3( - cableThickness, - cableThickness, 0), 
        Vector3(cableThickness, - cableThickness, 0), 
        Vector3(cableThickness, cableThickness, 0), 
        Vector3( - cableThickness, cableThickness, 0)
    ]


    var vertexCount = 0


    for pole in poles.get_children():

        var polePosition = pole.global_position + Vector3(0, 10, 0)


        for target in pole.targets:

            var targetPosition = target.global_position + Vector3(0, 10, 0)


            var curve = Curve3D.new()
            var points = 10


            for index in range(points + 1):
                var progress = float(index) / points
                var point = polePosition.lerp(targetPosition, progress)
                point.y -= 4.0 * progress * (1.0 - progress)
                curve.add_point(point)


            var density = 0.5;
            var length = curve.get_baked_length()
            var steps = int(length * density) + 1
            var stepSize = length / steps if steps > 0 else length


            for index in range(steps + 1):
                var point = curve.sample_baked(index * stepSize)
                var nextPoint = curve.sample_baked(min((index + 1) * stepSize, length))
                var forward = (nextPoint - point).normalized() if index < steps else (point - curve.sample_baked((index - 1) * stepSize)).normalized()
                var up = Vector3.UP
                var right = forward.cross(up).normalized()
                up = right.cross(forward).normalized()


                var uCoord = index * stepSize / length if length > 0 else 0.0


                for cornerIndex in range(4):
                    var crossPoint = crossSection[cornerIndex]
                    var vertex = point + right * crossPoint.x + up * crossPoint.y
                    var vCoord = 0.0 if cornerIndex < 2 else 1.0
                    ST.set_uv(Vector2(uCoord, vCoord))
                    ST.set_normal(right)
                    ST.add_vertex(vertex)
                    vertexCount += 1


                if index > 0:
                    for cornerIndex in range(4):
                        var nextCorner = (cornerIndex + 1) % 4
                        var idx = vertexCount - 4 + cornerIndex
                        var idxPrev = vertexCount - 8 + cornerIndex
                        var idxNext = vertexCount - 4 + nextCorner
                        var idxPrevNext = vertexCount - 8 + nextCorner
                        ST.add_index(idxPrevNext)
                        ST.add_index(idx)
                        ST.add_index(idxPrev)
                        ST.add_index(idxPrevNext)
                        ST.add_index(idxNext)
                        ST.add_index(idx)


    if vertexCount > 0:
        output.mesh = ST.commit()
        output.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func ExecuteGenerateBlocker(_value: bool) -> void :

    var output = MeshInstance3D.new()
    output.name = "Blocker"
    add_child(output, true)
    output.set_owner(get_tree().edited_scene_root)


    var ST = SurfaceTool.new()
    ST.begin(Mesh.PRIMITIVE_TRIANGLES)


    var colliderWidth = 5.0
    var crossSection = [Vector3( - colliderWidth / 2.0, 0, 0), Vector3(colliderWidth / 2.0, 0, 0)]


    var vertexCount = 0


    for pole in poles.get_children():

        var polePosition = pole.global_position + Vector3(0, 10, 0)


        for target in pole.targets:

            var targetPosition = target.global_position + Vector3(0, 10, 0)


            var curve = Curve3D.new()
            var points = 10


            for index in range(points + 1):
                var progress = float(index) / points
                var point = polePosition.lerp(targetPosition, progress)
                curve.add_point(point)


            var density = 0.5;
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
        output.get_child(0).surface = "Cables"

func ExecuteClear(_value: bool) -> void :

    var childCount = get_child_count()


    if childCount != 0 && childCount < 3:
        for child in get_children():
            if child.name == "Mesh" || child.name == "Blocker":
                remove_child(child)
                child.queue_free()

    clear = false
