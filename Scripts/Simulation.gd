extends Node

@export var season = 1
@export var day = 1
@export var simulate = false
@export var time = 1200.0
@export var rate = 0.2777
@export var weather = "Neutral"
@export var weatherTime = 600.0

func _process(delta):
    if simulate:

        time += rate * delta
        weatherTime -= delta


        if simulate && time >= 2400.0:
            time = 0.0
            day += 1
            Loader.UpdateProgression()
            print("Simulation: New Day " + "(" + str(day) + ")")


        if weatherTime <= 0:
            WeatherChange()

func WeatherChange():
    var weatherRoll = randi_range(0, 100)


    if weatherRoll == 0:
        weather = "Aurora"


    elif weatherRoll > 0 && weatherRoll <= 10:
        weather = "Storm"


    elif weatherRoll > 10 && weatherRoll <= 20:
        weather = "Rain"


    elif weatherRoll > 20 && weatherRoll <= 30:
        weather = "Overcast"


    elif weatherRoll > 30 && weatherRoll <= 40:
        weather = "Wind"


    elif weatherRoll > 40 && weatherRoll <= 100:
        weather = "Neutral"


    weatherTime = randf_range(300.0, 1200.0)
    print("Simulation: Weather " + "(" + weather + ")")
