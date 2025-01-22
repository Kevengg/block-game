extends Control


func _ready():
	var saveDir = DirAccess.open("res://data/saves/")
	var saves = saveDir.get_files()
	saves.remove_at(saves.find("lastUsed.json"))

	for save in saves:
		var loadButton = $Load.duplicate()
		loadButton.text = save
		loadButton.visible = true
		add_child(loadButton)
