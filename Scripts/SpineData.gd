extends Resource
class_name SpineData

@export_group("Spine")
@export var bone = 12
@export var weight = 1.0

@export_group("Impulse")
@export var impulse = 0.2
@export var recovery = 0.2
@export var impact = 20.0
@export var recoil = 5.0

@export_group("Defend")
@export var pistolDefend = Vector3(20, -10, 0)
@export var rifleDefend = Vector3(20, -10, 0)

@export_group("Combat")
@export var pistolCombatN = Vector3(10, -30, 0)
@export var pistolCombatS = Vector3(10, -30, 0)
@export var rifleCombatN = Vector3(10, -35, 0)
@export var rifleCombatS = Vector3(10, -35, 0)

@export_group("Hunt")
@export var pistolHuntN = Vector3(40, -35, 0)
@export var pistolHuntS = Vector3(10, -25, 0)
@export var rifleHuntN = Vector3(40, -35, 0)
@export var rifleHuntS = Vector3(10, -25, 0)

@export_group("Attack")
@export var pistolAttackN = Vector3(25, -25, 0)
@export var rifleAttackN = Vector3(25, -25, 0)
