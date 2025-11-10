extends Node

# ==========================================
# STORY STATE MANAGER - CAUSAL NARRATIVE ENGINE
# ==========================================
# Tracks world state variables that determine all future events
# No parallel branches - single timeline with persistent consequences

# Core world state dictionary
var world_state = {
	"reputation": 0,           # Social standing among sects (-100 to 100)
	"karma": 0,                # Moral alignment, affects fate (-100 to 100)
	"destiny_thread": 0,       # Determines world coincidences (0 to 100)
	"sect_influence": {},      # Dictionary of sect_name: influence_value
	"faith_in_system": 100,    # Trust in the Villain Simulator (0 to 100)
	"realm_level": 1,          # Cultivation progress (1 to 7)
	"heart_sutra": "Heart Sutra of Silent Chaos",
	"abilities": [],           # List of unlocked passive/active powers
	"inventory": [],           # Items player possesses
	"insight_clues": [],       # Discovered insights about the world
	"simulations_done": 0,     # Total simulations run
	"alliances": [],           # Allied sects/factions
	"enemies": [],             # Enemy sects/factions
	"followers": [],           # NPCs who follow the player
	"world_events": [],        # Triggered world events (persistent)
	"npc_states": {},          # States of individual NPCs
	"locations_discovered": [], # Unlocked locations
	"secrets_revealed": [],    # Major plot revelations
}

# Event history for causal tracking
var event_history = []

# Signal declarations
signal world_state_changed(variable_name, old_value, new_value)
signal event_triggered(event_name, event_data)
signal karma_threshold_crossed(threshold_type)
signal realm_breakthrough(new_realm)

func _ready():
	print("StoryStateManager initialized")
	# Initialize default sect influences
	world_state["sect_influence"] = {
		"Talisman Sect": 0,
		"Moon Pavilion": 0,
		"Crimson Blood Sect": 0,
		"Heaven's Gate": 0,
		"Shadow Demon Cult": 0
	}

# ==========================================
# STATE MODIFICATION FUNCTIONS
# ==========================================

func modify_state(variable_name: String, delta: int):
	"""
	Modify a world state variable by a delta amount
	Triggers signals for listeners
	"""
	if not world_state.has(variable_name):
		push_error("Variable %s not found in world_state" % variable_name)
		return
	
	var old_value = world_state[variable_name]
	world_state[variable_name] += delta
	
	# Clamp certain values
	match variable_name:
		"reputation", "karma":
			world_state[variable_name] = clamp(world_state[variable_name], -100, 100)
		"destiny_thread", "faith_in_system":
			world_state[variable_name] = clamp(world_state[variable_name], 0, 100)
	
	emit_signal("world_state_changed", variable_name, old_value, world_state[variable_name])
	
	# Check for threshold events
	check_thresholds(variable_name)
	
	# Log the change
	log_event("state_change", {
		"variable": variable_name,
		"old_value": old_value,
		"new_value": world_state[variable_name],
		"delta": delta
	})

func set_state(variable_name: String, value):
	"""
	Directly set a world state variable
	"""
	if not world_state.has(variable_name):
		push_error("Variable %s not found in world_state" % variable_name)
		return
	
	var old_value = world_state[variable_name]
	world_state[variable_name] = value
	emit_signal("world_state_changed", variable_name, old_value, value)
	
	log_event("state_set", {
		"variable": variable_name,
		"old_value": old_value,
		"new_value": value
	})

func get_state(variable_name: String):
	"""
	Get a world state variable
	"""
	if world_state.has(variable_name):
		return world_state[variable_name]
	else:
		push_warning("Variable %s not found in world_state" % variable_name)
		return null

# ==========================================
# SECT INFLUENCE MANAGEMENT
# ==========================================

func modify_sect_influence(sect_name: String, delta: int):
	"""
	Modify influence with a specific sect
	"""
	if not world_state["sect_influence"].has(sect_name):
		world_state["sect_influence"][sect_name] = 0
	
	var old_value = world_state["sect_influence"][sect_name]
	world_state["sect_influence"][sect_name] += delta
	world_state["sect_influence"][sect_name] = clamp(world_state["sect_influence"][sect_name], -100, 100)
	
	emit_signal("world_state_changed", "sect_influence." + sect_name, old_value, world_state["sect_influence"][sect_name])
	
	# Check if this creates alliance or enmity
	if world_state["sect_influence"][sect_name] >= 70 and not sect_name in world_state["alliances"]:
		add_alliance(sect_name)
	elif world_state["sect_influence"][sect_name] <= -70 and not sect_name in world_state["enemies"]:
		add_enemy(sect_name)

