extends Node

# ==========================================
# SIMULATION MANAGER - VILLAIN SIMULATOR ENGINE
# Runs procedural/AI-driven simulations of possible futures
# ==========================================

signal simulation_started(simulation_data)
signal simulation_event_occurred(event_text)
signal simulation_completed(results)
signal choice_presented(choices_array)
signal rewards_applied(selected_rewards)

# Simulation state
var is_simulating: bool = false
var current_simulation: Dictionary = {}
var simulation_log: Array = []

# Simulation configuration
var simulation_speed: float = 1.0
var auto_simulate: bool = false

# Event templates for procedural generation
var event_templates = []
var death_causes = []


func _ready():
	print("[SimulationManager] Initialized")
	_initialize_event_templates()
	_initialize_death_causes()


# ==========================================
# SIMULATION FLOW
# ==========================================

func start_simulation():
	"""Initialize and start a new simulation"""
	if is_simulating:
		push_warning("Simulation already in progress")
		return
	
	print("[Simulation] Starting new simulation...")
	is_simulating = true
	simulation_log.clear()
	
	# Roll ability for this simulation
	var rolled_ability = AbilitySystem.roll_random_ability()
	
	# Gather current player state
	var player_stats = CultivationSystem.get_all_stats()
	var player_realm = CultivationSystem.current_realm
	var karma = StoryStateManager.get_state("karma")
	var reputation = StoryStateManager.get_state("reputation")
	var destiny = StoryStateManager.get_state("destiny_thread")
	
	# Create simulation context
	current_simulation = {
		"rolled_ability": rolled_ability,
		"starting_stats": player_stats.duplicate(),
		"starting_realm": player_realm,
		"starting_karma": karma,
		"starting_reputation": reputation,
		"starting_destiny": destiny,
		"events": [],
		"duration": 0,
		"death_cause": "",
		"insights_gained": [],
		"items_found": [],
		"sutras_discovered": [],
		"stat_changes": {},
		"success_rating": 0  # 0-100
	}
	
	emit_signal("simulation_started", current_simulation)
	
	# Run simulation
	_run_simulation_logic()


func _run_simulation_logic():
	"""Execute the simulation logic (procedural generation)"""
	var simulation_length = randi() % 8 + 5  # 5-12 events
	
	_add_log("Simulation begins...")
	_add_log("You possess: " + current_simulation["rolled_ability"]["name"] + " (" + current_simulation["rolled_ability"]["rank"] + " Rank)")
	
	# Generate sequence of events based on world state
	for i in range(simulation_length):
		var event = _generate_event(i, simulation_length)
		_process_event(event)
		
		# Small delay between events for readability
		yield(get_tree().create_timer(0.3 * simulation_speed), "timeout")
	
	# Determine death/conclusion
	var conclusion = _generate_conclusion()
	_process_conclusion(conclusion)
	
	# Complete simulation
	_complete_simulation()


func _generate_event(event_index: int, total_events: int) -> Dictionary:
	"""Generate a simulation event based on current state and world context"""
	var karma = current_simulation["starting_karma"]
	var reputation = current_simulation["starting_reputation"]
	var realm = current_simulation["starting_realm"]
	
	# Weight event selection by world state
	var event_pool = []
	
	for template in event_templates:
		var weight = _calculate_event_weight(template, karma, reputation, realm)
		if weight > 0:
			event_pool.append({"template": template, "weight": weight})
	
	# Weighted random selection
	var total_weight = 0
	for e in event_pool:
		total_weight += e["weight"]
	
	var roll = randf() * total_weight
	var cumulative = 0
	for e in event_pool:
		cumulative += e["weight"]
		if roll <= cumulative:
			return _instantiate_event(e["template"])
	
	# Fallback
	return {"text": "You continue your journey...", "type": "neutral"}


func _instantiate_event(template: Dictionary) -> Dictionary:
	"""Create specific event instance from template"""
	var event = template.duplicate()
	
	# Replace variables in text
	if event.has("text_variants"):
		event["text"] = event["text_variants"][randi() % event["text_variants"].size()]
	
	return event


