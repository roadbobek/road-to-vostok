@tool
extends Node3D

@export var sort: bool = false: set = ExecuteSort
@export var reindex: bool = false: set = ExecuteReindex
@export_group("Optimizer")
@export var merge: bool = false: set = ExecuteMerge
@export var shadows = false
@export var fractional = false
@export var visibility = 50.0
@export_group("Runtime")
@export var clear = false



func _ready() -> void :

    if Engine.is_editor_hint(): return

    if visible: return

    if process_mode != ProcessMode.PROCESS_MODE_DISABLED: return


    if !Engine.is_editor_hint() && !clear:
        push_warning("Optimizer: " + owner.name + " (Not cleared)")


    if !Engine.is_editor_hint() && clear:
        queue_free()



func ExecuteSort(_value: bool) -> void :

    if !_value: return
    if !Engine.is_editor_hint(): return


    var children = get_children()

    if children.size() == 0: return

    children.sort_custom( func(a, b): return a.name.naturalnocasecmp_to(b.name) < 0)


    for child in children:
        move_child(child, -1)


    emit_signal("child_order_changed")
    sort = false

func ExecuteReindex(_value: bool) -> void :

    if !_value: return
    if !Engine.is_editor_hint(): return


    var children = get_children()

    if children.size() == 0: return


    var regex = RegEx.new()
    regex.compile("(_\\d+)$")
    var counters = {}


    for child in children:

        var baseName = regex.sub(child.name, "")

        if !counters.has(baseName):
            child.name = baseName
            counters[baseName] = 2

        else:
            child.name = baseName + "_" + str(counters[baseName])
            counters[baseName] += 1


    reindex = false

func ExecuteMerge(_value: bool) -> void :

    if !_value: return
    if !Engine.is_editor_hint(): return


    var RMap = {}
    var PMap = {}


    var targetSurfaces = ["Generic", "Wood", "Metal", "Concrete", "Rock"]

    var materialList = {}


    for child in get_children():

        for element in child.get_children():

            if element is MeshInstance3D:

                if element.name == "Mesh" || element.name == "LOD0":

                    var surfaceCount = element.mesh.get_surface_count()

                    for i in range(surfaceCount):

                        var surfaceMaterial = element.get_surface_override_material(i)

                        if !materialList.has(surfaceMaterial):

                            materialList[surfaceMaterial] = SurfaceTool.new()

                        materialList[surfaceMaterial].append_from(element.mesh, i, child.transform)


                    if element.get_child_count() != 0:

                        if element.get_child(0) is StaticBody3D:

                            var staticBody = element.get_child(0)
                            var surfaceType = "Empty"


                            if "surface" in staticBody and staticBody.surface in targetSurfaces:
                                surfaceType = staticBody.surface


                            if !RMap.has(surfaceType): RMap[surfaceType] = SurfaceTool.new()
                            if !PMap.has(surfaceType): PMap[surfaceType] = SurfaceTool.new()


                            for i in range(surfaceCount):
                                RMap[surfaceType].append_from(element.mesh, i, child.transform)
                                PMap[surfaceType].append_from(element.mesh, i, child.transform)


                if element.name == "Collider_R":

                    var staticBody = element.get_child(0)
                    var surfaceType = "Empty"

                    if "surface" in staticBody and staticBody.surface in targetSurfaces:
                        surfaceType = staticBody.surface

                    if !RMap.has(surfaceType): RMap[surfaceType] = SurfaceTool.new()

                    for i in range(element.mesh.get_surface_count()):
                        RMap[surfaceType].append_from(element.mesh, i, child.transform)

                if element.name == "Collider_P":

                    var staticBody = element.get_child(0)
                    var surfaceType = "Empty"

                    if "surface" in staticBody and staticBody.surface in targetSurfaces:
                        surfaceType = staticBody.surface

                    if !PMap.has(surfaceType): PMap[surfaceType] = SurfaceTool.new()

                    for i in range(element.mesh.get_surface_count()):
                        PMap[surfaceType].append_from(element.mesh, i, child.transform)


    var output = Node3D.new()
    output.name = self.name + " [M]"
    get_parent().add_child(output, true)
    output.owner = get_tree().edited_scene_root
    get_parent().move_child(output, get_index() + 1)
    if fractional: output.global_position.y = 0.01


    var mergedMesh = ArrayMesh.new()

    var sortedMaterials = materialList.keys()
    sortedMaterials.sort_custom( func(a, b): return str(a) < str(b))

    for material in sortedMaterials:
        materialList[material].commit(mergedMesh)


    var outputMesh = MeshInstance3D.new()
    outputMesh.mesh = mergedMesh
    outputMesh.name = "Mesh"
    output.add_child(outputMesh, true)
    outputMesh.set_owner(get_tree().edited_scene_root)
    if !shadows: outputMesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    if visibility != 0: outputMesh.visibility_range_end = visibility


    var surfaceIndex = 0
    for material in sortedMaterials:
        outputMesh.set_surface_override_material(surfaceIndex, material)
        surfaceIndex += 1


    if !RMap.is_empty() || !PMap.is_empty():

        var colliderParent = Node3D.new()
        colliderParent.name = "Colliders"
        output.add_child(colliderParent, true)
        colliderParent.set_owner(get_tree().edited_scene_root)


        var surfaces = RMap.keys()
        for key in PMap.keys():
            if !key in surfaces: surfaces.append(key)
        surfaces.sort()


        for type in surfaces:

            var targetSurface = "" if type == "Empty" else type


            if RMap.has(type):
                var colliderR = MeshInstance3D.new()
                colliderR.mesh = RMap[type].commit()
                colliderR.name = type + "_Collider_R"
                colliderParent.add_child(colliderR, true)
                colliderR.set_owner(get_tree().edited_scene_root)
                colliderR.set_layer_mask_value(1, false)
                colliderR.create_trimesh_collision()
                colliderR.get_child(0).name = "StaticBody3D"
                colliderR.get_child(0).set_collision_layer_value(1, false)
                colliderR.get_child(0).set_collision_layer_value(5, true)
                colliderR.get_child(0).set_script(Surface)
                colliderR.get_child(0).surface = targetSurface

            if PMap.has(type):
                var colliderP = MeshInstance3D.new()
                colliderP.mesh = PMap[type].commit()
                colliderP.name = type + "_Collider_P"
                colliderParent.add_child(colliderP, true)
                colliderP.set_owner(get_tree().edited_scene_root)
                colliderP.set_layer_mask_value(1, false)
                colliderP.create_trimesh_collision()
                colliderP.get_child(0).name = "StaticBody3D"
                colliderP.get_child(0).set_collision_layer_value(1, false)
                colliderP.get_child(0).set_collision_layer_value(6, true)
                colliderP.get_child(0).set_script(Surface)
                colliderP.get_child(0).surface = targetSurface


    self.visible = false
    self.process_mode = Node.PROCESS_MODE_DISABLED


    merge = false
    FoldHierarchy(output)



func FoldHierarchy(node: Node) -> void :
    node.set_display_folded(true)
    for child in node.get_children():
        FoldHierarchy(child)
