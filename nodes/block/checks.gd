extends Node3D


func _ready():
	checkHidden()
#
## checks and hides relevant blocks
func checkHidden() -> void :
	var rays = find_children("", "RayCast3D") as Array[RayCast3D]
	for ray in rays:
		ray.force_raycast_update()
		var target = ray.get_collider() as StaticBody3D
		if (!target):
			
			var t = get_parent().find_child("MeshInstance3D") as MeshInstance3D 
			t.material_override = null
			break
		else: 
			print (target)


func delete() -> void :
	var rays = find_children("", "RayCast3D") as Array[RayCast3D]
	for ray in rays:
		ray.force_raycast_update()
		var target = ray.get_collider() as StaticBody3D
		if (target):
			target.find_child("MeshInstance3D").material_override = null 
	get_parent().free()
