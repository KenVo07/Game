extends Node

# ==========================================
# AUDIO MANAGER
# Handles music, sound effects, and audio state
# ==========================================

signal music_changed(track_name)
signal volume_changed(bus_name, volume)

# Audio players
var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var sfx_players: Array = []

# Audio settings
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var ambient_volume: float = 0.5

# Current state
var current_music_track: String = ""
var is_music_playing: bool = false

# Music tracks (paths to audio files)
var music_tracks = {
	"main_menu": "res://assets/audio/music/main_menu.ogg",
	"exploration": "res://assets/audio/music/exploration.ogg",
	"combat": "res://assets/audio/music/combat.ogg",
	"simulation": "res://assets/audio/music/simulation.ogg",
	"boss": "res://assets/audio/music/boss.ogg",
	"ambient_temple": "res://assets/audio/ambient/temple.ogg",
	"ambient_forest": "res://assets/audio/ambient/forest.ogg"
}

# SFX paths
var sfx_library = {
	"button_click": "res://assets/audio/sfx/button_click.wav",
	"talisman_cast": "res://assets/audio/sfx/talisman_cast.wav",
	"sword_slash": "res://assets/audio/sfx/sword_slash.wav",
	"cultivation_breakthrough": "res://assets/audio/sfx/breakthrough.wav",
	"item_pickup": "res://assets/audio/sfx/item_pickup.wav",
	"death": "res://assets/audio/sfx/death.wav",
	"simulation_start": "res://assets/audio/sfx/simulation_start.wav",
	"quest_complete": "res://assets/audio/sfx/quest_complete.wav"
}


func _ready():
	print("[AudioManager] Initialized")
	_setup_audio_players()
	_setup_audio_buses()


# ==========================================
# AUDIO PLAYER SETUP
# ==========================================

func _setup_audio_players():
	"""Create audio stream players"""
	# Music player
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)
	
	# Ambient player
	ambient_player = AudioStreamPlayer.new()
	ambient_player.name = "AmbientPlayer"
	ambient_player.bus = "Ambient"
	add_child(ambient_player)
	
	# Create pool of SFX players
	for i in range(8):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.name = "SFXPlayer" + str(i)
		sfx_player.bus = "SFX"
		add_child(sfx_player)
		sfx_players.append(sfx_player)


func _setup_audio_buses():
	"""Configure audio buses"""
	# Get audio server
	var master_bus = AudioServer.get_bus_index("Master")
	
	# Create buses if they don't exist
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, "Music")
	
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, "SFX")
	
	if AudioServer.get_bus_index("Ambient") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, "Ambient")
	
	# Set initial volumes
	set_volume("Master", master_volume)
	set_volume("Music", music_volume)
	set_volume("SFX", sfx_volume)
	set_volume("Ambient", ambient_volume)


# ==========================================
# MUSIC CONTROL
# ==========================================

func play_music(track_name: String, fade_in: bool = true):
	"""Play background music"""
	if not music_tracks.has(track_name):
		push_warning("Music track not found: " + track_name)
		return
	
	if current_music_track == track_name and is_music_playing:
		return  # Already playing this track
	
	# Load and play
	var track_path = music_tracks[track_name]
	
	# Check if file exists (placeholder check)
	# In real implementation, would load actual audio file
	print("[Audio] Playing music: " + track_name)
	
	current_music_track = track_name
	is_music_playing = true
	
	# TODO: Implement actual audio loading and crossfade
	# var stream = load(track_path)
	# music_player.stream = stream
	# music_player.play()
	
	emit_signal("music_changed", track_name)


func stop_music(fade_out: bool = true):
	"""Stop current music"""
	if music_player.playing:
		music_player.stop()
	
	is_music_playing = false
	current_music_track = ""


func pause_music():
	"""Pause music"""
	music_player.stream_paused = true


func resume_music():
	"""Resume paused music"""
	music_player.stream_paused = false


# ==========================================
# SOUND EFFECTS
# ==========================================

