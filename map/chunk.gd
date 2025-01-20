extends GridMap

## what each block drops
@export var blockDrops: JSON = null
## important data related to items
@export var items: JSON = null

var itemPrefab = preload("res://item/item.tscn")

## runs checks on startup to prevent game to start without dependencies and logs it in a good way
func _ready():
	if (!blockDrops):
		push_error("no block drop data selected")
	if (!items):
		push_error("no item data selected")
	if (!itemPrefab):
		push_error("no item prefab selected")


## calculates and returns what items are dropped when the block is broken
func calc_drop(blockId: int) -> Dictionary:
	## selects drop data related to specific block based on id
	var dropData: Dictionary = blockDrops.data[blockId - 1]
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

		
		## holds current item
		var item = items.data[drop]

		## sets the mesh of the item to the correct one if it has one
		if item.mesh != null:
			itemInstance.set_mesh(item.mesh)

		itemInstance.set_mesh(load("res://blocks/dirt/dirt.tres"))
		## gives a random rotation to the item


		add_sibling(itemInstance)

## gets center of grid based ol local position 	
func get_grid_center_global(global_pos: Vector3) -> Vector3:
	return to_global((get_grid_center(to_local(global_pos))))


## gets center of grid based ol local position 
func get_grid_center(local_pos: Vector3) -> Vector3:
	local_pos = (local_pos.floor())
	local_pos.x += .5
	local_pos.y += .5
	local_pos.z += .5
	return local_pos
