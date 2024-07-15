extends GridMap
@export var mapSizeInSteps := 30;
@export var stepBottom := -20;
@export var stepWidth := 10;
@export var stepHeight := 10;
@export var maxSteps := 5;
@export var perlinSeed := 40;


# Called when the node enters the scene tree for the first time.
func _ready():
	stepBottom = stepBottom * stepHeight
	
	cell_octant_size = 3 * stepWidth
	
	var perlin = FastNoiseLite.new()
	perlin.noise_type = perlin.TYPE_PERLIN
	perlin.seed = perlinSeed
	
	var rangeOfSize = range(floor(-((mapSizeInSteps * stepWidth) / 2.0)), floor((mapSizeInSteps * stepWidth) / 2.0))
	
	var a := sqrt(perlinSeed) * 3.14
	 
	
	for x in rangeOfSize:
		for z in rangeOfSize:
			var y :int = clamp(round(perlin.get_noise_2d(x / stepWidth, z / stepWidth) * a ), -2, maxSteps ) * stepHeight # height
			set_cell_item(Vector3(x, y, z), 0)
			for y2 in range(stepBottom, y):
				set_cell_item(Vector3(x, y2, z), 0)


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
