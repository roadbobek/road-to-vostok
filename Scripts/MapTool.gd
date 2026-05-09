extends ScrollContainer


var focused = false
var panning = false
var zoomLevel = 1.0
var zoomSpeed = 0.1
var maxZoom = 1.0
var minZoom = 0.31
var baseZoom = 0.75


@onready var map: TextureRect = get_child(0)
const mapSize = Vector2(3840, 2160)

func _ready():

    map.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    map.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
    map.pivot_offset = Vector2.ZERO
    map.custom_minimum_size = mapSize


    zoomLevel = baseZoom
    map.scale = Vector2(zoomLevel, zoomLevel)
    map.custom_minimum_size = mapSize * zoomLevel

func _gui_input(event):

    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
        panning = event.pressed
        accept_event()


    if event is InputEventMouseMotion && panning:
        scroll_horizontal -= int(event.relative.x)
        scroll_vertical -= int(event.relative.y)
        focused = false
        accept_event()


    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP || event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            accept_event()

            if event.pressed:
                var mousePosition = get_local_mouse_position()

                if event.button_index == MOUSE_BUTTON_WHEEL_UP && zoomLevel < maxZoom:
                    Zoom(1.0 + zoomSpeed, mousePosition)
                    focused = false
                elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN && zoomLevel > minZoom:
                    Zoom(1.0 - zoomSpeed, mousePosition)
                    focused = false

func Zoom(factor: float, mouse_pos: Vector2):
    var previousZoom = zoomLevel
    zoomLevel = clamp(zoomLevel * factor, minZoom, maxZoom)

    if !is_equal_approx(previousZoom, zoomLevel):

        var mapPixel = (mouse_pos + Vector2(scroll_horizontal, scroll_vertical)) / previousZoom


        map.scale = Vector2(zoomLevel, zoomLevel)
        map.custom_minimum_size = mapSize * zoomLevel


        scroll_horizontal = int(mapPixel.x * zoomLevel - mouse_pos.x)
        scroll_vertical = int(mapPixel.y * zoomLevel - mouse_pos.y)

func Focus(marker: String):

    if focused:
        return


    var targetMarker = map.get_node_or_null(marker)


    if targetMarker:

        zoomLevel = baseZoom
        map.scale = Vector2(zoomLevel, zoomLevel)
        map.custom_minimum_size = mapSize * zoomLevel


        if !is_visible_in_tree():
            await self.visibility_changed


        await get_tree().process_frame


        var targetScrollX = (targetMarker.position.x * zoomLevel) - (size.x / 2.0)
        var targetScrollY = (targetMarker.position.y * zoomLevel) - (size.y / 2.0)


        scroll_horizontal = int(targetScrollX)
        scroll_vertical = int(targetScrollY)
        focused = true
