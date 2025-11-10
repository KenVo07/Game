extends Node

# ==========================================
# SIMULATION MANAGER - VILLAIN SIMULATOR
# ==========================================
# Manages the simulation system that predicts possible futures

# Simulation state
var simulation_active = false
var current_simulation = {}
var simulation_logs = []  # History of all simulations

# Simulation templates for narrative generation
var death_causes = [
	"overwhelmed by cursed qi",
	"betrayed by a trusted disciple",
	"consumed by demonic cultivation",
	"struck down by heavenly tribulation",
	"sealed by a righteous sect alliance",
	"lost in spatial void during breakthrough",
	"poisoned during a sect banquet",
	"ambushed by assassins from Shadow Demon Cult",
	"drained by a forbidden talisman",
	"fell into an ancient formation trap"
]

var event_templates = [
	"discovered an ancient cave",
	"encountered a mysterious cultivator",
	"witnessed a sect war",
	"found a legendary artifact",
	"was challenged to a duel",
	"uncovered a conspiracy",
	"broke through to the next realm",
	"formed an alliance with a powerful sect",
	"offended a hidden expert",
	"accidentally released a sealed demon"
]

# Reward options structure
var current_reward_options = []

# Signals
signal simulation_started(simulation_data)
signal simulation_completed(results)
signal rewards_presented(options)
signal reward_selected(reward_data)

func _ready():
	print("SimulationManager initialized")
	randomize()

# ==========================================
# SIMULATION FLOW
# ==========================================

func start_simulation() -> Dictionary:
	"""
	Start a new simulation
	Main simulation flow:
	1. Roll ability rank
	2. Load current stats and sutra
	3. Generate narrative events
	4. Determine death/outcome
	5. Calculate rewards
	6. Present choices
	"""
	if simulation_active:
		push_warning("Simulation already active")
		return {}
	
	simulation_active = true
	
	# Step 1: Roll ability for this simulation
	var rolled_ability = AbilitySystem.roll_ability()
	
	# Step 2: Load current player state
	var current_stats = CultivationSystem.stats.duplicate()
	var current_realm = CultivationSystem.get_current_realm()
	var heart_sutra = CultivationSystem.heart_sutra
	var karma = StoryStateManager.get_state("karma")
	var reputation = StoryStateManager.get_state("reputation")
	
	# Step 3 & 4: Run simulation logic
	var simulation_result = run_simulation_logic(rolled_ability, current_stats, karma)
	
	# Step 5: Generate rewards
	var rewards = generate_reward_options(simulation_result, rolled_ability)
	
	# Create simulation record
	current_simulation = {
		"timestamp": OS.get_unix_time(),
		"rolled_ability": rolled_ability,
		"starting_stats": current_stats,
		"starting_realm": current_realm,
		"starting_karma": karma,
		"simulation_result": simulation_result,
		"reward_options": rewards
	}
	
	# Increment simulation count
	StoryStateManager.modify_state("simulations_done", 1)
	
	# Add to history
	simulation_logs.append(current_simulation.duplicate())
	
	emit_signal("simulation_started", current_simulation)
	print("Simulation started with ", rolled_ability["rank"], " ability: ", rolled_ability["name"])
	
	return current_simulation

func run_simulation_logic(rolled_ability: Dictionary, stats: Dictionary, karma: int) -> Dictionary:
	"""
	Core simulation logic - generates narrative and outcome
	This is where the "villain simulator" creates the story
	"""
	var events = []
	var insights = []
	var new_items = []
	var new_sutras = []
	var stat_changes = {}
	
	# Determine simulation length based on ability rank and karma
	var event_count = get_simulation_event_count(rolled_ability["rank"], karma)
	
	# Generate events
	for i in range(event_count):
		var event = generate_simulation_event(rolled_ability, karma, i)
		events.append(event)
		
		# Events can provide rewards
		if event.has("item_found"):
			new_items.append(event["item_found"])
		if event.has("insight"):
			insights.append(event["insight"])
	
	# Determine death cause (influenced by karma and ability)
	var death_cause = determine_death_cause(rolled_ability, karma, events)
	
	# Calculate stat changes from simulation
	stat_changes = calculate_stat_changes(rolled_ability, events, death_cause)
	
	# Possibly discover new sutras
	if randf() < get_sutra_discovery_chance(rolled_ability["rank"]):
		new_sutras.append(generate_sutra_reward(karma))
	
	# Generate narrative log
	var narrative = generate_narrative_log(events, death_cause, rolled_ability)
	
	return {
		"events": events,
		"death_cause": death_cause,
		"narrative": narrative,
		"stat_changes": stat_changes,
		"new_items": new_items,
		"new_sutras": new_sutras,
		"insights": insights,
		"survival_time": event_count * 10  # Each event = ~10 days
	}

