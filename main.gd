extends Node3D

@export var items: Node

var lastLoaded = "res://data/saves/lastUsed.json"

func load_map(save: JSON):
	set_meta("saveData", save)
	var map = preload("res://map/map.tscn").instantiate() as Node3D
	map.saveData = save.data
	map.items = items
	get_tree().root.add_child(map)
