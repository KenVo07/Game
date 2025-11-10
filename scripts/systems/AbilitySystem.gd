extends Node

# ==========================================
# ABILITY SYSTEM
# Manages ability rolling, unlocking, and active ability effects
# ==========================================

signal ability_rolled(ability_name, rank)
signal ability_unlocked(ability_name, ability_type)
signal ability_activated(ability_name, effect_data)

# Ability Rank Tiers
const ABILITY_RANKS = ["White", "Green", "Blue", "Purple", "Gold"]

# Roll probabilities (must sum to 1.0)
const ROLL_PROBABILITIES = {
	"White": 0.50,   # 50%
	"Green": 0.25,   # 25%
	"Blue": 0.15,    # 15%
	"Purple": 0.08,  # 8%
	"Gold": 0.02     # 2%
}

# Ability Database
var ability_database = {
	# WHITE RANK (Common)
	"Quick Learner": {
		"rank": "White",
		"type": "passive",
		"description": "Gain 10% more cultivation progress from all sources.",
		"effect": {"cultivation_bonus": 0.1}
	},
	"Iron Body": {
		"rank": "White",
		"type": "passive",
		"description": "Increase vitality by 5.",
		"effect": {"stat_bonus": {"vitality": 5}}
	},
	"Keen Insight": {
		"rank": "White",
		"type": "passive",
		"description": "Occasionally reveal hidden quest hints.",
		"effect": {"insight_chance": 0.15}
	},
	
	# GREEN RANK (Uncommon)
	"Spirit Resonance": {
		"rank": "Green",
		"type": "passive",
		"description": "Increase spirit by 8 and qi capacity by 30.",
		"effect": {"stat_bonus": {"spirit": 8, "qi_capacity": 30}}
	},
	"Shadow Affinity": {
		"rank": "Green",
		"type": "passive",
		"description": "Gain bonus damage in darkness. Reduced karma loss from dark deeds.",
		"effect": {"shadow_damage": 1.2, "karma_reduction": 0.3}
	},
	"Talisman Prodigy": {
		"rank": "Green",
		"type": "passive",
		"description": "Talisman techniques cost 20% less qi.",
		"effect": {"talisman_cost_reduction": 0.2}
	},
	
	# BLUE RANK (Rare)
	"Echo of the Dead": {
		"rank": "Blue",
		"type": "passive",
		"description": "Gain cultivation progress when witnessing death. Can commune with spirits.",
		"effect": {"death_cultivation": 5, "spirit_communion": true}
	},
	"Mind Splitter": {
		"rank": "Blue",
		"type": "active",
		"description": "Split your consciousness temporarily - control simulation while playing.",
		"effect": {"dual_consciousness": true},
		"cooldown": 60.0
	},
	"Karmic Manipulator": {
		"rank": "Blue",
		"type": "active",
		"description": "Once per simulation, reverse a karma change.",
		"effect": {"karma_reversal": true},
		"cooldown": 120.0
	},
	
	# PURPLE RANK (Epic)
	"Talisman Whisperer": {
		"rank": "Purple",
		"type": "passive",
		"description": "Talismans have double effect. Can craft legendary talismans.",
		"effect": {"talisman_power": 2.0, "legendary_craft": true}
	},
	"Fate Weaver": {
		"rank": "Purple",
		"type": "passive",
		"description": "Destiny thread increases faster. Critical moments trigger fate interventions.",
		"effect": {"destiny_multiplier": 1.5, "fate_intervention": true}
	},
	"Immortal Insight": {
		"rank": "Purple",
		"type": "passive",
		"description": "See one possible future before making critical choices.",
		"effect": {"future_vision": true}
	},
	
	# GOLD RANK (Legendary)
	"Naturally Supreme": {
		"rank": "Gold",
		"type": "passive",
		"description": "Double all stat gains. Breakthrough requirements reduced by 30%.",
		"effect": {"stat_multiplier": 2.0, "breakthrough_reduction": 0.3}
	},
	"System Override": {
		"rank": "Gold",
		"type": "active",
		"description": "Force a specific outcome in the next simulation.",
		"effect": {"simulation_control": true},
		"cooldown": 300.0
	},
	"Eternal Regression": {
		"rank": "Gold",
		"type": "active",
		"description": "Death doesn't end the game - restart from last checkpoint with memories intact.",
		"effect": {"death_immunity": true, "memory_retention": true}
	}
}

# Player's unlocked abilities
var unlocked_abilities: Array = []
var active_abilities: Array = []
var passive_abilities: Array = []

# Cooldown tracking
var ability_cooldowns: Dictionary = {}

# Technique abilities (unlocked via sutras)
var technique_abilities: Array = []


func _ready():
	print("[AbilitySystem] Initialized")