func play_sfx(sfx_name: String, pitch_variance: float = 0.0):
	"""Play sound effect"""
	if not sfx_library.has(sfx_name):
		push_warning("SFX not found: " + sfx_name)
		return
	
	# Find available player
	var player = _get_available_sfx_player()
	if not player:
		push_warning("No available SFX players")
		return
	
	# TODO: Load actual audio
	# var stream = load(sfx_library[sfx_name])
	# player.stream = stream
	
	# Apply pitch variance
	if pitch_variance > 0:
		player.pitch_scale = rand_range(1.0 - pitch_variance, 1.0 + pitch_variance)
	else:
		player.pitch_scale = 1.0
	
	player.play()
	print("[Audio] Playing SFX: " + sfx_name)


func _get_available_sfx_player() -> AudioStreamPlayer:
	"""Get first available SFX player"""
	for player in sfx_players:
		if not player.playing:
			return player
	return null


# ==========================================
# AMBIENT SOUND
# ==========================================

func play_ambient(ambient_name: String):
	"""Play ambient sound loop"""
	if not music_tracks.has(ambient_name):
		push_warning("Ambient sound not found: " + ambient_name)
		return
	
	# TODO: Load actual audio
	# var stream = load(music_tracks[ambient_name])
	# ambient_player.stream = stream
	# ambient_player.play()
	
	print("[Audio] Playing ambient: " + ambient_name)


func stop_ambient():
	"""Stop ambient sound"""
	ambient_player.stop()


# ==========================================
# VOLUME CONTROL
# ==========================================

func set_volume(bus_name: String, volume: float):
	"""Set volume for audio bus (0.0 to 1.0)"""
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_warning("Audio bus not found: " + bus_name)
		return
	
	# Convert linear volume to dB
	var db = linear2db(volume)
	AudioServer.set_bus_volume_db(bus_index, db)
	
	# Update stored volume
	match bus_name:
		"Master":
			master_volume = volume
		"Music":
			music_volume = volume
		"SFX":
			sfx_volume = volume
		"Ambient":
			ambient_volume = volume
	
	emit_signal("volume_changed", bus_name, volume)


func get_volume(bus_name: String) -> float:
	"""Get current volume for bus"""
	match bus_name:
		"Master":
			return master_volume
		"Music":
			return music_volume
		"SFX":
			return sfx_volume
		"Ambient":
			return ambient_volume
	return 0.0


func mute_bus(bus_name: String):
	"""Mute audio bus"""
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		AudioServer.set_bus_mute(bus_index, true)


func unmute_bus(bus_name: String):
	"""Unmute audio bus"""
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		AudioServer.set_bus_mute(bus_index, false)


# ==========================================
# CONTEXTUAL AUDIO
# ==========================================

func play_context_music(context: String):
	"""Play appropriate music for game context"""
	match context:
		"menu":
			play_music("main_menu")
		"exploration":
			play_music("exploration")
		"combat":
			play_music("combat")
		"simulation":
			play_music("simulation")
		"boss":
			play_music("boss")


func play_ui_sound(action: String):
	"""Play UI-related sounds"""
	match action:
		"click":
			play_sfx("button_click")
		"hover":
			pass  # Could add hover sound
		"error":
			pass  # Could add error sound


# ==========================================
# SAVE/LOAD
# ==========================================

func get_save_data() -> Dictionary:
	"""Return audio settings for saving"""
	return {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"ambient_volume": ambient_volume,
		"current_music": current_music_track
	}


func load_save_data(data: Dictionary):
	"""Restore audio settings"""
	if data.has("master_volume"):
		set_volume("Master", data["master_volume"])
	if data.has("music_volume"):
		set_volume("Music", data["music_volume"])
	if data.has("sfx_volume"):
		set_volume("SFX", data["sfx_volume"])
	if data.has("ambient_volume"):
		set_volume("Ambient", data["ambient_volume"])
	
	print("[AudioManager] Loaded audio settings")
