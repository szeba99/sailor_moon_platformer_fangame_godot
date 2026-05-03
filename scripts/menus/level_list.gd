extends ColorRect

@onready var item_list = $ItemList
@onready var status_label = $Label
var selected_level_path: String = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	#create user levels folder if it doesn't exist.
	DirAccess.make_dir_recursive_absolute("user://levels/")
	
	
	
	item_list.clear()
	# 1. List built in levels
	list_levels_in_dir("res://scenes/") 
	
	# 2. List user levels
	list_levels_in_dir("user://levels/")
	
	# Connect to signal the event of click
	item_list.item_selected.connect(_on_level_selected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func list_levels_in_dir(path: String):
	if not DirAccess.dir_exists_absolute(path):
		print("ERROR: Directory does not exist: ", path) # DEBUG
		return

	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Only add files ending in .tscn
			if !dir.current_is_dir() and file_name.ends_with(".tscn"):
				var full_path = path.path_join(file_name)
				# save it to the list, but we also add the full path as metadatad
				var idx = item_list.add_item(file_name)
				item_list.set_item_metadata(idx, full_path)
			
			file_name = dir.get_next()

func _on_level_selected(index: int):
	# Select path from metadata
	selected_level_path = item_list.get_item_metadata(index)
	status_label.text = "" + item_list.get_item_text(index)

func _on_play_button_pressed():
	if selected_level_path != "":
		# also updating the Global variable for level restarts
		Global.current_level_path = selected_level_path
		get_tree().paused = false
		get_tree().change_scene_to_file(selected_level_path)
	else:
		status_label.text = "Please select a level first!"
