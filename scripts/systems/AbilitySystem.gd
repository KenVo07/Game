extends Node

# ==========================================
# ABILITY SYSTEM
# ==========================================
# Manages ability rolls, passive powers, and active techniques

# Ability rank definitions
const ABILITY_RANKS = ["White", "Green", "Blue", "Purple", "Gold"]

# Ability pool organized by rank
var ability_pool = {
	"White": [
		{
			"name": "Quick Learner",
			"description": "Gain 10% more cultivation progress from all sources",
			"type": "passive",
			"effects": {"cultivation_speed": 0.1}
		},
		{
			"name": "Sturdy Body",
			"description": "Increase max vitality by 20",
			"type": "passive",
			"effects": {"max_vitality": 20}
		},
		{
			"name": "Qi Recovery",
			"description": "Regenerate qi 20% faster",
			"type": "passive",
			"effects": {"qi_regen": 0.2}
		}
	],
	"Green": [
		{
			"name": "Spirit Resonance",
			"description": "Increase spirit stat by 15%",
			"type": "passive",
			"effects": {"spirit_mult": 0.15}
		},
		{
			"name": "Combat Instinct",
			"description": "Dodge cooldown reduced by 30%",
			"type": "passive",
			"effects": {"dodge_cooldown": -0.3}
		},
		{
			"name": "Talisman Affinity",
			"description": "Talisman abilities cost 20% less qi",
			"type": "passive",
			"effects": {"talisman_cost": -0.2}
		}
	],
	"Blue": [
		{
			"name": "Echo of the Dead",
			"description": "When killing an enemy, absorb their qi",
			"type": "passive",
			"effects": {"qi_drain_on_kill": true}
		},
		{
			"name": "Mind Splitter",
			"description": "Attacks have 15% chance to confuse enemies",
			"type": "passive",
			"effects": {"confuse_chance": 0.15}
		},
		{
			"name": "Phantom Movement",
			"description": "Leave afterimages when dodging that deal damage",
			"type": "passive",
			"effects": {"dodge_damage": true}
		}
	],
	"Purple": [
		{
			"name": "Talisman Whisperer",
			"description": "Can communicate with ancient talismans, revealing secrets",
			"type": "passive",
			"effects": {"talisman_secrets": true, "insight_bonus": 2}
		},
		{
			"name": "Demon Heart",
			"description": "Convert vitality to qi at 2:1 ratio",
			"type": "active",
			"effects": {"vitality_to_qi": 2}
		},
		{
			"name": "Heaven's Defiance",
			"description": "Ignore karma penalties for 60 seconds (cooldown: 300s)",
			"type": "active",
			"effects": {"karma_immunity": 60}
		}
	],
	"Gold": [
		{
			"name": "Naturally Supreme",
			"description": "All stats increased by 25%. Cultivation speed doubled.",
			"type": "passive",
			"effects": {"all_stats": 0.25, "cultivation_speed": 1.0}
		},
		{
			"name": "Fate Weaver",
			"description": "Can reroll simulation outcomes once per simulation",
			"type": "active",
			"effects": {"simulation_reroll": true}
		},
		{
			"name": "Void Walker",
			"description": "Can teleport to any discovered location",
			"type": "active",
			"effects": {"teleport": true}
		}
	]
}

# Player's current abilities
var unlocked_abilities = []
var active_ability_cooldowns = {}

# Unlocked techniques (from sutras)
var unlocked_techniques = []

# Signals
signal ability_rolled(ability_data, rank)
signal ability_unlocked(ability_name)
signal technique_unlocked(technique_name)
signal ability_activated(ability_name)

func _ready():
	print("AbilitySystem initialized")

func _process(delta):
	# Update cooldowns
	for ability in active_ability_cooldowns.keys():
		if active_ability_cooldowns[ability] > 0:
			active_ability_cooldowns[ability] -= delta

# ==========================================
# ABILITY ROLLING (Pre-Simulation)
# ==========================================

func roll_ability_rank() -> String:
	"""
	Roll a random ability rank based on weighted probabilities
	White: 50%
	Green: 25%
	Blue: 15%
	Purple: 8%
	Gold: 2%
	"""
	var roll = randf()
	
	if roll < 0.50:
		return "White"
	elif roll < 0.75:
		return "Green"
	elif roll < 0.90:
		return "Blue"
	elif roll < 0.98:
		return "Purple"
	else:
		return "Gold"

