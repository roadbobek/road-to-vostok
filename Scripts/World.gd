@tool
extends Node3D


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var gameData = preload("res://Resources/GameData.tres")

@export_group("Time of Day")
@export var enable = false
@export var audio = false
@export var shelter = false
@export var intro = false
@export var compatibility = false
@export_range(0, 2400, 0.001) var time = 1200.0
@export_range(0, 1.0, 0.1) var tick = 0.0
var tickTimer: float = 0.0

@export_group("Weather")
@export var winter = false
@export var overcast = false
@export var wind = false
@export var rain = false
@export var snow = false
@export var thunder = false
@export var fog = false
@export var aurora = false

@export_group("Gradients")
@export var ambientColor: GradientTexture1D
@export var overcastColor: GradientTexture1D
@export var skyColor: GradientTexture1D
@export var horizonColor: GradientTexture1D
@export var groundColor: GradientTexture1D
@export var sunColor: GradientTexture1D
@export var sunScatter: GradientTexture1D
@export var moonColor: GradientTexture1D
@export var underwaterColor: GradientTexture1D
@export var sunEnergy: CurveTexture
@export var skyReflection: CurveTexture
@export var fogDensity: CurveTexture

@onready var planet = $Planet
@onready var sun = $Planet / Sun
@onready var moon = $Planet / Moon
@onready var sunLight = $Planet / Sun / Light
@onready var moonLight = $Planet / Moon / Light

@onready var dawnAudio = $Audio / Dawn
@onready var dayAudio = $Audio / Day
@onready var duskAudio = $Audio / Dusk
@onready var nightAudio = $Audio / Night
@onready var windLightAudio = $Audio / Wind_Light
@onready var windHeavyAudio = $Audio / Wind_Heavy
@onready var windHowlAudio = $Audio / Wind_Howl
@onready var rainAudio = $Audio / Rain
@onready var thunderAudio = $Audio / Thunder
@onready var strikeAudio = $Audio / Strike


var sunDirection: Vector3
var moonDirection: Vector3


var dawnVolume = 0.0
var dayVolume = 0.0
var duskVolume = 0.0
var nightVolume = 0.0
var windLightVolume = 0.0
var windHeavyVolume = 0.0
var windHowlVolume = 0.0
var rainVolume = 0.0
var thunderVolume = 0.0
var strikeVolume = 0.0


var winterValue = 0.0
var overcastValue = 0.0
var windValue = 0.0
var rainValue = 0.0
var snowValue = 0.0
var fogValue = 0.0
var auroraValue = 0.0


var thunderTimer = 10.0
var thunderStriked = false
var defaultEnergy = 0.0

@export_group("References")
@export var skyMaterial: Material
@export var waterMaterial: Material
@export var underwaterMaterial: Material

@export_group("Settings")
@export_subgroup("Rendering")
@export var RLow: bool = false: set = ExecuteLowRendering
@export var RNative: bool = false: set = ExecuteNativeRendering

@export_subgroup("Lighting")
@export var LLow: bool = false: set = ExecuteLowLighting
@export var LMedium: bool = false: set = ExecuteMediumLighting
@export var LHigh: bool = false: set = ExecuteHighLighting
@export var LUltra: bool = false: set = ExecuteUltraLighting

@export_subgroup("Detail Shadows")
@export var detailsShadowsOn: bool = false: set = ExecuteDetailShadowsOn
@export var detailShadowsOff: bool = false: set = ExecuteDetailShadowsOff

@export_subgroup("Water Reflections")
@export var waterReflectionsOn: bool = false: set = ExecuteWaterReflectionsOn
@export var waterReflectionsOff: bool = false: set = ExecuteWaterReflectionsOff

@export_subgroup("Furniture")
@export var showIndicators: bool = false: set = ExecuteShowIndicators
@export var hideIndicators: bool = false: set = ExecuteHideIndicators

@export_subgroup("Spawns")
@export var showSpawns: bool = false: set = ExecuteShowSpawns
@export var hideSpawns: bool = false: set = ExecuteHideSpawns


@onready var environment = $Environment
@onready var rainVFX = $VFX / Rain
@onready var snowVFX = $VFX / Snow


var blendingSpeed = 20.0
var blendingBoost = 1.0

