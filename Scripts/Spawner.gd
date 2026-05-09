@tool
extends Node3D

@export var surface: Mesh
@export var data: SpawnerData
@export var generate: bool = false: set = ExecuteGenerate
@export var clear: bool = false: set = ExecuteClear
@export_group("Utility")
@export var finalize: bool = false: set = ExecuteFinalizeTrees
@export var recover: bool = false: set = ExecuteTreeRecovery
@export var reduce: bool = false: set = ExecuteTreeReduction



func _ready() -> void :

    if !Engine.is_editor_hint():
        var sceneData = data as SpawnerSceneData
        if sceneData && sceneData.runtime:
            ExecuteGenerate(true)



func ExecuteGenerate(_value: bool) -> void :

    ExecuteClear(true)


    if !surface:
        print("Surface not assigned!")
        return
    if !data:
        print("Data not assigned!")
        return


    var chunkData: = data as SpawnerChunkData
    var sceneData: = data as SpawnerSceneData


    if chunkData && !chunkData.mesh:
        print("Chunk mesh not assigned!")
        return
    if sceneData && sceneData.scenes.size() == 0:
        print("Scenes not assigned!")
        return


    var blockers: Array[Rect2] = []
    GetBlockerMasks("Blocker", blockers)


    var MDT = MeshDataTool.new()
    MDT.create_from_surface(surface, 0)
    var faces = MDT.get_face_count()


    var chunksData = {}
    var spaceState = get_world_3d().direct_space_state if ( !chunkData || data.perimeterType > 0) else null


    var candidates: Array = []


    for i in range(faces):

        var v0 = MDT.get_vertex(MDT.get_face_vertex(i, 0))
        var v1 = MDT.get_vertex(MDT.get_face_vertex(i, 1))
        var v2 = MDT.get_vertex(MDT.get_face_vertex(i, 2))


        if abs(v0.x) > data.area / 2.0 || abs(v0.z) > data.area / 2.0: continue


        var isFar = abs(v0.x) > 200.0 || abs(v0.z) > 200.0
        var activeDensity = data.farDensity if isFar else data.density


        var faceCount = 0
        if activeDensity >= 1.0: faceCount = int(activeDensity)
        elif randf() < activeDensity: faceCount = 1
        if faceCount <= 0: continue


        for d in range(faceCount):
            var facePosition = RandomBarycentric(v0, v1, v2)
            var faceNormal = MDT.get_face_normal(i)
            candidates.append({"pos": facePosition, "normal": faceNormal})


    candidates.shuffle()


    var accepted: Array = PoisonFilter(candidates, data.minDistance)


    candidates.clear()


    for candidate in accepted:

        var facePosition: Vector3 = candidate.pos
        var faceNormal: Vector3 = candidate.normal
        var spawnPosition2D = Vector2(facePosition.x, facePosition.z)


        var blocked = false
        for rect in blockers:
            if rect.has_point(spawnPosition2D):
                blocked = true
                break
        if blocked: continue


        var surfaceTransform = GetSurfaceTransform(facePosition, faceNormal)



        if chunkData:

            if data.perimeterType > 0 && data.perimeter > 0 && spaceState:

                var rayStart = surfaceTransform.origin + Vector3.UP * 100.0
                var rayEnd = surfaceTransform.origin + Vector3.DOWN * 100.0
                var rayMask = 4294967295 ^ (1 << 28)
                var query = PhysicsRayQueryParameters3D.create(rayStart, rayEnd, rayMask)
                var hit = spaceState.intersect_ray(query)


                if hit:

                    if abs(hit.position.y - surfaceTransform.origin.y) <= 0.1:

                        if PerimeterCheck(hit, spaceState):
                            ProcessMultimeshData(facePosition, surfaceTransform, chunksData, chunkData.size)


            else:
                ProcessMultimeshData(facePosition, surfaceTransform, chunksData, chunkData.size)





        elif sceneData:

            if spaceState:

                var rayStart = surfaceTransform.origin + Vector3.UP * 100.0
                var rayEnd = surfaceTransform.origin + Vector3.DOWN * 100.0
                var rayMask = 4294967295 ^ (1 << 28)
                if sceneData.border: rayMask &= ~ (1 << 30)
                var query = PhysicsRayQueryParameters3D.create(rayStart, rayEnd, rayMask)
                var hit = spaceState.intersect_ray(query)


                if hit:

                    if abs(hit.position.y - surfaceTransform.origin.y) <= 0.1:

                        surfaceTransform.origin = hit.position

                        if data.normals: surfaceTransform = RealignToNormal(surfaceTransform, hit.normal)

                        if PerimeterCheck(hit, spaceState):
                            SpawnScene(surfaceTransform, sceneData)

            else:
                SpawnScene(surfaceTransform, sceneData)



    if chunkData:

        var allTransforms: Array = []


        for key in chunksData.keys():
            CreateChunkNode(key, chunksData[key], chunkData)

            allTransforms.append_array(chunksData[key].transforms)


        if chunkData.collider:

            CreateCollider(self, allTransforms, chunkData.mesh, "Collider_R", 5, chunkData.surface)

            CreateCollider(self, allTransforms, chunkData.collider, "Collider_P", 6, chunkData.surface)





    if Engine.is_editor_hint():
        FoldHierarchy(self)

