extends Node3D

@export var light: Light3D
@export var mesh: MeshInstance3D
@export var defaultMaterial: Material
@export var litMaterial: Material

func Activate():
    if light && mesh && litMaterial:
        light.show()
        mesh.set_surface_override_material(0, litMaterial)

func Deactivate():
    if light && mesh && defaultMaterial:
        light.hide()
        mesh.set_surface_override_material(0, defaultMaterial)
