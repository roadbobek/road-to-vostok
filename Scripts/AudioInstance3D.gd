extends AudioStreamPlayer3D

func PlayInstance(audioEvent: AudioEvent, unitSize: float, maxDistance: float):

    if audioEvent.audioClips.is_empty(): return


    stream = audioEvent.audioClips.pick_random()
    unit_size = unitSize
    max_distance = maxDistance


    if audioEvent.randomPitch:
        volume_db = randf_range(audioEvent.volume - 1.0, audioEvent.volume)
        pitch_scale = randf_range(0.9, 1.0)
    else:
        volume_db = audioEvent.volume


    play()

func _process(_delta) -> void :
    if !is_playing():
        queue_free()
