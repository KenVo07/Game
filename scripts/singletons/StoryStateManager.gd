extends Node

# ==========================================
# STORY STATE MANAGER - CAUSAL NARRATIVE ENGINE
# ==========================================
# Manages the global world state that determines all narrative outcomes.
# Every decision, action, and event modifies these variables.
# Future events query these to determine what happens next.

signal world_state_changed(variable_name, old_value, new_value)
signal causal_event_triggered(event_name, data)

var world_state = {
	"reputation": 0,          # Social standing among sects
	"karma": 0,               # Moral alignment, affects fate
	"destiny_thread": 0,      # Determines world coincidences
	"sect_influence": {},     # Standing with each sect
	"faith_in_system": 100,   # Trust in the Villain Simulator
	"realm_level": 1,         # Cultivation progress
	"heart_sutra": "Default Sutra",
	"abilities": [],          # List of unlocked passive/active powers
	"inventory": [],
	"insight_clues": [],
	"simulations_done": 0,
	"death_count": 0,
	"alliances": [],
	"enemies": [],
	"destroyed_artifacts": [],
	"saved_npcs": [],
	"killed_npcs": []
}

# Causal rules - conditions that trigger world events
var causal_rules = []

func _ready():
	_initialize_causal_rules()
	print("[StoryStateManager] Initialized with causal narrative engine")

func _initialize_causal_rules():
	"""Initialize the causal event rules"""
	causal_rules = [
		{
			"name": "Heavenly Tribulation",
			"condition": func(): return world_state["karma"] < -50,
			"effect": func(): trigger_event("heavenly_tribulation")
		},
		{
			"name": "Demonic Path Unlock",
			"condition": func(): return world_state["karma"] < -30 and world_state["death_count"] > 5,
			"effect": func(): trigger_event("demonic_path_unlock")
		},
		{
			"name": "Righteous Path Unlock",
			"condition": func(): return world_state["karma"] > 50,
			"effect": func(): trigger_event("righteous_path_unlock")
		},
		{
			"name": "Sect Revenge Raid",
			"condition": func(): return world_state.get("sect_influence", {}).values().min() < -50 if world_state.get("sect_influence", {}).size() > 0 else false,
			"effect": func(): trigger_event("sect_revenge_raid")
		},
		{
			"name": "System Collapse",
			"condition": func(): return world_state["faith_in_system"] < 10,
			"effect": func(): trigger_event("system_collapse")
		},
		{
			"name": "Forbidden Archive Access",
			"condition": func(): return world_state.get("sect_influence", {}).get("Talisman Sect", 0) > 70 and "Talisman Sect" in world_state["alliances"],
			"effect": func(): trigger_event("forbidden_archive_unlock")
		}
	]

func modify_state(variable_name: String, delta_value):
	"""Modify a world state variable and trigger causal checks"""
	if not variable_name in world_state:
		push_error("Attempted to modify non-existent world state variable: " + variable_name)
		return
	
	var old_value = world_state[variable_name]
	
	# Handle different types
	if typeof(old_value) == TYPE_INT or typeof(old_value) == TYPE_REAL:
		world_state[variable_name] += delta_value
	elif typeof(old_value) == TYPE_ARRAY:
		if not delta_value in old_value:
			world_state[variable_name].append(delta_value)
	elif typeof(old_value) == TYPE_DICTIONARY:
		if typeof(delta_value) == TYPE_DICTIONARY:
			for key in delta_value.keys():
				if key in world_state[variable_name]:
					world_state[variable_name][key] += delta_value[key]
				else:
					world_state[variable_name][key] = delta_value[key]
	else:
		world_state[variable_name] = delta_value
	
	emit_signal("world_state_changed", variable_name, old_value, world_state[variable_name])
	
	# Check causal rules after state change
	_check_causal_rules()
	
	print("[StoryStateManager] %s changed: %s -> %s" % [variable_name, str(old_value), str(world_state[variable_name])])

func set_state(variable_name: String, value):
	"""Directly set a world state variable"""
	if not variable_name in world_state:
		push_error("Attempted to set non-existent world state variable: " + variable_name)
		return
	
	var old_value = world_state[variable_name]
	world_state[variable_name] = value
	
	emit_signal("world_state_changed", variable_name, old_value, value)
	_check_causal_rules()
	
	print("[StoryStateManager] %s set: %s -> %s" % [variable_name, str(old_value), str(value)])

