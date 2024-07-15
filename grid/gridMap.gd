extends MeshLibrary
#
#


func _init():
	
# updates items in lib
	var dirs = DirAccess.get_directories_at("./blocks/")
	
	for dir in dirs: 
		#print (dir)
		if (find_item_by_name(dir) == -1):
			var id = get_last_unused_item_id()
			create_item(id)
			set_item_name(id, dir)
