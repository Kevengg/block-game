extends Node3D

@export var items: Node

func load_map(save: Dictionary):
	set_meta("saveData", save)
	var map = preload("res://map/map.tscn").instantiate() as Node3D
	map.saveData = save
	map.items = items
	get_tree().root.add_child(map)
