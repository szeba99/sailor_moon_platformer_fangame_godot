extends Node

# ==========================================
# PHASE 1: VARIABLE DECLARATIONS
# Add your new variables here.
# ==========================================

var save_name: String = "slot_1" # This is also the filename

var lives: int = 3
var score: int = 0
var current_level_path: String = "res://scenes/testlevel.tscn"
var player_name: String = "Sailor Moon"
var checkpoint_x : float = 0.0
var checkpoint_y : float = 0.0

# ==========================================
# PHASE 2: PACKING LOGIC (For Saving)
# Add your variables to this dictionary.
# ==========================================

func _get_data_to_save() -> Dictionary:
	return {
		"save_name": save_name,
		"lives": lives,
		"score": score,
		"current_level_path": current_level_path,
		"player_name": player_name,
		"checkpoint_x": checkpoint_x,
		"checkpoint_y": checkpoint_y,
	}

# ==========================================
# PHASE 3: UNPACKING LOGIC (For Loading)
# Map the loaded data back to your variables.
# ==========================================

func _apply_loaded_data(data: Dictionary):
	if data.has("save_name"): save_name = data["save_name"]
	if data.has("lives"): lives = data["lives"]
	if data.has("score"): score = data["score"]
	if data.has("current_level_path"): current_level_path = data["current_level_path"]
	if data.has("player_name"): player_name = data["player_name"]
	if data.has("checkpoint_x"): checkpoint_x = data["checkpoint_x"]
	if data.has("checkpoint_y"): checkpoint_y = data["checkpoint_y"]

# ==========================================
# PHASE 4: INTERNAL ENGINE LOGIC
# You don't need to touch anything below this line.
# ==========================================

var save_directory: String = ""

func _ready():
	save_directory = _determine_save_folder()
	print("Global: Save system initialized at: ", save_directory)

func save_game():
	var data = _get_data_to_save()
	var path = save_directory.path_join(save_name + ".save")
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	if file:
		var json_string = JSON.stringify(data, "\t")
		file.store_line(json_string)
		file.close()
		print("Global: Successfully saved to ", path)
	else:
		printerr("Global: Save failed! Error: ", FileAccess.get_open_error())

func load_game(target_name: String):
	var path = save_directory.path_join(target_name + ".save")
	
	if not FileAccess.file_exists(path):
		print("Global: No save file found at ", path)
		return false
		
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		if json.parse(json_string) == OK:
			_apply_loaded_data(json.data)
			print("Global: Successfully loaded ", path)
			return true
	return false

func _determine_save_folder() -> String:
	if OS.has_feature("editor"):
		_ensure_dir("res://saves")
		return "res://saves"
	
	if OS.has_feature("web") or OS.has_feature("android") or OS.has_feature("ios"):
		return "user://"

	var exe_dir = OS.get_executable_path().get_base_dir()
	var local_saves = exe_dir.path_join("saves")
	return local_saves if _ensure_dir(local_saves) else "user://saves"

func _ensure_dir(path: String) -> bool:
	if not DirAccess.dir_exists_absolute(path):
		return DirAccess.make_dir_recursive_absolute(path) == OK
	return true

# ==========================================
# PHASE 4: END OF SAVE GAME LOGIC.
# Other utility functions go down here here
# ==========================================

func set_checkpoint(x:float, y:float):
	checkpoint_x = x
	checkpoint_y = y

func reset_checkpoint():
	checkpoint_x = 0.0
	checkpoint_y = 0.0
