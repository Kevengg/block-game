extends Node
class_name Game



class json:
	extends Node
	static func updateJsonFile(json:JSON):
		var file = FileAccess.open(json.resource_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(json.data, "\t") )
		
	
	
	static func parseVector4i(string:String) :
		
		var regex = RegEx.new()
		regex.compile(r"\(([0-9]*?),([0-9]*?),([0-9]*?),([0-9]*?)\)")
		var r = regex.search(string)
		if (!!r):
			return Vector4i(int(r.get_string(1)),int(r.get_string(2)),int(r.get_string(3)),int(r.get_string(4)))
		return null
	
	## parse a vector as string of x length to a libeary of x length FIXME not implemented
	static func parseVectorX(string:String, x:int, i:bool=false):
		pass
	
	
	