func ExecuteClear(_value: bool) -> void :

    if !is_inside_tree(): return
    for child in get_children():
        child.free()

func ExecuteFinalizeTrees(_value: bool) -> void :

    if !is_inside_tree(): return
    var sceneData: = data as SpawnerSceneData
    if !sceneData || sceneData.scenes.size() == 0:
        print("Finalize only available for scene-based tree spawners!")
        return


    var treeInstances: Array = []
    for child in get_children():
        if child.scene_file_path != "":
            treeInstances.append(child)
    treeInstances.sort_custom( func(a, b): return a.name < b.name)


    for child in get_children():
        if child.scene_file_path == "" && (child.name == "Shadow" || child.name == "Collider" || child.name == "Obstruction" || child.name.begins_with("Tree")):
            child.free()


    var firstChild = treeInstances[0] if treeInstances.size() > 0 else null
    var initialMesh = firstChild.get_node_or_null("Mesh") if firstChild else null
    var initialBillboard = firstChild.get_node_or_null("Billboard") if firstChild else null
    var initialShadow = firstChild.get_node_or_null("Shadow") if firstChild else null
    var branchMaterial = initialMesh.get_surface_override_material(0) if initialMesh else null
    var trunkMaterial = initialMesh.get_surface_override_material(1) if initialMesh else null
    var billboardMaterial = initialBillboard.get_surface_override_material(0) if initialBillboard else null
    var shadowMaterial = initialShadow.get_surface_override_material(0) if initialShadow else null


    var shadowTransforms: Array = []
    var shadowMeshes: Array = []
    var colliderTransforms: Array = []
    var colliderMeshes: Array = []
    var obstructionTransforms: Array = []
    var obstructionMeshes: Array = []


    var treeCount: int = 0
    for instance in treeInstances:
        var meshNode = instance.get_node_or_null("Mesh")
        var billboardNode = instance.get_node_or_null("Billboard")
        var shadowNode = instance.get_node_or_null("Shadow")
        var colliderNode = instance.get_node_or_null("Collider")
        var obstructionNode = instance.get_node_or_null("Obstruction")


        if shadowNode && shadowNode is MeshInstance3D && shadowNode.mesh:
            shadowTransforms.append(shadowNode.global_transform)
            shadowMeshes.append(shadowNode.mesh)


        if colliderNode && colliderNode is MeshInstance3D && colliderNode.mesh:
            colliderTransforms.append(colliderNode.global_transform)
            colliderMeshes.append(colliderNode.mesh)


        if obstructionNode && obstructionNode is MeshInstance3D && obstructionNode.mesh:
            obstructionTransforms.append(obstructionNode.global_transform)
            obstructionMeshes.append(obstructionNode.mesh)


        if meshNode && meshNode is MeshInstance3D:
            var treeMesh = MeshInstance3D.new()
            treeMesh.name = "Tree" if treeCount == 0 else "Tree_%02d" % treeCount
            treeCount += 1
            treeMesh.mesh = meshNode.mesh
            treeMesh.global_transform = meshNode.global_transform
            if branchMaterial: treeMesh.set_surface_override_material(0, branchMaterial)
            if trunkMaterial: treeMesh.set_surface_override_material(1, trunkMaterial)
            treeMesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
            treeMesh.visibility_range_end = meshNode.visibility_range_end
            add_child(treeMesh, true)
            treeMesh.owner = get_tree().edited_scene_root


            if billboardNode && billboardNode is MeshInstance3D:
                var billboard = MeshInstance3D.new()
                billboard.name = "Billboard"
                billboard.mesh = billboardNode.mesh
                billboard.transform = Transform3D.IDENTITY
                billboard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
                billboard.visibility_range_begin = billboardNode.visibility_range_begin
                if billboardMaterial: billboard.set_surface_override_material(0, billboardMaterial)
                treeMesh.add_child(billboard, true)
                billboard.owner = get_tree().edited_scene_root


        instance.free()


    if shadowMaterial && shadowTransforms.size() > 0:
        CreateMergedMeshMixed(self, shadowTransforms, shadowMeshes, shadowMaterial, "Shadow")


    if colliderTransforms.size() > 0:
        CreateMergedColliderMixed(self, colliderTransforms, colliderMeshes, "Collider", 1, "Wood")


    if obstructionTransforms.size() > 0:
        CreateMergedColliderMixed(self, obstructionTransforms, obstructionMeshes, "Obstruction", 11, "")


    if Engine.is_editor_hint():
        FoldHierarchy(self)

