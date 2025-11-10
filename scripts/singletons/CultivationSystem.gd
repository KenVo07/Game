extends Node

# ==========================================
# CULTIVATION SYSTEM
# ==========================================
# Manages player cultivation realm, sutras, and progression

signal realm_breakthrough(new_realm)
signal sutra_learned(sutra_name)
signal stat_changed(stat_name, old_value, new_value)

# Realm progression
var realms = [
	"Mortal",
	"Qi Condensation",
	"Foundation Establishment",
	"Core Formation",
	"Nascent Soul",
	"Saint",
	"True Immortal"
]

var current_realm = "Mortal"
var current_realm_index = 0

# Player stats
var stats = {
	"strength": 10,
	"spirit": 10,
	"vitality": 10,
	"agility": 10,
	"qi": 100,
	"qi_max": 100,
	"health": 100,
	"health_max": 100
}

# Sutras
var heart_sutra = "Heart Sutra of Silent Chaos"
var combat_sutras = []
var technique_sutras = []
var movement_sutras = []

# Abilities (passive powers)
var abilities = []

# Breakthrough requirements
var breakthrough_requirements = {
	"Mortal": {
		"qi_threshold": 100,
		"item": null,
		"insight": false
	},
	"Qi Condensation": {
		"qi_threshold": 300,
		"item": "Qi Condensation Pill",
		"insight": true
	},
	"Foundation Establishment": {
		"qi_threshold": 1000,
		"item": "Foundation Pill",
		"insight": true
	},
	"Core Formation": {
		"qi_threshold": 5000,
		"item": "Core Formation Elixir",
		"insight": true
	},
	"Nascent Soul": {
		"qi_threshold": 20000,
		"item": "Nascent Soul Fruit",
		"insight": true
	},
	"Saint": {
		"qi_threshold": 100000,
		"item": "Saint's Tribulation Stone",
		"insight": true
	}
}

func _ready():
	print("[CultivationSystem] Initialized")

func set_heart_sutra(sutra_name: String):
	"""Set the player's heart sutra (determines cultivation path)"""
	heart_sutra = sutra_name
	print("[CultivationSystem] Heart Sutra set: " + sutra_name)
	
	# Apply heart sutra bonuses
	_apply_heart_sutra_effects(sutra_name)

func _apply_heart_sutra_effects(sutra_name: String):
	"""Apply stat bonuses based on heart sutra"""
	match sutra_name:
		"Heart Sutra of Silent Chaos":
			modify_stat("spirit", 5)
			modify_stat("strength", 3)
		"Heart Sutra of Eternal Hatred":
			modify_stat("strength", 8)
			modify_stat("vitality", -2)
		"Heart Sutra of Tranquil Mind":
			modify_stat("spirit", 10)
			modify_stat("qi_max", 50)
		"Heart Sutra of Iron Body":
			modify_stat("vitality", 10)
			modify_stat("health_max", 50)

func learn_sutra(sutra_name: String, sutra_type: String):
	"""Learn a new sutra"""
	match sutra_type:
		"combat":
			if not sutra_name in combat_sutras:
				combat_sutras.append(sutra_name)
				emit_signal("sutra_learned", sutra_name)
				print("[CultivationSystem] Combat Sutra learned: " + sutra_name)
		"technique":
			if not sutra_name in technique_sutras:
				technique_sutras.append(sutra_name)
				emit_signal("sutra_learned", sutra_name)
				print("[CultivationSystem] Technique Sutra learned: " + sutra_name)
		"movement":
			if not sutra_name in movement_sutras:
				movement_sutras.append(sutra_name)
				emit_signal("sutra_learned", sutra_name)
				print("[CultivationSystem] Movement Sutra learned: " + sutra_name)

func add_ability(ability_name: String):
	"""Add a passive ability"""
	if not ability_name in abilities:
		abilities.append(ability_name)
		_apply_ability_effect(ability_name)
		print("[CultivationSystem] Ability gained: " + ability_name)

func _apply_ability_effect(ability_name: String):
	"""Apply passive ability effects"""
	# This would contain the logic for each ability
	match ability_name:
		"Quick Learner":
			# Increases qi gain by 20%
			pass
		"Spirit Resonance":
			modify_stat("spirit", 5)
		"Iron Constitution":
			modify_stat("vitality", 8)
			modify_stat("health_max", 30)
		"Naturally Supreme":
			modify_stat("strength", 10)
			modify_stat("spirit", 10)
			modify_stat("vitality", 10)
			modify_stat("agility", 10)

func modify_stat(stat_name: String, delta: int):
	"""Modify a player stat"""
	if not stat_name in stats:
		push_error("Attempted to modify non-existent stat: " + stat_name)
		return
	
	var old_value = stats[stat_name]
	stats[stat_name] += delta
	
	# Ensure stats don't go negative
	if stats[stat_name] < 0:
		stats[stat_name] = 0
	
	emit_signal("stat_changed", stat_name, old_value, stats[stat_name])
	print("[CultivationSystem] %s: %d -> %d" % [stat_name, old_value, stats[stat_name]])

