extends Node

# ==========================================
# STORY STATE MANAGER - CAUSAL NARRATIVE ENGINE
# Manages the single-thread world state that drives all narrative outcomes
# ==========================================

signal world_state_changed(variable_name, old_value, new_value)
signal event_triggered(event_name, context)
signal consequence_applied(consequence_data)

# Core World State Dictionary - The Single Source of Truth
var world_state = {
	"reputation": 0,           # Social standing among sects (-100 to 100)
	"karma": 0,                # Moral alignment, affects fate (-100 to 100)
	"destiny_thread": 0,       # Determines world coincidences (0 to 100)
	"sect_influences": {},     # Standing with each sect {sect_name: influence_value}
	"faith_in_system": 100,    # Trust in the Villain Simulator (0 to 100)
	"realm_level": 1,          # Cultivation realm progression
	"heart_sutra": "Default Sutra",
	"abilities": [],           # List of unlocked passive/active powers
	"inventory": [],           # Item storage
	"insight_clues": [],       # Narrative hints and discoveries
	"simulations_done": 0,     # Track simulation count
	"npcs_met": [],            # NPCs encountered
	"npcs_killed": [],         # NPCs killed (affects future events)
	"sects_destroyed": [],     # Sects eliminated
	"forbidden_knowledge": [], # Secret learnings
	"active_quests": [],       # Current objectives
	"completed_events": [],    # Story markers
	"world_flags": {}          # Boolean flags for specific story branches
}

# Causal Event Rules - Define cause-and-effect relationships
var causal_rules = []

# Event History - Track all major decisions and their timestamps
var event_history = []


func _ready():
	print("[StoryStateManager] Initialized causal narrative engine")
	_initialize_causal_rules()
	_initialize_default_sects()


# ==========================================
# WORLD STATE MANAGEMENT
# ==========================================

func modify_state(variable: String, delta, is_absolute: bool = false):
	"""
	Modify a world state variable and trigger causal events.
	variable: the key in world_state to modify
	delta: amount to add (or set if is_absolute)
	is_absolute: if true, sets the value directly instead of adding
	"""
	if not world_state.has(variable):
		push_error("Attempted to modify non-existent world state variable: " + variable)
		return
	
	var old_value = world_state[variable]
	
	if is_absolute:
		world_state[variable] = delta
	else:
		# Handle different types appropriately
		if typeof(old_value) == TYPE_INT or typeof(old_value) == TYPE_REAL:
			world_state[variable] += delta
		elif typeof(old_value) == TYPE_ARRAY:
			world_state[variable].append(delta)
		elif typeof(old_value) == TYPE_DICTIONARY:
			# For dictionaries, delta should be {key: value}
			if typeof(delta) == TYPE_DICTIONARY:
				for key in delta.keys():
					world_state[variable][key] = delta[key]
	
	var new_value = world_state[variable]
	
	# Emit signal for UI updates
	emit_signal("world_state_changed", variable, old_value, new_value)
	
	# Record event
	_record_event(variable, old_value, new_value)
	
	# Check and trigger causal rules
	_evaluate_causal_rules()
	
	print("[StoryState] %s: %s -> %s" % [variable, str(old_value), str(new_value)])


func get_state(variable: String):
	"""Get current value of a world state variable"""
	if world_state.has(variable):
		return world_state[variable]
	else:
		push_warning("Attempted to get non-existent variable: " + variable)
		return null


func set_flag(flag_name: String, value: bool):
	"""Set a boolean story flag"""
	world_state["world_flags"][flag_name] = value
	emit_signal("world_state_changed", "world_flags." + flag_name, !value, value)


func get_flag(flag_name: String) -> bool:
	"""Check if a story flag is set"""
	if world_state["world_flags"].has(flag_name):
		return world_state["world_flags"][flag_name]
	return false


# ==========================================
# SECT INFLUENCE MANAGEMENT
# ==========================================