func ExecuteTreeRecovery(_value: bool) -> void :

    if !is_inside_tree(): return
    var sceneData: = data as SpawnerSceneData
    if !sceneData || sceneData.scenes.size() == 0:
        print("Recovery only available for scene-based tree spawners!")
        return


    var letters = ["_A_", "_B_", "_C_", "_D_"]


    var recoveryMap: Dictionary = {}

    for child in get_children():

        if child.name == "Shadow" || child.name == "Collider" || child.name == "Obstruction": continue
        if !(child is MeshInstance3D): continue
        if !child.mesh: continue


        var meshName: String = child.mesh.resource_path
        var matchedIndex: int = -1
        for i in range(letters.size()):
            if i < sceneData.scenes.size() && meshName.contains(letters[i]):
                matchedIndex = i
                break
        if matchedIndex == -1: continue


        if !recoveryMap.has(matchedIndex):
            recoveryMap[matchedIndex] = []
        recoveryMap[matchedIndex].append(child.global_transform)

    if recoveryMap.is_empty():
        print("Recovery: no recognized tree meshes found!")
        return


    for child in get_children():
        child.free()


    for sceneIndex in recoveryMap.keys():
        var packedScene: PackedScene = sceneData.scenes[sceneIndex]
        for t in recoveryMap[sceneIndex]:
            var instance = packedScene.instantiate()
            add_child(instance, true)
            instance.owner = get_tree().edited_scene_root
            instance.global_transform = t


    if Engine.is_editor_hint():
        FoldHierarchy(self)

func ExecuteTreeReduction(_value: bool) -> void :

    if !is_inside_tree(): return
    var children = get_children()
    for i in range(children.size()):
        if i % 5 == 4:
            children[i].free()



func SpawnScene(surfaceTransform: Transform3D, sceneData: SpawnerSceneData) -> void :

    var randomScene = sceneData.scenes[randi() % sceneData.scenes.size()]

    var instance = randomScene.instantiate()
    add_child(instance, true)
    instance.owner = get_tree().edited_scene_root
    instance.global_transform = surfaceTransform

    instance.global_position.y += sceneData.yOffset

func CreateChunkNode(key: String, chunkDict: Dictionary, chunkData: SpawnerChunkData) -> void :

    var coords = key.split("_")
    var centerX = (float(coords[0]) * chunkData.size) + (chunkData.size * 0.5)
    var centerZ = (float(coords[1]) * chunkData.size) + (chunkData.size * 0.5)


    var totalY = 0.0
    for surfaceTransform in chunkDict.transforms:
        totalY += surfaceTransform.origin.y
    var averageY = totalY / chunkDict.transforms.size()


    var chunkOrigin = Vector3(centerX, averageY, centerZ)


    var multimesh = BuildMultimesh(chunkDict.transforms, chunkData.mesh, chunkOrigin, chunkData.material)
    multimesh.name = "Chunk"
    multimesh.layers = 1 << (chunkData.layer - 1)
    add_child(multimesh, true)
    multimesh.owner = get_tree().edited_scene_root
    multimesh.global_position = chunkOrigin


    if !chunkData.LOD:
        multimesh.visibility_range_end = chunkData.renderEnd


    else:
        multimesh.visibility_range_end = chunkData.renderLOD

        var LODMesh = BuildMultimesh(chunkDict.transforms, chunkData.LOD, chunkOrigin, chunkData.material)
        LODMesh.name = "LOD"
        LODMesh.layers = 1 << (chunkData.layer - 1)
        LODMesh.visibility_range_begin = chunkData.renderLOD - 1.0
        LODMesh.visibility_range_end = chunkData.renderEnd
        multimesh.add_child(LODMesh, true)
        LODMesh.owner = get_tree().edited_scene_root

