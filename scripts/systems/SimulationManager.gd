extends Node

# Villain Simulator - Core Simulation System
# Generates procedural narrative simulations based on current world state

signal simulation_started()
signal simulation_completed(result)
signal simulation_choice_presented(choices)

# Simulation state
var is_simulating = false
var current_simulation = null
var simulation_log = []

# Narrative templates for death causes
var death_causes = [
	"overwhelmed by cursed qi during cultivation",
	"ambushed by rival sect assassins",
	"consumed by inner demons during breakthrough",
	"betrayed by a trusted ally",
	"struck down by heavenly tribulation",
	"sacrificed in a forbidden ritual",
	"lost in the void between realms",
	"torn apart by spatial rift",
	"poisoned by a demonic artifact",
	"challenged a Saint realm expert and lost",
	"drained of life force by ancient formation",
	"possessed by an evil spirit"
]

# Event templates
var event_templates = [
	"encountered a mysterious cave",
	"met a wandering cultivator",
	"discovered an ancient ruin",
	"challenged by a sect disciple",
	"found a rare spiritual herb",
	"triggered a hidden formation",
	"saved by a fortuitous encounter",
	"witnessed a demonic ritual",
	"stumbled upon a secret meeting",
	"attracted by strange phenomenon"
]

func _ready():
	randomize()

# Start a new simulation
func start_simulation():
	if is_simulating:
		push_warning("Simulation already in progress")
		return
	
	is_simulating = true
	emit_signal("simulation_started")
	
	# Roll new ability for this simulation
	var rolled_ability = AbilitySystem.roll_random_ability()
	
	# Run simulation
	current_simulation = _run_simulation(rolled_ability)
	
	# Increment simulations counter
	StoryStateManager.modify_state("simulations_done", 1, "Simulation completed")
	StoryStateManager.modify_state("deaths_witnessed", 1, "Witnessed simulated death")
	
	# Add to simulation log
	simulation_log.append(current_simulation)
	if simulation_log.size() > 50:
		simulation_log.pop_front()
	
	is_simulating = false
	emit_signal("simulation_completed", current_simulation)
	
	# Present choices to player
	_present_choices(current_simulation)
	
	return current_simulation

# Core simulation logic
func _run_simulation(rolled_ability: Dictionary) -> Dictionary:
	var result = {
		"ability": rolled_ability,
		"events": [],
		"death_cause": "",
		"rewards": {
			"stats": {},
			"items": [],
			"sutras": [],
			"insights": []
		},
		"narrative": "",
		"duration_days": 0
	}
	
	# Simulate a series of events
	var num_events = randi() % 5 + 3  # 3-7 events
	var current_karma = StoryStateManager.world_state["karma"]
	var current_realm = CultivationSystem.current_realm
	
	var narrative_parts = []
	narrative_parts.append("You enter the simulation with the ability: [color=#%s]%s[/color]" % [
		AbilitySystem.get_rank_color(rolled_ability["rank"]).to_html(false),
		rolled_ability["name"]
	])
	
	# Generate events based on world state
	for i in range(num_events):
		var event = _generate_event(current_karma, current_realm)
		result["events"].append(event)
		narrative_parts.append(event["description"])
		
		# Accumulate rewards
		if event.has("stat_gain"):
			for stat in event["stat_gain"]:
				if not result["rewards"]["stats"].has(stat):
					result["rewards"]["stats"][stat] = 0
				result["rewards"]["stats"][stat] += event["stat_gain"][stat]
		
		if event.has("item"):
			result["rewards"]["items"].append(event["item"])
		
		if event.has("insight"):
			result["rewards"]["insights"].append(event["insight"])
	
	# Determine death cause
	result["death_cause"] = _generate_death_cause(current_karma, rolled_ability)
	narrative_parts.append("\n[color=red]The simulation ends: %s[/color]" % result["death_cause"])
	
	# Calculate duration
	result["duration_days"] = randi() % 1000 + 100
	
	# Possibly grant a sutra
	if randf() < 0.3:  # 30% chance
		var sutra = _generate_random_sutra()
		result["rewards"]["sutras"].append(sutra)
	
	# Generate full narrative
	result["narrative"] = "\n\n".join(narrative_parts)
	
	return result

# Generate a single simulation event
func _generate_event(karma: int, realm: String) -> Dictionary:
	var event = {
		"description": "",
		"stat_gain": {},
		"item": null,
		"insight": null
	}
	
	# Choose event type based on karma
	var event_type = randi() % 4
	
	match event_type:
		0:  # Combat encounter
			if karma < -20:
				event["description"] = "You brutally slaughter a group of righteous cultivators. Their screams echo in the void."
				event["stat_gain"] = {"strength": randi() % 3 + 1}
			else:
				event["description"] = "You defend yourself against demonic beasts, barely surviving."
				event["stat_gain"] = {"vitality": randi() % 2 + 1}
		
		1:  # Cultivation opportunity
			event["description"] = event_templates[randi() % event_templates.size()] + ". You use this chance to cultivate."
			event["stat_gain"] = {"spirit": randi() % 3 + 1, "comprehension": randi() % 2 + 1}
		
		2:  # Social encounter
			if karma > 20:
				event["description"] = "A senior cultivator recognizes your righteous aura and shares wisdom."
				event["stat_gain"] = {"comprehension": randi() % 4 + 2}
			else:
				event["description"] = "You manipulate a sect disciple, stealing their resources."
				event["item"] = _generate_random_item()
		
		3:  # Discovery
			event["description"] = "You discover an ancient inscription that hints at hidden secrets."
			event["insight"] = _generate_random_insight()
	
	return event

