extends Node

# ==========================================
# SIMULATION MANAGER - THE VILLAIN SIMULATOR
# ==========================================
# Core logic for running text-based simulations
# Generates narrative outcomes based on player stats and choices

signal simulation_started()
signal simulation_step_generated(step_text)
signal simulation_ended(result)
signal reward_choices_available(choices)

var is_simulating = false
var current_simulation = null
var simulation_history = []

# Simulation event templates
var event_templates = [
	# Early game events
	{"stage": "early", "type": "cultivation", "text": "You discover a hidden cave with residual qi. You attempt to absorb it...", "outcomes": ["success_minor", "failure_safe", "neutral"]},
	{"stage": "early", "type": "combat", "text": "A rogue cultivator challenges you to a duel.", "outcomes": ["victory", "defeat", "escape"]},
	{"stage": "early", "type": "social", "text": "You encounter a traveling merchant selling mysterious pills.", "outcomes": ["purchase", "negotiate", "ignore"]},
	{"stage": "early", "type": "exploration", "text": "You find ancient ruins marked with strange talismans.", "outcomes": ["investigate", "avoid", "neutral"]},
	
	# Mid game events
	{"stage": "mid", "type": "cultivation", "text": "You attempt to breakthrough to the next realm.", "outcomes": ["success_major", "failure_dangerous", "partial"]},
	{"stage": "mid", "type": "combat", "text": "A sect sends disciples to capture you for your techniques.", "outcomes": ["victory", "defeat", "negotiate"]},
	{"stage": "mid", "type": "moral", "text": "You discover a village being raided by demonic cultivators.", "outcomes": ["save_villagers", "ignore", "join_demons"]},
	{"stage": "mid", "type": "discovery", "text": "You uncover a fragment of a lost supreme sutra.", "outcomes": ["success_major", "cursed", "incomplete"]},
	
	# Late game events
	{"stage": "late", "type": "tribulation", "text": "The Heavens sense your growing power and send down tribulation lightning.", "outcomes": ["survive", "wounded", "death"]},
	{"stage": "late", "type": "faction", "text": "Multiple sects form an alliance to eliminate you as a threat.", "outcomes": ["victory", "defeat", "flee"]},
	{"stage": "late", "type": "secret", "text": "You discover the true origin of the Villain Simulator.", "outcomes": ["accept_truth", "reject_truth", "transcend"]},
]

# Death causes based on context
var death_causes = [
	"overwhelmed by cursed qi",
	"betrayed by a supposed ally",
	"consumed by inner demons during breakthrough",
	"struck down by heavenly tribulation",
	"ambushed by sect elders",
	"cultivation deviation from forbidden technique",
	"trapped in an ancient formation",
	"poisoned by demonic pill",
	"soul shattered in mental duel",
	"erased by a supreme immortal's palm strike"
]

func _ready():
	print("[SimulationManager] Initialized")

func start_simulation() -> Dictionary:
	"""
	Start a new simulation
	Returns the initial simulation data
	"""
	if is_simulating:
		push_error("Simulation already in progress")
		return {}
	
	is_simulating = true
	emit_signal("simulation_started")
	
	# Roll ability for this simulation
	var rolled_ability = AbilitySystem.roll_ability()
	
	# Get current player state
	var player_stats = CultivationSystem.get_cultivation_data()
	var world_state = StoryStateManager.get_narrative_context()
	
	# Create simulation instance
	current_simulation = {
		"id": OS.get_unix_time(),
		"rolled_ability": rolled_ability,
		"starting_stats": player_stats,
		"starting_world_state": world_state,
		"events": [],
		"outcome": {},
		"rewards": []
	}
	
	# Generate simulation events
	_generate_simulation_events()
	
	# Determine outcome
	_determine_simulation_outcome()
	
	# Generate reward choices
	_generate_reward_choices()
	
	# Add to history
	simulation_history.append(current_simulation.duplicate())
	
	# Update story state
	StoryStateManager.modify_state("simulations_done", 1)
	
	print("[SimulationManager] Simulation #%d started" % StoryStateManager.get_state("simulations_done"))
	
	return current_simulation

func _generate_simulation_events():
	"""Generate a sequence of events for the simulation"""
	var realm_level = CultivationSystem.current_realm_index
	var karma = StoryStateManager.get_state("karma")
	
	# Determine simulation stage based on realm
	var stage = "early"
	if realm_level >= 4:
		stage = "late"
	elif realm_level >= 2:
		stage = "mid"
	
	# Generate 3-5 events
	var num_events = 3 + randi() % 3
	
	for i in range(num_events):
		var event = _roll_event(stage, karma)
		current_simulation["events"].append(event)
		emit_signal("simulation_step_generated", event["text"])

