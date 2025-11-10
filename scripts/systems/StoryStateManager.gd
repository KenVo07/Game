extends Node

# Causal World State Manager
# Tracks all story variables and manages narrative branching

signal world_state_changed(variable, old_value, new_value)
signal event_triggered(event_name, params)
signal ending_reached(ending_type)

# Core world state dictionary
var world_state = {
	"reputation": 0,           # social standing among sects (-100 to 100)
	"karma": 0,                # moral alignment (-100 to 100)
	"destiny_thread": 0,       # fate influence (0 to 100)
	"sect_influence": {},      # dict of sect_name: influence_value
	"faith_in_system": 100,    # trust in Villain Simulator (0 to 100)
	"realm_level": 1,          # cultivation progress (1 to 7)
	"heart_sutra": "Heart Sutra of Silent Chaos",
	"abilities": [],           # list of unlocked abilities
	"inventory": [],           # items and artifacts
	"insight_clues": [],       # discovered secrets
	"simulations_done": 0,     # total simulations run
	"alliances": [],           # allied sects/factions
	"enemies": [],             # hostile factions
	"deaths_witnessed": 0,     # simulated deaths
	"npcs_met": [],            # encountered NPCs
	"locations_discovered": [], # explored areas
	"story_flags": {}          # custom event flags
}

# Causal event history
var event_history = []

# Event rules and triggers
var causal_rules = {}

func _ready():
	_initialize_causal_rules()
	_initialize_sects()

func _initialize_sects():
	world_state["sect_influence"] = {
		"Talisman Sect": 0,
		"Moon Pavilion": 0,
		"Blood Demon Sect": 0,
		"Imperial Guard": 0,
		"Hidden Masters": 0
	}

func _initialize_causal_rules():
	# Define cause-effect relationships
	causal_rules = {
		"karma_negative_tribulation": {
			"condition": func(): return world_state["karma"] < -50,
			"effect": "Heavenly Tribulation - Punishment Realm",
			"priority": 10
		},
		"karma_positive_ascension": {
			"condition": func(): return world_state["karma"] > 50 and world_state["realm_level"] >= 6,
			"effect": "Path to Heaven Gate Opens",
			"priority": 9
		},
		"sect_alliance_archive": {
			"condition": func(): return world_state["sect_influence"].get("Talisman Sect", 0) > 70 and "Talisman Sect" in world_state["alliances"],
			"effect": "Unlock Forbidden Archive",
			"priority": 5
		},
		"faith_collapse": {
			"condition": func(): return world_state["faith_in_system"] <= 0,
			"effect": "Eternal Loop Ending",
			"priority": 10
		},
		"demonic_transformation": {
			"condition": func(): return world_state["karma"] < -70 and world_state["faith_in_system"] > 50,
			"effect": "Become Demonic Overlord",
			"priority": 10
		}
	}

# Modify world state and trigger events
func modify_state(variable: String, delta, reason: String = ""):
	if not world_state.has(variable):
		push_error("Invalid world state variable: " + variable)
		return
	
	var old_value = world_state[variable]
	
	# Handle different types
	if typeof(old_value) == TYPE_INT or typeof(old_value) == TYPE_REAL:
		world_state[variable] = clamp(old_value + delta, -100, 100)
	elif typeof(old_value) == TYPE_ARRAY:
		if delta not in old_value:
			world_state[variable].append(delta)
	else:
		world_state[variable] = delta
	
	var new_value = world_state[variable]
	
	# Record event
	_record_event({
		"type": "state_change",
		"variable": variable,
		"old_value": old_value,
		"new_value": new_value,
		"reason": reason,
		"timestamp": OS.get_ticks_msec()
	})
	
	emit_signal("world_state_changed", variable, old_value, new_value)
	
	# Check for triggered events
	_check_causal_triggers()

# Modify sect influence
func modify_sect_influence(sect_name: String, delta: int, reason: String = ""):
	if not world_state["sect_influence"].has(sect_name):
		world_state["sect_influence"][sect_name] = 0
	
	var old_value = world_state["sect_influence"][sect_name]
	world_state["sect_influence"][sect_name] = clamp(old_value + delta, -100, 100)
	
	_record_event({
		"type": "sect_influence_change",
		"sect": sect_name,
		"old_value": old_value,
		"new_value": world_state["sect_influence"][sect_name],
		"reason": reason,
		"timestamp": OS.get_ticks_msec()
	})
	
	emit_signal("world_state_changed", "sect_influence", sect_name, world_state["sect_influence"][sect_name])
	_check_causal_triggers()

