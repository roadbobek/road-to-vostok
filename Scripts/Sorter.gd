@tool
extends Node

@export var sort: bool = false: set = ExecuteSort
@export var reindex: bool = false: set = ExecuteReindex

func ExecuteSort(_value: bool) -> void :

    var children = get_children()


    if children.size() == 0:
        return


    children.sort_custom( func(a, b): return a.name.naturalnocasecmp_to(b.name) < 0)


    for child in children:
        move_child(child, -1)


    emit_signal("child_order_changed")


    print("Nodes sorted: ", children.size())


    sort = false

func ExecuteReindex(_value: bool) -> void :

    var children = get_children()


    if children.size() == 0:
        return


    var regex = RegEx.new()
    regex.compile("(_\\d+)$")
    var counters = {}
    var changes = 0


    for child in children:

        var oldName = child.name
        var baseName = regex.sub(child.name, "")


        if !counters.has(baseName):
            child.name = baseName
            counters[baseName] = 2

        else:
            child.name = baseName + "_" + str(counters[baseName])
            counters[baseName] += 1


        if child.name != oldName:
            changes += 1


    print("Nodes reindexed: ", changes)


    reindex = false
