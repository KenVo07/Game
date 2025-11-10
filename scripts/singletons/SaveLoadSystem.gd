extends Node

# ==========================================
# SAVE/LOAD SYSTEM
# ==========================================
# Manages game save data persistence

const SAVE_DIR = "user://saves/"
const MAX_SAVE_SLOTS = 5

signal save_completed(slot_id)
signal load_completed(slot_id)
signal save_failed(slot_id, error)
signal load_failed(slot_id, error)

func _ready():
	# Ensure save directory exists
	var dir = Directory.new()
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
	print("[SaveLoadSystem] Initialized, save directory: " + SAVE_DIR)

func save_game(slot_id: int) -> bool:
	"""Save the current game state to a slot"""
	if slot_id < 1 or slot_id > MAX_SAVE_SLOTS:
		push_error("Invalid save slot: " + str(slot_id))
		emit_signal("save_failed", slot_id, "Invalid slot")
		return false
	
	var save_data = _compile_save_data()
	var file_path = SAVE_DIR + "save_" + str(slot_id) + ".json"
	
	var file = File.new()
	var error = file.open(file_path, File.WRITE)
	
	if error != OK:
		push_error("Failed to open save file: " + file_path)
		emit_signal("save_failed", slot_id, "File access error")
		return false
	
	file.store_string(JSON.print(save_data, "\t"))
	file.close()
	
	emit_signal("save_completed", slot_id)
	print("[SaveLoadSystem] Game saved to slot %d" % slot_id)
	return true

func load_game(slot_id: int) -> bool:
	"""Load game state from a slot"""
	if slot_id < 1 or slot_id > MAX_SAVE_SLOTS:
		push_error("Invalid save slot: " + str(slot_id))
		emit_signal("load_failed", slot_id, "Invalid slot")
		return false
	
	var file_path = SAVE_DIR + "save_" + str(slot_id) + ".json"
	
	var file = File.new()
	if not file.file_exists(file_path):
		push_error("Save file does not exist: " + file_path)
		emit_signal("load_failed", slot_id, "File not found")
		return false
	
	var error = file.open(file_path, File.READ)
	if error != OK:
		push_error("Failed to open save file: " + file_path)
		emit_signal("load_failed", slot_id, "File access error")
		return false
	
	var content = file.get_as_text()
	file.close()
	
	var parse_result = JSON.parse(content)
	if parse_result.error != OK:
		push_error("Failed to parse save file: " + parse_result.error_string)
		emit_signal("load_failed", slot_id, "Parse error")
		return false
	
	var save_data = parse_result.result
	_apply_save_data(save_data)
	
	emit_signal("load_completed", slot_id)
	print("[SaveLoadSystem] Game loaded from slot %d" % slot_id)
	return true

func _compile_save_data() -> Dictionary:
	"""Compile all game state into a save data dictionary"""
	return {
		"version": "1.0.0",
		"timestamp": OS.get_unix_time(),
		"playtime": 0,  # TODO: Track playtime
		
		# World state
		"world_state": StoryStateManager.world_state.duplicate(true),
		
		# Cultivation
		"cultivation": CultivationSystem.get_cultivation_data(),
		
		# Abilities
		"abilities": AbilitySystem.get_ability_data(),
		
		# Simulation history
		"simulation_history": SimulationManager.get_simulation_history(),
		
		# Player position (would be set by player node)
		"player_position": {
			"x": 0,
			"y": 0,
			"scene": "WorldScene"
		}
	}

func _apply_save_data(save_data: Dictionary):
	"""Apply loaded save data to game systems"""
	# Restore world state
	if "world_state" in save_data:
		StoryStateManager.load_state(save_data["world_state"])
	
	# Restore cultivation
	if "cultivation" in save_data:
		CultivationSystem.load_cultivation_data(save_data["cultivation"])
	
	# Restore abilities
	if "abilities" in save_data:
		AbilitySystem.load_ability_data(save_data["abilities"])
	
	# Restore simulation history
	if "simulation_history" in save_data:
		SimulationManager.simulation_history = save_data["simulation_history"]
	
	# Player position would be restored by the scene manager
	print("[SaveLoadSystem] Save data applied successfully")

func delete_save(slot_id: int) -> bool:
	"""Delete a save slot"""
	if slot_id < 1 or slot_id > MAX_SAVE_SLOTS:
		push_error("Invalid save slot: " + str(slot_id))
		return false
	
	var file_path = SAVE_DIR + "save_" + str(slot_id) + ".json"
	
	var dir = Directory.new()
	if not dir.file_exists(file_path):
		return false
	
	var error = dir.remove(file_path)
	if error != OK:
		push_error("Failed to delete save file: " + file_path)
		return false
	
	print("[SaveLoadSystem] Save slot %d deleted" % slot_id)
	return true

func get_save_info(slot_id: int) -> Dictionary:
	"""Get information about a save slot without loading it"""
	if slot_id < 1 or slot_id > MAX_SAVE_SLOTS:
		return {}
	
	var file_path = SAVE_DIR + "save_" + str(slot_id) + ".json"
	
	var file = File.new()
	if not file.file_exists(file_path):
		return {}
	
	var error = file.open(file_path, File.READ)
	if error != OK:
		return {}
	
	var content = file.get_as_text()
	file.close()
	
	var parse_result = JSON.parse(content)
	if parse_result.error != OK:
		return {}
	
	var save_data = parse_result.result
	
	return {
		"exists": true,
		"timestamp": save_data.get("timestamp", 0),
		"playtime": save_data.get("playtime", 0),
		"realm": save_data.get("cultivation", {}).get("realm", "Unknown"),
		"simulations": save_data.get("world_state", {}).get("simulations_done", 0)
	}

func list_saves() -> Array:
	"""List all available save slots with their info"""
	var saves = []
	for i in range(1, MAX_SAVE_SLOTS + 1):
		var info = get_save_info(i)
		info["slot_id"] = i
		saves.append(info)
	return saves

func quick_save() -> bool:
	"""Quick save to slot 1"""
	return save_game(1)

func quick_load() -> bool:
	"""Quick load from slot 1"""
	return load_game(1)
