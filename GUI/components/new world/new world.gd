extends Control

@export var saveData: JSON
@export var mapSize := 6
signal seedError(msg: String)
signal nameError(msg: String)

func _on_button_pressed():
	var worldName = $"world name".text
	var worldSeed = $"world seed".text

	# validate name
	if name.length() == 0:
		emit_signal("nameError", "world needs a name")
		return

	# validate seed
	if is_nan(int(worldSeed)) || (int(worldSeed) % 2 != 0):
		emit_signal("seedError", "invalid")
		return

	# create new save 
	saveData.data.push_front({
		"name": worldName,
		"seed": worldSeed,
		"mapSize": mapSize,
		"chunks": {"0,0": ["(0,0,0,1)", "(1,0,0,2)"]}
		})
	
	# update saved data
	Game.json.updateJsonFile(saveData)