# Add alliance or enemy
func add_alliance(faction: String, reason: String = ""):
	if faction not in world_state["alliances"]:
		world_state["alliances"].append(faction)
		_record_event({
			"type": "alliance_formed",
			"faction": faction,
			"reason": reason,
			"timestamp": OS.get_ticks_msec()
		})
		_check_causal_triggers()

func add_enemy(faction: String, reason: String = ""):
	if faction not in world_state["enemies"]:
		world_state["enemies"].append(faction)
		_record_event({
			"type": "enemy_made",
			"faction": faction,
			"reason": reason,
			"timestamp": OS.get_ticks_msec()
		})
		_check_causal_triggers()

# Set story flag
func set_flag(flag_name: String, value = true):
	world_state["story_flags"][flag_name] = value
	_record_event({
		"type": "flag_set",
		"flag": flag_name,
		"value": value,
		"timestamp": OS.get_ticks_msec()
	})

# Check if flag is set
func has_flag(flag_name: String) -> bool:
	return world_state["story_flags"].get(flag_name, false)

# Record event in history
func _record_event(event: Dictionary):
	event_history.append(event)
	# Keep history manageable (last 500 events)
	if event_history.size() > 500:
		event_history.pop_front()

# Check all causal rules and trigger events
func _check_causal_triggers():
	var rules_sorted = causal_rules.keys()
	# Sort by priority (would need custom sort in real implementation)
	
	for rule_key in rules_sorted:
		var rule = causal_rules[rule_key]
		if rule["condition"].call():
			trigger_event(rule["effect"])

# Trigger a world event
func trigger_event(event_name: String, params: Dictionary = {}):
	print("EVENT TRIGGERED: ", event_name)
	
	_record_event({
		"type": "world_event",
		"event": event_name,
		"params": params,
		"timestamp": OS.get_ticks_msec()
	})
	
	emit_signal("event_triggered", event_name, params)
	
	# Check for endings
	_check_endings(event_name)

# Check if ending conditions are met
func _check_endings(event_name: String = ""):
	if event_name == "Eternal Loop Ending" or world_state["faith_in_system"] <= 0:
		emit_signal("ending_reached", "eternal_loop")
	elif event_name == "Become Demonic Overlord" or (world_state["karma"] < -70 and world_state["faith_in_system"] > 50):
		emit_signal("ending_reached", "demonic_overlord")
	elif world_state["karma"] > 50 and world_state["realm_level"] >= 6:
		emit_signal("ending_reached", "immortal_ascension")

# Get current world state snapshot
func get_world_state() -> Dictionary:
	return world_state.duplicate(true)

# Get event history
func get_event_history(count: int = 10) -> Array:
	var start = max(0, event_history.size() - count)
	return event_history.slice(start, event_history.size() - 1)

# Query state for conditions
func query_state(condition: String) -> bool:
	# Simple condition parser for dialogue/choices
	# Example: "karma > 20" or "has_alliance:Talisman Sect"
	
	if condition.begins_with("has_alliance:"):
		var faction = condition.substr(13)
		return faction in world_state["alliances"]
	
	if condition.begins_with("has_enemy:"):
		var faction = condition.substr(10)
		return faction in world_state["enemies"]
	
	if condition.begins_with("has_flag:"):
		var flag = condition.substr(9)
		return has_flag(flag)
	
	if condition.begins_with("realm_level"):
		# Parse "realm_level >= 3"
		var parts = condition.split(" ")
		if parts.size() == 3:
			var op = parts[1]
			var value = int(parts[2])
			match op:
				">=": return world_state["realm_level"] >= value
				"<=": return world_state["realm_level"] <= value
				">": return world_state["realm_level"] > value
				"<": return world_state["realm_level"] < value
				"==": return world_state["realm_level"] == value
	
	# Similar for karma, reputation, etc.
	for var_name in ["karma", "reputation", "destiny_thread", "faith_in_system"]:
		if condition.begins_with(var_name):
			var parts = condition.split(" ")
			if parts.size() == 3:
				var op = parts[1]
				var value = int(parts[2])
				match op:
					">=": return world_state[var_name] >= value
					"<=": return world_state[var_name] <= value
					">": return world_state[var_name] > value
					"<": return world_state[var_name] < value
					"==": return world_state[var_name] == value
	
	return false

# Save/Load world state
func save_to_dict() -> Dictionary:
	return {
		"world_state": world_state.duplicate(true),
		"event_history": event_history.duplicate(true)
	}

func load_from_dict(data: Dictionary):
	if data.has("world_state"):
		world_state = data["world_state"].duplicate(true)
	if data.has("event_history"):
		event_history = data["event_history"].duplicate(true)
	
	emit_signal("world_state_changed", "loaded", null, null)
