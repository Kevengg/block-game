extends Control

var save = preload("res://data/saveData.json").data

func _ready():
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
	
	queue_free()
