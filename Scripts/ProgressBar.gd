extends ProgressBar


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@onready var timer = $Timer

var recipe: RecipeData
var progressTime = 0
var progressTimer = 0
signal completed

func Start(craftRecipe: RecipeData):

    recipe = craftRecipe

    value = 0

    timer.wait_time = recipe.time
    timer.start()

    PlayCrafting()

func _physics_process(_delta):
    var percentage = ((1 - timer.time_left / recipe.time) * 100)
    value = percentage

func _on_timer_timeout() -> void :
    PlayAttach()
    emit_signal("completed")

func PlayCrafting():
    var crafting = audioInstance2D.instantiate()
    add_child(crafting)
    crafting.PlayInstance(recipe.audio)

func PlayAttach():
    var attach = audioInstance2D.instantiate()
    get_tree().get_root().add_child(attach)
    attach.PlayInstance(audioLibrary.UIAttach)