func BuildMultimesh(transforms: Array, meshResource: Mesh, origin: Vector3, material: Material) -> MultiMeshInstance3D:

    var multimesh = MultiMeshInstance3D.new()
    var mm = MultiMesh.new()
    mm.transform_format = MultiMesh.TRANSFORM_3D
    mm.mesh = meshResource
    mm.instance_count = transforms.size()


    for i in range(transforms.size()):
        var localTransform = transforms[i]
        localTransform.origin -= origin
        mm.set_instance_transform(i, localTransform)


    multimesh.multimesh = mm
    if material: multimesh.material_override = material


    return multimesh

func CreateCollider(parent: Node3D, transforms: Array, meshResource: Mesh, colliderName: String, layer: int, surfaceName: String) -> void :

    var ST = SurfaceTool.new()
    ST.begin(Mesh.PRIMITIVE_TRIANGLES)


    for surfaceTransform in transforms:
        var localTransform = surfaceTransform
        localTransform.origin -= parent.global_position
        ST.append_from(meshResource, 0, localTransform)


    var outputMesh = ST.commit()


    if outputMesh.get_surface_count() > 0:

        var staticBody = StaticBody3D.new()
        staticBody.name = colliderName
        staticBody.collision_layer = 1 << (layer - 1)
        staticBody.collision_mask = 1
        parent.add_child(staticBody, true)
        staticBody.owner = get_tree().edited_scene_root
        staticBody.set_script(Surface)
        staticBody.surface = surfaceName


        var collisionShape = CollisionShape3D.new()
        collisionShape.shape = outputMesh.create_trimesh_shape()
        staticBody.add_child(collisionShape, true)
        collisionShape.owner = get_tree().edited_scene_root

func CreateMergedMeshMixed(parent: Node3D, transforms: Array, meshResources: Array, material: Material, meshName: String) -> void :

    var ST = SurfaceTool.new()
    ST.begin(Mesh.PRIMITIVE_TRIANGLES)


    for i in range(transforms.size()):
        ST.append_from(meshResources[i], 0, transforms[i])


    var outputMesh = ST.commit()


    if outputMesh.get_surface_count() > 0:
        var meshInstance = MeshInstance3D.new()
        meshInstance.name = meshName
        meshInstance.mesh = outputMesh
        if material: meshInstance.set_surface_override_material(0, material)

        meshInstance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
        parent.add_child(meshInstance, true)
        meshInstance.owner = get_tree().edited_scene_root

func CreateMergedColliderMixed(parent: Node3D, transforms: Array, meshResources: Array, colliderName: String, layer: int, surfaceName: String) -> void :

    var ST = SurfaceTool.new()
    ST.begin(Mesh.PRIMITIVE_TRIANGLES)


    for i in range(transforms.size()):
        var localTransform = transforms[i]
        localTransform.origin -= parent.global_position
        ST.append_from(meshResources[i], 0, localTransform)


    var outputMesh = ST.commit()


    if outputMesh.get_surface_count() > 0:

        var staticBody = StaticBody3D.new()
        staticBody.name = colliderName
        staticBody.collision_layer = 1 << (layer - 1)
        staticBody.collision_mask = 1
        parent.add_child(staticBody, true)
        staticBody.owner = get_tree().edited_scene_root

        if surfaceName != "":
            staticBody.set_script(Surface)
            staticBody.surface = surfaceName


        var collisionShape = CollisionShape3D.new()
        collisionShape.shape = outputMesh.create_trimesh_shape()
        staticBody.add_child(collisionShape, true)
        collisionShape.owner = get_tree().edited_scene_root

func PerimeterCheck(hit: Dictionary, spaceState: PhysicsDirectSpaceState3D) -> bool:

    if data.perimeterType == 0 || data.perimeter <= 0: return true


    var cardinalDirections = [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]
    var diagonalDirs = [Vector3(1, 0, 1).normalized(), Vector3(-1, 0, 1).normalized(), Vector3(1, 0, -1).normalized(), Vector3(-1, 0, -1).normalized()]


    var perimeterRays = []

    if data.perimeterType >= 1: perimeterRays.append([cardinalDirections, float(data.perimeter)])

    if data.perimeterType >= 2: perimeterRays.append([cardinalDirections, data.perimeter * 0.5])

    if data.perimeterType >= 3:
        perimeterRays.append([diagonalDirs, float(data.perimeter)])
        perimeterRays.append([diagonalDirs, data.perimeter * 0.5])


    for raySet in perimeterRays:
        var rayDirections = raySet[0]
        var rayDistances = raySet[1]

        for dir in rayDirections:

            var pOrigin = hit.position + dir * rayDistances
            var pRayStart = pOrigin + Vector3.UP * 100.0
            var pRayEnd = pOrigin + Vector3.DOWN * 100.0
            var pMask = 4294967295 ^ (1 << 28)
            var pQuery = PhysicsRayQueryParameters3D.create(pRayStart, pRayEnd, pMask)
            var pHit = spaceState.intersect_ray(pQuery)

            if !pHit || pHit.collider != hit.collider: return false


    return true