func roll_ability() -> Dictionary:
	"""
	Roll a random ability (rank and specific ability)
	Returns ability data
	"""
	var rank = roll_ability_rank()
	var abilities_in_rank = ability_pool[rank]
	var chosen_ability = abilities_in_rank[randi() % abilities_in_rank.size()]
	
	var ability_data = {
		"rank": rank,
		"name": chosen_ability["name"],
		"description": chosen_ability["description"],
		"type": chosen_ability["type"],
		"effects": chosen_ability["effects"]
	}
	
	emit_signal("ability_rolled", ability_data, rank)
	print("Rolled ability: [", rank, "] ", chosen_ability["name"])
	
	return ability_data

func roll_ability_of_rank(rank: String) -> Dictionary:
	"""
	Roll a specific rank ability (for testing or special events)
	"""
	if not rank in ABILITY_RANKS:
		push_error("Invalid ability rank: " + rank)
		return {}
	
	var abilities_in_rank = ability_pool[rank]
	if abilities_in_rank.size() == 0:
		push_error("No abilities in rank: " + rank)
		return {}
	
	var chosen_ability = abilities_in_rank[randi() % abilities_in_rank.size()]
	
	var ability_data = {
		"rank": rank,
		"name": chosen_ability["name"],
		"description": chosen_ability["description"],
		"type": chosen_ability["type"],
		"effects": chosen_ability["effects"]
	}
	
	emit_signal("ability_rolled", ability_data, rank)
	return ability_data

# ==========================================
# ABILITY MANAGEMENT
# ==========================================

func unlock_ability(ability_data: Dictionary):
	"""
	Unlock an ability and apply its effects
	"""
	var ability_name = ability_data["name"]
	
	# Check if already unlocked
	if has_ability(ability_name):
		print("Ability already unlocked: ", ability_name)
		return
	
	unlocked_abilities.append(ability_data)
	emit_signal("ability_unlocked", ability_name)
	
	# Apply passive effects immediately
	if ability_data["type"] == "passive":
		apply_passive_ability(ability_data)
	
	# Add to StoryStateManager
	var abilities_list = StoryStateManager.get_state("abilities")
	abilities_list.append(ability_name)
	
	print("Unlocked ability: [", ability_data["rank"], "] ", ability_name)

func has_ability(ability_name: String) -> bool:
	"""
	Check if player has an ability
	"""
	for ability in unlocked_abilities:
		if ability["name"] == ability_name:
			return true
	return false

func get_ability_data(ability_name: String) -> Dictionary:
	"""
	Get data for an ability
	"""
	for ability in unlocked_abilities:
		if ability["name"] == ability_name:
			return ability
	return {}

func apply_passive_ability(ability_data: Dictionary):
	"""
	Apply effects of a passive ability
	"""
	var effects = ability_data["effects"]
	
	# Apply stat modifications
	if effects.has("cultivation_speed"):
		var bonus = effects["cultivation_speed"]
		CultivationSystem.modify_stat("cultivation_speed", bonus)
	
	if effects.has("max_vitality"):
		var bonus = effects["max_vitality"]
		CultivationSystem.modify_stat("max_vitality", bonus)
	
	if effects.has("spirit_mult"):
		var mult = effects["spirit_mult"]
		var current_spirit = CultivationSystem.get_stat("spirit")
		var bonus = int(current_spirit * mult)
		CultivationSystem.modify_stat("spirit", bonus)
	
	if effects.has("all_stats"):
		var mult = effects["all_stats"]
		for stat in ["strength", "spirit", "comprehension"]:
			var current_val = CultivationSystem.get_stat(stat)
			var bonus = int(current_val * mult)
			CultivationSystem.modify_stat(stat, bonus)
		
		if effects.has("cultivation_speed"):
			CultivationSystem.modify_stat("cultivation_speed", effects["cultivation_speed"])
	
	print("Applied passive ability: ", ability_data["name"])

# ==========================================
# ACTIVE ABILITIES
# ==========================================

func activate_ability(ability_name: String) -> bool:
	"""
	Activate an active ability
	Returns true if successful
	"""
	var ability = get_ability_data(ability_name)
	
	if ability.empty():
		print("Ability not found: ", ability_name)
		return false
	
	if ability["type"] != "active":
		print("Ability is not active: ", ability_name)
		return false
	
	# Check cooldown
	if is_on_cooldown(ability_name):
		print("Ability on cooldown: ", ability_name)
		return false
	
	# Execute ability effects
	var success = execute_active_ability(ability)
	
	if success:
		emit_signal("ability_activated", ability_name)
		# Set cooldown if applicable
		if ability["effects"].has("cooldown"):
			set_cooldown(ability_name, ability["effects"]["cooldown"])
	
	return success