func _process_event(event: Dictionary):
	"""Process a simulation event and apply its effects"""
	_add_log(event["text"])
	
	current_simulation["events"].append(event)
	
	# Apply event effects to simulation state
	if event.has("karma_change"):
		current_simulation["starting_karma"] += event["karma_change"]
	
	if event.has("reputation_change"):
		current_simulation["starting_reputation"] += event["reputation_change"]
	
	if event.has("insight"):
		current_simulation["insights_gained"].append(event["insight"])
	
	if event.has("item"):
		current_simulation["items_found"].append(event["item"])
	
	if event.has("stat_change"):
		for stat in event["stat_change"].keys():
			if not current_simulation["stat_changes"].has(stat):
				current_simulation["stat_changes"][stat] = 0
			current_simulation["stat_changes"][stat] += event["stat_change"][stat]
	
	emit_signal("simulation_event_occurred", event["text"])


func _generate_conclusion() -> Dictionary:
	"""Generate simulation ending based on accumulated state"""
	var karma = current_simulation["starting_karma"]
	var reputation = current_simulation["starting_reputation"]
	
	# Select appropriate death cause
	var weighted_deaths = []
	
	for death in death_causes:
		var weight = _calculate_death_weight(death, karma, reputation)
		if weight > 0:
			weighted_deaths.append({"death": death, "weight": weight})
	
	var total_weight = 0
	for d in weighted_deaths:
		total_weight += d["weight"]
	
	var roll = randf() * total_weight
	var cumulative = 0
	for d in weighted_deaths:
		cumulative += d["weight"]
		if roll <= cumulative:
			return d["death"]
	
	# Fallback death
	return {"cause": "mysterious circumstances", "type": "neutral"}


func _process_conclusion(conclusion: Dictionary):
	"""Process the simulation conclusion"""
	current_simulation["death_cause"] = conclusion["cause"]
	
	_add_log("---")
	_add_log("Your journey ends: " + conclusion["cause"])
	
	# Calculate success rating
	var success = 50
	success += current_simulation["starting_karma"] * 0.3
	success += current_simulation["starting_reputation"] * 0.2
	success += current_simulation["insights_gained"].size() * 5
	success += current_simulation["items_found"].size() * 3
	
	current_simulation["success_rating"] = clamp(success, 0, 100)


func _complete_simulation():
	"""Finalize simulation and present choices"""
	is_simulating = false
	
	# Increment simulation counter
	StoryStateManager.modify_state("simulations_done", 1)
	
	_add_log("---")
	_add_log("Simulation complete. Success rating: " + str(current_simulation["success_rating"]))
	
	# Generate reward choices (player picks 2 of 5)
	var choices = _generate_reward_choices()
	
	emit_signal("simulation_completed", current_simulation)
	emit_signal("choice_presented", choices)
	
	print("[Simulation] Simulation completed")


# ==========================================
# REWARD SYSTEM
# ==========================================

func _generate_reward_choices() -> Array:
	"""Generate 5 reward options based on simulation results"""
	var choices = []
	
	# Option 1: Apply stat changes
	if not current_simulation["stat_changes"].empty():
		var stat_text = "Gain stats: "
		for stat in current_simulation["stat_changes"].keys():
			stat_text += "%s +%d " % [stat, current_simulation["stat_changes"][stat]]
		choices.append({
			"type": "stats",
			"description": stat_text,
			"data": current_simulation["stat_changes"]
		})
	else:
		choices.append({
			"type": "stats",
			"description": "Gain +2 to all stats",
			"data": {"strength": 2, "agility": 2, "spirit": 2, "vitality": 2}
		})
	
	# Option 2: Insights/Knowledge
	if not current_simulation["insights_gained"].empty():
		choices.append({
			"type": "insight",
			"description": "Gain insight: " + current_simulation["insights_gained"][0],
			"data": current_simulation["insights_gained"][0]
		})
	else:
		choices.append({
			"type": "insight",
			"description": "Gain random quest clue",
			"data": "You sense something important in the eastern mountains..."
		})
	
	# Option 3: Items
	if not current_simulation["items_found"].empty():
		choices.append({
			"type": "item",
			"description": "Obtain: " + current_simulation["items_found"][0],
			"data": current_simulation["items_found"][0]
		})
	else:
		choices.append({
			"type": "item",
			"description": "Obtain: Cultivation Pill (restores 50 qi)",
			"data": "Cultivation Pill"
		})
	
	# Option 4: Unlock ability
	choices.append({
		"type": "ability",
		"description": "Unlock ability: " + current_simulation["rolled_ability"]["name"],
		"data": current_simulation["rolled_ability"]["name"]
	})
	
	# Option 5: Cultivation progress
	var cult_gain = int(current_simulation["success_rating"] * 0.5)
	choices.append({
		"type": "cultivation",
		"description": "Gain %d cultivation progress" % cult_gain,
		"data": cult_gain
	})
	
	return choices


