extends Control

# ==========================================
# MAIN MENU
# Title screen with new game, load game, settings, quit
# ==========================================

# UI References
onready var new_game_button = $MenuPanel/VBoxContainer/NewGameButton
onready var load_game_button = $MenuPanel/VBoxContainer/LoadGameButton
onready var settings_button = $MenuPanel/VBoxContainer/SettingsButton
onready var quit_button = $MenuPanel/VBoxContainer/QuitButton
onready var title_label = $TitleLabel


func _ready():
	print("[MainMenu] Initialized")
	_connect_buttons()
	_play_menu_music()


func _connect_buttons():
	"""Connect button signals"""
	if new_game_button:
		new_game_button.connect("pressed", self, "_on_new_game_pressed")
	
	if load_game_button:
		load_game_button.connect("pressed", self, "_on_load_game_pressed")
	
	if settings_button:
		settings_button.connect("pressed", self, "_on_settings_pressed")
	
	if quit_button:
		quit_button.connect("pressed", self, "_on_quit_pressed")


func _play_menu_music():
	"""Start main menu music"""
	AudioManager.play_context_music("menu")


# ==========================================
# BUTTON HANDLERS
# ==========================================

func _on_new_game_pressed():
	"""Start new game"""
	print("[MainMenu] Starting new game...")
	AudioManager.play_ui_sound("click")
	
	# Reset all systems
	StoryStateManager.reset_world_state()
	
	# Load game world scene
	get_tree().change_scene("res://scenes/WorldScene.tscn")


func _on_load_game_pressed():
	"""Open load game menu"""
	print("[MainMenu] Opening load game menu...")
	AudioManager.play_ui_sound("click")
	
	# TODO: Implement load game menu
	# For now, quick load from slot 0
	if SaveLoadSystem.load_game(0):
		get_tree().change_scene("res://scenes/WorldScene.tscn")
	else:
		print("[MainMenu] No save file found")


func _on_settings_pressed():
	"""Open settings menu"""
	print("[MainMenu] Opening settings...")
	AudioManager.play_ui_sound("click")
	
	# TODO: Implement settings menu
	print("[MainMenu] Settings not implemented yet")


func _on_quit_pressed():
	"""Quit game"""
	print("[MainMenu] Quitting game...")
	AudioManager.play_ui_sound("click")
	
	get_tree().quit()


# ==========================================
# INPUT
# ==========================================

func _input(event):
	"""Handle input"""
	# ESC to quit from main menu
	if event.is_action_pressed("ui_cancel"):
		_on_quit_pressed()
