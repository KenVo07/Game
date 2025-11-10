extends Control

# ==========================================
# SIMULATION MENU UI
# ==========================================
# UI for viewing and starting simulations

# UI Elements
onready var simulation_button = $VBoxContainer/StartSimulationButton
onready var narrative_text = $VBoxContainer/ScrollContainer/NarrativeText
onready var reward_container = $VBoxContainer/RewardContainer
onready var ability_info = $VBoxContainer/AbilityInfo

# State
var current_simulation = {}
var selected_rewards = []

# Signals
signal simulation_requested()
signal rewards_confirmed(reward1, reward2)

func _ready():
	visible = false
	
	# Connect signals
	SimulationManager.connect("simulation_started", self, "_on_simulation_started")
	SimulationManager.connect("simulation_completed", self, "_on_simulation_completed")
	
	# Connect button
	if simulation_button:
		simulation_button.connect("pressed", self, "_on_start_simulation_pressed")

func _input(event):
	"""
	Handle input
	"""
	if event.is_action_pressed("open_simulation") and not visible:
		open_menu()
	elif event.is_action_pressed("ui_cancel") and visible:
		close_menu()

# ==========================================
# MENU CONTROL
# ==========================================

func open_menu():
	"""
	Open simulation menu
	"""
	visible = true
	get_tree().paused = true
	
	# Update UI
	update_simulation_info()

func close_menu():
	"""
	Close simulation menu
	"""
	visible = false
	get_tree().paused = false

func update_simulation_info():
	"""
	Update simulation information
	"""
	if narrative_text:
		var sim_count = StoryStateManager.get_state("simulations_done")
		var faith = StoryStateManager.get_state("faith_in_system")
		
		var info = "=== VILLAIN SIMULATOR ===\n\n"
		info += "Simulations Run: %d\n" % sim_count
		info += "Faith in System: %d%%\n\n" % faith
		info += "Each simulation reveals a possible future.\n"
		info += "Learn from your deaths, grow stronger.\n\n"
		
		if faith < 30:
			info += "[WARNING] Faith in system critically low!\n"
		
		narrative_text.text = info

# ==========================================
# SIMULATION FLOW
# ==========================================

func _on_start_simulation_pressed():
	"""
	Start a new simulation
	"""
	# Disable button
	if simulation_button:
		simulation_button.disabled = true
	
	# Start simulation
	SimulationManager.start_simulation()

func _on_simulation_started(simulation_data):
	"""
	Handle simulation start
	"""
	current_simulation = simulation_data
	display_simulation_results()

func display_simulation_results():
	"""
	Display simulation narrative and results
	"""
	if not narrative_text:
		return
	
	var result = current_simulation["simulation_result"]
	var ability = current_simulation["rolled_ability"]
	
	# Display ability
	if ability_info:
		var ability_text = "[%s] %s\n%s" % [
			ability["rank"],
			ability["name"],
			ability["description"]
		]
		ability_info.text = ability_text
	
	# Display narrative
	narrative_text.text = result["narrative"]
	
	# Display reward options
	display_reward_options()

func display_reward_options():
	"""
	Display 5 reward options for player to choose 2
	"""
	if not reward_container:
		return
	
	# Clear existing rewards
	for child in reward_container.get_children():
		child.queue_free()
	
	var options = current_simulation["reward_options"]
	
	# Create buttons for each option
	for option in options:
		var button = Button.new()
		button.text = "[%s] %s" % [option["id"], option["description"]]
		button.connect("pressed", self, "_on_reward_selected", [option["id"]])
		reward_container.add_child(button)
	
	# Add confirm button
	var confirm_button = Button.new()
	confirm_button.text = "Confirm Selection (Select 2)"
	confirm_button.disabled = true
	confirm_button.name = "ConfirmButton"
	confirm_button.connect("pressed", self, "_on_confirm_rewards")
	reward_container.add_child(confirm_button)

func _on_reward_selected(reward_id: String):
	"""
	Handle reward selection
	"""
	if reward_id in selected_rewards:
		# Deselect
		selected_rewards.erase(reward_id)
	else:
		# Select
		if selected_rewards.size() < 2:
			selected_rewards.append(reward_id)
	
	# Update button states
	update_reward_button_states()

func update_reward_button_states():
	"""
	Update reward button visual states
	"""
	if not reward_container:
		return
	
	for child in reward_container.get_children():
		if child is Button and child.name != "ConfirmButton":
			# Extract reward ID from button text
			var text = child.text
			var id = text.substr(1, 1)  # Get character between [ and ]
			
			if id in selected_rewards:
				child.modulate = Color.yellow
			else:
				child.modulate = Color.white
			
			# Disable unselected buttons if 2 are already selected
			if selected_rewards.size() >= 2 and not id in selected_rewards:
				child.disabled = true
			else:
				child.disabled = false
	
	# Enable/disable confirm button
	var confirm_button = reward_container.get_node_or_null("ConfirmButton")
	if confirm_button:
		confirm_button.disabled = selected_rewards.size() != 2

func _on_confirm_rewards():
	"""
	Confirm reward selection
	"""
	if selected_rewards.size() != 2:
		return
	
	# Apply rewards
	SimulationManager.select_rewards(selected_rewards[0], selected_rewards[1])
	
	# Clear selection
	selected_rewards.clear()
	
	# Re-enable simulation button
	if simulation_button:
		simulation_button.disabled = false
	
	# Show completion message
	if narrative_text:
		narrative_text.text += "\n\n=== Rewards Applied ==="
	
	# Close menu after a delay
	yield(get_tree().create_timer(2.0), "timeout")
	close_menu()

func _on_simulation_completed(results):
	"""
	Handle simulation completion
	"""
	pass  # Already handled in reward confirmation

# ==========================================
# SPECIAL FUNCTIONS
# ==========================================

func can_reroll():
	"""
	Check if player can reroll simulation
	"""
	return SimulationManager.can_reroll_simulation()

func reroll_simulation():
	"""
	Reroll the simulation
	"""
	if can_reroll():
		selected_rewards.clear()
		SimulationManager.reroll_simulation()