func get_simulation_event_count(ability_rank: String, karma: int) -> int:
	"""
	Determine how many events occur in the simulation
	"""
	var base_count = 3
	
	match ability_rank:
		"White":
			base_count = 2
		"Green":
			base_count = 3
		"Blue":
			base_count = 4
		"Purple":
			base_count = 5
		"Gold":
			base_count = 7
	
	# Karma can extend or shorten survival
	if karma > 30:
		base_count += 1
	elif karma < -30:
		base_count -= 1
	
	return max(1, base_count)

func generate_simulation_event(ability: Dictionary, karma: int, event_index: int) -> Dictionary:
	"""
	Generate a single event in the simulation
	"""
	var event_text = event_templates[randi() % event_templates.size()]
	var event = {
		"description": event_text,
		"index": event_index
	}
	
	# Chance to find items or gain insights
	if randf() < 0.3:
		var items = ["Cursed Amulet", "Ancient Jade", "Blood Pill", "Spirit Stone", "Talisman Fragment"]
		event["item_found"] = items[randi() % items.size()]
	
	if randf() < 0.2:
		var insight_options = [
			"The Moon Pavilion hides a dark secret",
			"A hidden path exists beneath the Crimson Sect",
			"The System's power comes from absorbed souls",
			"An ancient seal is weakening in the North"
		]
		event["insight"] = insight_options[randi() % insight_options.size()]
	
	# Karma influences events
	if karma < -30 and randf() < 0.4:
		event["karma_event"] = "attracted demonic attention"
	elif karma > 30 and randf() < 0.3:
		event["karma_event"] = "received heaven's blessing"
	
	return event

func determine_death_cause(ability: Dictionary, karma: int, events: Array) -> String:
	"""
	Determine how the simulated self dies
	"""
	var possible_deaths = death_causes.duplicate()
	
	# Karma influences death type
	if karma < -50:
		possible_deaths.append("consumed by inner demons")
		possible_deaths.append("hunted by righteous cultivators")
	elif karma > 50:
		possible_deaths.append("sacrificed self to seal evil")
		possible_deaths.append("ascended but left a regret")
	
	# Ability rank affects survival
	if ability["rank"] == "Gold":
		if randf() < 0.3:
			return "achieved enlightenment and transcended"
	elif ability["rank"] == "White":
		possible_deaths.append("died to a common beast")
		possible_deaths.append("failed first breakthrough")
	
	return possible_deaths[randi() % possible_deaths.size()]

func calculate_stat_changes(ability: Dictionary, events: Array, death_cause: String) -> Dictionary:
	"""
	Calculate what stats the player gains from this simulation
	"""
	var changes = {
		"strength": 0,
		"spirit": 0,
		"comprehension": 0
	}
	
	# Base gains from event count
	changes["strength"] = events.size()
	changes["spirit"] = events.size()
	changes["comprehension"] = int(events.size() * 0.5)
	
	# Ability rank multiplier
	var multiplier = 1.0
	match ability["rank"]:
		"White":
			multiplier = 1.0
		"Green":
			multiplier = 1.3
		"Blue":
			multiplier = 1.6
		"Purple":
			multiplier = 2.0
		"Gold":
			multiplier = 3.0
	
	for stat in changes:
		changes[stat] = int(changes[stat] * multiplier)
	
	# Death cause can provide bonuses
	if "tribulation" in death_cause.to_lower():
		changes["spirit"] += 5
	if "demonic" in death_cause.to_lower():
		changes["strength"] += 5
	
	return changes