func get_sect_influence(sect_name: String) -> int:
	"""
	Get influence with a specific sect
	"""
	if world_state["sect_influence"].has(sect_name):
		return world_state["sect_influence"][sect_name]
	return 0

# ==========================================
# RELATIONSHIP MANAGEMENT
# ==========================================

func add_alliance(faction_name: String):
	"""
	Add a faction to alliances
	"""
	if not faction_name in world_state["alliances"]:
		world_state["alliances"].append(faction_name)
		trigger_event("alliance_formed", {"faction": faction_name})

func remove_alliance(faction_name: String):
	"""
	Remove a faction from alliances
	"""
	if faction_name in world_state["alliances"]:
		world_state["alliances"].erase(faction_name)
		trigger_event("alliance_broken", {"faction": faction_name})

func add_enemy(faction_name: String):
	"""
	Add a faction to enemies
	"""
	if not faction_name in world_state["enemies"]:
		world_state["enemies"].append(faction_name)
		trigger_event("enemy_declared", {"faction": faction_name})
		
		# Remove from alliances if present
		if faction_name in world_state["alliances"]:
			remove_alliance(faction_name)

func add_follower(npc_name: String):
	"""
	Add an NPC follower
	"""
	if not npc_name in world_state["followers"]:
		world_state["followers"].append(npc_name)
		trigger_event("follower_joined", {"npc": npc_name})

# ==========================================
# INVENTORY & ITEMS
# ==========================================

func add_item(item_name: String, quantity: int = 1):
	"""
	Add item to inventory
	"""
	for item in world_state["inventory"]:
		if item["name"] == item_name:
			item["quantity"] += quantity
			return
	
	world_state["inventory"].append({
		"name": item_name,
		"quantity": quantity
	})

func remove_item(item_name: String, quantity: int = 1) -> bool:
	"""
	Remove item from inventory, returns true if successful
	"""
	for i in range(world_state["inventory"].size()):
		var item = world_state["inventory"][i]
		if item["name"] == item_name:
			if item["quantity"] >= quantity:
				item["quantity"] -= quantity
				if item["quantity"] <= 0:
					world_state["inventory"].remove(i)
				return true
	return false

func has_item(item_name: String) -> bool:
	"""
	Check if player has an item
	"""
	for item in world_state["inventory"]:
		if item["name"] == item_name and item["quantity"] > 0:
			return true
	return false

# ==========================================
# INSIGHT & CLUES
# ==========================================

func add_insight(insight_text: String):
	"""
	Add an insight clue
	"""
	if not insight_text in world_state["insight_clues"]:
		world_state["insight_clues"].append(insight_text)
		trigger_event("insight_gained", {"insight": insight_text})

func reveal_secret(secret_name: String):
	"""
	Reveal a major plot secret
	"""
	if not secret_name in world_state["secrets_revealed"]:
		world_state["secrets_revealed"].append(secret_name)
		trigger_event("secret_revealed", {"secret": secret_name})

# ==========================================
# THRESHOLD & TRIGGER SYSTEM
# ==========================================

func check_thresholds(variable_name: String):
	"""
	Check if any thresholds are crossed and trigger events
	"""
	match variable_name:
		"karma":
			var karma = world_state["karma"]
			if karma < -50 and not has_triggered_event("heavenly_tribulation"):
				trigger_event("heavenly_tribulation", {"type": "punishment"})
			elif karma > 50 and not has_triggered_event("heaven_gate_opens"):
				trigger_event("heaven_gate_opens", {})
			elif karma < -70 and not has_triggered_event("demonic_path_unlocked"):
				trigger_event("demonic_path_unlocked", {})
				emit_signal("karma_threshold_crossed", "demonic")
			elif karma > 70 and not has_triggered_event("immortal_path_unlocked"):
				trigger_event("immortal_path_unlocked", {})
				emit_signal("karma_threshold_crossed", "immortal")
		
		"faith_in_system":
			var faith = world_state["faith_in_system"]
			if faith <= 10 and not has_triggered_event("system_collapse_warning"):
				trigger_event("system_collapse_warning", {})
			elif faith <= 0 and not has_triggered_event("eternal_loop"):
				trigger_event("eternal_loop", {})

