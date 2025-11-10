extends Control

# ==========================================
# LOG BOOK - Event History & Quest Tracker
# Displays simulation history, insights, and world events
# ==========================================

# UI References
onready var tabs = $Panel/MarginContainer/VBoxContainer/Tabs
onready var event_history_text = $Panel/MarginContainer/VBoxContainer/TabContainer/EventHistory/ScrollContainer/EventHistoryText
onready var insights_text = $Panel/MarginContainer/VBoxContainer/TabContainer/Insights/ScrollContainer/InsightsText
onready var quests_container = $Panel/MarginContainer/VBoxContainer/TabContainer/Quests/ScrollContainer/QuestsContainer
onready var close_button = $Panel/MarginContainer/VBoxContainer/CloseButton


func _ready():
	print("[LogBook] Initialized")
	visible = false
	_connect_signals()
	
	if close_button:
		close_button.connect("pressed", self, "close")


func _connect_signals():
	"""Connect to story state signals"""
	StoryStateManager.connect("event_triggered", self, "_on_event_triggered")
	StoryStateManager.connect("world_state_changed", self, "_on_world_state_changed")


# ==========================================
# MENU CONTROL
# ==========================================

func open():
	"""Open log book"""
	visible = true
	_refresh_all()
	print("[LogBook] Opened")


func close():
	"""Close log book"""
	visible = false
	print("[LogBook] Closed")


func _refresh_all():
	"""Refresh all log book content"""
	_refresh_event_history()
	_refresh_insights()
	_refresh_quests()


# ==========================================
# EVENT HISTORY
# ==========================================

func _refresh_event_history():
	"""Refresh event history display"""
	if not event_history_text:
		return
	
	event_history_text.clear()
	
	var history = StoryStateManager.get_event_history(50)
	
	if history.empty():
		event_history_text.append_bbcode("[i]No events recorded yet...[/i]")
		return
	
	event_history_text.append_bbcode("[b]== World Event History ==[/b]\n\n")
	
	for event in history:
		var sim_count = event.get("simulation_count", 0)
		var variable = event.get("variable", "unknown")
		var old_val = event.get("old_value", "?")
		var new_val = event.get("new_value", "?")
		
		var entry = "[color=gray]Sim %d:[/color] %s changed: %s → %s\n" % [
			sim_count,
			variable,
			_format_value(old_val),
			_format_value(new_val)
		]
		
		event_history_text.append_bbcode(entry)


func _format_value(value) -> String:
	"""Format value for display"""
	if typeof(value) == TYPE_ARRAY:
		return str(value.size()) + " items"
	elif typeof(value) == TYPE_DICTIONARY:
		return "dict"
	else:
		return str(value)


# ==========================================
# INSIGHTS
# ==========================================

func _refresh_insights():
	"""Refresh insights display"""
	if not insights_text:
		return
	
	insights_text.clear()
	
	var insights = StoryStateManager.get_state("insight_clues")
	
	if insights.empty():
		insights_text.append_bbcode("[i]No insights discovered yet...[/i]")
		return
	
	insights_text.append_bbcode("[b]== Discovered Insights ==[/b]\n\n")
	
	for i in range(insights.size()):
		var insight = insights[i]
		insights_text.append_bbcode("[color=cyan]• [/color]" + insight + "\n\n")


# ==========================================
# QUESTS
# ==========================================

func _refresh_quests():
	"""Refresh quest display"""
	if not quests_container:
		return
	
	# Clear existing quest entries
	for child in quests_container.get_children():
		child.queue_free()
	
	var active_quests = StoryStateManager.get_state("active_quests")
	
	if active_quests.empty():
		var label = Label.new()
		label.text = "No active quests"
		label.add_color_override("font_color", Color(0.7, 0.7, 0.7))
		quests_container.add_child(label)
		return
	
	# Display active quests
	for quest in active_quests:
		_add_quest_entry(quest)


func _add_quest_entry(quest_data):
	"""Add quest entry to UI"""
	if not quests_container:
		return
	
	# Create quest panel
	var quest_panel = PanelContainer.new()
	var vbox = VBoxContainer.new()
	quest_panel.add_child(vbox)
	
	# Quest title
	var title_label = Label.new()
	title_label.text = quest_data.get("title", "Unknown Quest")
	title_label.add_color_override("font_color", Color.gold)
	vbox.add_child(title_label)
	
	# Quest description
	var desc_label = Label.new()
	desc_label.text = quest_data.get("description", "")
	desc_label.autowrap = true
	vbox.add_child(desc_label)
	
	# Quest progress (if applicable)
	if quest_data.has("progress"):
		var progress_label = Label.new()
		progress_label.text = "Progress: %d/%d" % [quest_data["progress"], quest_data["goal"]]
		vbox.add_child(progress_label)
	
	quests_container.add_child(quest_panel)


# ==========================================
# SIGNAL HANDLERS
# ==========================================

func _on_event_triggered(event_name: String, context: Dictionary):
	"""Handle new event"""
	if visible:
		_refresh_event_history()


func _on_world_state_changed(variable_name: String, old_value, new_value):
	"""Handle world state changes"""
	if visible:
		if variable_name == "insight_clues":
			_refresh_insights()
		elif variable_name == "active_quests":
			_refresh_quests()


# ==========================================
# INPUT HANDLING
# ==========================================

func _input(event):
	"""Handle input"""
	# Toggle with L key
	if event.is_action_pressed("ui_select"):  # Could map to custom key
		if visible:
			close()
		else:
			open()
	
	# Close with ESC
	if event.is_action_pressed("ui_cancel") and visible:
		close()
