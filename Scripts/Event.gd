extends PanelContainer


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

var eventData: EventData
var interface

@onready var highlight = $Highlight
@onready var day = $Margin / Elements / Header / Day
@onready var title = $Margin / Elements / Header / Title
@onready var status = $Margin / Elements / Header / Status
@onready var content = $Margin / Elements / Content
@onready var type = $Margin / Elements / Content / Type
@onready var description = $Margin / Elements / Content / Description
@onready var location = $Margin / Elements / Content / Location
@onready var possibility = $Margin / Elements / Content / Possibility
@onready var showButton: Button = $Margin / Elements / Header / Show

var defaultColor = Color8(0, 0, 0, 0)
var activeColor = Color8(0, 255, 0, 32)



func Initialize(event: EventData, targetInterface):

    Collapse()


    eventData = event


    day.text = "Day " + str(eventData.day)
    title.text = eventData.name
    type.text = eventData.type + " Event"
    description.text = eventData.description


    if event.map == "" && event.zone == "":
        location.get_child(0).text = "All maps & zones"
    elif event.map != "":
        location.get_child(0).text = event.map
    elif event.zone != "":
        location.get_child(0).text = event.zone


    if event.possibility == 0:
        possibility.get_child(0).text = "Guaranteed"
    else:
        possibility.get_child(0).text = "~" + str(eventData.possibility) + "%" + " / " + "map instance"


    if Simulation.day >= eventData.day:
        Active()
        status.text = "Activated"
        status.modulate = Color.GREEN
    else:
        Default()
        var daysLeft = eventData.day - Simulation.day
        status.text = "In " + str(daysLeft) + " Days"
        status.modulate = Color(1.0, 1.0, 1.0, 0.5)


    interface = targetInterface



func _on_show_toggled(toggled_on: bool) -> void :
    if toggled_on:
        Expand()
        PlayClick()
    else:
        Collapse()
        PlayClick()

func Collapse():

    content.hide()
    showButton.text = "Show"

func Expand():

    content.show()
    showButton.text = "Hide"



func Default():
    highlight.color = defaultColor
    status.modulate = defaultColor
    status.text = "Not active"

func Active():
    highlight.color = activeColor
    status.modulate = Color.GREEN
    status.text = "Active"



func PlayClick():
    var click = audioInstance2D.instantiate()
    add_child(click)
    click.PlayInstance(audioLibrary.UIClick)
