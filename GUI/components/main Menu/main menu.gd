extends Control

var helper = Game.helpers

@export var saveData: JSON = null
@export var items: Node = null

var save = preload("res://data/saveData.json").data[0]

func _ready():

	helper.checkItem(saveData, get_tree(), (scene_file_path + " - " + "no save data selected"))
	helper.checkItem(items, get_tree(), (scene_file_path + " - " + "no place to put items"))

	# set project version
	if ProjectSettings.get_setting("application/config/version") == "":
		$"Control/version".text = "DEVELOPMENT"
	else:
		$"Control/version".text = ProjectSettings.get_setting("application/config/version")

	# set displayed name to name of save if there is one, if not; removes the continue menu
	if !save.is_empty():
		$"VFlowContainer/continue/save name".text = save.name
	else:
		$"VFlowContainer/continue".queue_free()
		

## quits game when quit button is pressed
func _on_exit_pressed():
	get_tree().quit()


func _on_continue_pressed():
	get_tree().root.get_child(0).load_map(save)
	queue_free()
	

func _on_singlepalyer_pressed():
	var nextPage = load("res://GUI/components/new world/new world.tscn").instantiate()
	nextPage.saveData = saveData
	add_sibling(nextPage)
	queue_free()
