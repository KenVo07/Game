extends Node

# ==========================================
# SAVE/LOAD SYSTEM
# Handles game state persistence across sessions
# ==========================================

signal save_completed(slot_id)
signal load_completed(slot_id)
signal save_failed(error_message)
signal load_failed(error_message)

const SAVE_DIR = "user://saves/"
const SAVE_FILE_PREFIX = "save_"
const SAVE_FILE_EXTENSION = ".json"
const MAX_SAVE_SLOTS = 10

# Current save slot
var current_save_slot: int = -1


func _ready():
	print("[SaveLoadSystem] Initialized")
	_ensure_save_directory()


# ==========================================
# SAVE FUNCTIONS
# ==========================================

func save_game(slot_id: int = -1) -> bool:
	"""Save current game state to specified slot (or current slot)"""
	if slot_id == -1:
		slot_id = current_save_slot
	
	if slot_id < 0 or slot_id >= MAX_SAVE_SLOTS:
		push_error("Invalid save slot: " + str(slot_id))
		emit_signal("save_failed", "Invalid save slot")
		return false
	
	print("[SaveLoad] Saving game to slot " + str(slot_id))
	
	# Gather all save data
	var save_data = {
		"version": "1.0.0",
		"timestamp": OS.get_datetime(),
		"play_time": OS.get_ticks_msec(),
		"slot_id": slot_id,
		
		# System data
		"story_state": StoryStateManager.get_save_data(),
		"cultivation": CultivationSystem.get_save_data(),
		"abilities": AbilitySystem.get_save_data(),
		"simulation": SimulationManager.get_save_data(),
		
		# Player data (would be added from Player node)
		"player_position": Vector2.ZERO,
		"player_health": 100,
		
		# Meta data
		"current_scene": get_tree().current_scene.filename if get_tree().current_scene else ""
	}
	
	# Convert to JSON
	var json_string = JSON.print(save_data, "\t")
	
	# Write to file
	var file = File.new()
	var file_path = _get_save_path(slot_id)
	var error = file.open(file_path, File.WRITE)
	
	if error != OK:
		push_error("Failed to open save file for writing: " + str(error))
		emit_signal("save_failed", "Failed to write save file")
		return false
	
	file.store_string(json_string)
	file.close()
	
	current_save_slot = slot_id
	emit_signal("save_completed", slot_id)
	print("[SaveLoad] Game saved successfully to slot " + str(slot_id))
	
	return true


func quick_save() -> bool:
	"""Quick save to slot 0"""
	return save_game(0)


# ==========================================
# LOAD FUNCTIONS
# ==========================================

func load_game(slot_id: int) -> bool:
	"""Load game state from specified slot"""
	if slot_id < 0 or slot_id >= MAX_SAVE_SLOTS:
		push_error("Invalid save slot: " + str(slot_id))
		emit_signal("load_failed", "Invalid save slot")
		return false
	
	var file_path = _get_save_path(slot_id)
	
	if not _save_exists(slot_id):
		push_error("Save file does not exist: " + file_path)
		emit_signal("load_failed", "Save file not found")
		return false
	
	print("[SaveLoad] Loading game from slot " + str(slot_id))
	
	# Read file
	var file = File.new()
	var error = file.open(file_path, File.READ)
	
	if error != OK:
		push_error("Failed to open save file for reading: " + str(error))
		emit_signal("load_failed", "Failed to read save file")
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	# Parse JSON
	var parse_result = JSON.parse(json_string)
	if parse_result.error != OK:
		push_error("Failed to parse save file JSON: " + parse_result.error_string)
		emit_signal("load_failed", "Corrupted save file")
		return false
	
	var save_data = parse_result.result
	
	# Restore all systems
	if save_data.has("story_state"):
		StoryStateManager.load_save_data(save_data["story_state"])
	
	if save_data.has("cultivation"):
		CultivationSystem.load_save_data(save_data["cultivation"])
	
	if save_data.has("abilities"):
		AbilitySystem.load_save_data(save_data["abilities"])
	
	if save_data.has("simulation"):
		SimulationManager.load_save_data(save_data["simulation"])
	
	# TODO: Restore player position and scene
	# This would require changing scenes and repositioning the player
	
	current_save_slot = slot_id
	emit_signal("load_completed", slot_id)
	print("[SaveLoad] Game loaded successfully from slot " + str(slot_id))
	
	return true


