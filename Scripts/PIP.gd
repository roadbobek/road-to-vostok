extends Camera3D

func _physics_process(_delta):
    if owner.visible:
        global_transform = owner.global_transform * Transform3D(Basis(), Vector3.ZERO).rotated(Vector3.UP, PI)
