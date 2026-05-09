extends AudioStreamPlayer

func PlayInstance(audioEvent: AudioEvent):

    if audioEvent.audioClips.is_empty(): return


    stream = audioEvent.audioClips.pick_random()


    if audioEvent.randomPitch:
        volume_db = randf_range(audioEvent.volume - 1.0, audioEvent.volume)
        pitch_scale = randf_range(0.9, 1.0)
    else:
        volume_db = audioEvent.volume


    play()

func _process(_delta) -> void :
    if !is_playing():
        queue_free()
