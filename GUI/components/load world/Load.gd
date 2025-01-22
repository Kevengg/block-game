extends Button

func _ready():
	print(text)


func _pressed():
	# find save
	var save = load("res://data/saves/" + text)
	print("pressed")

	# send load command to main
	get_tree().root.get_child(0).load_map(save)
	$"..".queue_free()
