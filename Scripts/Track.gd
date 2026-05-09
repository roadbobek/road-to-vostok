extends PanelContainer


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

var trackData: TrackData
var interface

@onready var highlight = $Highlight
@onready var background = $Background
@onready var waveform = $Waveform
@onready var title = $Margin / Elements / Header / Title
@onready var length = $Margin / Elements / Header / Length
@onready var playButton = $Margin / Elements / Header / Play

var normalColor = Color(0.0, 0.0, 0.0, 0.0)
var activeColor = Color(0.0, 1.0, 0.0, 0.1)



func Initialize(track: TrackData, targetInterface):

    Default()


    trackData = track


    title.text = trackData.name
    var totalLenght = trackData.audio.get_length()
    var minutes = int(totalLenght / 60)
    var seconds = int(totalLenght) % 60
    length.text = "%d:%02d" % [minutes, seconds]


    interface = targetInterface



func _on_play_toggled(toggled_on: bool) -> void :
    if toggled_on:
        interface.PlayCasette(trackData.audio)
        Active()
        PlayCasettePlay()
    else:
        interface.ResetCasette()
        Default()
        PlayCasetteStop()



func Default():
    waveform.hide()
    highlight.color = normalColor
    playButton.text = "▶"

func Active():
    waveform.show()
    highlight.color = activeColor
    playButton.text = "■"



func PlayClick():
    var click = audioInstance2D.instantiate()
    add_child(click)
    click.PlayInstance(audioLibrary.UIClick)

func PlayCasettePlay():
    var casettePlay = audioInstance2D.instantiate()
    add_child(casettePlay)
    casettePlay.PlayInstance(audioLibrary.UICasettePlay)

func PlayCasetteStop():
    var casetteStop = audioInstance2D.instantiate()
    add_child(casetteStop)
    casetteStop.PlayInstance(audioLibrary.UICasetteStop)