func _ready() -> void :

    if !Engine.is_editor_hint():
        if intro:
            Static()
            return


    if !Engine.is_editor_hint():
        enable = true
        audio = true


        sunLight.shadow_caster_mask &= ~ (1 << (3 - 1))
        moonLight.shadow_caster_mask &= ~ (1 << (3 - 1))


    if !Engine.is_editor_hint():
        if shelter:
            Static()
            windLightAudio.play()
            windLightAudio.volume_db = linear_to_db(0.2)


    if !Engine.is_editor_hint():
        rainVFX.hide()
        snowVFX.hide()
        rainVFX.emitting = false
        snowVFX.emitting = false


    if !Engine.is_editor_hint():

        if shelter:
            environment.environment.fog_enabled = false
            environment.environment.volumetric_fog_enabled = false

        elif gameData.compatibility:
            environment.environment.fog_enabled = true
            environment.environment.volumetric_fog_enabled = false

        else:
            environment.environment.fog_enabled = false
            environment.environment.volumetric_fog_enabled = true

func _process(delta):

    if intro: return


    if enable:

        if !shelter:
            tickTimer += delta
            if tickTimer > tick:
                Weather(delta)
                Audio(delta)
                TOD()
                tickTimer = 0.0

        else:
            Static()


    if !Engine.is_editor_hint():

        if (gameData.isTransitioning || gameData.isSleeping) && !gameData.isCaching:
            return


        if gameData.isCaching: blendingBoost = 100.0
        else: blendingBoost = 1.0


        time = Simulation.time


        if Simulation.season == 1:
            gameData.season = 1
            winter = false

        elif Simulation.season == 2:
            gameData.season = 2
            winter = true


        if !shelter:



            if Simulation.weather == "Aurora":
                aurora = true
                thunder = false
                fog = false
                rain = false
                snow = false
                overcast = false
                wind = false
                gameData.fog = false



            elif Simulation.weather == "Storm":
                aurora = false
                overcast = true
                wind = true

                if gameData.season == 1:
                    rain = true
                    snow = false
                    thunder = true
                    fog = false
                    gameData.fog = false

                elif gameData.season == 2:
                    rain = false
                    snow = true
                    thunder = false
                    fog = true
                    gameData.fog = true



            elif Simulation.weather == "Rain":
                aurora = false
                thunder = false
                fog = false
                overcast = true
                wind = false
                gameData.fog = false

                if gameData.season == 1:
                    rain = true
                    snow = false
                elif gameData.season == 2:
                    rain = false
                    snow = true



            elif Simulation.weather == "Overcast":
                aurora = false
                thunder = false
                fog = false
                rain = false
                snow = false
                overcast = true
                wind = true
                gameData.fog = false



            elif Simulation.weather == "Fog":
                aurora = false
                thunder = false
                fog = true
                rain = false
                snow = false
                overcast = true
                wind = true
                gameData.fog = true



            elif Simulation.weather == "Wind":
                aurora = false
                thunder = false
                fog = false
                rain = false
                snow = false
                overcast = false
                wind = true
                gameData.fog = false



            elif Simulation.weather == "Neutral":
                aurora = false
                thunder = false
                fog = false
                rain = false
                snow = false
                overcast = false
                wind = false
                gameData.fog = false



            elif Simulation.weather == "Custom":
                aurora = false
                thunder = false
                fog = false
                rain = false
                snow = false
                overcast = false
                wind = false
                gameData.fog = false

