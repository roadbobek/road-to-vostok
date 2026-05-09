extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

var placable: Node3D
var furniture: Furniture
var targetPosition = Vector3.ZERO
var targetRotation = Vector3.ZERO
var lerpSpeed = 7.5
var maxDistance = 4.0
var minDistance = 0.5
var distance = 1.0
var angle = 0.0
var rotateMode = false
var orientationMode = 1
var initialWait = false
var waitTime = 0.1

@onready var interactor = $"../Interactor"

func _input(event):
    if gameData.freeze || gameData.isReloading || gameData.isInspecting || !gameData.isPlacing:
        return


    if event is InputEventMouseButton && gameData.decor:
        if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
            gameData.magnet = !gameData.magnet


    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_MIDDLE && event.is_pressed():
            orientationMode += 1
            if orientationMode > 3:
                orientationMode = 1


    if rotateMode:
        if event is InputEventMouseButton:
            if event.button_index == MOUSE_BUTTON_WHEEL_UP:
                angle += 0.1
            if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                angle -= 0.1


    else:
        if event is InputEventMouseButton:
            if event.button_index == MOUSE_BUTTON_WHEEL_UP && - position.z < maxDistance:
                distance += 0.05

            if event.button_index == MOUSE_BUTTON_WHEEL_DOWN && - position.z > minDistance:
                distance -= 0.05


    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed() && gameData.isPlacing:
        rotateMode = !rotateMode


    if Input.is_action_just_pressed(("interact")) && gameData.isPlacing:
        if placable && furniture:
            furniture.Catalog()
            placable = null
            furniture = null
            gameData.isPlacing = false

func _physics_process(delta):
    if gameData.freeze || gameData.isReloading || gameData.isInspecting:
        return

    if Input.is_action_just_pressed(("place")) && gameData.decor:
        if gameData.interaction && interactor.target && interactor.target.is_in_group("Furniture") && !gameData.isPlacing:


            position = - transform.basis.z * 0.0

            var distanceToTarget = global_position.distance_to(interactor.target.owner.global_position)

            distance = distanceToTarget


            angle = 0.0

            placable = interactor.target.owner
            gameData.isPlacing = true


            for child in placable.get_children():
                if child is Furniture:
                    furniture = child

            furniture.StartMove()

        elif gameData.isPlacing && placable && furniture.CanPlace():
            furniture.ResetMove()
            placable = null
            furniture = null
            gameData.isPlacing = false

    if Input.is_action_just_pressed(("place")) && !gameData.decor:

        if gameData.interaction && interactor.target && interactor.target.is_in_group("Item") && !gameData.isPlacing && !initialWait:
            distance = 1.0
            angle = 0.0
            orientationMode = 1

            placable = interactor.target
            placable.body_entered.connect(self.Collided)
            gameData.isPlacing = true



            placable.linear_velocity = Vector3.ZERO
            placable.angular_velocity = Vector3.ZERO


            placable.Freeze()
            initialWait = true
            await get_tree().create_timer(waitTime, false).timeout;
            initialWait = false
            placable.Kinematic()


        elif gameData.isPlacing && placable && !initialWait:
            placable.body_entered.disconnect(self.Collided)
            placable.linear_velocity = Vector3(0, 0.1, 0)
            placable.angular_velocity = Vector3(1, 1, 1)
            placable.Unfreeze()
            placable = null
            gameData.isPlacing = false


    if gameData.isPlacing && placable && !gameData.decor:

        position = ( - transform.basis.z * distance) + ( - transform.basis.y * placable.mesh.get_aabb().get_center().y)


        placable.global_position = lerp(placable.global_position, global_position, delta * 5.0)
        placable.global_rotation.y = lerp_angle(placable.global_rotation.y, global_rotation.y + deg_to_rad(placable.slotData.itemData.orientation) + angle, delta * 5.0)


        if orientationMode == 1:
            placable.global_rotation.x = lerp_angle(placable.global_rotation.x, 0.0, delta * 5.0)
            placable.global_rotation.z = lerp_angle(placable.global_rotation.z, 0.0, delta * 5.0)
        elif orientationMode == 2:
            placable.global_rotation.x = lerp_angle(placable.global_rotation.x, deg_to_rad(-90), delta * 5.0)
            placable.global_rotation.z = lerp_angle(placable.global_rotation.z, 0.0, delta * 5.0)
        elif orientationMode == 3:
            placable.global_rotation.x = lerp_angle(placable.global_rotation.x, 0.0, delta * 5.0)
            placable.global_rotation.z = lerp_angle(placable.global_rotation.z, deg_to_rad(-90), delta * 5.0)


    if gameData.isPlacing && placable && gameData.decor:

        position = ( - transform.basis.z * distance) + ( - transform.basis.y * furniture.mesh.get_aabb().get_center().y)


        var floatingTarget = global_position
        var finalTarget = floatingTarget
        var surfaceOffset = 0.05


        var snapData = furniture.GetSnapData()


        if gameData.magnet && snapData["valid"]:

            var hitPoint = snapData["point"]
            var hitNormal = snapData["normal"]


            if furniture.wallElement:
                var toFloating = floatingTarget - hitPoint
                var distanceFromWall = toFloating.dot(hitNormal)
                finalTarget = (floatingTarget - (hitNormal * distanceFromWall)) + (hitNormal * surfaceOffset)
                var targetRotationRad = atan2(hitNormal.x, hitNormal.z)
                placable.global_rotation.y = lerp_angle(placable.global_rotation.y, targetRotationRad + angle, delta * 10.0)

            else:
                finalTarget = Vector3(floatingTarget.x, hitPoint.y + surfaceOffset, floatingTarget.z)
                placable.global_rotation.y = lerp_angle(placable.global_rotation.y, global_rotation.y + angle, delta * 5.0)


            placable.global_position = lerp(placable.global_position, finalTarget, delta * 20.0)


        else:
            placable.global_rotation.y = lerp_angle(placable.global_rotation.y, global_rotation.y + angle, delta * 5.0)
            placable.global_position = lerp(placable.global_position, floatingTarget, delta * 7.5)