func get_state(variable_name: String):
	"""Get a world state variable"""
	return world_state.get(variable_name, null)

func _check_causal_rules():
	"""Check all causal rules and trigger events if conditions are met"""
	for rule in causal_rules:
		if rule["condition"].call():
			rule["effect"].call()

func trigger_event(event_name: String, data: Dictionary = {}):
	"""Trigger a causal event"""
	print("[StoryStateManager] CAUSAL EVENT TRIGGERED: " + event_name)
	emit_signal("causal_event_triggered", event_name, data)
	
	# Apply event-specific effects
	match event_name:
		"heavenly_tribulation":
			_handle_heavenly_tribulation()
		"sect_revenge_raid":
			_handle_sect_revenge()
		"demonic_path_unlock":
			_handle_demonic_path()
		"righteous_path_unlock":
			_handle_righteous_path()
		"system_collapse":
			_handle_system_collapse()
		"forbidden_archive_unlock":
			_handle_forbidden_archive()

func _handle_heavenly_tribulation():
	"""Player faces divine punishment for evil deeds"""
	print("[StoryStateManager] The Heavens strike with tribulation lightning!")
	# This would spawn a special encounter in the world

func _handle_sect_revenge():
	"""A sect sends cultivators to eliminate the player"""
	print("[StoryStateManager] A sect mobilizes against you!")
	# This would trigger hostile NPCs to spawn

func _handle_demonic_path():
	"""Unlock demonic cultivation techniques"""
	print("[StoryStateManager] The Demonic Path opens before you...")
	world_state["insight_clues"].append("Demonic Cultivation Manual location revealed")

func _handle_righteous_path():
	"""Unlock righteous cultivation techniques"""
	print("[StoryStateManager] The Heavenly Path acknowledges your virtue.")
	world_state["insight_clues"].append("Heaven's Gate path revealed")

func _handle_system_collapse():
	"""The Villain Simulator begins to malfunction"""
	print("[StoryStateManager] The Simulator fractures... reality distorts...")
	world_state["insight_clues"].append("Simulator Origin fragment found")

func _handle_forbidden_archive():
	"""Gain access to secret knowledge"""
	print("[StoryStateManager] The Forbidden Archive doors unlock...")
	world_state["insight_clues"].append("Forbidden Archive coordinates obtained")

func apply_causal_action(action: Dictionary):
	"""
	Apply a complex action with multiple state changes
	Example: {
		"karma": -15,
		"sect_influence": {"Talisman Sect": -30},
		"enemies": "Elder Feng",
		"destroyed_artifacts": "Sacred Talisman"
	}
	"""
	for key in action.keys():
		if key in world_state:
			modify_state(key, action[key])

func get_narrative_context() -> Dictionary:
	"""Return current world state for AI/narrative generation"""
	return {
		"karma_state": _get_karma_description(),
		"realm": world_state["realm_level"],
		"reputation": world_state["reputation"],
		"faith": world_state["faith_in_system"],
		"major_actions": {
			"deaths": world_state["death_count"],
			"simulations": world_state["simulations_done"],
			"alliances": world_state["alliances"],
			"enemies": world_state["enemies"]
		}
	}

func _get_karma_description() -> String:
	"""Convert karma value to narrative description"""
	var karma = world_state["karma"]
	if karma < -70:
		return "Abyssal Demon"
	elif karma < -30:
		return "Demonic Path"
	elif karma < 0:
		return "Morally Gray"
	elif karma < 30:
		return "Righteous"
	elif karma < 70:
		return "Virtuous"
	else:
		return "Heavenly Saint"

func reset_state():
	"""Reset world state (for new game)"""
	world_state = {
		"reputation": 0,
		"karma": 0,
		"destiny_thread": 0,
		"sect_influence": {},
		"faith_in_system": 100,
		"realm_level": 1,
		"heart_sutra": "Default Sutra",
		"abilities": [],
		"inventory": [],
		"insight_clues": [],
		"simulations_done": 0,
		"death_count": 0,
		"alliances": [],
		"enemies": [],
		"destroyed_artifacts": [],
		"saved_npcs": [],
		"killed_npcs": []
	}
	print("[StoryStateManager] World state reset")

func load_state(state_data: Dictionary):
	"""Load world state from saved data"""
	world_state = state_data
	_check_causal_rules()
	print("[StoryStateManager] World state loaded")
