extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


## only for testing
func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_O:
				collect()
				
		
		if event.keycode == KEY_LEFT:
			apply_force(Vector3(60, 0, 0))
		if event.keycode == KEY_RIGHT:
			apply_force(Vector3(-60, 0, 0))
		if event.keycode == KEY_UP:
			apply_force(Vector3(0, 0, 60))
		if event.keycode == KEY_DOWN:
			apply_force(Vector3(0, 0, -60))

func collect():
	
	#gets global position of carracter
	var pos = global_position
	#max nesesary legnth of ray
	var ray_length = 1
	#creates the ray, takes origin: here global position of cara, destination: here position of carra modified by max ray length   
	var query = PhysicsRayQueryParameters3D.create(pos, pos - Vector3(0, ray_length, 0, ), 1)
	#gets the result of ray query
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	print(collision)
	#if tere is a colition
	if !collision.is_empty():
		#get the chunk it colides with
		var chunk: GridMap = get_node(collision.collider.get_path() as NodePath)
		#FIXME figure out a beter way to correct for offset
		#call on functin in chunk to break the wanted block
		chunk.block_break(collision.position - Vector3(0, 1, 0))