func modify_sect_influence(sect_name: String, delta: int):
	"""Change standing with a specific sect"""
	if not world_state["sect_influences"].has(sect_name):
		world_state["sect_influences"][sect_name] = 0
	
	var old_value = world_state["sect_influences"][sect_name]
	world_state["sect_influences"][sect_name] = clamp(old_value + delta, -100, 100)
	
	var new_value = world_state["sect_influences"][sect_name]
	emit_signal("world_state_changed", "sect_influence." + sect_name, old_value, new_value)
	
	# Check for sect-specific events
	_check_sect_events(sect_name, new_value)


func get_sect_influence(sect_name: String) -> int:
	"""Get current influence with a sect"""
	if world_state["sect_influences"].has(sect_name):
		return world_state["sect_influences"][sect_name]
	return 0


# ==========================================
# CAUSAL RULE ENGINE
# ==========================================

func _initialize_causal_rules():
	"""Define all causal event rules"""
	causal_rules = [
		# Karma-based events
		{
			"name": "Heavenly Tribulation",
			"condition": func(): return world_state["karma"] < -50,
			"trigger_once": false,
			"cooldown": 10,
			"last_triggered": -999,
			"effect": func(): trigger_event("heavenly_tribulation_punishment")
		},
		{
			"name": "Celestial Blessing",
			"condition": func(): return world_state["karma"] > 50,
			"trigger_once": false,
			"cooldown": 15,
			"last_triggered": -999,
			"effect": func(): trigger_event("celestial_blessing")
		},
		
		# Faith system collapse
		{
			"name": "System Rebellion",
			"condition": func(): return world_state["faith_in_system"] < 20,
			"trigger_once": true,
			"effect": func(): trigger_event("system_rebellion")
		},
		
		# Reputation thresholds
		{
			"name": "Notorious Villain",
			"condition": func(): return world_state["reputation"] < -70,
			"trigger_once": true,
			"effect": func(): trigger_event("notorious_villain_status")
		},
		{
			"name": "Legendary Hero",
			"condition": func(): return world_state["reputation"] > 70,
			"trigger_once": true,
			"effect": func(): trigger_event("legendary_hero_status")
		},
		
		# Simulation count milestones
		{
			"name": "Simulation Addiction",
			"condition": func(): return world_state["simulations_done"] > 20,
			"trigger_once": true,
			"effect": func(): trigger_event("simulation_addiction")
		},
		
		# Destiny thread events
		{
			"name": "Fateful Encounter",
			"condition": func(): return world_state["destiny_thread"] > 70,
			"trigger_once": false,
			"cooldown": 20,
			"last_triggered": -999,
			"effect": func(): trigger_event("fateful_encounter")
		}
	]


func _evaluate_causal_rules():
	"""Check all causal rules and trigger matching events"""
	for rule in causal_rules:
		# Skip if already triggered and set to trigger once
		if rule.get("trigger_once", false) and rule.get("triggered", false):
			continue
		
		# Check cooldown
		if rule.has("cooldown"):
			var time_since_trigger = world_state["simulations_done"] - rule.get("last_triggered", -999)
			if time_since_trigger < rule["cooldown"]:
				continue
		
		# Evaluate condition
		if rule["condition"].call():
			print("[CausalRule] Triggered: " + rule["name"])
			rule["effect"].call()
			rule["triggered"] = true
			if rule.has("cooldown"):
				rule["last_triggered"] = world_state["simulations_done"]


func trigger_event(event_name: String, context: Dictionary = {}):
	"""Manually trigger a narrative event"""
	print("[StoryEvent] Triggering: " + event_name)
	
	# Add to completed events
	if not event_name in world_state["completed_events"]:
		world_state["completed_events"].append(event_name)
	
	emit_signal("event_triggered", event_name, context)
	
	# Apply automatic consequences based on event type
	_apply_event_consequences(event_name, context)


# ==========================================
# EVENT CONSEQUENCE SYSTEM
# ==========================================

