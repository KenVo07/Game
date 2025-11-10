extends Control

# ==========================================
# MAIN MENU
# ==========================================

onready var new_game_button = $VBoxContainer/NewGameButton
onready var continue_button = $VBoxContainer/ContinueButton
onready var load_game_button = $VBoxContainer/LoadGameButton
onready var settings_button = $VBoxContainer/SettingsButton
onready var quit_button = $VBoxContainer/QuitButton
onready var title_label = $TitleLabel

func _ready():
	# Play menu music
	AudioManager.play_bgm("menu")
	
	# Connect buttons
	if new_game_button:
		new_game_button.connect("pressed", self, "_on_new_game_pressed")
	if continue_button:
		continue_button.connect("pressed", self, "_on_continue_pressed")
	if load_game_button:
		load_game_button.connect("pressed", self, "_on_load_game_pressed")
	if settings_button:
		settings_button.connect("pressed", self, "_on_settings_pressed")
	if quit_button:
		quit_button.connect("pressed", self, "_on_quit_pressed")
	
	# Check if continue option is available
	_check_save_availability()

func _check_save_availability():
	"""Check if there's a save to continue from"""
	if continue_button:
		var save_info = SaveLoadSystem.get_save_info(1)
		continue_button.disabled = not save_info.get("exists", false)

func _on_new_game_pressed():
	"""Start a new game"""
	AudioManager.play_sfx("button_click")
	
	# Reset all systems
	StoryStateManager.reset_state()
	CultivationSystem.reset_cultivation()
	AbilitySystem.reset_abilities()
	
	# Load world scene
	get_tree().change_scene("res://scenes/WorldScene.tscn")

func _on_continue_pressed():
	"""Continue from last save"""
	AudioManager.play_sfx("button_click")
	
	if SaveLoadSystem.quick_load():
		get_tree().change_scene("res://scenes/WorldScene.tscn")
	else:
		print("[MainMenu] Failed to load save")

func _on_load_game_pressed():
	"""Open load game menu"""
	AudioManager.play_sfx("button_click")
	# Would open load game UI
	print("[MainMenu] Load game menu not yet implemented")

func _on_settings_pressed():
	"""Open settings menu"""
	AudioManager.play_sfx("button_click")
	# Would open settings UI
	print("[MainMenu] Settings menu not yet implemented")

func _on_quit_pressed():
	"""Quit the game"""
	AudioManager.play_sfx("button_click")
	get_tree().quit()
