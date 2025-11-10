extends Control

# ==========================================
# SIMULATION MENU
# ==========================================
# UI for the Villain Simulator

signal simulation_rewards_selected(reward_indices)

onready var log_text = $Panel/VBoxContainer/ScrollContainer/LogText
onready var ability_display = $Panel/VBoxContainer/AbilityPanel/AbilityLabel
onready var reward_container = $Panel/VBoxContainer/RewardsPanel/RewardContainer
onready var start_button = $Panel/VBoxContainer/StartButton
onready var confirm_button = $Panel/VBoxContainer/ConfirmButton

var current_simulation = null
var selected_rewards = []
var reward_buttons = []

func _ready():
	# Connect signals
	SimulationManager.connect("simulation_started", self, "_on_simulation_started")
	SimulationManager.connect("simulation_step_generated", self, "_on_simulation_step")
	SimulationManager.connect("simulation_ended", self, "_on_simulation_ended")
	SimulationManager.connect("reward_choices_available", self, "_on_rewards_available")
	
	# Connect button signals
	if start_button:
		start_button.connect("pressed", self, "_on_start_pressed")
	if confirm_button:
		confirm_button.connect("pressed", self, "_on_confirm_pressed")
		confirm_button.visible = false
	
	# Play simulation ambience
	AudioManager.play_bgm("simulation")

func _on_start_pressed():
	"""Start a new simulation"""
	AudioManager.play_sfx("simulation_start")
	start_button.visible = false
	
	# Clear previous content
	if log_text:
		log_text.bbcode_text = "[center][color=#8b0000]THE VILLAIN SIMULATOR AWAKENS[/color][/center]\n\n"
	
	# Start simulation
	current_simulation = SimulationManager.start_simulation()
	
	# Display rolled ability
	if ability_display and current_simulation.has("rolled_ability"):
		var ability = current_simulation["rolled_ability"]
		var color = AbilitySystem.get_rank_color(ability["rank"])
		ability_display.bbcode_text = "[color=#%s]%s - %s[/color]\n%s" % [
			color.to_html(false),
			ability["rank"],
			ability["name"],
			ability["desc"]
		]

func _on_simulation_step(step_text: String):
	"""Add simulation step to log"""
	if log_text:
		log_text.bbcode_text += step_text + "\n\n"
		
		# Auto-scroll to bottom
		yield(get_tree(), "idle_frame")
		var scroll = log_text.get_parent()
		if scroll is ScrollContainer:
			scroll.scroll_vertical = scroll.get_v_scrollbar().max_value

func _on_simulation_started():
	"""Simulation has started"""
	print("[SimulationMenu] Simulation started")

func _on_simulation_ended(outcome: Dictionary):
	"""Simulation has ended, show outcome"""
	if log_text:
		log_text.bbcode_text += "\n[center]" + ("-" * 50) + "[/center]\n"
		log_text.bbcode_text += "[center][color=#ff0000]SIMULATION COMPLETE[/color][/center]\n\n"
		
		if outcome.get("died", false):
			log_text.bbcode_text += "[color=#ff4444]Death: %s[/color]\n\n" % outcome.get("death_cause", "Unknown")
		else:
			log_text.bbcode_text += "[color=#44ff44]Survived: %s[/color]\n\n" % outcome.get("achievement", "Unknown")
		
		# Show insights
		var insights = outcome.get("insights_gained", [])
		if insights.size() > 0:
			log_text.bbcode_text += "[color=#ffaa00]Insights Gained:[/color]\n"
			for insight in insights:
				log_text.bbcode_text += "• " + insight + "\n"
		
		log_text.bbcode_text += "\n" + outcome.get("final_text", "") + "\n"

func _on_rewards_available(rewards: Array):
	"""Show reward selection UI"""
	if not reward_container:
		return
	
	# Clear previous rewards
	for button in reward_buttons:
		button.queue_free()
	reward_buttons.clear()
	selected_rewards.clear()
	
	# Create reward buttons
	for i in range(rewards.size()):
		var reward = rewards[i]
		var button = Button.new()
		button.text = reward["display"]
		button.toggle_mode = true
		button.connect("toggled", self, "_on_reward_toggled", [i, button])
		reward_container.add_child(button)
		reward_buttons.append(button)
	
	# Show confirm button
	if confirm_button:
		confirm_button.visible = true

func _on_reward_toggled(pressed: bool, reward_index: int, button: Button):
	"""Handle reward selection toggle"""
	if pressed:
		# Check if already have 2 selected
		if selected_rewards.size() >= 2:
			button.pressed = false
			return
		selected_rewards.append(reward_index)
	else:
		selected_rewards.erase(reward_index)
	
	AudioManager.play_sfx("button_click")

func _on_confirm_pressed():
	"""Confirm reward selection"""
	if selected_rewards.size() != 2:
		print("[SimulationMenu] Must select exactly 2 rewards")
		return
	
	AudioManager.play_sfx("reward_select")
	
	# Apply rewards
	SimulationManager.apply_selected_rewards(selected_rewards)
	
	# Emit signal
	emit_signal("simulation_rewards_selected", selected_rewards)
	
	# Close simulation menu
	_close_simulation()

func _close_simulation():
	"""Close the simulation menu"""
	# Return to game
	get_tree().paused = false
	queue_free()

func _input(event):
	"""Handle input"""
	if event.is_action_pressed("ui_cancel") and confirm_button and not confirm_button.visible:
		# Can't close during active simulation
		pass
