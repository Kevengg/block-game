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
		var itemInstance = itemPrefab.instantiate()
		itemInstance.set("position", pos)
		add_sibling(itemInstance)
		print(pos)