func get_sutra_discovery_chance(ability_rank: String) -> float:
	"""
	Chance to discover a new sutra
	"""
	match ability_rank:
		"White":
			return 0.05
		"Green":
			return 0.10
		"Blue":
			return 0.20
		"Purple":
			return 0.35
		"Gold":
			return 0.60
	return 0.05

func generate_sutra_reward(karma: int) -> String:
	"""
	Generate a sutra as a reward
	"""
	var sutras = []
	
	if karma < -30:
		sutras = ["Blood Demon Arts", "Heart Sutra of Veiled Hatred"]
	elif karma > 30:
		sutras = ["Celestial Blade Codex", "Heart Sutra of Celestial Harmony"]
	else:
		sutras = ["Talisman Strike Sutra", "Shadow Step Manual"]
	
	return sutras[randi() % sutras.size()]

func generate_narrative_log(events: Array, death_cause: String, ability: Dictionary) -> String:
	"""
	Generate a narrative text log of the simulation
	This would ideally use AI/LLM, but we'll use template-based for now
	"""
	var narrative = ""
	narrative += "With the power of [" + ability["rank"] + "] " + ability["name"] + ", the simulation begins.\n\n"
	
	for event in events:
		narrative += "• " + event["description"].capitalize() + ".\n"
		if event.has("item_found"):
			narrative += "  Found: " + event["item_found"] + "\n"
		if event.has("insight"):
			narrative += "  Insight: " + event["insight"] + "\n"
	
	narrative += "\nEventually, the simulated self " + death_cause + ".\n"
	narrative += "\nThe vision fades, but knowledge remains..."
	
	return narrative

# ==========================================
# REWARD SYSTEM
# ==========================================

func generate_reward_options(simulation_result: Dictionary, ability: Dictionary) -> Array:
	"""
	Generate 5 reward options (A, B, C, D, E)
	Player selects 2
	"""
	var options = []
	
	# Option A: Stat increases
	if not simulation_result["stat_changes"].empty():
		options.append({
			"id": "A",
			"type": "stats",
			"description": "Gain " + str(simulation_result["stat_changes"]),
			"data": simulation_result["stat_changes"]
		})
	
	# Option B: Learn the rolled ability
	options.append({
		"id": "B",
		"type": "ability",
		"description": "Unlock ability: " + ability["name"],
		"data": ability
	})
	
	# Option C: Items found
	if simulation_result["new_items"].size() > 0:
		options.append({
			"id": "C",
			"type": "items",
			"description": "Obtain items: " + str(simulation_result["new_items"]),
			"data": simulation_result["new_items"]
		})
	else:
		# Fallback: random item
		options.append({
			"id": "C",
			"type": "items",
			"description": "Obtain: Spirit Stones x10",
			"data": ["Spirit Stone"]
		})
	
	# Option D: Sutras
	if simulation_result["new_sutras"].size() > 0:
		options.append({
			"id": "D",
			"type": "sutra",
			"description": "Learn sutra: " + simulation_result["new_sutras"][0],
			"data": simulation_result["new_sutras"][0]
		})
	else:
		options.append({
			"id": "D",
			"type": "cultivation",
			"description": "Gain realm progress: +15%",
			"data": 0.15
		})
	
	# Option E: Insights or special rewards
	if simulation_result["insights"].size() > 0:
		options.append({
			"id": "E",
			"type": "insight",
			"description": "Gain insight: " + simulation_result["insights"][0],
			"data": simulation_result["insights"]
		})
	else:
		options.append({
			"id": "E",
			"type": "karma",
			"description": "Destiny shift: +10 Karma",
			"data": 10
		})
	
	current_reward_options = options
	return options

func select_rewards(choice1: String, choice2: String):
	"""
	Player selects 2 rewards from options
	"""
	if choice1 == choice2:
		push_error("Cannot select same reward twice")
		return
	
	var selected_rewards = []
	
	for option in current_reward_options:
		if option["id"] == choice1 or option["id"] == choice2:
			selected_rewards.append(option)
			apply_reward(option)
	
	emit_signal("reward_selected", selected_rewards)
	complete_simulation()