# ==========================================
# ABILITY ROLLING (PRE-SIMULATION)
# ==========================================

func roll_ability_rank() -> String:
	"""Roll for ability rank based on probabilities"""
	var roll = randf()
	var cumulative = 0.0
	
	for rank in ABILITY_RANKS:
		cumulative += ROLL_PROBABILITIES[rank]
		if roll <= cumulative:
			return rank
	
	return "White"  # Fallback


func roll_random_ability() -> Dictionary:
	"""Roll a random ability (rank + specific ability)"""
	var rank = roll_ability_rank()
	
	# Get all abilities of this rank
	var rank_abilities = []
	for ability_name in ability_database.keys():
		if ability_database[ability_name]["rank"] == rank:
			rank_abilities.append(ability_name)
	
	if rank_abilities.empty():
		push_error("No abilities found for rank: " + rank)
		return {}
	
	# Pick random ability from this rank
	var ability_name = rank_abilities[randi() % rank_abilities.size()]
	var ability_data = ability_database[ability_name].duplicate()
	ability_data["name"] = ability_name
	
	emit_signal("ability_rolled", ability_name, rank)
	print("[AbilitySystem] Rolled: %s (%s rank)" % [ability_name, rank])
	
	return ability_data


func roll_ability_by_rank(rank: String) -> Dictionary:
	"""Roll an ability of specific rank (for testing/events)"""
	var rank_abilities = []
	for ability_name in ability_database.keys():
		if ability_database[ability_name]["rank"] == rank:
			rank_abilities.append(ability_name)
	
	if rank_abilities.empty():
		return {}
	
	var ability_name = rank_abilities[randi() % rank_abilities.size()]
	var ability_data = ability_database[ability_name].duplicate()
	ability_data["name"] = ability_name
	
	return ability_data


# ==========================================
# ABILITY MANAGEMENT
# ==========================================

func unlock_ability(ability_name: String) -> bool:
	"""Unlock an ability permanently"""
	if not ability_database.has(ability_name):
		push_error("Ability not found: " + ability_name)
		return false
	
	if ability_name in unlocked_abilities:
		print("[AbilitySystem] Already unlocked: " + ability_name)
		return false
	
	unlocked_abilities.append(ability_name)
	var ability_data = ability_database[ability_name]
	
	# Categorize by type
	if ability_data["type"] == "passive":
		passive_abilities.append(ability_name)
		_apply_passive_effects(ability_name, ability_data)
	else:
		active_abilities.append(ability_name)
	
	# Add to story state
	StoryStateManager.modify_state("abilities", ability_name)
	
	emit_signal("ability_unlocked", ability_name, ability_data["type"])
	print("[AbilitySystem] Unlocked: %s (%s)" % [ability_name, ability_data["type"]])
	
	return true


func unlock_technique_ability(technique_name: String, source_sutra: String):
	"""Unlock technique ability from sutra"""
	if not technique_name in technique_abilities:
		technique_abilities.append(technique_name)
		print("[AbilitySystem] Unlocked technique: %s (from %s)" % [technique_name, source_sutra])


func has_ability(ability_name: String) -> bool:
	"""Check if ability is unlocked"""
	return ability_name in unlocked_abilities


func get_unlocked_abilities() -> Array:
	"""Get all unlocked abilities"""
	return unlocked_abilities.duplicate()


# ==========================================
# PASSIVE ABILITY EFFECTS
# ==========================================

func _apply_passive_effects(ability_name: String, ability_data: Dictionary):
	"""Apply passive ability bonuses immediately"""
	var effect = ability_data.get("effect", {})
	
	# Stat bonuses
	if effect.has("stat_bonus"):
		for stat in effect["stat_bonus"].keys():
			CultivationSystem.modify_stat(stat, effect["stat_bonus"][stat])
	
	# Cultivation bonus
	if effect.has("cultivation_bonus"):
		# This would be applied in CultivationSystem when calculating progress
		pass
	
	# Special effects are handled by checking has_ability() in relevant systems
	print("[AbilitySystem] Applied passive effects for: " + ability_name)


func get_cultivation_multiplier() -> float:
	"""Calculate total cultivation multiplier from abilities"""
	var multiplier = 1.0
	
	for ability_name in passive_abilities:
		var ability_data = ability_database[ability_name]
		var effect = ability_data.get("effect", {})
		
		if effect.has("cultivation_bonus"):
			multiplier += effect["cultivation_bonus"]
	
	return multiplier


func get_stat_multiplier() -> float:
	"""Get stat gain multiplier (for Naturally Supreme, etc)"""
	var multiplier = 1.0
	
	if has_ability("Naturally Supreme"):
		multiplier = 2.0
	
	return multiplier


# ==========================================
# ACTIVE ABILITY USAGE
# ==========================================

