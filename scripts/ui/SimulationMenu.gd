extends Control

# ==========================================
# SIMULATION MENU - VILLAIN SIMULATOR UI
# Main interface for running simulations and choosing rewards
# ==========================================

signal simulation_initiated()
signal rewards_selected(reward_indices)

# UI References
onready var simulation_log = $Panel/MarginContainer/VBoxContainer/SimulationLog
onready var start_button = $Panel/MarginContainer/VBoxContainer/ButtonsPanel/StartButton
onready var reward_choices_panel = $Panel/MarginContainer/VBoxContainer/RewardChoicesPanel
onready var ability_roll_label = $Panel/MarginContainer/VBoxContainer/AbilityRollLabel
onready var success_rating_label = $Panel/MarginContainer/VBoxContainer/SuccessRatingLabel

# Reward choice buttons
var reward_buttons: Array = []
var selected_rewards: Array = []
var max_reward_selections: int = 2

# State
var is_simulating: bool = false
var current_choices: Array = []


func _ready():
	print("[SimulationMenu] Initialized")
	visible = false
	_connect_signals()
	_setup_reward_buttons()


func _connect_signals():
	"""Connect to simulation manager"""
	SimulationManager.connect("simulation_started", self, "_on_simulation_started")
	SimulationManager.connect("simulation_event_occurred", self, "_on_simulation_event")
	SimulationManager.connect("simulation_completed", self, "_on_simulation_completed")
	SimulationManager.connect("choice_presented", self, "_on_choices_presented")
	
	# Connect start button
	if start_button:
		start_button.connect("pressed", self, "_on_start_button_pressed")


func _setup_reward_buttons():
	"""Create reward selection buttons"""
	if not reward_choices_panel:
		return
	
	# Create 5 reward option buttons
	for i in range(5):
		var button = Button.new()
		button.name = "RewardButton" + str(i)
		button.text = "Reward Option " + str(i + 1)
		button.toggle_mode = true
		button.connect("toggled", self, "_on_reward_button_toggled", [i])
		reward_choices_panel.add_child(button)
		reward_buttons.append(button)
	
	reward_choices_panel.visible = false


# ==========================================
# MENU CONTROL
# ==========================================

func open():
	"""Open simulation menu"""
	visible = true
	_reset_ui()
	print("[SimulationMenu] Opened")


func close():
	"""Close simulation menu"""
	visible = false
	print("[SimulationMenu] Closed")


func _reset_ui():
	"""Reset UI to default state"""
	if simulation_log:
		simulation_log.clear()
	
	if ability_roll_label:
		ability_roll_label.text = ""
	
	if success_rating_label:
		success_rating_label.text = ""
	
	if reward_choices_panel:
		reward_choices_panel.visible = false
	
	if start_button:
		start_button.disabled = false
		start_button.text = "Start Simulation"
	
	selected_rewards.clear()
	current_choices.clear()


# ==========================================
# SIMULATION FLOW
# ==========================================

func _on_start_button_pressed():
	"""Handle start simulation button"""
	if is_simulating:
		return
	
	print("[SimulationMenu] Starting simulation...")
	start_button.disabled = true
	start_button.text = "Simulating..."
	
	# Start simulation
	SimulationManager.start_simulation()
	emit_signal("simulation_initiated")


func _on_simulation_started(simulation_data):
	"""Handle simulation start"""
	is_simulating = true
	
	# Display rolled ability
	var ability = simulation_data["rolled_ability"]
	if ability_roll_label and not ability.empty():
		ability_roll_label.text = "Rolled Ability: %s (%s Rank)" % [ability["name"], ability["rank"]]
		
		# Color by rank
		match ability["rank"]:
			"White":
				ability_roll_label.add_color_override("font_color", Color.white)
			"Green":
				ability_roll_label.add_color_override("font_color", Color.green)
			"Blue":
				ability_roll_label.add_color_override("font_color", Color.cyan)
			"Purple":
				ability_roll_label.add_color_override("font_color", Color.purple)
			"Gold":
				ability_roll_label.add_color_override("font_color", Color.gold)
	
	_add_log("=== Simulation Started ===")


func _on_simulation_event(event_text):
	"""Handle simulation event log entry"""
	_add_log(event_text)


func _on_simulation_completed(results):
	"""Handle simulation completion"""
	is_simulating = false
	
	_add_log("=== Simulation Complete ===")
	
	# Display success rating
	if success_rating_label:
		var rating = results.get("success_rating", 0)
		success_rating_label.text = "Success Rating: %d/100" % rating
		
		# Color by success
		if rating >= 70:
			success_rating_label.add_color_override("font_color", Color.green)
		elif rating >= 40:
			success_rating_label.add_color_override("font_color", Color.yellow)
		else:
			success_rating_label.add_color_override("font_color", Color.red)
	
	# Reset button
	if start_button:
		start_button.disabled = false
		start_button.text = "Start New Simulation"


func _on_choices_presented(choices: Array):
	"""Handle reward choices presentation"""
	current_choices = choices
	selected_rewards.clear()
	
	# Show reward panel
	if reward_choices_panel:
		reward_choices_panel.visible = true
	
	# Update button texts
	for i in range(min(choices.size(), reward_buttons.size())):
		var button = reward_buttons[i]
		var choice = choices[i]
		button.text = choice["description"]
		button.pressed = false
		button.disabled = false
	
	_add_log("\n--- Choose 2 Rewards ---")


# ==========================================
# REWARD SELECTION
# ==========================================

func _on_reward_button_toggled(pressed: bool, button_index: int):
	"""Handle reward button selection"""
	if pressed:
		# Check if we can select more
		if selected_rewards.size() >= max_reward_selections:
			# Deselect this button
			reward_buttons[button_index].pressed = false
			print("[SimulationMenu] Can only select %d rewards" % max_reward_selections)
			return
		
		selected_rewards.append(button_index)
		print("[SimulationMenu] Selected reward %d" % button_index)
	else:
		# Remove from selection
		selected_rewards.erase(button_index)
	
	# Check if ready to apply
	if selected_rewards.size() == max_reward_selections:
		_apply_rewards()


func _apply_rewards():
	"""Apply selected rewards"""
	if selected_rewards.size() != max_reward_selections:
		return
	
	print("[SimulationMenu] Applying rewards: " + str(selected_rewards))
	
	# Apply through simulation manager
	SimulationManager.apply_reward_choices(selected_rewards)
	
	# Disable all reward buttons
	for button in reward_buttons:
		button.disabled = true
	
	_add_log("Rewards applied!")
	
	emit_signal("rewards_selected", selected_rewards)
	
	# Auto-close after delay
	yield(get_tree().create_timer(2.0), "timeout")
	close()


# ==========================================
# LOG DISPLAY
# ==========================================

func _add_log(text: String):
	"""Add text to simulation log"""
	if not simulation_log:
		return
	
	simulation_log.append_bbcode("\n" + text)
	
	# Auto-scroll to bottom
	simulation_log.scroll_to_line(simulation_log.get_line_count())


# ==========================================
# INPUT HANDLING
# ==========================================

func _input(event):
	"""Handle input"""
	# Close with ESC
	if event.is_action_pressed("ui_cancel") and visible and not is_simulating:
		close()
	
	# Open with T key
	if event.is_action_pressed("open_simulation") and not visible:
		open()