func Collided(body: Node3D):
    if body.is_in_group("Display") && placable.slotData.itemData.type in ["Weapon", "Attachment", "Knife", "Grenade"]:

        var offsetVector = body.global_transform.affine_inverse() * placable.global_position
        var wallOffset = 0.0
        var wallOrientation = 0.0


        if offsetVector.z > 0:
            wallOffset = placable.slotData.itemData.wallOffset
            wallOrientation = placable.slotData.itemData.orientation

        else:
            wallOffset = - placable.slotData.itemData.wallOffset
            wallOrientation = - placable.slotData.itemData.orientation


        placable.global_transform = body.global_transform
        placable.global_position += body.global_transform.basis.x * offsetVector.x
        placable.global_position += body.global_transform.basis.y * offsetVector.y
        placable.global_position += body.global_transform.basis.z * wallOffset

        if orientationMode == 2:
            placable.global_rotation.x = deg_to_rad(-90)
        elif orientationMode == 3:
            placable.global_rotation.z = deg_to_rad(-90)


        var orientation = deg_to_rad(wallOrientation)
        placable.global_rotation.y = body.global_rotation.y + orientation

        placable.body_entered.disconnect(self.Collided)
        placable.Freeze()
        placable = null
        gameData.isPlacing = false
        AttachAudio()
    else:
        placable.body_entered.disconnect(self.Collided)
        placable.Unfreeze()
        placable = null
        gameData.isPlacing = false

func ContextPlace(target: Node3D):

    if gameData.decor:

            distance = 2.0
            angle = 0.0


            position = - transform.basis.z * distance
            target.global_position = global_position


            for child in target.get_children():
                if child is Furniture:
                    furniture = child


            placable = target
            gameData.isPlacing = true
            furniture.StartMove()


    else:
        placable = target
        placable.body_entered.connect(self.Collided)
        gameData.isPlacing = true

        placable.rotation.x = deg_to_rad(0)
        placable.rotation.z = deg_to_rad(0)
        placable.linear_velocity = Vector3.ZERO
        placable.angular_velocity = Vector3.ZERO

        distance = 1.0
        angle = 0.0
        orientationMode = 1

        position = ( - transform.basis.z * distance) + ( - transform.basis.y * placable.mesh.get_aabb().get_center().y)
        placable.global_position = global_position
        placable.global_rotation.y = global_rotation.y + deg_to_rad(placable.slotData.itemData.orientation) + angle


        placable.Freeze()
        initialWait = true
        await get_tree().create_timer(waitTime, false).timeout;
        initialWait = false
        placable.Kinematic()

func AttachAudio():
    var attach = audioInstance2D.instantiate()
    add_child(attach)
    attach.PlayInstance(audioLibrary.UIAttach)
