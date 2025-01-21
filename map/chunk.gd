extends GridMap

## what each block drops
@export var blockDrops: JSON = null
## important data related to items
@export var items: JSON = null

@export var toReplace: Dictionary = {
	"2": preload("res://tests/test.tscn")
}


var itemPrefab = preload("res://item/item.tscn")

## runs checks on startup to prevent game to start without dependencies and logs it in a good way
func _ready():
	if name != "GridTest":
		if (!blockDrops):
			printerr(scene_file_path, " - ", "no block drop data selected")
			get_tree().quit(1)
		if (!items):
			printerr(scene_file_path, " - ", "no item data selected")
			get_tree().quit(1)
		if (!itemPrefab):
			printerr(scene_file_path, " - ", "no item prefab selected")
			get_tree().quit(1)
	
	replace_many_with_scenes(toReplace)

	load_structure(load("res://resource/structures/alter.tscn"), Vector3(0, 48, 0))
	pass

## calculates and returns what items are dropped when the block is broken
func calc_drop(blockId: int) -> Dictionary:
	## selects drop data related to specific block based on id
	var dropData: Dictionary = blockDrops.data[blockId]
	## holds what is dropped from this instance
	var drops: Dictionary = {}
	## witch item ids are excluded
	var excluded = false
	for item in dropData:
		## exit loop if all items are excluded
		if excluded == true:
			break
		## skip item if it specifically is excluded 
		if typeof(excluded) == TYPE_ARRAY && (excluded as Array).has(item):
			continue
		## check if item will drop
		if randi_range(1, 100) <= dropData[item].chance:
			## if drop excludes something
			if dropData[item].exclude != null:
				var exclude = dropData[item].exclude
				## if item exclude all
				if exclude == true:
					##clears all dropped items
					drops.clear()
					excluded = true
				else:
					## for every item to be excluded (ex)
					for ex in exclude:
						## remove the item from drops
						drops.erase(ex)
						#adds the excluded item to the list of excluded items
						if typeof(excluded) != TYPE_ARRAY:
							excluded = [ex]
						else:
							excluded.append(ex)
					
			## if count is static return only it
			if typeof(dropData[item].count) == TYPE_FLOAT:
				drops[item] = dropData[item].count

			## if count is range select the amount based on it
			else:
				var r = dropData[item].count
				drops[item] = randi_range(r[0], r[1])
				

	return drops

## removes a block and drops its items
func block_break(pos: Vector3):
	#save the type of block
	var block = get_cell_item(pos)
	#remove it from sene 
	set_cell_item(to_local(pos), -1)
	var drops = calc_drop(block)
	
	print(drops)
	##FIXME create system to spawn items from broken block
	for drop in drops:
		drop = int(drop)
		## creates a new item instance
		var itemInstance = itemPrefab.instantiate() as Node3D
		## stets the position of the item instance to where the broken block was
		# itemInstance.set("position", pos)
		itemInstance.position = get_grid_center_global(pos)

		## sets the mesh of the item to the correct one if it has one
		if items.data[drop].mesh != null:
			itemInstance.set_meta("mesh", load(items.data[drop].mesh))

		## gives a random rotation to the item
		itemInstance.rotate_y(randi_range(0, 4) * 90)

		$"..".items.add_child(itemInstance)

## gets center of grid based ol local position 	
func get_grid_center_global(global_pos: Vector3) -> Vector3:
	return to_global((get_grid_center(to_local(global_pos))))

## gets center of grid based ol local position 
func get_grid_center(local_pos: Vector3) -> Vector3:
	local_pos = (local_pos.floor())
	local_pos.x += cell_size.x / 2
	local_pos.y += cell_size.y / 2
	local_pos.z += cell_size.z / 2
	return local_pos

func replace_with_scene(global_pos: Vector3, scene: PackedScene, child_of: Node = $"..") -> void:

	## holds where the scene origin should be 
	var origin = get_grid_center_global(global_pos)

	## make an instance of the scene
	var sceneInstance: Node3D = scene.instantiate()

	# set the position of the scene 
	sceneInstance.position = origin

	# create the scene
	child_of.add_child.call_deferred(sceneInstance)

	# remove temp item
	set_cell_item(global_pos, -1)

func replace_many_with_scenes(replacements: Dictionary, child_of: Node = $"..") -> void:
	for replacement in replacements:
		var cells = get_used_cells_by_item(int(replacement))
		for cell in cells:
			replace_with_scene(cell, replacements[replacement], child_of)
			

## loads given structure FIXME should probably be om map component
func load_structure(structure: PackedScene, pos: Vector3) -> void:

	## instance of wanted structure  
	var tempInstance: GridMap = structure.instantiate() as GridMap

	## list of all occupied cells in the structure
	var cellCords = (tempInstance as GridMap).get_used_cells()

	#loop thru occupied cells
	for cord in cellCords:
		## item in cell
		var item = tempInstance.get_cell_item(cord)
		# set the block based on the cord given by the structure modified my the position in the chunk 
		set_cell_item(pos + (cord as Vector3), item)
	
	# remove instance when done
	tempInstance.queue_free()
