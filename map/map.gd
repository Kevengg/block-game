extends Node3D 

## seed for noice map, determins what noice map to use
@export var noiceSeed := 3302;
## size of one chunk in blocks
@export var chunkSize := 16;
## lowest block in world
@export var worldBottom := -32
## where to save data
@export var saveData:JSON= null;
## mapsize in chunks
@export var mapSize:= 1
## how manny height changes is posible (in steps)
@export var heightDiviation := 8
## how heigh eatch step shuld be
@export var stepHeigth:= chunkSize
## how many chunks to gennerate per frame
@export var genSpeed := 2



var blockLib = preload("res://blocks/blocks.lib.tres")
var chunk = preload("res://map/chunk.tscn")
var noice = FastNoiseLite.new()
var chunks:Array[Vector2i] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	if (!saveData):
		push_error("no save data on map" )
	noice.noise_type = noice.TYPE_PERLIN
	noice.offset = Vector3(noiceSeed, 0, noiceSeed)
	
	## gennerate a list over all chunks that shuld be loaded
	for x in mapSize:
		for y in mapSize:
			chunks.append(Vector2i(x, y))
	#
	#loadMap()

func getHeight(cord: Vector2i) -> int:
	return int(noice.get_noise_2d(cord.x, cord.y) * heightDiviation + heightDiviation - 3) * stepHeigth
	#return 1
	
	
	 

## load the map from savee data and/or seed
func loadMap():
	var regex = RegEx.new()
	regex.compile(r"\(([0-9]*?),([0-9]*?),([0-9]*?),([0-9]*?)\)")
	for x in mapSize:
		for z in mapSize:
			
			var iChunk:GridMap = chunk.instantiate() as GridMap
			add_child(iChunk)
			iChunk.global_position = Vector3(x * chunkSize, 0, z * chunkSize)
			iChunk.mesh_library = blockLib
			var chunkData = genChunc(Vector2i(x,z))
			var saveChunkdata:Array[Vector4i] = []
			var key = str(x)+","+str(z)
			if (saveData.data["chunks"].has(key)):
				for item in saveData.data["chunks"][key] :
					var r = regex.search(item)
					if (!!r):
						saveChunkdata.append(Vector4i(int(r.get_string(1)),int(r.get_string(2)),int(r.get_string(3)),int(r.get_string(4))))
			chunkData.append_array(saveChunkdata)
			for item in chunkData as Array[Vector4i]:
				iChunk.set_cell_item(Vector3(item.x, item.y, item.z), item.w)



func save():
	saveData.set("test", 1)

## generates an vector 2 array were v[1] is height, and v[2] is block id
func genChunc(cord: Vector2i) -> Array[Vector4i]:
	## haight based on noice
	var height = getHeight(cord) 

	var chunkData:Array[Vector4i] = []
	var blockID = 0
	var r = range(0, chunkSize )
	## range based on chunk size
	## x is width
	for x in r:
		## y is range
		for y in range(worldBottom, height):
			## z is length
			for z in r: 
				chunkData.append(Vector4i(x, y, z, blockID))
	var saveChunkdata:Array[Vector4i] = []
	var key = str(cord.x)+","+str(cord.y)
	if (saveData.data["chunks"].has(key)):
		chunkData.append_array(saveData.data["chunks"][key].map(Game.json.parseVector4i))
	return chunkData



func _process(delta):
	if (!chunks.is_empty()):
		var chunksToGennerate:Array[Vector2i] = []
		print(round(genSpeed / ceil(delta * 100)))
		for _count in round(genSpeed / ceil(delta * 100)) :
			chunksToGennerate.append(chunks.pop_front())
		
		for chunkToGennerate in chunksToGennerate:
			## instance of chunk to add data to
			var iChunk:GridMap = chunk.instantiate() as GridMap
			add_child(iChunk)
			iChunk.global_position = Vector3(chunkToGennerate.x * chunkSize, 0, chunkToGennerate.y * chunkSize)
			iChunk.mesh_library = blockLib
			
			var blockData = genChunc(chunkToGennerate)
			for block in blockData:
				iChunk.set_cell_item(Vector3i(block.x, block.y, block.z), block.w)