func quick_load() -> bool:
	"""Quick load from slot 0"""
	return load_game(0)


# ==========================================
# SAVE SLOT MANAGEMENT
# ==========================================

func delete_save(slot_id: int) -> bool:
	"""Delete a save file"""
	if not _save_exists(slot_id):
		return false
	
	var dir = Directory.new()
	var file_path = _get_save_path(slot_id)
	var error = dir.remove(file_path)
	
	if error != OK:
		push_error("Failed to delete save file: " + str(error))
		return false
	
	print("[SaveLoad] Deleted save slot " + str(slot_id))
	return true


func get_save_info(slot_id: int) -> Dictionary:
	"""Get metadata about a save file without fully loading it"""
	if not _save_exists(slot_id):
		return {}
	
	var file = File.new()
	var file_path = _get_save_path(slot_id)
	
	if file.open(file_path, File.READ) != OK:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var parse_result = JSON.parse(json_string)
	if parse_result.error != OK:
		return {}
	
	var save_data = parse_result.result
	
	# Extract metadata
	return {
		"slot_id": slot_id,
		"timestamp": save_data.get("timestamp", {}),
		"play_time": save_data.get("play_time", 0),
		"realm": save_data.get("cultivation", {}).get("current_realm", "Unknown"),
		"karma": save_data.get("story_state", {}).get("world_state", {}).get("karma", 0),
		"simulations": save_data.get("story_state", {}).get("world_state", {}).get("simulations_done", 0)
	}


func get_all_saves_info() -> Array:
	"""Get info for all save slots"""
	var saves = []
	
	for slot_id in range(MAX_SAVE_SLOTS):
		if _save_exists(slot_id):
			saves.append(get_save_info(slot_id))
	
	return saves


func _save_exists(slot_id: int) -> bool:
	"""Check if save file exists"""
	var file = File.new()
	return file.file_exists(_get_save_path(slot_id))


func _get_save_path(slot_id: int) -> String:
	"""Get full path for save file"""
	return SAVE_DIR + SAVE_FILE_PREFIX + str(slot_id) + SAVE_FILE_EXTENSION


func _ensure_save_directory():
	"""Create save directory if it doesn't exist"""
	var dir = Directory.new()
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
		print("[SaveLoad] Created save directory: " + SAVE_DIR)


# ==========================================
# AUTO-SAVE
# ==========================================

var auto_save_enabled: bool = true
var auto_save_interval: float = 300.0  # 5 minutes
var time_since_auto_save: float = 0.0


func _process(delta):
	"""Handle auto-save timer"""
	if not auto_save_enabled:
		return
	
	time_since_auto_save += delta
	
	if time_since_auto_save >= auto_save_interval:
		auto_save()
		time_since_auto_save = 0.0


func auto_save():
	"""Perform auto-save to dedicated slot"""
	var auto_save_slot = MAX_SAVE_SLOTS - 1  # Last slot reserved for auto-save
	save_game(auto_save_slot)
	print("[SaveLoad] Auto-save completed")


func set_auto_save_enabled(enabled: bool):
	"""Enable/disable auto-save"""
	auto_save_enabled = enabled


# ==========================================
# CLOUD SAVE INTEGRATION (PLACEHOLDER)
# ==========================================

func upload_save_to_cloud(slot_id: int):
	"""Placeholder for cloud save functionality"""
	push_warning("Cloud save not implemented")


func download_save_from_cloud(slot_id: int):
	"""Placeholder for cloud save functionality"""
	push_warning("Cloud save not implemented")


# ==========================================
# DEBUG
# ==========================================

func print_all_saves():
	"""Debug print all save files"""
	print("========== SAVE FILES ==========")
	var saves = get_all_saves_info()
	for save in saves:
		print("Slot %d: Realm=%s, Karma=%d, Time=%s" % [
			save["slot_id"],
			save["realm"],
			save["karma"],
			str(save["timestamp"])
		])
	print("================================")