func GetBlockerMasks(groupName: String, blockerList: Array[Rect2]) -> void :

    var nodes = get_tree().get_nodes_in_group(groupName)

    for node in nodes:

        if node is VisualInstance3D:

            var bounds = node.global_transform * node.get_aabb()

            var safeBounds = bounds.grow(1.0)

            blockerList.append(Rect2(safeBounds.position.x, safeBounds.position.z, safeBounds.size.x, safeBounds.size.z))

func PoisonFilter(candidates: Array, minDist: float) -> Array:

    var accepted: Array = []
    var cellSize = minDist / sqrt(2.0)
    var grid = {}


    for candidate in candidates:

        var p: Vector3 = candidate.pos
        var gx = int(floor(p.x / cellSize))
        var gz = int(floor(p.z / cellSize))


        var tooClose = false
        for ox in range(-3, 4):
            for oz in range(-3, 4):
                var key = str(gx + ox) + "_" + str(gz + oz)
                if grid.has(key):
                    var nearby: Vector3 = grid[key]
                    var dx = p.x - nearby.x
                    var dz = p.z - nearby.z

                    if dx * dx + dz * dz < minDist * minDist:
                        tooClose = true
                        break

            if tooClose: break

        if tooClose: continue


        accepted.append(candidate)

        grid[str(gx) + "_" + str(gz)] = p


    grid.clear()


    return accepted

func RandomBarycentric(v0: Vector3, v1: Vector3, v2: Vector3) -> Vector3:

    var R1 = randf(); var R2 = randf(); var SQRT_R1 = sqrt(R1)
    return (v0 * (1.0 - SQRT_R1)) + (v1 * (SQRT_R1 * (1.0 - R2))) + (v2 * (SQRT_R1 * R2))

func GetSurfaceTransform(pos: Vector3, normal: Vector3) -> Transform3D:

    var surfaceTransform = Transform3D()
    var finalBasis = Basis()


    if data.normals:
        var VY = normal
        var VX = Vector3.FORWARD.cross(VY).normalized()
        if VX.length() == 0:
            VX = Vector3.RIGHT.cross(VY).normalized()
        var VZ = VX.cross(VY).normalized()
        finalBasis = Basis(VX, VY, VZ)

    else:
        var tiltX = randf_range(-0.1, 0.1)
        var tiltZ = randf_range(-0.1, 0.1)
        finalBasis = Basis.from_euler(Vector3(tiltX, 0, tiltZ))


    finalBasis = finalBasis.rotated(finalBasis.y, randf_range(0, TAU))
    var randomScale = randf_range(data.minScale, data.maxScale)
    finalBasis = finalBasis.scaled(Vector3(randomScale, randomScale, randomScale))


    surfaceTransform.basis = finalBasis
    surfaceTransform.origin = pos
    return surfaceTransform

func ProcessMultimeshData(pos: Vector3, surfaceTransform: Transform3D, dataMap: Dictionary, chunkSize: float) -> void :

    var key = str(floor(pos.x / chunkSize)) + "_" + str(floor(pos.z / chunkSize))

    if !dataMap.has(key):
        dataMap[key] = {"transforms": []}

    dataMap[key].transforms.append(surfaceTransform)

func RealignToNormal(surfaceTransform: Transform3D, normal: Vector3) -> Transform3D:

    var currentScale = surfaceTransform.basis.get_scale()


    var VY = normal
    var VX = surfaceTransform.basis.z.cross(VY).normalized()
    if VX.length() == 0:
        VX = Vector3.RIGHT.cross(VY).normalized()
    var VZ = VX.cross(VY).normalized()


    surfaceTransform.basis = Basis(VX, VY, VZ).scaled(currentScale)
    return surfaceTransform

func FoldHierarchy(node: Node) -> void :
    for child in node.get_children():
        FoldHierarchy(child)
    if node != self:
        node.set_display_folded(true)
