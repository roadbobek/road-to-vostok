extends TextureRect
class_name Grid


var items = []
var grid = {}


var cellSize = 64
var gridWidth = 0
var gridHeight = 0


var tetrisSize

func _ready():
    CreateGrid()



func Spawn(item):

    var originalPosition = item.global_position

    for y in range(gridHeight):
        for x in range(gridWidth):

            if !grid[x][y]:
                item.global_position = global_position + Vector2(x, y) * cellSize

                if Place(item):
                    return true


    item.global_position = originalPosition
    return false

func Place(item):

    var itemPosition = item.global_position + Vector2(float(cellSize) / 2, float(cellSize) / 2)
    var gridPosition = GetGridPosition(itemPosition)
    var gridItemSize = GetGridSize(item)


    if CheckGridSpace(gridPosition.x, gridPosition.y, gridItemSize.x, gridItemSize.y):
        UpdateGrid(gridPosition.x, gridPosition.y, gridItemSize.x, gridItemSize.y, true)
        item.global_position = global_position + Vector2(gridPosition.x, gridPosition.y) * cellSize
        items.append(item)
        item.reparent(self)
        item.State("Static")
        return true
    else:
        return false

func Pick(item):

    if !items.has(item):
        print("Item not found: ", item.name)
        return null


    var itemPosition = item.global_position + Vector2(float(cellSize) / 2, float(cellSize) / 2)
    var gridPosition = GetGridPosition(itemPosition)
    var gridSize = GetGridSize(item)


    UpdateGrid(gridPosition.x, gridPosition.y, gridSize.x, gridSize.y, false)


    items.remove_at(items.find(item))


    return item



func CreateGrid():
    var results = {}
    var panelSize = self.size

    results.x = clamp(int(panelSize.x / cellSize), 1, 500)
    results.y = clamp(int(panelSize.y / cellSize), 1, 500)

    gridWidth = results.x
    gridHeight = results.y

    for x in range(gridWidth):
        grid[x] = {}
        for y in range(gridHeight):
            grid[x][y] = false

func CreateContainerGrid(containerSize: Vector2):

    containerSize.x = clamp(containerSize.x, 4, 8)
    containerSize.y = clamp(containerSize.y, 1, 13)


    gridWidth = containerSize.x
    gridHeight = containerSize.y


    var gridSize = Vector2(containerSize.x * cellSize, containerSize.y * cellSize)
    custom_minimum_size = gridSize
    self.size = gridSize


    grid.clear()
    items.clear()


    for x in range(gridWidth):
        grid[x] = {}
        for y in range(gridHeight):
            grid[x][y] = false

func ClearGrid():
    items.clear()
    CreateGrid()

func GetGridSize(item):
    var results = {}
    var itemSizeX
    var itemSizeY

    if item.rotated:
        itemSizeX = item.slotData.itemData.size.y * 64
        itemSizeY = item.slotData.itemData.size.x * 64
    else:
        itemSizeX = item.slotData.itemData.size.x * 64
        itemSizeY = item.slotData.itemData.size.y * 64

    results.x = clamp(int(itemSizeX / cellSize), 1, 500)
    results.y = clamp(int(itemSizeY / cellSize), 1, 500)

    tetrisSize = results
    return results

func GetGridPosition(itemPosition):
    var localPosition = itemPosition - global_position
    var results = {}

    results.x = int(localPosition.x / cellSize)
    results.y = int(localPosition.y / cellSize)
    return results

func CheckGridSpace(x, y, w, h):
    if x < 0 or y < 0:
        return false

    if x + w > gridWidth or y + h > gridHeight:
        return false

    for i in range(x, x + w):
        for j in range(y, y + h):
            if grid[i][j]:
                return false

    return true

func UpdateGrid(x, y, w, h, state):
    for i in range(x, x + w):
        for j in range(y, y + h):
            grid[i][j] = state