func _roll_event(stage: String, karma: int) -> Dictionary:
	"""Roll a random event appropriate for the current stage and karma"""
	# Filter events by stage
	var valid_events = []
	for template in event_templates:
		if template["stage"] == stage or template["stage"] == "any":
			valid_events.append(template)
	
	if valid_events.size() == 0:
		valid_events = event_templates  # Fallback to all events
	
	# Pick random event
	var template = valid_events[randi() % valid_events.size()]
	
	# Determine outcome based on player stats and karma
	var outcome = _determine_event_outcome(template, karma)
	
	return {
		"type": template["type"],
		"text": template["text"],
		"outcome": outcome,
		"outcome_text": _generate_outcome_text(template["type"], outcome)
	}

func _determine_event_outcome(template: Dictionary, karma: int) -> String:
	"""Determine the outcome of an event"""
	var possible_outcomes = template["outcomes"]
	var roll = randf()
	
	# Modify roll based on karma
	if karma > 30:
		roll += 0.1  # Slight bonus for good karma
	elif karma < -30:
		roll -= 0.1  # Slight penalty for bad karma
	
	# Simple weighted selection
	if roll < 0.4:
		return possible_outcomes[0] if possible_outcomes.size() > 0 else "neutral"
	elif roll < 0.7:
		return possible_outcomes[1] if possible_outcomes.size() > 1 else "neutral"
	else:
		return possible_outcomes[2] if possible_outcomes.size() > 2 else "neutral"

func _generate_outcome_text(event_type: String, outcome: String) -> String:
	"""Generate narrative text for an event outcome"""
	match outcome:
		"success_minor":
			return "You succeeded and gained minor benefits."
		"success_major":
			return "Remarkable success! Your power grows significantly."
		"failure_safe":
			return "You failed, but escaped without harm."
		"failure_dangerous":
			return "Failure! You suffered significant injuries."
		"victory":
			return "You emerged victorious from the confrontation."
		"defeat":
			return "You were defeated and forced to retreat."
		"escape":
			return "You managed to escape with your life."
		"neutral":
			return "The outcome was inconclusive."
		"cursed":
			return "You gained power, but at a terrible cost..."
		"partial":
			return "Partial success, but complications arose."
		"save_villagers":
			return "You saved the villagers and earned their gratitude."
		"ignore":
			return "You walked away without getting involved."
		"join_demons":
			return "You joined the demonic cultivators in their raid..."
		"survive":
			return "You survived the tribulation, though barely."
		"wounded":
			return "You survived but suffered severe wounds."
		"death":
			return "You perished in the tribulation."
		"transcend":
			return "You transcended mortal understanding."
		_:
			return "Something happened."

func _determine_simulation_outcome():
	"""Determine the final outcome of the simulation"""
	var death_chance = 0.7  # Base 70% chance of death in simulation
	
	# Modify based on realm level
	death_chance -= CultivationSystem.current_realm_index * 0.05
	
	# Modify based on rolled ability
	if current_simulation["rolled_ability"]["rank"] == "Gold":
		death_chance -= 0.3
	elif current_simulation["rolled_ability"]["rank"] == "Purple":
		death_chance -= 0.2
	elif current_simulation["rolled_ability"]["rank"] == "Blue":
		death_chance -= 0.1
	
	var dies = randf() < death_chance
	
	if dies:
		current_simulation["outcome"] = {
			"died": true,
			"death_cause": death_causes[randi() % death_causes.size()],
			"insights_gained": _generate_insights(),
			"final_text": _generate_death_narrative()
		}
	else:
		current_simulation["outcome"] = {
			"died": false,
			"achievement": _generate_survival_achievement(),
			"insights_gained": _generate_insights(),
			"final_text": _generate_survival_narrative()
		}
	
	emit_signal("simulation_ended", current_simulation["outcome"])

func _generate_death_narrative() -> String:
	"""Generate narrative text for simulation death"""
	var templates = [
		"In the simulated future, you fell to %s. The path ahead grows darker.",
		"The simulation shows your demise: %s. Learn from this failure.",
		"Your alternate self perished, %s. Their sacrifice reveals hidden truths.",
		"The Villain Simulator recorded your death: %s. This knowledge may save you."
	]
	var template = templates[randi() % templates.size()]
	return template % current_simulation["outcome"]["death_cause"]

func _generate_survival_narrative() -> String:
	"""Generate narrative text for simulation survival"""
	var templates = [
		"In this simulated path, you survived and %s. Remarkable.",
		"The simulation reveals a path to victory: %s.",
		"Your alternate self thrived, achieving %s. This future is possible.",
		"The Villain Simulator shows success: %s. Follow this path."
	]
	var template = templates[randi() % templates.size()]
	return template % current_simulation["outcome"]["achievement"]

func _generate_survival_achievement() -> String:
	"""Generate an achievement for surviving the simulation"""
	var achievements = [
		"reached the next realm of cultivation",
		"defeated a powerful sect elder",
		"uncovered an ancient treasure",
		"mastered a forbidden technique",
		"formed an alliance with a hidden sect",
		"broke through karmic shackles"
	]
	return achievements[randi() % achievements.size()]

