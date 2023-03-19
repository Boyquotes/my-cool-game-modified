extends Node


var player_file_path: String = "user://player_data.json"

var player_data: Dictionary = {
	health = 100
}

func _init():
	pass

func save_game():
	var file: FileAccess = FileAccess.open(player_file_path, FileAccess.WRITE)
	file.store_var(player_data);
	file.close()
	
func load_data():
	# We don't have a save to load. So create a default file.
	if not FileAccess.file_exists(player_file_path):
		player_data = {
			health = 100
		}
		save_game()
	
	var file: FileAccess = FileAccess.open(player_file_path, FileAccess.WRITE)
	player_data = file.get_var()
	file.close()