func execute_active_ability(ability: Dictionary) -> bool:
	"""
	Execute the effects of an active ability
	"""
	var effects = ability["effects"]
	
	match ability["name"]:
		"Demon Heart":
			# Convert vitality to qi
			var vitality = CultivationSystem.get_stat("vitality")
			var conversion_rate = effects["vitality_to_qi"]
			var amount_to_convert = min(vitality - 10, 50)  # Keep at least 10 vitality
			if amount_to_convert > 0:
				CultivationSystem.modify_stat("vitality", -amount_to_convert)
				CultivationSystem.modify_stat("qi", amount_to_convert * conversion_rate)
				return true
		
		"Heaven's Defiance":
			# Temporary karma immunity (would need to be handled by game logic)
			print("Heaven's Defiance activated!")
			return true
		
		"Fate Weaver":
			# Allow simulation reroll (handled by SimulationManager)
			print("Fate Weaver activated - can reroll simulation!")
			return true
		
		"Void Walker":
			# Teleportation (handled by world navigation)
			print("Void Walker activated - select destination!")
			return true
	
	return false

func is_on_cooldown(ability_name: String) -> bool:
	"""
	Check if an ability is on cooldown
	"""
	if active_ability_cooldowns.has(ability_name):
		return active_ability_cooldowns[ability_name] > 0
	return false

func set_cooldown(ability_name: String, duration: float):
	"""
	Set cooldown for an ability
	"""
	active_ability_cooldowns[ability_name] = duration

func get_cooldown_remaining(ability_name: String) -> float:
	"""
	Get remaining cooldown time
	"""
	if active_ability_cooldowns.has(ability_name):
		return max(0, active_ability_cooldowns[ability_name])
	return 0

# ==========================================
# TECHNIQUE MANAGEMENT (From Sutras)
# ==========================================

func unlock_technique(technique_name: String):
	"""
	Unlock a combat technique
	"""
	if technique_name in unlocked_techniques:
		print("Technique already unlocked: ", technique_name)
		return
	
	unlocked_techniques.append(technique_name)
	emit_signal("technique_unlocked", technique_name)
	print("Unlocked technique: ", technique_name)

func has_technique(technique_name: String) -> bool:
	"""
	Check if player has a technique
	"""
	return technique_name in unlocked_techniques

func get_techniques() -> Array:
	"""
	Get all unlocked techniques
	"""
	return unlocked_techniques

# ==========================================
# ABILITY EFFECTS QUERIES
# ==========================================

func get_total_effect(effect_name: String) -> float:
	"""
	Get the total value of an effect from all abilities
	"""
	var total = 0.0
	
	for ability in unlocked_abilities:
		if ability["effects"].has(effect_name):
			total += ability["effects"][effect_name]
	
	return total

func has_effect(effect_name: String) -> bool:
	"""
	Check if player has any ability with a specific effect
	"""
	for ability in unlocked_abilities:
		if ability["effects"].has(effect_name):
			return true
	return false

func get_stat_multiplier(stat_name: String) -> float:
	"""
	Get total multiplier for a stat from abilities
	"""
	var multiplier = 1.0
	
	for ability in unlocked_abilities:
		var mult_key = stat_name + "_mult"
		if ability["effects"].has(mult_key):
			multiplier += ability["effects"][mult_key]
	
	return multiplier

# ==========================================
# SERIALIZATION
# ==========================================

func get_save_data() -> Dictionary:
	"""
	Get data to save
	"""
	return {
		"unlocked_abilities": unlocked_abilities.duplicate(),
		"unlocked_techniques": unlocked_techniques.duplicate(),
		"active_ability_cooldowns": active_ability_cooldowns.duplicate()
	}

func load_save_data(data: Dictionary):
	"""
	Load data from save
	"""
	if data.has("unlocked_abilities"):
		unlocked_abilities = data["unlocked_abilities"]
		# Reapply passive abilities
		for ability in unlocked_abilities:
			if ability["type"] == "passive":
				apply_passive_ability(ability)
	
	if data.has("unlocked_techniques"):
		unlocked_techniques = data["unlocked_techniques"]
	
	if data.has("active_ability_cooldowns"):
		active_ability_cooldowns = data["active_ability_cooldowns"]
	
	print("Ability data loaded")

# ==========================================
# DEBUGGING
# ==========================================

func print_abilities():
	"""
	Print all unlocked abilities for debugging
	"""
	print("=== UNLOCKED ABILITIES ===")
	for ability in unlocked_abilities:
		print("[", ability["rank"], "] ", ability["name"], " (", ability["type"], ")")
		print("  ", ability["description"])
	print("=========================")

func print_techniques():
	"""
	Print all unlocked techniques
	"""
	print("=== UNLOCKED TECHNIQUES ===")
	for tech in unlocked_techniques:
		print("  ", tech)
	print("===========================")
