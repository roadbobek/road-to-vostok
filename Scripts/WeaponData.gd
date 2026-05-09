extends ItemData
class_name WeaponData

@export_group("Action")
@export var weaponType: String
@export var weaponAction: String


@export_group("Audio (Custom)")
@export var fireSemi: Resource
@export var fireAuto: Resource
@export var fireSuppressed: Resource
@export var charge: Resource
@export var reloadEmpty: Resource
@export var reloadTactical: Resource
@export var magazineAttachEmpty: Resource
@export var magazineAttachTactical: Resource
@export var magazineDetach: Resource
@export var ammoCheck: Resource
@export var tailOutdoor: Resource
@export_subgroup("Manual")
@export var reload: Resource
@export var insertStart: Resource
@export var insertEnd: Resource
@export var insert: Resource
@export_group("Audio (Modular)")
@export var tailIndoor: Resource
@export var tailIndoorSuppressed: Resource
@export var tailOutdoorSuppressed: Resource


@export_group("Caliber")
@export var ammo: ItemData
@export var caliber: String
enum Casing{None, Pistol, Rifle, Shell}
@export var casing = Casing.None


@export_group("Fire")
@export var damage = 0.0
@export var penetration = 0
@export var fireRate = 0.0
@export var magazineSize = 0


@export_group("Recoil")
@export var kick = 0.0
@export var kickPower = 0.0
@export var kickRecovery = 0.0
@export var verticalRecoil = 0.0
@export var horizontalRecoil = 0.0
@export var rotationPower = 0.0
@export var rotationRecovery = 0.0


@export_group("Rig")
@export_subgroup("Slide")
enum SlideDirection{X, Y, Z}
@export var slideDirection = SlideDirection.X
@export var slideMovement = 0.0
@export var slideDefault = 0.0
@export var slideSpeed = 0.0
@export var slideLock = false
@export_subgroup("Selector")
enum SelectorDirection{X, Y, Z}
@export var selectorDirection = SelectorDirection.X
@export var selectorRotation: Vector2
@export_subgroup("Hammer")
enum HammerDirection{X, Y, Z}
@export var hammerDirection = HammerDirection.X
@export var hammerRotation: Vector2
@export var hammerLock = false
@export_subgroup("Sights")
@export var foldSights = false
@export var foldSightsRotation = 0.0
@export_subgroup("Misc")
@export var useMount = false
@export var nativeSuppressor = false


@export_group("Handling")
@export var lowPosition = Vector3.ZERO
@export var lowRotation = Vector3.ZERO
@export var highPosition = Vector3.ZERO
@export var highRotation = Vector3.ZERO
@export var aimPosition = Vector3.ZERO
@export var aimRotation = Vector3.ZERO
@export var cantedPosition = Vector3.ZERO
@export var cantedRotation = Vector3.ZERO
@export var inspectPosition = Vector3.ZERO
@export var inspectRotation = Vector3.ZERO
@export var collisionPosition = Vector3.ZERO
@export var collisionRotation = Vector3.ZERO
