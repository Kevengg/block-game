extends GridMap

## x and z size of map
@export var mapSize = 30 
## maximum count of plates
@export var maxPlates = 6
## blocks per plate
@export var plateHeight = 10
## seed used for perlinNoice, used to generate map geometry
@export var noiceSeed = 20
## x val of lowest block in map
@export var minHeight = -10


## calculate what material a item at a certan height shuld have 
func calcMat (y: int): 
	var lib = self.mesh_library
	
	
	
	if y < -6:
		return lib.find_item_by_name("stone")
	elif y >= 1: 
		return lib.find_item_by_name("stone")
	else :
		return lib.find_item_by_name("dirt")
	
	

# Called when the node enters the scene tree for the first time.
func _ready():
	var perlinNoice = FastNoiseLite.new()
	perlinNoice.noise_type = FastNoiseLite.TYPE_PERLIN
	perlinNoice.seed = noiceSeed
	perlinNoice.fractal_octaves = 3
	perlinNoice.cellular_jitter = 1
	perlinNoice.domain_warp_fractal_lacunarity = 20
	
	
	for x in range(mapSize):
		
		for z in range(mapSize):
			@warning_ignore("integer_division")
			var y = floor((perlinNoice.get_noise_2d((x/15), (z/15)))  * 40 - 3) 
			if y > maxPlates:
				y = maxPlates
			for c in range(plateHeight + 1):
				set_cell_item(Vector3i(x,y + y * plateHeight + (c) , z), calcMat(y) )
				
	## holds the range of y values, minHeigt to higest posible height
	var maxHeight = range(minHeight, maxPlates * plateHeight)
	var stone = mesh_library.find_item_by_name("stone")
	
	for x in range(mapSize):
		for z in range(mapSize):
				for y in maxHeight:
					## combined verctor of x y z
					var v = Vector3i(x,y,z)
					if(get_cell_item(v)!=-1):
						break # exits y loop when it finds a cell with an item in it
					else:
						set_cell_item(v, stone)
	
	var itemsTypes = mesh_library.get_item_list()
	# for item types in map
	for itemType in itemsTypes:
		#get all items of type
		var cells = get_used_cells_by_item(itemType)
		# find name of item in map
		var itemTypeName = mesh_library.get_item_name(itemType)
		# find the file in folder that matches regex
		var item = load("./blocks/" + itemTypeName + "/" + itemTypeName + ".tscn")
		# for item in arr
		for cell in cells:
			var itemInstance = item.instantiate()
			# put instance from file wher item is
			itemInstance.translate(cell)
			add_child(itemInstance)
			# delete item
			set_cell_item(cell, -1)



