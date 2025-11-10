extends Control

# Simulation Menu - Interface for running villain simulator

signal simulation_requested()
signal choices_made(choice1, choice2)

onready var start_button = $Panel/VBoxContainer/StartButton
onready var narrative_label = $Panel/VBoxContainer/ScrollContainer/NarrativeLabel
onready var choice_container = $Panel/VBoxContainer/ChoiceContainer
onready var close_button = $Panel/VBoxContainer/CloseButton

var current_choices = []
var selected_choices = []

func _ready():
	hide()
	
	if start_button:
		start_button.connect("pressed", self, "_on_start_button_pressed")
	
	if close_button:
		close_button.connect("pressed", self, "_on_close_button_pressed")
	
	# Connect to simulation manager
	SimulationManager.connect("simulation_completed", self, "_on_simulation_completed")
	SimulationManager.connect("simulation_choice_presented", self, "_on_choices_presented")

func open_menu():
	show()
	_reset_ui()

func close_menu():
	hide()

func _reset_ui():
	if narrative_label:
		narrative_label.bbcode_text = "[center]Activate the Villain Simulator to see possible futures...[/center]"
	
	if start_button:
		start_button.disabled = false
		start_button.text = "Run Simulation"
	
	_clear_choices()

func _on_start_button_pressed():
	start_button.disabled = true
	start_button.text = "Simulating..."
	
	if narrative_label:
		narrative_label.bbcode_text = "[center]The simulator activates, reality fractures...[/center]"
	
	# Start simulation
	SimulationManager.start_simulation()
	AudioManager.play_bgm("simulation")

func _on_simulation_completed(result):
	# Display narrative
	if narrative_label:
		narrative_label.bbcode_text = result["narrative"]
	
	# Update faith in system
	StoryStateManager.modify_state("faith_in_system", -2, "Witnessed another simulated death")

func _on_choices_presented(choices):
	current_choices = choices
	_display_choices()

func _display_choices():
	_clear_choices()
	
	if not choice_container:
		return
	
	var instruction = Label.new()
	instruction.text = "Select TWO rewards:"
	instruction.align = Label.ALIGN_CENTER
	choice_container.add_child(instruction)
	
	for choice in current_choices:
		var button = Button.new()
		button.text = choice["label"]
		button.rect_min_size = Vector2(400, 40)
		button.connect("pressed", self, "_on_choice_selected", [choice])
		
		# Color based on type
		match choice["type"]:
			"ability":
				button.modulate = AbilitySystem.get_rank_color(choice["value"].get("rank", "White"))
			"sutras":
				button.modulate = Color(0.8, 0.6, 1.0)
			"stats":
				button.modulate = Color(0.6, 1.0, 0.6)
		
		choice_container.add_child(button)
	
	# Add confirm button
	var confirm = Button.new()
	confirm.text = "Confirm Selection"
	confirm.rect_min_size = Vector2(400, 50)
	confirm.connect("pressed", self, "_on_confirm_choices")
	choice_container.add_child(confirm)

func _clear_choices():
	if not choice_container:
		return
	
	for child in choice_container.get_children():
		child.queue_free()
	
	selected_choices.clear()

func _on_choice_selected(choice):
	if selected_choices.size() >= 2:
		# Remove oldest selection
		selected_choices.pop_front()
	
	selected_choices.append(choice)
	
	# Visual feedback
	print("Selected: ", choice["label"])

func _on_confirm_choices():
	if selected_choices.size() != 2:
		print("Must select exactly 2 choices!")
		return
	
	# Apply choices
	for choice in selected_choices:
		SimulationManager.apply_choice(choice)
	
	emit_signal("choices_made", selected_choices[0], selected_choices[1])
	
	# Close menu
	call_deferred("close_menu")
	AudioManager.play_sfx("ability_unlock")

func _on_close_button_pressed():
	close_menu()