func _apply_event_consequences(event_name: String, context: Dictionary):
	"""Apply world state changes based on events"""
	match event_name:
		"heavenly_tribulation_punishment":
			modify_state("karma", 10)  # Punishment reduces negative karma
			modify_state("faith_in_system", -15)
			emit_signal("consequence_applied", {
				"type": "tribulation",
				"message": "The Heavens strike down upon you. Your sins are recorded."
			})
		
		"celestial_blessing":
			modify_state("destiny_thread", 15)
			emit_signal("consequence_applied", {
				"type": "blessing",
				"message": "Celestial qi flows through you. Fortune smiles upon your path."
			})
		
		"system_rebellion":
			set_flag("system_has_rebelled", true)
			emit_signal("consequence_applied", {
				"type": "critical",
				"message": "The Villain Simulator awakens... it no longer obeys you."
			})
		
		"simulation_addiction":
			modify_state("faith_in_system", -30)
			set_flag("addicted_to_simulations", true)
			emit_signal("consequence_applied", {
				"type": "warning",
				"message": "You can no longer distinguish simulation from reality..."
			})


func _check_sect_events(sect_name: String, influence: int):
	"""Check for sect-specific threshold events"""
	if influence <= -80:
		trigger_event("sect_declares_vendetta", {"sect": sect_name})
	elif influence >= 80:
		trigger_event("sect_offers_alliance", {"sect": sect_name})


# ==========================================
# EVENT RECORDING & HISTORY
# ==========================================

func _record_event(variable: String, old_value, new_value):
	"""Record significant changes to event history"""
	var record = {
		"timestamp": OS.get_ticks_msec(),
		"simulation_count": world_state["simulations_done"],
		"variable": variable,
		"old_value": old_value,
		"new_value": new_value
	}
	event_history.append(record)
	
	# Keep history manageable (last 100 events)
	if event_history.size() > 100:
		event_history.pop_front()


func get_event_history(count: int = 10) -> Array:
	"""Get recent event history"""
	var start_idx = max(0, event_history.size() - count)
	return event_history.slice(start_idx, event_history.size() - 1)


# ==========================================
# INITIALIZATION
# ==========================================

func _initialize_default_sects():
	"""Set up starting sect relationships"""
	var sects = [
		"Talisman Sect",
		"Sword Saint Pavilion",
		"Moon Shadow Clan",
		"Demonic Blood Cult",
		"Heavenly Star Alliance"
	]
	
	for sect in sects:
		world_state["sect_influences"][sect] = 0


# ==========================================
# SAVE/LOAD INTERFACE
# ==========================================

func get_save_data() -> Dictionary:
	"""Return complete world state for saving"""
	return {
		"world_state": world_state.duplicate(true),
		"event_history": event_history.duplicate(true)
	}


func load_save_data(data: Dictionary):
	"""Restore world state from save data"""
	if data.has("world_state"):
		world_state = data["world_state"].duplicate(true)
	if data.has("event_history"):
		event_history = data["event_history"].duplicate(true)
	
	print("[StoryStateManager] Loaded saved state")
	emit_signal("world_state_changed", "full_load", null, world_state)


# ==========================================
# DEBUG & UTILITIES
# ==========================================

func reset_world_state():
	"""Reset to default state (for testing)"""
	world_state = {
		"reputation": 0,
		"karma": 0,
		"destiny_thread": 0,
		"sect_influences": {},
		"faith_in_system": 100,
		"realm_level": 1,
		"heart_sutra": "Default Sutra",
		"abilities": [],
		"inventory": [],
		"insight_clues": [],
		"simulations_done": 0,
		"npcs_met": [],
		"npcs_killed": [],
		"sects_destroyed": [],
		"forbidden_knowledge": [],
		"active_quests": [],
		"completed_events": [],
		"world_flags": {}
	}
	_initialize_default_sects()
	event_history.clear()
	print("[StoryStateManager] World state reset")


func print_world_state():
	"""Debug function to print current world state"""
	print("========== WORLD STATE ==========")
	for key in world_state.keys():
		print("%s: %s" % [key, str(world_state[key])])
	print("=================================")
