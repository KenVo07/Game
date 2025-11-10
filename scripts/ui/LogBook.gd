extends Control

# ==========================================
# LOG BOOK
# ==========================================
# Records of past simulations and insights

onready var log_list = $Panel/VBoxContainer/ScrollContainer/LogList
onready var detail_text = $Panel/VBoxContainer/DetailPanel/DetailText
onready var close_button = $Panel/VBoxContainer/CloseButton

func _ready():
	if close_button:
		close_button.connect("pressed", self, "_on_close_pressed")
	
	_populate_logs()

func _populate_logs():
	"""Populate the log list with simulation history"""
	if not log_list:
		return
	
	# Clear existing items
	for child in log_list.get_children():
		child.queue_free()
	
	# Get simulation history
	var history = SimulationManager.get_simulation_history()
	
	if history.size() == 0:
		var label = Label.new()
		label.text = "No simulations recorded yet."
		log_list.add_child(label)
		return
	
	# Create log entry for each simulation
	for i in range(history.size()):
		var sim = history[i]
		var button = Button.new()
		
		var died = sim.get("outcome", {}).get("died", false)
		var status = "DEATH" if died else "SURVIVED"
		var color = "red" if died else "green"
		
		button.text = "Simulation #%d - [%s]" % [i + 1, status]
		button.connect("pressed", self, "_on_log_selected", [sim])
		
		log_list.add_child(button)

func _on_log_selected(simulation: Dictionary):
	"""Show details of a selected simulation"""
	if not detail_text:
		return
	
	var text = ""
	text += "[b]Simulation Details[/b]\n\n"
	
	# Rolled ability
	if simulation.has("rolled_ability"):
		var ability = simulation["rolled_ability"]
		text += "[color=yellow]Rolled Ability:[/color] %s (%s)\n" % [ability["name"], ability["rank"]]
		text += "%s\n\n" % ability["desc"]
	
	# Events
	if simulation.has("events"):
		text += "[color=cyan]Events:[/color]\n"
		for event in simulation["events"]:
			text += "• %s\n" % event.get("text", "Unknown event")
			text += "  → %s\n" % event.get("outcome_text", "Unknown outcome")
		text += "\n"
	
	# Outcome
	if simulation.has("outcome"):
		var outcome = simulation["outcome"]
		text += "[color=orange]Outcome:[/color]\n"
		if outcome.get("died", false):
			text += "[color=red]DEATH:[/color] %s\n" % outcome.get("death_cause", "Unknown")
		else:
			text += "[color=green]SURVIVED:[/color] %s\n" % outcome.get("achievement", "Unknown")
		
		# Insights
		if outcome.has("insights_gained") and outcome["insights_gained"].size() > 0:
			text += "\n[color=yellow]Insights:[/color]\n"
			for insight in outcome["insights_gained"]:
				text += "• %s\n" % insight
	
	detail_text.bbcode_text = text

func _on_close_pressed():
	"""Close the log book"""
	queue_free()