func apply_reward_choices(choice_indices: Array):
	"""Apply the rewards the player selected (2 choices)"""
	if choice_indices.size() != 2:
		push_error("Must select exactly 2 rewards")
		return
	
	var choices = _generate_reward_choices()
	var selected_rewards = []
	
	for idx in choice_indices:
		if idx < 0 or idx >= choices.size():
			continue
		
		var choice = choices[idx]
		selected_rewards.append(choice)
		
		match choice["type"]:
			"stats":
				for stat in choice["data"].keys():
					CultivationSystem.modify_stat(stat, choice["data"][stat])
				print("[Reward] Applied stat bonuses")
			
			"insight":
				StoryStateManager.modify_state("insight_clues", choice["data"])
				print("[Reward] Gained insight")
			
			"item":
				StoryStateManager.modify_state("inventory", choice["data"])
				print("[Reward] Obtained item: " + choice["data"])
			
			"ability":
				AbilitySystem.unlock_ability(choice["data"])
				print("[Reward] Unlocked ability: " + choice["data"])
			
			"cultivation":
				CultivationSystem.add_cultivation_progress(choice["data"])
				print("[Reward] Gained cultivation progress")
	
	emit_signal("rewards_applied", selected_rewards)


# ==========================================
# EVENT & DEATH TEMPLATES
# ==========================================

func _initialize_event_templates():
	"""Define event templates for simulation generation"""
	event_templates = [
		# Neutral/exploration events
		{
			"text_variants": [
				"You discover an ancient ruin covered in mysterious inscriptions.",
				"A traveling merchant offers rare cultivation resources.",
				"You encounter a fellow cultivator on their own journey."
			],
			"type": "neutral",
			"karma_weight": 0,
			"reputation_weight": 0
		},
		
		# Positive karma events
		{
			"text_variants": [
				"You save a village from demon beasts. The villagers are grateful.",
				"You help an elder break through their bottleneck.",
				"You return a stolen artifact to its rightful owner."
			],
			"type": "righteous",
			"karma_change": 5,
			"reputation_change": 3,
			"karma_weight": 1,
			"reputation_weight": 0
		},
		
		# Negative karma events
		{
			"text_variants": [
				"You plunder a sect's treasury, taking precious resources.",
				"You eliminate witnesses to your secret technique.",
				"You betray an ally for personal gain."
			],
			"type": "villainous",
			"karma_change": -8,
			"reputation_change": 5,
			"stat_change": {"strength": 1, "spirit": 1},
			"karma_weight": -1,
			"reputation_weight": 0
		},
		
		# Discovery events
		{
			"text_variants": [
				"You find a hidden cave with ancient cultivation sutras.",
				"An old jade slip reveals forgotten techniques.",
				"You decipher a secret technique from broken murals."
			],
			"type": "discovery",
			"insight": "You've learned something valuable...",
			"karma_weight": 0,
			"reputation_weight": 0
		},
		
		# Combat events
		{
			"text_variants": [
				"You clash with a rival sect's disciple. Victory is hard-won.",
				"A rogue cultivator challenges you to a duel.",
				"You face a corrupted demon in single combat."
			],
			"type": "combat",
			"stat_change": {"strength": 2, "agility": 1},
			"karma_weight": 0,
			"reputation_weight": 1
		},
		
		# Mystical events
		{
			"text_variants": [
				"You encounter a spirit that offers cryptic wisdom.",
				"A heavenly phenomenon grants you temporary enlightenment.",
				"You witness a sect master's breakthrough from afar."
			],
			"type": "mystical",
			"stat_change": {"spirit": 3},
			"insight": "The dao reveals itself in mysterious ways...",
			"karma_weight": 0,
			"reputation_weight": 0
		}
	]