func trigger_event(event_name: String, event_data: Dictionary = {}):
	"""
	Trigger a world event
	"""
	var event = {
		"name": event_name,
		"data": event_data,
		"triggered": true
	}
	
	if not has_triggered_event(event_name):
		world_state["world_events"].append(event_name)
	
	emit_signal("event_triggered", event_name, event_data)
	log_event(event_name, event_data)

func has_triggered_event(event_name: String) -> bool:
	"""
	Check if an event has been triggered
	"""
	return event_name in world_state["world_events"]

# ==========================================
# CAUSAL RULE EVALUATION
# ==========================================

func evaluate_causal_rules():
	"""
	Evaluate all causal rules based on current world state
	Returns a list of possible events/paths that should be unlocked
	"""
	var unlocked_paths = []
	
	# Rule: High sect influence + alliance unlocks forbidden archive
	if get_sect_influence("Talisman Sect") > 70 and "Talisman Sect" in world_state["alliances"]:
		if not "Forbidden Archive" in world_state["locations_discovered"]:
			unlocked_paths.append("Forbidden Archive")
	
	# Rule: Low karma triggers demon encounters
	if world_state["karma"] < -30:
		unlocked_paths.append("DemonEncounter")
	
	# Rule: High destiny thread increases rare events
	if world_state["destiny_thread"] > 80:
		unlocked_paths.append("FateEvent")
	
	# Rule: High simulation count reveals system secrets
	if world_state["simulations_done"] > 10:
		unlocked_paths.append("SystemSecretHint")
	
	return unlocked_paths

# ==========================================
# NPC STATE MANAGEMENT
# ==========================================

func set_npc_state(npc_name: String, state_key: String, value):
	"""
	Set a state variable for an NPC
	"""
	if not world_state["npc_states"].has(npc_name):
		world_state["npc_states"][npc_name] = {}
	
	world_state["npc_states"][npc_name][state_key] = value

func get_npc_state(npc_name: String, state_key: String):
	"""
	Get a state variable for an NPC
	"""
	if world_state["npc_states"].has(npc_name):
		if world_state["npc_states"][npc_name].has(state_key):
			return world_state["npc_states"][npc_name][state_key]
	return null

# ==========================================
# EVENT LOGGING
# ==========================================

func log_event(event_type: String, event_data: Dictionary):
	"""
	Log an event to history for causality tracking
	"""
	event_history.append({
		"type": event_type,
		"data": event_data,
		"timestamp": OS.get_unix_time(),
		"world_state_snapshot": {
			"karma": world_state["karma"],
			"reputation": world_state["reputation"],
			"realm_level": world_state["realm_level"]
		}
	})

func get_event_history() -> Array:
	"""
	Get the full event history
	"""
	return event_history

func get_recent_events(count: int = 10) -> Array:
	"""
	Get the most recent events
	"""
	var recent = []
	var start_idx = max(0, event_history.size() - count)
	for i in range(start_idx, event_history.size()):
		recent.append(event_history[i])
	return recent

# ==========================================
# DEBUGGING & UTILITIES
# ==========================================

func print_world_state():
	"""
	Print current world state for debugging
	"""
	print("=== WORLD STATE ===")
	print("Karma: ", world_state["karma"])
	print("Reputation: ", world_state["reputation"])
	print("Destiny Thread: ", world_state["destiny_thread"])
	print("Faith in System: ", world_state["faith_in_system"])
	print("Realm Level: ", world_state["realm_level"])
	print("Heart Sutra: ", world_state["heart_sutra"])
	print("Simulations Done: ", world_state["simulations_done"])
	print("Alliances: ", world_state["alliances"])
	print("Enemies: ", world_state["enemies"])
	print("==================")

func reset_world_state():
	"""
	Reset world state to defaults (for new game)
	"""
	world_state = {
		"reputation": 0,
		"karma": 0,
		"destiny_thread": 0,
		"sect_influence": {
			"Talisman Sect": 0,
			"Moon Pavilion": 0,
			"Crimson Blood Sect": 0,
			"Heaven's Gate": 0,
			"Shadow Demon Cult": 0
		},
		"faith_in_system": 100,
		"realm_level": 1,
		"heart_sutra": "Heart Sutra of Silent Chaos",
		"abilities": [],
		"inventory": [],
		"insight_clues": [],
		"simulations_done": 0,
		"alliances": [],
		"enemies": [],
		"followers": [],
		"world_events": [],
		"npc_states": {},
		"locations_discovered": [],
		"secrets_revealed": [],
	}
	event_history = []
	print("World state reset to defaults")