func TOD():

    environment.environment.sky.sky_material = skyMaterial


    var hourMapped = remap(time, 0.0, 2400.0, 0.0, 1.0)


    planet.rotation_degrees.x = hourMapped * 360.0
    planet.rotation_degrees.y = 75.0
    planet.rotation_degrees.z = -45.0


    if time > 600 && time < 1800:
        sunLight.light_cull_mask = 1048575
        sunLight.shadow_enabled = true
        moonLight.light_cull_mask = 0
        moonLight.shadow_enabled = false
    else:
        sunLight.light_cull_mask = 0
        sunLight.shadow_enabled = false
        moonLight.light_cull_mask = 1048575
        moonLight.shadow_enabled = true


    skyMaterial.set_shader_parameter("overcast", overcastValue)
    skyMaterial.set_shader_parameter("skyColor", skyColor.gradient.sample(hourMapped))
    skyMaterial.set_shader_parameter("horizonColor", skyColor.gradient.sample(hourMapped) * 0.8)
    skyMaterial.set_shader_parameter("groundColor", skyColor.gradient.sample(hourMapped) * 0.5)
    skyMaterial.set_shader_parameter("reflection", skyReflection.curve.sample(hourMapped))


    environment.environment.volumetric_fog_density = fogDensity.curve.sample(hourMapped) * fogValue / 100.0
    environment.environment.volumetric_fog_emission = skyColor.gradient.sample(hourMapped)
    environment.environment.volumetric_fog_albedo = sunScatter.gradient.sample(hourMapped)


    if Engine.is_editor_hint() && compatibility:
        environment.environment.fog_light_color = skyColor.gradient.sample(hourMapped)
        environment.environment.fog_light_energy = 1.5
        environment.environment.fog_sky_affect = 0.0
        environment.environment.fog_density = fogDensity.curve.sample(hourMapped) * fogValue / 2000.0
        environment.environment.fog_height_density = 0.0


    if !Engine.is_editor_hint():
        if gameData.isSubmerged:
            environment.environment.fog_light_color = underwaterColor.gradient.sample(hourMapped)
            environment.environment.fog_light_energy = 1.5
            environment.environment.fog_sky_affect = 1.0
            environment.environment.fog_density = 0.5
            environment.environment.fog_height_density = 0.5
        else:
            environment.environment.fog_light_color = skyColor.gradient.sample(hourMapped)
            environment.environment.fog_light_energy = 1.5
            environment.environment.fog_sky_affect = 0.0
            environment.environment.fog_density = fogDensity.curve.sample(hourMapped) * fogValue / 2000.0
            environment.environment.fog_height_density = 0.0


    var sunIntensity = remap(overcastValue, 0.0, 1.0, sunEnergy.curve.sample(hourMapped), 0.5)
    var moonIntensity = remap(overcastValue, 0.0, 1.0, 2.0, 0.5)
    sunLight.light_energy = sunIntensity
    moonLight.light_energy = moonIntensity
    sunLight.light_color = sunColor.gradient.sample(hourMapped)
    moonLight.light_color = moonColor.gradient.sample(hourMapped)


    var ambient = lerp(ambientColor.gradient.sample(hourMapped), overcastColor.gradient.sample(hourMapped), overcastValue)
    environment.environment.ambient_light_color = ambient
    environment.environment.ambient_light_sky_contribution = 0.5


    if !Engine.is_editor_hint():
        if time > 500 && time < 700: gameData.TOD = 1
        elif time > 700 && time < 1600: gameData.TOD = 2
        elif time > 1600 && time < 1900: gameData.TOD = 3
        else: gameData.TOD = 4

func Weather(delta):


    if winter: winterValue = move_toward(winterValue, 1.0, delta / (blendingSpeed / blendingBoost))
    else: winterValue = move_toward(winterValue, 0.0, delta / (blendingSpeed / blendingBoost))

    RenderingServer.global_shader_parameter_set("Snow", winterValue)



    if overcast: overcastValue = move_toward(overcastValue, 1.0, delta / (blendingSpeed / blendingBoost))
    else: overcastValue = move_toward(overcastValue, 0.0, delta / (blendingSpeed / blendingBoost))



    if wind: windValue = move_toward(windValue, 1.0, delta / (blendingSpeed / blendingBoost))
    else: windValue = move_toward(windValue, 0.2, delta / (blendingSpeed / blendingBoost))

    RenderingServer.global_shader_parameter_set("Wind", windValue)



    if fog: fogValue = move_toward(fogValue, 4.0, delta / (blendingSpeed / blendingBoost))
    else: fogValue = move_toward(fogValue, 1.0, delta / (blendingSpeed / blendingBoost))



    if rain && overcastValue > 0.5: rainValue = move_toward(rainValue, 1.0, delta / (blendingSpeed / blendingBoost))
    else: rainValue = move_toward(rainValue, 0.0, delta / (blendingSpeed / blendingBoost))

    RenderingServer.global_shader_parameter_set("Rain", rainValue)
    rainVFX.draw_pass_1.material.albedo_color.a = rainValue
    rainVFX.speed_scale = 1.0 + (windValue / 2.0)

    if !Engine.is_editor_hint():
        if gameData.isSubmerged:
            rainVFX.hide()
            return

    if rainValue > 0.1 && !rainVFX.emitting:
        rainVFX.show()
        rainVFX.amount_ratio = 1.0
        rainVFX.emitting = true
    elif rainValue < 0.1 && rainVFX.emitting:
        rainVFX.hide()
        rainVFX.amount_ratio = 0.0
        rainVFX.emitting = false



    if snow: snowValue = move_toward(snowValue, 1.0, delta / (blendingSpeed / blendingBoost))
    else: snowValue = move_toward(snowValue, 0.0, delta / (blendingSpeed / blendingBoost))

    snowVFX.draw_pass_1.material.albedo_color.a = snowValue
    snowVFX.speed_scale = 1.0 + (windValue / 2.0)

    if !Engine.is_editor_hint():
        if gameData.isSubmerged:
            snowVFX.hide()
            return

    if snowValue > 0.1 && !snowVFX.emitting:
        snowVFX.show()
        snowVFX.amount_ratio = 1.0
        snowVFX.emitting = true
    elif snowValue < 0.1 && snowVFX.emitting:
        snowVFX.hide()
        snowVFX.amount_ratio = 0.0
        snowVFX.emitting = false



    if thunder && overcastValue > 0.5:
        thunderTimer -= delta

        if thunderTimer <= 0.0:
            strikeAudio.play()
            defaultEnergy = environment.environment.background_energy_multiplier


            if !gameData.indoor:
                var flashRoll = randi_range(0, 1)
                if flashRoll == 1:
                    environment.environment.background_energy_multiplier = defaultEnergy + 0.4

            thunderTimer = randf_range(1, 30)
            thunderStriked = true

        if thunderStriked:
            await get_tree().create_timer(0.1, false).timeout;
            environment.environment.background_energy_multiplier = defaultEnergy
            thunderStriked = false



    if aurora: auroraValue = move_toward(auroraValue, 1.0, delta / blendingSpeed)
    else: auroraValue = move_toward(auroraValue, 0.0, delta / blendingSpeed)

    skyMaterial.set_shader_parameter("auroraIntensity", auroraValue)

