extends Control


var gameData = preload("res://Resources/GameData.tres")

@onready var label: Label = $Panel / Margin / Label
var GPUTime = 0.0
var CPUTime = 0.0
var hardware = ""

func _input(event):
    if event is InputEventKey && event.pressed && event.keycode == KEY_KP_ENTER && !event.is_echo() && !gameData.menu:

        RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(), true)


        hardware = ""


        hardware += "CPU: " + OS.get_processor_name() + "\n"
        hardware += "GPU: " + RenderingServer.get_video_adapter_name() + "\n"
        hardware += "Driver: " + RenderingServer.get_video_adapter_api_version() + "\n"


        visible = !visible

func Basic():

    hardware = ""


    hardware += OS.get_processor_name() + "  |  "
    hardware += RenderingServer.get_video_adapter_name() + "  |  "
    hardware += RenderingServer.get_video_adapter_api_version()


    var text = hardware

    label.text = text

func _process(_delta):

    if !visible || gameData.menu: return


    var viewport = get_viewport().get_viewport_rid()
    var gpuTime = RenderingServer.viewport_get_measured_render_time_gpu(viewport)
    var cpuTime = (Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) + Performance.get_monitor(Performance.TIME_PROCESS)) * 1000
    var resolution = DisplayServer.window_get_size()


    GPUTime = lerp(GPUTime, gpuTime, 0.1)
    CPUTime = lerp(CPUTime, cpuTime, 0.1)


    var text = hardware
    text += "Resolution: " + str(resolution.x) + "x" + str(resolution.y) + "\n"
    text += "\n"
    text += "FPS: " + str(int(Engine.get_frames_per_second())) + "\n"
    text += "CPU Time: " + str(snappedf(CPUTime, 0.01)) + " ms\n"
    text += "GPU Time: " + str(snappedf(GPUTime, 0.01)) + " ms\n"
    text += "\n"
    text += "Draw Calls: " + str(int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))) + "\n"
    text += "Tris (AP): " + str(int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))) + "\n"
    text += "\n"
    text += "Nodes: " + str(int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))) + "\n"
    text += "Collision Pairs: " + str(int(Performance.get_monitor(Performance.PHYSICS_3D_COLLISION_PAIRS)))

    label.text = text
