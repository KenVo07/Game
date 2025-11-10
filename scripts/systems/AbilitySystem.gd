extends Node

# Ability Roll and Management System
# Handles random ability generation for simulations

signal ability_rolled(ability_name, rank)
signal ability_unlocked(ability_name)

# Ability ranks
const ABILITY_RANKS = ["White", "Green", "Blue", "Purple", "Gold"]

# Ability pool organized by rank
var ability_pool = {
	"White": [
		{"name": "Quick Learner", "description": "Gain +5% cultivation speed", "effect": {"cultivation_speed": 1.05}},
		{"name": "Iron Body", "description": "+10 Vitality", "effect": {"vitality": 10}},
		{"name": "Sharp Mind", "description": "+5 Comprehension", "effect": {"comprehension": 5}},
		{"name": "Keen Eye", "description": "Better item detection", "effect": {"detection_range": 1.2}}
	],
	"Green": [
		{"name": "Spirit Resonance", "description": "+15 Spirit, +50 Qi Capacity", "effect": {"spirit": 15, "qi_capacity": 50}},
		{"name": "Natural Fighter", "description": "+15 Strength, improved combat", "effect": {"strength": 15, "damage_mult": 1.1}},
		{"name": "Lucky Star", "description": "+10 Luck, better loot", "effect": {"luck": 10, "loot_mult": 1.2}},
		{"name": "Dao Insight", "description": "+10 Comprehension, faster breakthroughs", "effect": {"comprehension": 10, "breakthrough_speed": 1.2}}
	],
	"Blue": [
		{"name": "Echo of the Dead", "description": "Gain insights from slain enemies", "effect": {"soul_harvest": true}},
		{"name": "Mind Splitter", "description": "Can run multiple thought processes", "effect": {"parallel_thinking": true, "comprehension": 20}},
		{"name": "Phantom Form", "description": "Dash becomes invulnerable phase", "effect": {"phase_dash": true}},
		{"name": "Qi Regeneration", "description": "Passively restore Qi in combat", "effect": {"qi_regen": 5}}
	],
	"Purple": [
		{"name": "Talisman Whisperer", "description": "Talismans cost 50% less Qi and deal double damage", "effect": {"talisman_cost": 0.5, "talisman_damage": 2.0}},
		{"name": "Fate Touched", "description": "Destined encounters, +20 Destiny Thread", "effect": {"destiny_thread": 20, "special_events": true}},
		{"name": "Demon Heart", "description": "Gain power from negative karma", "effect": {"demon_power": true, "strength_per_negative_karma": 0.5}},
		{"name": "Heavenly Blessed", "description": "Tribulations become easier, +30 to all stats", "effect": {"tribulation_reduction": 0.5, "all_stats": 30}}
	],
	"Gold": [
		{"name": "Naturally Supreme", "description": "Cultivation speed x3, all stats +50", "effect": {"cultivation_speed": 3.0, "all_stats": 50}},
		{"name": "Time Walker", "description": "Can slow time briefly in combat", "effect": {"time_slow": true, "time_slow_duration": 3.0}},
		{"name": "System Breaker", "description": "Ignore realm restrictions, learn any technique", "effect": {"no_restrictions": true}},
		{"name": "Reincarnator's Memory", "description": "Knowledge of all major events and locations", "effect": {"omniscient": true, "all_stats": 40}}
	]
}

# Currently active abilities
var active_abilities = []

# Last rolled ability (for simulation)
var last_rolled_ability = null

func _ready():
	pass

# Roll a random ability rank based on probabilities
func roll_ability_rank() -> String:
	var roll = randf()
	
	if roll < 0.50:      # 50% White
		return "White"
	elif roll < 0.75:    # 25% Green
		return "Green"
	elif roll < 0.90:    # 15% Blue
		return "Blue"
	elif roll < 0.98:    # 8% Purple
		return "Purple"
	else:                # 2% Gold
		return "Gold"

# Roll a random ability from a specific rank
func roll_ability_from_rank(rank: String) -> Dictionary:
	if not ability_pool.has(rank) or ability_pool[rank].size() == 0:
		push_error("Invalid or empty ability rank: " + rank)
		return {}
	
	var abilities = ability_pool[rank]
	var ability = abilities[randi() % abilities.size()]
	
	return ability.duplicate()