func Audio(delta):


    if !audio:
        dawnAudio.stop()
        dayAudio.stop()
        duskAudio.stop()
        nightAudio.stop()
        rainAudio.stop()
        windLightAudio.stop()
        windHeavyAudio.stop()
        windHowlAudio.stop()
        thunderAudio.stop()
        strikeAudio.stop()
        dawnVolume = 0.0
        dayVolume = 0.0
        duskVolume = 0.0
        nightVolume = 0.0
        windLightVolume = 0.0
        windHeavyVolume = 0.0
        windHowlVolume = 0.0
        rainVolume = 0.0
        thunderVolume = 0.0
        strikeVolume = 0.0
        return




    if time > 600 && time < 1000 && !winter && !overcast && !wind:
        dawnVolume = move_toward(dawnVolume, 0.5, delta / (blendingSpeed / blendingBoost))
        dayVolume = move_toward(dayVolume, 0.01, delta / (blendingSpeed / blendingBoost))
        duskVolume = move_toward(duskVolume, 0.01, delta / (blendingSpeed / blendingBoost))
        nightVolume = move_toward(nightVolume, 0.01, delta / (blendingSpeed / blendingBoost))

    elif time > 1000 && time < 1500 && !winter && !overcast && !wind:
        dawnVolume = move_toward(dawnVolume, 0.01, delta / (blendingSpeed / blendingBoost))
        dayVolume = move_toward(dayVolume, 1.0, delta / (blendingSpeed / blendingBoost))
        duskVolume = move_toward(duskVolume, 0.01, delta / (blendingSpeed / blendingBoost))
        nightVolume = move_toward(nightVolume, 0.01, delta / (blendingSpeed / blendingBoost))

    elif time > 1500 && time < 1800 && !winter && !overcast && !wind:
        dawnVolume = move_toward(dawnVolume, 0.01, delta / (blendingSpeed / blendingBoost))
        dayVolume = move_toward(dayVolume, 0.01, delta / (blendingSpeed / blendingBoost))
        duskVolume = move_toward(duskVolume, 1.0, delta / (blendingSpeed / blendingBoost))
        nightVolume = move_toward(nightVolume, 0.01, delta / (blendingSpeed / blendingBoost))

    elif (time > 0 && time < 600) || (time > 1800) && !winter && !overcast && !wind:
        dawnVolume = move_toward(dawnVolume, 0.01, delta / (blendingSpeed / blendingBoost))
        dayVolume = move_toward(dayVolume, 0.01, delta / (blendingSpeed / blendingBoost))
        duskVolume = move_toward(duskVolume, 0.01, delta / (blendingSpeed / blendingBoost))
        nightVolume = move_toward(nightVolume, 1.0, delta / (blendingSpeed / blendingBoost))

    else:
        dawnVolume = move_toward(dawnVolume, 0.01, delta / (blendingSpeed / blendingBoost))
        dayVolume = move_toward(dayVolume, 0.01, delta / (blendingSpeed / blendingBoost))
        duskVolume = move_toward(duskVolume, 0.01, delta / (blendingSpeed / blendingBoost))
        nightVolume = move_toward(nightVolume, 0.01, delta / (blendingSpeed / blendingBoost))


    if winter || (overcast && !wind): windLightVolume = move_toward(windLightVolume, 0.4, delta / (blendingSpeed / blendingBoost))
    else: windLightVolume = move_toward(windLightVolume, 0.01, delta / (blendingSpeed / blendingBoost))


    if wind: windHeavyVolume = move_toward(windHeavyVolume, 0.4, delta / (blendingSpeed / blendingBoost))
    else: windHeavyVolume = move_toward(windHeavyVolume, 0.01, delta / (blendingSpeed / blendingBoost))


    if rain && overcastValue > 0.5: rainVolume = move_toward(rainVolume, 1.0, delta / (blendingSpeed / blendingBoost))
    else: rainVolume = move_toward(rainVolume, 0.01, delta / (blendingSpeed / blendingBoost))


    if thunder && overcastValue > 0.5: thunderVolume = move_toward(thunderVolume, 1.0, delta / (blendingSpeed / blendingBoost))
    else: thunderVolume = move_toward(thunderVolume, 0.01, delta / (blendingSpeed / blendingBoost))



    if dawnAudio.playing && dawnVolume == 0.01: dawnAudio.stop()
    elif !dawnAudio.playing && dawnVolume > 0.01: dawnAudio.play()

    if dayAudio.playing && dayVolume == 0.01: dayAudio.stop()
    elif !dayAudio.playing && dayVolume > 0.01: dayAudio.play()

    if duskAudio.playing && duskVolume == 0.01: duskAudio.stop()
    elif !duskAudio.playing && duskVolume > 0.01: duskAudio.play()

    if nightAudio.playing && nightVolume == 0.01: nightAudio.stop()
    elif !nightAudio.playing && nightVolume > 0.01: nightAudio.play()

    if rainAudio.playing && rainVolume == 0.01: rainAudio.stop()
    elif !rainAudio.playing && rainVolume > 0.01: rainAudio.play()

    if windLightAudio.playing && windLightVolume == 0.01: windLightAudio.stop()
    elif !windLightAudio.playing && windLightVolume > 0.01: windLightAudio.play()

    if windHeavyAudio.playing && windHeavyVolume == 0.01: windHeavyAudio.stop()
    elif !windHeavyAudio.playing && windHeavyVolume > 0.01: windHeavyAudio.play()

    if windHowlAudio.playing && windHowlVolume == 0.01: windHowlAudio.stop()
    elif !windHowlAudio.playing && windHowlVolume > 0.01: windHowlAudio.play()

    if thunderAudio.playing && thunderVolume == 0.01: thunderAudio.stop()
    elif !thunderAudio.playing && thunderVolume > 0.01: thunderAudio.play()



    dawnAudio.volume_db = linear_to_db(dawnVolume)
    dayAudio.volume_db = linear_to_db(dayVolume)
    duskAudio.volume_db = linear_to_db(duskVolume)
    nightAudio.volume_db = linear_to_db(nightVolume)
    rainAudio.volume_db = linear_to_db(rainVolume)
    windLightAudio.volume_db = linear_to_db(windLightVolume)
    windHeavyAudio.volume_db = linear_to_db(windHeavyVolume)
    windHowlAudio.volume_db = linear_to_db(windHowlVolume)
    thunderAudio.volume_db = linear_to_db(thunderVolume)
    strikeAudio.volume_db = linear_to_db(thunderVolume)