func set_stat(stat_name: String, value: int):
	"""Set a player stat directly"""
	if not stat_name in stats:
		push_error("Attempted to set non-existent stat: " + stat_name)
		return
	
	var old_value = stats[stat_name]
	stats[stat_name] = value
	
	emit_signal("stat_changed", stat_name, old_value, stats[stat_name])
	print("[CultivationSystem] %s set: %d -> %d" % [stat_name, old_value, stats[stat_name]])

func can_breakthrough() -> bool:
	"""Check if player can breakthrough to next realm"""
	if current_realm_index >= realms.size() - 1:
		return false  # Already at max realm
	
	var next_realm = realms[current_realm_index + 1]
	if not next_realm in breakthrough_requirements:
		return true  # No requirements for this realm
	
	var reqs = breakthrough_requirements[next_realm]
	
	# Check qi threshold
	if stats["qi"] < reqs["qi_threshold"]:
		return false
	
	# Check for required item
	if reqs["item"]:
		if not StoryStateManager.get_state("inventory").has(reqs["item"]):
			return false
	
	# Check for insight requirement
	if reqs["insight"]:
		# Would check if player has gained sufficient insight
		# For now, simplified
		if StoryStateManager.get_state("simulations_done") < (current_realm_index + 1) * 3:
			return false
	
	return true

func breakthrough() -> bool:
	"""Attempt to breakthrough to next realm"""
	if not can_breakthrough():
		print("[CultivationSystem] Breakthrough failed - requirements not met")
		return false
	
	current_realm_index += 1
	current_realm = realms[current_realm_index]
	
	# Apply realm breakthrough bonuses
	_apply_realm_breakthrough_bonuses()
	
	# Update story state
	StoryStateManager.set_state("realm_level", current_realm_index + 1)
	
	emit_signal("realm_breakthrough", current_realm)
	print("[CultivationSystem] BREAKTHROUGH! New Realm: " + current_realm)
	
	return true

func _apply_realm_breakthrough_bonuses():
	"""Apply stat bonuses on realm breakthrough"""
	var multiplier = current_realm_index + 1
	
	modify_stat("strength", 5 * multiplier)
	modify_stat("spirit", 5 * multiplier)
	modify_stat("vitality", 5 * multiplier)
	modify_stat("agility", 3 * multiplier)
	
	# Increase qi and health max
	modify_stat("qi_max", 100 * multiplier)
	modify_stat("health_max", 50 * multiplier)
	
	# Restore to full
	stats["qi"] = stats["qi_max"]
	stats["health"] = stats["health_max"]

func get_realm_power_level() -> int:
	"""Calculate numerical power level based on realm and stats"""
	var base_power = (current_realm_index + 1) * 100
	var stat_power = (stats["strength"] + stats["spirit"] + stats["vitality"] + stats["agility"]) * 2
	return base_power + stat_power

func heal(amount: int):
	"""Heal the player"""
	stats["health"] = min(stats["health"] + amount, stats["health_max"])

func restore_qi(amount: int):
	"""Restore qi"""
	stats["qi"] = min(stats["qi"] + amount, stats["qi_max"])

func take_damage(amount: int):
	"""Player takes damage"""
	stats["health"] -= amount
	if stats["health"] <= 0:
		stats["health"] = 0
		_handle_death()

func _handle_death():
	"""Handle player death"""
	print("[CultivationSystem] Player has died!")
	StoryStateManager.modify_state("death_count", 1)
	# This would trigger the simulation system

func get_cultivation_data() -> Dictionary:
	"""Export cultivation data for save/simulation"""
	return {
		"realm": current_realm,
		"realm_index": current_realm_index,
		"stats": stats.duplicate(),
		"heart_sutra": heart_sutra,
		"combat_sutras": combat_sutras.duplicate(),
		"technique_sutras": technique_sutras.duplicate(),
		"movement_sutras": movement_sutras.duplicate(),
		"abilities": abilities.duplicate()
	}

func load_cultivation_data(data: Dictionary):
	"""Load cultivation data from save"""
	current_realm = data.get("realm", "Mortal")
	current_realm_index = data.get("realm_index", 0)
	stats = data.get("stats", stats)
	heart_sutra = data.get("heart_sutra", "Heart Sutra of Silent Chaos")
	combat_sutras = data.get("combat_sutras", [])
	technique_sutras = data.get("technique_sutras", [])
	movement_sutras = data.get("movement_sutras", [])
	abilities = data.get("abilities", [])
	print("[CultivationSystem] Cultivation data loaded")

func reset_cultivation():
	"""Reset cultivation (for new game)"""
	current_realm = "Mortal"
	current_realm_index = 0
	stats = {
		"strength": 10,
		"spirit": 10,
		"vitality": 10,
		"agility": 10,
		"qi": 100,
		"qi_max": 100,
		"health": 100,
		"health_max": 100
	}
	heart_sutra = "Heart Sutra of Silent Chaos"
	combat_sutras = []
	technique_sutras = []
	movement_sutras = []
	abilities = []
	print("[CultivationSystem] Cultivation reset")
