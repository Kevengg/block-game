extends Node3D

var helpers = Game.helpers
var json = Game.json

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
## block library
@export var blockLib: MeshLibrary = preload("res://map/mesh_lib/mesh_lib.tres")


var noise = FastNoiseLite.new()
## holds chunks that should be loaded
var chunks: Array[Vector2i] = []

var blockLocation := "res://blocks/"

func _ready():
	saveData = load("res://data/saves/Test Save 1.json").data
	
	helpers.checkItem(!saveData.is_empty(), get_tree(), (scene_file_path + " - " + "no save data on map"))

	noise.noise_type = noise.TYPE_PERLIN


	# set noise offset based on world seed
	var mapSeed = str(saveData.seed)
	helpers.checkItem(mapSeed.length() % 2 == 0, get_tree(), (scene_file_path + " - " + "invalid seed"))
	noise.offset = Vector3(float(mapSeed.substr(0, mapSeed.length() / 2)), 0, float(mapSeed.substr(mapSeed.length() / 2 - 1, -1)))

	## generate a list over all chunks that should be loaded
	for x in saveData.mapSize:
		for y in saveData.mapSize:
			chunks.append(Vector2i(x, y))

## gets the height deviation in an chunk based on the perlin noise
func getHeight(cord: Vector2i) -> int:
	return int(noise.get_noise_2d(cord.x, cord.y) * heightDeviation + heightDeviation - 3) * stepHeight

## checks if 2 item vector4 are the same 
func comparePosition(pos1: Vector4i, pos2: Vector4i) -> bool:
	var cord1 = Vector3(pos1.x, pos1.y, pos1.z)
	var cord2 = Vector3(pos2.x, pos2.y, pos2.z)
	return cord1 == cord2

## checks if an item vector4 is in a list
func positionInList(pos: Vector4i, list: Array[Vector4i]):
	for item in list:
		if comparePosition(pos, item):
			return item
	return null
	

## generates an vector 4 array were v[x,y,z] is coordinates, and v[w] is block id
func genChunk(cord: Vector2i) -> Array[Vector4i]:
	## hight based on noise
	var height = getHeight(cord)

	var chunkData: Array[Vector4i] = []
	
	## range based on chunk size
	var r = range(0, chunkSize)


		## x is width
	for x in r:
		## y is height
		for y in range(worldBottom, height):
			var key = str(cord.x) + "," + str(cord.y)
			# runs if chunk has no saved changes  
			if !saveData["chunks"].has(key):
				## z is length
				for z in r:
					chunkData.append(Vector4i(x, y, z, genBlock(Vector3i(x, y, z))))
			else:
				
				var chunkSave = json.parseVector4iArray(saveData["chunks"][key])
 
				for z in r:
					var existing = positionInList(Vector4i(x, y, z, -1), chunkSave)

					if !!existing:
						chunkData.append(existing)
					else:
						chunkData.append(Vector4i(x, y, z, genBlock(Vector3i(x, y, z))))
	
	return chunkData


# FIXME create system for generating different blocks 
func genBlock(_pos: Vector3i) -> int:
	var blockID = 0
	return blockID


func _process(delta):
	if (!chunks.is_empty()):
		var chunksToGenerate: Array[Vector2i] = []
		for _count in round(genSpeed / ceil(delta * 100)):
			chunksToGenerate.append(chunks.pop_front())
		
		for chunkToGenerate in chunksToGenerate:
			var chunk = Node3D.new()
			chunk.name = str(chunkToGenerate.x) + "," + str(chunkToGenerate.y)

			chunk.position = Vector3(chunkToGenerate.x * chunkSize, 0, chunkToGenerate.y * chunkSize)
			add_child(chunk)
			var blockData := genChunk(chunkToGenerate)
			for block in blockData:
				var blockName := blockLib.get_item_name(block.w)

				var blockInstance: Node3D = load(blockLocation + blockName + "/" + blockName + ".tscn").instantiate()
				blockInstance.position = Vector3i(block.x, block.y, block.z)
				chunk.add_child(blockInstance)
	else: print("done")