func Static():

    environment.environment.sky.sky_material = skyMaterial


    skyMaterial.set_shader_parameter("overcast", 1.0)
    skyMaterial.set_shader_parameter("skyColor", Color.WHITE)
    skyMaterial.set_shader_parameter("horizonColor", Color.DIM_GRAY)
    skyMaterial.set_shader_parameter("groundColor", Color.DIM_GRAY)
    skyMaterial.set_shader_parameter("reflection", 1.0)


    environment.environment.ambient_light_color = Color.BLACK
    environment.environment.ambient_light_sky_contribution = 0.5


    sunLight.light_cull_mask = 0
    sunLight.shadow_enabled = false
    moonLight.light_cull_mask = 0
    moonLight.shadow_enabled = false


    aurora = false
    thunder = false
    fog = false
    rain = false
    snow = false
    overcast = false
    wind = false


    RenderingServer.global_shader_parameter_set("Snow", 0.0)
    RenderingServer.global_shader_parameter_set("Rain", 0.0)
    RenderingServer.global_shader_parameter_set("Wind", 0.0)



func ExecuteLowRendering(_value: bool) -> void :
    var currentRID = get_tree().get_root().get_viewport_rid()
    RenderingServer.viewport_set_scaling_3d_scale(currentRID, 0.9)
    RLow = false