func apply_reward(reward: Dictionary):
	"""
	Apply a selected reward
	"""
	match reward["type"]:
		"stats":
			for stat in reward["data"]:
				CultivationSystem.modify_stat(stat, reward["data"][stat])
			print("Applied stat reward: ", reward["data"])
		
		"ability":
			AbilitySystem.unlock_ability(reward["data"])
			print("Unlocked ability: ", reward["data"]["name"])
		
		"items":
			for item in reward["data"]:
				StoryStateManager.add_item(item)
			print("Obtained items: ", reward["data"])
		
		"sutra":
			var sutra_name = reward["data"]
			if CultivationSystem.sutra_database.has(sutra_name):
				var sutra = CultivationSystem.sutra_database[sutra_name]
				if sutra["type"] == "heart":
					CultivationSystem.load_heart_sutra(sutra_name)
				else:
					CultivationSystem.learn_technique_sutra(sutra_name)
			print("Learned sutra: ", sutra_name)
		
		"cultivation":
			CultivationSystem.add_realm_progress(reward["data"])
			print("Gained realm progress: ", reward["data"])
		
		"insight":
			for insight in reward["data"]:
				StoryStateManager.add_insight(insight)
			print("Gained insights: ", reward["data"])
		
		"karma":
			StoryStateManager.modify_state("karma", reward["data"])
			print("Karma changed: ", reward["data"])

func complete_simulation():
	"""
	Complete the current simulation
	"""
	simulation_active = false
	
	# Decrease faith in system slightly
	StoryStateManager.modify_state("faith_in_system", -1)
	
	emit_signal("simulation_completed", current_simulation)
	print("Simulation completed")

# ==========================================
# SIMULATION HISTORY
# ==========================================

func get_simulation_count() -> int:
	"""
	Get total number of simulations run
	"""
	return simulation_logs.size()

func get_last_simulation() -> Dictionary:
	"""
	Get the most recent simulation
	"""
	if simulation_logs.size() > 0:
		return simulation_logs[simulation_logs.size() - 1]
	return {}

func get_simulation_history(count: int = 10) -> Array:
	"""
	Get recent simulation history
	"""
	var history = []
	var start_idx = max(0, simulation_logs.size() - count)
	for i in range(start_idx, simulation_logs.size()):
		history.append(simulation_logs[i])
	return history

func get_all_simulations() -> Array:
	"""
	Get all simulation logs
	"""
	return simulation_logs

# ==========================================
# SPECIAL SIMULATION MODES
# ==========================================

func can_reroll_simulation() -> bool:
	"""
	Check if player can reroll (Fate Weaver ability)
	"""
	return AbilitySystem.has_ability("Fate Weaver")

func reroll_simulation():
	"""
	Reroll the current simulation (if Fate Weaver ability is unlocked)
	"""
	if not can_reroll_simulation():
		push_error("Cannot reroll simulation without Fate Weaver ability")
		return
	
	if not simulation_active:
		push_error("No active simulation to reroll")
		return
	
	print("Rerolling simulation with Fate Weaver...")
	
	# Remove last simulation from logs
	if simulation_logs.size() > 0:
		simulation_logs.pop_back()
	
	# Start new simulation
	start_simulation()

# ==========================================
# SERIALIZATION
# ==========================================

func get_save_data() -> Dictionary:
	"""
	Get data to save
	"""
	return {
		"simulation_logs": simulation_logs.duplicate(),
		"current_simulation": current_simulation.duplicate() if simulation_active else {}
	}

func load_save_data(data: Dictionary):
	"""
	Load data from save
	"""
	if data.has("simulation_logs"):
		simulation_logs = data["simulation_logs"]
	if data.has("current_simulation") and not data["current_simulation"].empty():
		current_simulation = data["current_simulation"]
		simulation_active = true
	
	print("Simulation data loaded")

# ==========================================
# DEBUGGING
# ==========================================

func print_simulation_summary():
	"""
	Print summary of current simulation
	"""
	if current_simulation.empty():
		print("No active simulation")
		return
	
	print("=== SIMULATION SUMMARY ===")
	print("Ability: [", current_simulation["rolled_ability"]["rank"], "] ", 
		  current_simulation["rolled_ability"]["name"])
	print("Events: ", current_simulation["simulation_result"]["events"].size())
	print("Death: ", current_simulation["simulation_result"]["death_cause"])
	print("Survival: ", current_simulation["simulation_result"]["survival_time"], " days")
	print("==========================")