func _initialize_death_causes():
	"""Define death cause templates"""
	death_causes = [
		{
			"cause": "overwhelmed by sect disciples seeking revenge",
			"type": "vengeance",
			"karma_weight": -1,
			"reputation_weight": -1
		},
		{
			"cause": "struck down by Heavenly Tribulation",
			"type": "tribulation",
			"karma_weight": -1.5,
			"reputation_weight": 0
		},
		{
			"cause": "consumed by forbidden cultivation technique",
			"type": "corruption",
			"karma_weight": -1,
			"reputation_weight": 0
		},
		{
			"cause": "ambushed by demon beasts in the wilderness",
			"type": "beast",
			"karma_weight": 0,
			"reputation_weight": 0
		},
		{
			"cause": "betrayed by a trusted ally",
			"type": "betrayal",
			"karma_weight": -0.5,
			"reputation_weight": 1
		},
		{
			"cause": "qi deviation during cultivation breakthrough",
			"type": "deviation",
			"karma_weight": 0,
			"reputation_weight": 0
		},
		{
			"cause": "poisoned by a rival's scheme",
			"type": "scheme",
			"karma_weight": 0,
			"reputation_weight": 0.5
		},
		{
			"cause": "ascending to immortality (apparent death to mortals)",
			"type": "success",
			"karma_weight": 1,
			"reputation_weight": 1
		}
	]


func _calculate_event_weight(template: Dictionary, karma: int, reputation: int, realm: String) -> float:
	"""Calculate probability weight for event based on world state"""
	var weight = 1.0
	
	# Karma influence
	if template.has("karma_weight"):
		if karma < 0 and template["karma_weight"] < 0:
			weight += abs(karma) * 0.01
		elif karma > 0 and template["karma_weight"] > 0:
			weight += karma * 0.01
	
	# Reputation influence
	if template.has("reputation_weight"):
		weight += abs(reputation) * template["reputation_weight"] * 0.005
	
	return max(weight, 0.1)


func _calculate_death_weight(death: Dictionary, karma: int, reputation: int) -> float:
	"""Calculate probability weight for death cause"""
	var weight = 1.0
	
	if death.has("karma_weight"):
		if karma < -30 and death["karma_weight"] < 0:
			weight += abs(karma) * 0.02
		elif karma > 30 and death["karma_weight"] > 0:
			weight += karma * 0.02
	
	if death.has("reputation_weight"):
		weight += abs(reputation) * 0.01
	
	return max(weight, 0.1)


# ==========================================
# LOG MANAGEMENT
# ==========================================

func _add_log(text: String):
	"""Add entry to simulation log"""
	simulation_log.append(text)
	print("[SimLog] " + text)


func get_simulation_log() -> Array:
	"""Get current simulation log"""
	return simulation_log.duplicate()


func get_full_log_text() -> String:
	"""Get simulation log as formatted text"""
	var full_text = ""
	for entry in simulation_log:
		full_text += entry + "\n"
	return full_text


# ==========================================
# SAVE/LOAD
# ==========================================

func get_save_data() -> Dictionary:
	"""Return simulation data for saving"""
	return {
		"last_simulation": current_simulation.duplicate(true),
		"simulation_count": StoryStateManager.get_state("simulations_done")
	}


func load_save_data(data: Dictionary):
	"""Restore simulation data"""
	if data.has("last_simulation"):
		current_simulation = data["last_simulation"].duplicate(true)
	
	print("[SimulationManager] Loaded saved data")
