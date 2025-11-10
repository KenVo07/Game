extends Node

# ==========================================
# ABILITY SYSTEM
# ==========================================
# Manages ability rolling, storage, and effects
# Abilities are randomly rolled before each simulation

signal ability_rolled(ability_name, rank)

# Ability ranks and their drop rates
var ability_ranks = {
	"White": 0.50,    # 50%
	"Green": 0.25,    # 25%
	"Blue": 0.15,     # 15%
	"Purple": 0.08,   # 8%
	"Gold": 0.02      # 2%
}

# Ability pool organized by rank
var ability_pool = {
	"White": [
		{"name": "Quick Learner", "desc": "Gain 20% more experience from all sources"},
		{"name": "Keen Insight", "desc": "Slightly increased comprehension of sutras"},
		{"name": "Iron Stomach", "desc": "Reduced negative effects from pills and elixirs"},
		{"name": "Light Sleeper", "desc": "Recover qi 10% faster during rest"}
	],
	"Green": [
		{"name": "Spirit Resonance", "desc": "+5 Spirit, improved qi manipulation"},
		{"name": "Battle Instinct", "desc": "+5 Agility, improved dodge chance"},
		{"name": "Fortified Body", "desc": "+8 Vitality, reduced damage from physical attacks"},
		{"name": "Qi Affinity", "desc": "+20% max qi, faster qi recovery"}
	],
	"Blue": [
		{"name": "Echo of the Dead", "desc": "Occasionally hear whispers of the fallen, gain hidden insights"},
		{"name": "Mind Splitter", "desc": "Can process two cultivation techniques simultaneously"},
		{"name": "Dao Heart", "desc": "Immunity to inner demons during breakthrough"},
		{"name": "Phantom Steps", "desc": "Movement techniques cost 30% less qi"}
	],
	"Purple": [
		{"name": "Talisman Whisperer", "desc": "Innate understanding of talisman arts, +50% talisman power"},
		{"name": "Karmic Sight", "desc": "Can see threads of karma connecting people and events"},
		{"name": "Void Touched", "desc": "Can cultivate using void energy, unlocks forbidden techniques"},
		{"name": "Immortal Bones", "desc": "Breakthrough success rate +50%, reduced tribulation damage"}
	],
	"Gold": [
		{"name": "Naturally Supreme", "desc": "+10 to all stats, doubled cultivation speed, heavenly destiny"},
		{"name": "Reincarnated Immortal", "desc": "Retain memories from simulations, can learn techniques from past lives"},
		{"name": "System Architect", "desc": "Can modify the Villain Simulator's parameters"},
		{"name": "Protagonist's Nemesis", "desc": "Steal fate from 'chosen ones', immune to plot armor"}
	]
}

var current_rolled_ability = null
var permanent_abilities = []

func _ready():
	print("[AbilitySystem] Initialized with %d total abilities" % _count_total_abilities())

func _count_total_abilities() -> int:
	"""Count total number of abilities across all ranks"""
	var count = 0
	for rank in ability_pool:
		count += ability_pool[rank].size()
	return count

func roll_ability() -> Dictionary:
	"""
	Roll a random ability based on rarity weights
	Returns: {name: String, rank: String, desc: String}
	"""
	var roll = randf()
	var cumulative = 0.0
	var rolled_rank = "White"
	
	# Determine rank based on weighted random
	for rank in ["White", "Green", "Blue", "Purple", "Gold"]:
		cumulative += ability_ranks[rank]
		if roll <= cumulative:
			rolled_rank = rank
			break
	
	# Select random ability from that rank
	var abilities_in_rank = ability_pool[rolled_rank]
	var selected_ability = abilities_in_rank[randi() % abilities_in_rank.size()]
	
	current_rolled_ability = {
		"name": selected_ability["name"],
		"rank": rolled_rank,
		"desc": selected_ability["desc"]
	}
	
	emit_signal("ability_rolled", current_rolled_ability["name"], rolled_rank)
	
	print("[AbilitySystem] Rolled %s (%s): %s" % [current_rolled_ability["name"], rolled_rank, current_rolled_ability["desc"]])
	
	return current_rolled_ability

func accept_rolled_ability():
	"""Accept the currently rolled ability and make it permanent"""
	if current_rolled_ability == null:
		push_error("No ability currently rolled to accept")
		return false
	
	# Check if already have this ability
	for ability in permanent_abilities:
		if ability["name"] == current_rolled_ability["name"]:
			print("[AbilitySystem] Already have ability: " + current_rolled_ability["name"])
			return false
	
	# Add to permanent abilities
	permanent_abilities.append(current_rolled_ability.duplicate())
	
	# Apply ability effect to cultivation system
	_apply_ability_effect(current_rolled_ability)
	
	# Add to story state
	StoryStateManager.modify_state("abilities", current_rolled_ability["name"])
	
	# Also add to cultivation system
	CultivationSystem.add_ability(current_rolled_ability["name"])
	
	print("[AbilitySystem] Ability permanently acquired: " + current_rolled_ability["name"])
	
	return true

