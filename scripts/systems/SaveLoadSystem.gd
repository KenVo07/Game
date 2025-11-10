extends Node

# ==========================================
# SAVE/LOAD SYSTEM
# ==========================================
# Manages game saves and loads

const SAVE_DIR = "user://saves/"
const SAVE_EXTENSION = ".json"
const MAX_SAVE_SLOTS = 10

# Current save slot
var current_save_slot = -1

func _ready():
	print("SaveLoadSystem initialized")
	ensure_save_directory()

func ensure_save_directory():
	"""
	Ensure save directory exists
	"""
	var dir = Directory.new()
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
		print("Created save directory: ", SAVE_DIR)

# ==========================================
# SAVE FUNCTIONS
# ==========================================

func save_game(slot: int = -1) -> bool:
	"""
	Save the current game state
	If slot is -1, uses current_save_slot
	"""
	if slot == -1:
		slot = current_save_slot
	
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		push_error("Invalid save slot: " + str(slot))
		return false
	
	var save_data = collect_save_data()
	var file_path = get_save_path(slot)
	
	var file = File.new()
	var error = file.open(file_path, File.WRITE)
	
	if error != OK:
		push_error("Failed to open save file: " + file_path)
		return false
	
	file.store_line(to_json(save_data))
	file.close()
	
	current_save_slot = slot
	print("Game saved to slot ", slot)
	return true

func collect_save_data() -> Dictionary:
	"""
	Collect all data to be saved
	"""
	var save_data = {
		"version": "1.0",
		"timestamp": OS.get_unix_time(),
		"play_time": 0,  # Could track this
		
		# Core systems
		"world_state": StoryStateManager.world_state.duplicate(),
		"event_history": StoryStateManager.get_event_history(),
		
		"cultivation": CultivationSystem.get_save_data(),
		"abilities": AbilitySystem.get_save_data(),
		"simulation": SimulationManager.get_save_data(),
		"audio": AudioManager.get_save_data(),
		
		# Additional data
		"current_scene": get_tree().current_scene.filename if get_tree().current_scene else "",
		"player_position": Vector2.ZERO,  # Would be set by player
	}
	
	return save_data

func quick_save() -> bool:
	"""
	Quick save to most recent slot (or slot 0)
	"""
	var slot = current_save_slot if current_save_slot >= 0 else 0
	return save_game(slot)

func auto_save() -> bool:
	"""
	Auto save to a dedicated auto-save slot
	"""
	var auto_save_slot = MAX_SAVE_SLOTS - 1  # Last slot is auto-save
	return save_game(auto_save_slot)

# ==========================================
# LOAD FUNCTIONS
# ==========================================

func load_game(slot: int) -> bool:
	"""
	Load a game from a save slot
	"""
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		push_error("Invalid save slot: " + str(slot))
		return false
	
	var file_path = get_save_path(slot)
	
	if not file_exists(file_path):
		push_warning("Save file does not exist: " + file_path)
		return false
	
	var file = File.new()
	var error = file.open(file_path, File.READ)
	
	if error != OK:
		push_error("Failed to open save file: " + file_path)
		return false
	
	var json_string = file.get_line()
	file.close()
	
	var parse_result = JSON.parse(json_string)
	
	if parse_result.error != OK:
		push_error("Failed to parse save file: " + parse_result.error_string)
		return false
	
	var save_data = parse_result.result
	apply_save_data(save_data)
	
	current_save_slot = slot
	print("Game loaded from slot ", slot)
	return true

func apply_save_data(data: Dictionary):
	"""
	Apply loaded save data to all systems
	"""
	# Restore world state
	if data.has("world_state"):
		StoryStateManager.world_state = data["world_state"]
	
	if data.has("event_history"):
		StoryStateManager.event_history = data["event_history"]
	
	# Restore cultivation
	if data.has("cultivation"):
		CultivationSystem.load_save_data(data["cultivation"])
	
	# Restore abilities
	if data.has("abilities"):
		AbilitySystem.load_save_data(data["abilities"])
	
	# Restore simulation
	if data.has("simulation"):
		SimulationManager.load_save_data(data["simulation"])
	
	# Restore audio settings
	if data.has("audio"):
		AudioManager.load_save_data(data["audio"])
	
	print("Save data applied to all systems")

# ==========================================
# SAVE MANAGEMENT
# ==========================================

