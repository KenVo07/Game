extends Control

# LogBook - Records all story events and insights

onready var log_text = $Panel/ScrollContainer/LogText
onready var close_button = $Panel/CloseButton

var log_entries = []

func _ready():
	hide()
	
	if close_button:
		close_button.connect("pressed", self, "close_logbook")
	
	# Connect to story events
	StoryStateManager.connect("event_triggered", self, "_on_event_triggered")
	StoryStateManager.connect("world_state_changed", self, "_on_world_state_changed")

func open_logbook():
	show()
	_update_display()

func close_logbook():
	hide()

func _on_event_triggered(event_name, params):
	_add_entry("[EVENT] " + event_name, Color(1.0, 0.8, 0.2))

func _on_world_state_changed(variable, old_value, new_value):
	if variable in ["karma", "reputation", "faith_in_system"]:
		var delta = new_value - old_value if typeof(old_value) == TYPE_INT else 0
		var color = Color(0.8, 0.8, 0.8)
		
		if delta > 0:
			color = Color(0.2, 1.0, 0.2)
		elif delta < 0:
			color = Color(1.0, 0.2, 0.2)
		
		_add_entry("%s changed: %s -> %s" % [variable.capitalize(), old_value, new_value], color)

func _add_entry(text: String, color: Color = Color.white):
	var timestamp = OS.get_datetime()
	var entry = {
		"text": text,
		"color": color,
		"time": "%02d:%02d:%02d" % [timestamp["hour"], timestamp["minute"], timestamp["second"]]
	}
	
	log_entries.append(entry)
	
	# Keep log manageable
	if log_entries.size() > 100:
		log_entries.pop_front()
	
	if visible and log_text:
		_update_display()

func _update_display():
	if not log_text:
		return
	
	var bbcode = ""
	
	# Display recent entries (last 50)
	var start = max(0, log_entries.size() - 50)
	for i in range(start, log_entries.size()):
		var entry = log_entries[i]
		bbcode += "[color=#%s][%s] %s[/color]\n" % [
			entry["color"].to_html(false),
			entry["time"],
			entry["text"]
		]
	
	# Add insights section
	bbcode += "\n[color=yellow]===== INSIGHTS =====[/color]\n"
	for insight in StoryStateManager.world_state["insight_clues"]:
		bbcode += "[color=cyan]• %s[/color]\n" % insight
	
	log_text.bbcode_text = bbcode
