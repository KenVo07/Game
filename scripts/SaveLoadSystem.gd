extends Node

# Save/Load System - Handles game state persistence

const SAVE_DIR = "user://saves/"
const MAX_SAVES = 10

func _ready():
	_ensure_save_directory()

func _ensure_save_directory():
	var dir = Directory.new()
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir(SAVE_DIR)

# Save game to specific slot
func save_game(slot: int) -> bool:
	if slot < 1 or slot > MAX_SAVES:
		push_error("Invalid save slot: " + str(slot))
		return false
	
	var save_data = _gather_save_data()
	var save_path = SAVE_DIR + "save_%d.json" % slot
	
	var file = File.new()
	var error = file.open(save_path, File.WRITE)
	if error != OK:
		push_error("Failed to open save file: " + save_path)
		return false
	
	file.store_line(to_json(save_data))
	file.close()
	
	print("Game saved to slot ", slot)
	return true

# Load game from specific slot
func load_game(slot: int) -> bool:
	if slot < 1 or slot > MAX_SAVES:
		push_error("Invalid save slot: " + str(slot))
		return false
	
	var save_path = SAVE_DIR + "save_%d.json" % slot
	
	var file = File.new()
	if not file.file_exists(save_path):
		push_error("Save file does not exist: " + save_path)
		return false
	
	var error = file.open(save_path, File.READ)
	if error != OK:
		push_error("Failed to open save file: " + save_path)
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var parse_result = JSON.parse(json_string)
	if parse_result.error != OK:
		push_error("Failed to parse save file")
		return false
	
	var save_data = parse_result.result
	_apply_save_data(save_data)
	
	print("Game loaded from slot ", slot)
	return true

# Check if save slot exists
func save_exists(slot: int) -> bool:
	var save_path = SAVE_DIR + "save_%d.json" % slot
	var file = File.new()
	return file.file_exists(save_path)

# Get save slot info
func get_save_info(slot: int) -> Dictionary:
	if not save_exists(slot):
		return {}
	
	var save_path = SAVE_DIR + "save_%d.json" % slot
	var file = File.new()
	file.open(save_path, File.READ)
	
	var json_string = file.get_as_text()
	file.close()
	
	var parse_result = JSON.parse(json_string)
	if parse_result.error != OK:
		return {}
	
	var save_data = parse_result.result
	
	return {
		"timestamp": save_data.get("timestamp", "Unknown"),
		"realm": save_data.get("cultivation", {}).get("current_realm", "Unknown"),
		"playtime": save_data.get("playtime", 0)
	}

# Delete save slot
func delete_save(slot: int) -> bool:
	var save_path = SAVE_DIR + "save_%d.json" % slot
	var dir = Directory.new()
	
	if dir.file_exists(save_path):
		var error = dir.remove(save_path)
		if error == OK:
			print("Deleted save slot ", slot)
			return true
		else:
			push_error("Failed to delete save slot ", slot)
			return false
	
	return false

# Gather all save data
func _gather_save_data() -> Dictionary:
	var save_data = {
		"version": "1.0",
		"timestamp": OS.get_datetime(),
		"playtime": 0,  # TODO: Track playtime
		"story_state": StoryStateManager.save_to_dict(),
		"cultivation": CultivationSystem.save_to_dict(),
		"abilities": AbilitySystem.save_to_dict(),
		"simulation": SimulationManager.save_to_dict(),
		"audio": AudioManager.save_to_dict()
	}
	
	# Save player position if in game
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		save_data["player_position"] = {
			"x": player[0].global_position.x,
			"y": player[0].global_position.y
		}
	
	return save_data

# Apply loaded save data
func _apply_save_data(data: Dictionary):
	if data.has("story_state"):
		StoryStateManager.load_from_dict(data["story_state"])
	
	if data.has("cultivation"):
		CultivationSystem.load_from_dict(data["cultivation"])
	
	if data.has("abilities"):
		AbilitySystem.load_from_dict(data["abilities"])
	
	if data.has("simulation"):
		SimulationManager.load_from_dict(data["simulation"])
	
	if data.has("audio"):
		AudioManager.load_from_dict(data["audio"])
	
	# Restore player position
	if data.has("player_position"):
		var player = get_tree().get_nodes_in_group("player")
		if player.size() > 0:
			player[0].global_position = Vector2(
				data["player_position"]["x"],
				data["player_position"]["y"]
			)

# Auto-save functionality
func auto_save():
	save_game(0)  # Slot 0 is auto-save

# Quick save
func quick_save():
	save_game(99)  # Slot 99 is quick save

# Quick load
func quick_load():
	return load_game(99)