func delete_save(slot: int) -> bool:
	"""
	Delete a save file
	"""
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		push_error("Invalid save slot: " + str(slot))
		return false
	
	var file_path = get_save_path(slot)
	
	if not file_exists(file_path):
		push_warning("Save file does not exist: " + file_path)
		return false
	
	var dir = Directory.new()
	var error = dir.remove(file_path)
	
	if error != OK:
		push_error("Failed to delete save file: " + file_path)
		return false
	
	print("Deleted save slot ", slot)
	return true

func get_save_info(slot: int) -> Dictionary:
	"""
	Get information about a save without loading it
	"""
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		return {}
	
	var file_path = get_save_path(slot)
	
	if not file_exists(file_path):
		return {}
	
	var file = File.new()
	var error = file.open(file_path, File.READ)
	
	if error != OK:
		return {}
	
	var json_string = file.get_line()
	file.close()
	
	var parse_result = JSON.parse(json_string)
	
	if parse_result.error != OK:
		return {}
	
	var save_data = parse_result.result
	
	# Extract key info
	var info = {
		"slot": slot,
		"exists": true,
		"timestamp": save_data.get("timestamp", 0),
		"realm": save_data.get("cultivation", {}).get("current_realm", "Unknown"),
		"karma": save_data.get("world_state", {}).get("karma", 0),
		"simulations": save_data.get("world_state", {}).get("simulations_done", 0)
	}
	
	return info

func get_all_saves() -> Array:
	"""
	Get information about all save slots
	"""
	var saves = []
	
	for i in range(MAX_SAVE_SLOTS):
		var info = get_save_info(i)
		if not info.empty():
			saves.append(info)
		else:
			saves.append({
				"slot": i,
				"exists": false
			})
	
	return saves

func file_exists(path: String) -> bool:
	"""
	Check if a file exists
	"""
	var file = File.new()
	return file.file_exists(path)

func get_save_path(slot: int) -> String:
	"""
	Get the file path for a save slot
	"""
	return SAVE_DIR + "save_" + str(slot) + SAVE_EXTENSION

# ==========================================
# NEW GAME
# ==========================================

func new_game():
	"""
	Start a new game (reset all systems)
	"""
	print("Starting new game...")
	
	# Reset all systems
	StoryStateManager.reset_world_state()
	
	# Reset cultivation - handled internally by loading default data
	CultivationSystem.load_save_data({
		"current_realm": "Mortal",
		"current_realm_index": 0,
		"realm_progress": 0.0,
		"heart_sutra": "Heart Sutra of Silent Chaos",
		"technique_sutras": [],
		"stats": {
			"strength": 10,
			"spirit": 10,
			"qi": 100,
			"max_qi": 100,
			"vitality": 100,
			"max_vitality": 100,
			"cultivation_speed": 1.0,
			"comprehension": 10
		}
	})
	
	# Reset abilities
	AbilitySystem.load_save_data({
		"unlocked_abilities": [],
		"unlocked_techniques": [],
		"active_ability_cooldowns": {}
	})
	
	# Reset simulation
	SimulationManager.load_save_data({
		"simulation_logs": [],
		"current_simulation": {}
	})
	
	current_save_slot = -1
	
	print("New game initialized")

# ==========================================
# UTILITIES
# ==========================================

func format_timestamp(timestamp: int) -> String:
	"""
	Format a unix timestamp to readable string
	"""
	var datetime = OS.get_datetime_from_unix_time(timestamp)
	return "%04d-%02d-%02d %02d:%02d" % [
		datetime.year,
		datetime.month,
		datetime.day,
		datetime.hour,
		datetime.minute
	]

func get_save_size(slot: int) -> int:
	"""
	Get the size of a save file in bytes
	"""
	var file_path = get_save_path(slot)
	
	if not file_exists(file_path):
		return 0
	
	var file = File.new()
	file.open(file_path, File.READ)
	var size = file.get_len()
	file.close()
	
	return size

# ==========================================
# DEBUGGING
# ==========================================

func print_save_info():
	"""
	Print information about all saves
	"""
	print("=== SAVE SLOTS ===")
	var saves = get_all_saves()
	for save in saves:
		if save["exists"]:
			var time_str = format_timestamp(save["timestamp"])
			print("Slot ", save["slot"], ": ", time_str, " | Realm: ", save["realm"], " | Karma: ", save["karma"])
		else:
			print("Slot ", save["slot"], ": Empty")
	print("==================")