# Roll a completely random ability (rank + specific ability)
func roll_random_ability() -> Dictionary:
	var rank = roll_ability_rank()
	var ability = roll_ability_from_rank(rank)
	ability["rank"] = rank
	
	last_rolled_ability = ability
	emit_signal("ability_rolled", ability["name"], rank)
	
	return ability

# Unlock and apply an ability
func unlock_ability(ability_data: Dictionary, temporary: bool = false):
	if ability_data.empty():
		return
	
	# Check if already active
	for active in active_abilities:
		if active["name"] == ability_data["name"]:
			return  # Already have this ability
	
	# Add to active abilities
	var ability = ability_data.duplicate()
	ability["temporary"] = temporary
	active_abilities.append(ability)
	
	# Apply effects
	_apply_ability_effects(ability["effect"])
	
	# Add to story state
	if ability["name"] not in StoryStateManager.world_state["abilities"]:
		StoryStateManager.world_state["abilities"].append(ability["name"])
	
	emit_signal("ability_unlocked", ability["name"])

# Apply ability effects to cultivation system
func _apply_ability_effects(effects: Dictionary):
	for effect_type in effects:
		var value = effects[effect_type]
		
		match effect_type:
			"strength", "spirit", "vitality", "comprehension", "luck", "qi_capacity":
				CultivationSystem.modify_stat(effect_type, value)
			
			"all_stats":
				CultivationSystem.modify_stat("strength", value)
				CultivationSystem.modify_stat("spirit", value)
				CultivationSystem.modify_stat("vitality", value)
				CultivationSystem.modify_stat("comprehension", value)
			
			"destiny_thread":
				StoryStateManager.modify_state("destiny_thread", value, "Ability effect")
			
			# Multipliers and special effects are stored for runtime use
			_:
				pass  # Other effects handled by gameplay code

# Check if player has a specific ability
func has_ability(ability_name: String) -> bool:
	for ability in active_abilities:
		if ability["name"] == ability_name:
			return true
	return false

# Get effect value from active abilities
func get_ability_effect(effect_type: String, default_value = 1.0):
	var result = default_value
	
	for ability in active_abilities:
		if ability["effect"].has(effect_type):
			var value = ability["effect"][effect_type]
			
			# Multiply for multipliers, add for additive
			if typeof(value) == TYPE_BOOL:
				return value
			elif effect_type.ends_with("_mult") or effect_type.ends_with("_speed"):
				result *= value
			else:
				result += value
	
	return result

# Get all active abilities
func get_active_abilities() -> Array:
	return active_abilities.duplicate()

# Remove temporary abilities
func clear_temporary_abilities():
	var to_remove = []
	for ability in active_abilities:
		if ability.get("temporary", false):
			to_remove.append(ability)
	
	for ability in to_remove:
		active_abilities.erase(ability)

# Get ability description by name
func get_ability_description(ability_name: String) -> String:
	for rank in ability_pool:
		for ability in ability_pool[rank]:
			if ability["name"] == ability_name:
				return ability["description"]
	return "Unknown ability"

# Get ability rank by name
func get_ability_rank(ability_name: String) -> String:
	for rank in ability_pool:
		for ability in ability_pool[rank]:
			if ability["name"] == ability_name:
				return rank
	return "Unknown"

# Get rank color for UI
func get_rank_color(rank: String) -> Color:
	match rank:
		"White":
			return Color(0.9, 0.9, 0.9)
		"Green":
			return Color(0.2, 0.8, 0.2)
		"Blue":
			return Color(0.2, 0.4, 1.0)
		"Purple":
			return Color(0.7, 0.2, 0.9)
		"Gold":
			return Color(1.0, 0.84, 0.0)
		_:
			return Color.white

# Save/Load
func save_to_dict() -> Dictionary:
	return {
		"active_abilities": active_abilities.duplicate(true),
		"last_rolled_ability": last_rolled_ability
	}

func load_from_dict(data: Dictionary):
	if data.has("active_abilities"):
		active_abilities = data["active_abilities"].duplicate(true)
	if data.has("last_rolled_ability"):
		last_rolled_ability = data["last_rolled_ability"]