# Generate death cause based on context
func _generate_death_cause(karma: int, ability: Dictionary) -> String:
	var causes = death_causes.duplicate()
	
	# Karma-influenced deaths
	if karma < -50:
		causes.append("struck down by heavenly punishment for accumulated sins")
		causes.append("betrayed and killed by your own demonic allies")
	elif karma > 50:
		causes.append("sacrificed yourself to save innocent lives")
		causes.append("peacefully ascended, but still technically 'died' in mortal realm")
	
	# Ability-influenced deaths
	if ability.has("name"):
		if "Demon" in ability["name"]:
			causes.append("consumed by your own demonic power")
		elif "Heavenly" in ability["name"]:
			causes.append("rejected by the heavens for your actions")
	
	return causes[randi() % causes.size()]

# Generate random item
func _generate_random_item() -> String:
	var items = [
		"Cursed Amulet",
		"Spirit Stone Cache",
		"Ancient Jade Slip",
		"Blood Refinement Pill",
		"Talisman Paper Bundle",
		"Immortal's Remnant",
		"Demonic Core Fragment",
		"Celestial Silk Robe"
	]
	return items[randi() % items.size()]

# Generate random sutra
func _generate_random_sutra() -> String:
	var sutras = [
		"Sutra of Veiled Hatred",
		"Sutra of Thunder Palm",
		"Sutra of Shadow Steps",
		"Sutra of Blood Refinement",
		"Sutra of Talisman Arts",
		"Sutra of Heavenly Sword",
		"Sutra of Phantom Dance"
	]
	return sutras[randi() % sutras.size()]

# Generate random insight/clue
func _generate_random_insight() -> String:
	var insights = [
		"The Cursed Amulet resonates strongly near Moon Pavilion",
		"A hidden passage exists beneath the Imperial Palace",
		"The Blood Demon Sect is planning a major assault",
		"An ancient formation can be activated with three jade keys",
		"The Sect Master of Talisman Sect has a dark secret",
		"A Saint realm expert is sealed in the Forbidden Mountains",
		"The Villain Simulator may have a sentient core"
	]
	return insights[randi() % insights.size()]

# Present choices to player after simulation
func _present_choices(simulation: Dictionary):
	var choices = []
	
	# Always include the rolled ability as option A
	choices.append({
		"type": "ability",
		"label": "A: Unlock Ability - " + simulation["ability"]["name"],
		"value": simulation["ability"]
	})
	
	# Option B: Stat gains
	if not simulation["rewards"]["stats"].empty():
		var stat_desc = ""
		for stat in simulation["rewards"]["stats"]:
			stat_desc += "%s +%d " % [stat.capitalize(), simulation["rewards"]["stats"][stat]]
		choices.append({
			"type": "stats",
			"label": "B: Gain Stats - " + stat_desc,
			"value": simulation["rewards"]["stats"]
		})
	
	# Option C: Items
	if not simulation["rewards"]["items"].empty():
		choices.append({
			"type": "items",
			"label": "C: Acquire Items - " + ", ".join(simulation["rewards"]["items"]),
			"value": simulation["rewards"]["items"]
		})
	
	# Option D: Sutras
	if not simulation["rewards"]["sutras"].empty():
		choices.append({
			"type": "sutras",
			"label": "D: Learn Sutra - " + simulation["rewards"]["sutras"][0],
			"value": simulation["rewards"]["sutras"][0]
		})
	
	# Option E: Insights
	if not simulation["rewards"]["insights"].empty():
		choices.append({
			"type": "insights",
			"label": "E: Gain Insight - " + simulation["rewards"]["insights"][0],
			"value": simulation["rewards"]["insights"][0]
		})
	
	# Pad with generic options if needed
	while choices.size() < 5:
		choices.append({
			"type": "cultivation",
			"label": "%s: Cultivation Progress" % char(65 + choices.size()),
			"value": 0.1
		})
	
	emit_signal("simulation_choice_presented", choices)

# Apply chosen rewards
func apply_choice(choice: Dictionary):
	match choice["type"]:
		"ability":
			AbilitySystem.unlock_ability(choice["value"], false)
		
		"stats":
			for stat in choice["value"]:
				CultivationSystem.modify_stat(stat, choice["value"][stat])
		
		"items":
			for item in choice["value"]:
				if item not in StoryStateManager.world_state["inventory"]:
					StoryStateManager.world_state["inventory"].append(item)
		
		"sutras":
			CultivationSystem.learn_sutra(choice["value"])
		
		"insights":
			if choice["value"] not in StoryStateManager.world_state["insight_clues"]:
				StoryStateManager.world_state["insight_clues"].append(choice["value"])
		
		"cultivation":
			CultivationSystem.cultivation_progress += choice["value"]

# Get simulation history
func get_simulation_log(count: int = 10) -> Array:
	var start = max(0, simulation_log.size() - count)
	return simulation_log.slice(start, simulation_log.size() - 1)

# Save/Load
func save_to_dict() -> Dictionary:
	return {
		"simulation_log": simulation_log.duplicate(true),
		"current_simulation": current_simulation
	}

func load_from_dict(data: Dictionary):
	if data.has("simulation_log"):
		simulation_log = data["simulation_log"].duplicate(true)
	if data.has("current_simulation"):
		current_simulation = data["current_simulation"]