func _generate_insights() -> Array:
	"""Generate insights gained from simulation"""
	var insights = []
	var num_insights = 1 + randi() % 3
	
	var possible_insights = [
		"The Moon Pavilion holds secrets beneath its foundation",
		"Elder Feng's weakness is his pride",
		"The Sacred Talisman resonates with void energy",
		"A hidden path exists through the Cursed Forest",
		"The Sect Master fears the return of the Demon Emperor",
		"Ancient formations lie dormant under Daxia Capital",
		"The Villain Simulator draws power from parallel timelines",
		"Your true identity is connected to the fallen immortals",
		"Karma threads can be severed with the right technique",
		"The Heavenly Dao is not as absolute as it seems"
	]
	
	for i in range(num_insights):
		if possible_insights.size() > 0:
			var idx = randi() % possible_insights.size()
			insights.append(possible_insights[idx])
			possible_insights.remove(idx)
	
	return insights

func _generate_reward_choices():
	"""Generate reward choices for the player to select"""
	var rewards = []
	
	# Always include the rolled ability as a choice
	rewards.append({
		"type": "ability",
		"data": current_simulation["rolled_ability"],
		"display": "[%s] %s" % [current_simulation["rolled_ability"]["rank"], current_simulation["rolled_ability"]["name"]]
	})
	
	# Generate 4 more random rewards
	var reward_types = ["stat", "sutra", "item", "insight", "karma"]
	
	for i in range(4):
		var reward_type = reward_types[randi() % reward_types.size()]
		var reward = _generate_reward(reward_type)
		rewards.append(reward)
	
	current_simulation["rewards"] = rewards
	emit_signal("reward_choices_available", rewards)

func _generate_reward(reward_type: String) -> Dictionary:
	"""Generate a specific type of reward"""
	match reward_type:
		"stat":
			var stats = ["strength", "spirit", "vitality", "agility"]
			var stat = stats[randi() % stats.size()]
			var value = 2 + randi() % 5
			return {
				"type": "stat",
				"data": {"stat": stat, "value": value},
				"display": "+%d %s" % [value, stat.capitalize()]
			}
		
		"sutra":
			var sutras = [
				"Sutra of Veiled Hatred",
				"Phantom Step Technique",
				"Talisman of Binding",
				"Qi Burst Formation",
				"Soul Shield Method"
			]
			var sutra = sutras[randi() % sutras.size()]
			return {
				"type": "sutra",
				"data": {"name": sutra, "sutra_type": "technique"},
				"display": "[Sutra] %s" % sutra
			}
		
		"item":
			var items = [
				"Cursed Amulet",
				"Spirit Stone (x5)",
				"Foundation Pill",
				"Talisman Paper (x10)",
				"Void Crystal Fragment"
			]
			var item = items[randi() % items.size()]
			return {
				"type": "item",
				"data": {"name": item},
				"display": "[Item] %s" % item
			}
		
		"insight":
			var insights = _generate_insights()
			var insight = insights[0] if insights.size() > 0 else "Mysterious knowledge"
			return {
				"type": "insight",
				"data": {"text": insight},
				"display": "[Insight] %s" % insight
			}
		
		"karma":
			var karma_change = (randi() % 20) - 10  # -10 to +10
			var karma_text = "Karma %+d" % karma_change
			return {
				"type": "karma",
				"data": {"value": karma_change},
				"display": "[Karma] %s" % karma_text
			}
		
		_:
			return {
				"type": "none",
				"data": {},
				"display": "Nothing"
			}

func apply_selected_rewards(reward_indices: Array):
	"""Apply the rewards selected by the player (max 2)"""
	if reward_indices.size() > 2:
		push_error("Can only select 2 rewards maximum")
		return
	
	for idx in reward_indices:
		if idx < 0 or idx >= current_simulation["rewards"].size():
			continue
		
		var reward = current_simulation["rewards"][idx]
		_apply_reward(reward)
	
	# End simulation
	is_simulating = false
	print("[SimulationManager] Simulation complete, rewards applied")

func _apply_reward(reward: Dictionary):
	"""Apply a specific reward"""
	match reward["type"]:
		"ability":
			AbilitySystem.accept_rolled_ability()
		
		"stat":
			var stat = reward["data"]["stat"]
			var value = reward["data"]["value"]
			CultivationSystem.modify_stat(stat, value)
		
		"sutra":
			var name = reward["data"]["name"]
			var sutra_type = reward["data"]["sutra_type"]
			CultivationSystem.learn_sutra(name, sutra_type)
		
		"item":
			var name = reward["data"]["name"]
			StoryStateManager.modify_state("inventory", name)
		
		"insight":
			var text = reward["data"]["text"]
			StoryStateManager.modify_state("insight_clues", text)
		
		"karma":
			var value = reward["data"]["value"]
			StoryStateManager.modify_state("karma", value)
	
	print("[SimulationManager] Reward applied: " + reward["display"])

func get_current_simulation() -> Dictionary:
	"""Get the current simulation data"""
	return current_simulation if current_simulation else {}

func get_simulation_history() -> Array:
	"""Get all past simulations"""
	return simulation_history

func get_simulation_count() -> int:
	"""Get total number of simulations run"""
	return simulation_history.size()
