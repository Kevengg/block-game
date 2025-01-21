extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom game play actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func collect():
	#gets global position of character
	var pos = global_position
	#max necessary length of ray
	var ray_length = 2
	#creates the ray, takes origin: here global position of cara, destination: here position of character modified by max ray length   
	var query = PhysicsRayQueryParameters3D.create(pos, pos - Vector3(0, ray_length, 0, ), 1)
	#gets the result of ray query
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	print(collision)
	#if there is a collision
	if !collision.is_empty():
		#get the chunk it collides with
		var chunk: GridMap = get_node(collision.collider.get_path() as NodePath)
		#FIXME figure out a better way to correct for offset
		#call on function in chunk to break the wanted block
		chunk.block_break(collision.position - Vector3(0, 1, 0))
		
func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_O:
				collect()