func can_use_ability(ability_name: String) -> bool:
	"""Check if active ability can be used"""
	if not ability_name in active_abilities:
		return false
	
	# Check cooldown
	if ability_cooldowns.has(ability_name):
		if OS.get_ticks_msec() < ability_cooldowns[ability_name]:
			return false
	
	return true


func use_ability(ability_name: String, context: Dictionary = {}) -> bool:
	"""Use an active ability"""
	if not can_use_ability(ability_name):
		print("[AbilitySystem] Cannot use ability: " + ability_name)
		return false
	
	var ability_data = ability_database[ability_name]
	var effect = ability_data.get("effect", {})
	
	# Apply cooldown
	if ability_data.has("cooldown"):
		var cooldown_end = OS.get_ticks_msec() + (ability_data["cooldown"] * 1000)
		ability_cooldowns[ability_name] = cooldown_end
	
	# Execute ability effect
	_execute_ability_effect(ability_name, effect, context)
	
	emit_signal("ability_activated", ability_name, effect)
	print("[AbilitySystem] Activated: " + ability_name)
	
	return true


func _execute_ability_effect(ability_name: String, effect: Dictionary, context: Dictionary):
	"""Execute the effect of an active ability"""
	match ability_name:
		"Mind Splitter":
			# Allow dual consciousness - this would be handled by SimulationManager
			context["dual_consciousness"] = true
		
		"Karmic Manipulator":
			# Reverse last karma change
			var history = StoryStateManager.get_event_history(1)
			if not history.empty():
				var last_event = history[0]
				if last_event["variable"] == "karma":
					var delta = last_event["old_value"] - last_event["new_value"]
					StoryStateManager.modify_state("karma", delta)
					print("[AbilitySystem] Reversed karma change")
		
		"System Override":
			# This would be handled in SimulationManager
			context["force_outcome"] = true
		
		"Eternal Regression":
			# Death immunity - handled by game manager
			context["death_immunity"] = true


func get_ability_cooldown(ability_name: String) -> float:
	"""Get remaining cooldown time in seconds"""
	if not ability_cooldowns.has(ability_name):
		return 0.0
	
	var time_remaining = (ability_cooldowns[ability_name] - OS.get_ticks_msec()) / 1000.0
	return max(0.0, time_remaining)


# ==========================================
# SPECIAL ABILITY CHECKS
# ==========================================

func has_future_vision() -> bool:
	"""Check if player has future sight ability"""
	return has_ability("Immortal Insight")


func has_fate_weaver() -> bool:
	"""Check if player has fate weaving"""
	return has_ability("Fate Weaver")


func has_death_immunity() -> bool:
	"""Check if player has eternal regression"""
	return has_ability("Eternal Regression")


func get_talisman_power_multiplier() -> float:
	"""Get talisman power multiplier"""
	if has_ability("Talisman Whisperer"):
		return 2.0
	return 1.0


func get_talisman_cost_reduction() -> float:
	"""Get talisman qi cost reduction"""
	var reduction = 0.0
	
	if has_ability("Talisman Prodigy"):
		reduction += 0.2
	
	return reduction


# ==========================================
# SAVE/LOAD
# ==========================================

func get_save_data() -> Dictionary:
	"""Return ability data for saving"""
	return {
		"unlocked_abilities": unlocked_abilities.duplicate(),
		"active_abilities": active_abilities.duplicate(),
		"passive_abilities": passive_abilities.duplicate(),
		"technique_abilities": technique_abilities.duplicate(),
		"ability_cooldowns": ability_cooldowns.duplicate()
	}


func load_save_data(data: Dictionary):
	"""Restore ability data from save"""
	unlocked_abilities = data.get("unlocked_abilities", [])
	active_abilities = data.get("active_abilities", [])
	passive_abilities = data.get("passive_abilities", [])
	technique_abilities = data.get("technique_abilities", [])
	ability_cooldowns = data.get("ability_cooldowns", {})
	
	# Reapply passive effects
	for ability_name in passive_abilities:
		if ability_database.has(ability_name):
			_apply_passive_effects(ability_name, ability_database[ability_name])
	
	print("[AbilitySystem] Loaded saved data")


# ==========================================
# DEBUG
# ==========================================

func print_abilities():
	"""Debug print all abilities"""
	print("========== ABILITIES ==========")
	print("Unlocked: %s" % str(unlocked_abilities))
	print("Active: %s" % str(active_abilities))
	print("Passive: %s" % str(passive_abilities))
	print("Techniques: %s" % str(technique_abilities))
	print("===============================")


func unlock_random_ability():
	"""Debug - unlock random ability"""
	var all_abilities = ability_database.keys()
	var ability_name = all_abilities[randi() % all_abilities.size()]
	unlock_ability(ability_name)
