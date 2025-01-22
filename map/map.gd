extends Node3D

var helpers = Game.helpers

## size of one chunk in blocks
@export var chunkSize := 16;
## lowest block in world
@export var worldBottom := -32
## where to save data
@export var saveData: Dictionary;
## how many height changes is possible (in steps)
@export var heightDeviation := 8
## how heigh each step should be
@export var stepHeight := chunkSize
## how many chunks to generate per frame
@export var genSpeed := 2
## where to store items
@export var items: Node3D = null
## block library
@export var blockLib: MeshLibrary = preload("res://map/mesh_lib/mesh_lib.tres")


var chunk = preload("res://map/chunk.tscn")
var noise = FastNoiseLite.new()
var chunks: Array[Vector2i] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	
	helpers.checkItem(saveData, get_tree(), (scene_file_path + " - " + "no save data on map"))
		
	
	noise.noise_type = noise.TYPE_PERLIN
	

	var mapSeed = str(saveData.seed)

	helpers.checkItem(mapSeed.length() % 2 == 0, get_tree(), (scene_file_path + " - " + "invalid seed"))


	noise.offset = Vector3(float(mapSeed.substr(0, mapSeed.length() / 2)), 0, float(mapSeed.substr(mapSeed.length() / 2 - 1, -1)))
	
	## generate a list over all chunks that should be loaded
	for x in saveData.mapSize:
		for y in saveData.mapSize:
			chunks.append(Vector2i(x, y))
	

func getHeight(cord: Vector2i) -> int:
	return int(noise.get_noise_2d(cord.x, cord.y) * heightDeviation + heightDeviation - 3) * stepHeight
	
	
func save():
	saveData[1] = "test"

## generates an vector 4 array were v[x,y,z] is coordinates, and v[w] is block id
func genChunk(cord: Vector2i) -> Array[Vector4i]:
	## hight based on noise
	var height = getHeight(cord)

	var chunkData: Array[Vector4i] = []
	var blockID = 0
	var r = range(0, chunkSize)
	## range based on chunk size
	## x is width
	for x in r:
		## y is range
		for y in range(worldBottom, height):
			## z is length
			for z in r:
				chunkData.append(Vector4i(x, y, z, blockID))
	
	var key = str(cord.x) + "," + str(cord.y)
	if (saveData["chunks"].has(key)):
		chunkData.append_array(saveData["chunks"][key].map(Game.json.parseVector4i))
	return chunkData


func _process(delta):
	if (!chunks.is_empty()):
		var chunksToGenerate: Array[Vector2i] = []
		for _count in round(genSpeed / ceil(delta * 100)):
			chunksToGenerate.append(chunks.pop_front())
		
		for chunkToGenerate in chunksToGenerate:
			## instance of chunk to add data to
			var iChunk: GridMap = chunk.instantiate() as GridMap
			add_child(iChunk)
			iChunk.global_position = Vector3(chunkToGenerate.x * chunkSize, 0, chunkToGenerate.y * chunkSize)
			iChunk.mesh_library = blockLib
			
			var blockData = genChunk(chunkToGenerate)
			for block in blockData:
				iChunk.set_cell_item(Vector3i(block.x, block.y, block.z), block.w)