func _apply_ability_effect(ability: Dictionary):
	"""Apply the mechanical effects of an ability"""
	match ability["name"]:
		# White tier
		"Quick Learner":
			# Would modify experience multiplier
			pass
		"Keen Insight":
			# Would modify comprehension rate
			pass
		"Iron Stomach":
			# Would reduce pill side effects
			pass
		"Light Sleeper":
			# Would increase qi recovery rate
			pass
		
		# Green tier
		"Spirit Resonance":
			CultivationSystem.modify_stat("spirit", 5)
		"Battle Instinct":
			CultivationSystem.modify_stat("agility", 5)
		"Fortified Body":
			CultivationSystem.modify_stat("vitality", 8)
		"Qi Affinity":
			var qi_max = CultivationSystem.stats["qi_max"]
			CultivationSystem.modify_stat("qi_max", int(qi_max * 0.2))
		
		# Blue tier
		"Echo of the Dead":
			# Would enable special dialogue/insights
			pass
		"Mind Splitter":
			# Would allow dual cultivation
			pass
		"Dao Heart":
			# Would modify breakthrough logic
			pass
		"Phantom Steps":
			# Would reduce movement skill costs
			pass
		
		# Purple tier
		"Talisman Whisperer":
			# Would boost talisman damage
			pass
		"Karmic Sight":
			# Would reveal hidden karma connections
			StoryStateManager.modify_state("insight_clues", "You can now see karmic threads...")
		"Void Touched":
			# Would unlock void cultivation
			StoryStateManager.modify_state("insight_clues", "The Void calls to you...")
		"Immortal Bones":
			# Would modify breakthrough success rate
			pass
		
		# Gold tier
		"Naturally Supreme":
			CultivationSystem.modify_stat("strength", 10)
			CultivationSystem.modify_stat("spirit", 10)
			CultivationSystem.modify_stat("vitality", 10)
			CultivationSystem.modify_stat("agility", 10)
		"Reincarnated Immortal":
			# Would enable memory retention from simulations
			StoryStateManager.modify_state("insight_clues", "Past lives flicker in your consciousness...")
		"System Architect":
			# Would allow simulation parameter modification
			StoryStateManager.modify_state("insight_clues", "You sense the Simulator's inner workings...")
		"Protagonist's Nemesis":
			# Would enable fate stealing
			StoryStateManager.modify_state("destiny_thread", 50)

func has_ability(ability_name: String) -> bool:
	"""Check if player has a specific ability"""
	for ability in permanent_abilities:
		if ability["name"] == ability_name:
			return true
	return false

func get_abilities_by_rank(rank: String) -> Array:
	"""Get all permanent abilities of a specific rank"""
	var result = []
	for ability in permanent_abilities:
		if ability["rank"] == rank:
			result.append(ability)
	return result

func get_all_abilities() -> Array:
	"""Get all permanent abilities"""
	return permanent_abilities.duplicate()

func get_ability_description(ability_name: String) -> String:
	"""Get the description of an ability"""
	# Check permanent abilities first
	for ability in permanent_abilities:
		if ability["name"] == ability_name:
			return ability["desc"]
	
	# Check ability pool
	for rank in ability_pool:
		for ability in ability_pool[rank]:
			if ability["name"] == ability_name:
				return ability["desc"]
	
	return "Unknown ability"

func get_rank_color(rank: String) -> Color:
	"""Get display color for ability rank"""
	match rank:
		"White":
			return Color(0.9, 0.9, 0.9)  # Light gray
		"Green":
			return Color(0.2, 0.8, 0.2)  # Green
		"Blue":
			return Color(0.3, 0.5, 1.0)  # Blue
		"Purple":
			return Color(0.7, 0.2, 0.8)  # Purple
		"Gold":
			return Color(1.0, 0.84, 0.0)  # Gold
		_:
			return Color.white

func clear_rolled_ability():
	"""Clear the currently rolled ability (if not accepted)"""
	current_rolled_ability = null

func reset_abilities():
	"""Reset all abilities (for new game)"""
	current_rolled_ability = null
	permanent_abilities = []
	print("[AbilitySystem] Abilities reset")

func get_ability_data() -> Dictionary:
	"""Export ability data for save"""
	return {
		"permanent_abilities": permanent_abilities.duplicate(),
		"current_rolled": current_rolled_ability.duplicate() if current_rolled_ability else null
	}

func load_ability_data(data: Dictionary):
	"""Load ability data from save"""
	permanent_abilities = data.get("permanent_abilities", [])
	current_rolled_ability = data.get("current_rolled", null)
	
	# Reapply all ability effects
	for ability in permanent_abilities:
		_apply_ability_effect(ability)
	
	print("[AbilitySystem] Ability data loaded, %d abilities" % permanent_abilities.size())