func ExecuteNativeRendering(_value: bool) -> void :
    var currentRID = get_tree().get_root().get_viewport_rid()
    RenderingServer.viewport_set_scaling_3d_scale(currentRID, 1.0)
    RNative = false

func ExecuteLowLighting(_value: bool) -> void :
    RenderingServer.directional_shadow_atlas_set_size(2048, true)
    sunLight.directional_shadow_mode = 1
    moonLight.directional_shadow_mode = 1
    sunLight.directional_shadow_max_distance = 100
    moonLight.directional_shadow_max_distance = 100
    LLow = false

func ExecuteMediumLighting(_value: bool) -> void :
    RenderingServer.directional_shadow_atlas_set_size(2048, true)
    sunLight.directional_shadow_mode = 1
    moonLight.directional_shadow_mode = 1
    sunLight.directional_shadow_max_distance = 200
    moonLight.directional_shadow_max_distance = 200
    LMedium = false

func ExecuteHighLighting(_value: bool) -> void :
    RenderingServer.directional_shadow_atlas_set_size(4096, true)
    sunLight.directional_shadow_mode = 1
    moonLight.directional_shadow_mode = 1
    sunLight.directional_shadow_max_distance = 200
    moonLight.directional_shadow_max_distance = 200
    LHigh = false

func ExecuteUltraLighting(_value: bool) -> void :
    RenderingServer.directional_shadow_atlas_set_size(4096, true)
    sunLight.directional_shadow_mode = 2
    moonLight.directional_shadow_mode = 2
    sunLight.directional_shadow_max_distance = 200
    moonLight.directional_shadow_max_distance = 200
    LUltra = false

func ExecuteDetailShadowsOn(_value: bool) -> void :

    sunLight.shadow_caster_mask |= (1 << (4 - 1))
    moonLight.shadow_caster_mask |= (1 << (4 - 1))
    detailsShadowsOn = false

func ExecuteDetailShadowsOff(_value: bool) -> void :

    sunLight.shadow_caster_mask &= ~ (1 << (4 - 1))
    moonLight.shadow_caster_mask &= ~ (1 << (4 - 1))
    detailShadowsOff = false

func ExecuteWaterReflectionsOn(_value: bool) -> void :
    waterMaterial.set_shader_parameter("SSREnabled", true)
    waterReflectionsOn = false

func ExecuteWaterReflectionsOff(_value: bool) -> void :
    waterMaterial.set_shader_parameter("SSREnabled", false)
    waterReflectionsOff = false

func ExecuteHideIndicators(_value: bool) -> void :

    var furnitures = get_tree().get_nodes_in_group("Furniture")


    for furniture in furnitures:


        for child in furniture.owner.get_children():
            if child is Furniture:
                child.indicator.hide()
                child.hint.hide()

    hideIndicators = false

func ExecuteShowIndicators(_value: bool) -> void :

    var furnitures = get_tree().get_nodes_in_group("Furniture")


    for furniture in furnitures:


        for child in furniture.owner.get_children():
            if child is Furniture:
                child.indicator.show()
                child.hint.show()

    showIndicators = false

func ExecuteShowSpawns(_value: bool) -> void :

    var transitions = get_tree().get_nodes_in_group("Transition")


    for transition in transitions:

        if transition.owner.spawn:
            transition.owner.spawn.show()

    showSpawns = false

func ExecuteHideSpawns(_value: bool) -> void :

    var transitions = get_tree().get_nodes_in_group("Transition")


    for transition in transitions:

        if transition.owner.spawn:
            transition.owner.spawn.hide()

    hideSpawns = false
