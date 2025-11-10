extends Node

# ==========================================
# AUDIO MANAGER
# ==========================================
# Manages background music and sound effects

var bgm_player: AudioStreamPlayer
var sfx_players = []
var num_sfx_players = 8

var bgm_volume = 0.7
var sfx_volume = 0.8

# Audio paths (to be populated with actual audio files)
var bgm_tracks = {
	"menu": "res://audio/bgm/menu_theme.ogg",
	"world": "res://audio/bgm/exploration.ogg",
	"combat": "res://audio/bgm/battle_theme.ogg",
	"simulation": "res://audio/bgm/simulation_ambience.ogg",
	"boss": "res://audio/bgm/boss_fight.ogg"
}

var sfx_sounds = {
	"button_click": "res://audio/sfx/button_click.wav",
	"ability_roll": "res://audio/sfx/ability_roll.wav",
	"breakthrough": "res://audio/sfx/breakthrough.wav",
	"hit": "res://audio/sfx/hit.wav",
	"dodge": "res://audio/sfx/dodge.wav",
	"qi_blast": "res://audio/sfx/qi_blast.wav",
	"simulation_start": "res://audio/sfx/simulation_start.wav",
	"reward_select": "res://audio/sfx/reward_select.wav"
}

func _ready():
	# Create BGM player
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Music"
	bgm_player.volume_db = linear2db(bgm_volume)
	add_child(bgm_player)
	
	# Create SFX players pool
	for i in range(num_sfx_players):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		player.volume_db = linear2db(sfx_volume)
		add_child(player)
		sfx_players.append(player)
	
	print("[AudioManager] Initialized with %d SFX channels" % num_sfx_players)

func play_bgm(track_name: String, fade_duration: float = 1.0):
	"""Play background music with optional fade"""
	if not track_name in bgm_tracks:
		push_error("BGM track not found: " + track_name)
		return
	
	# TODO: Implement fade transition
	# For now, just switch directly
	var path = bgm_tracks[track_name]
	
	# Check if file exists (won't in this basic setup)
	# var stream = load(path)
	# if stream:
	#	bgm_player.stream = stream
	#	bgm_player.play()
	
	print("[AudioManager] Playing BGM: " + track_name)

func stop_bgm(fade_duration: float = 1.0):
	"""Stop background music with optional fade"""
	# TODO: Implement fade out
	bgm_player.stop()
	print("[AudioManager] BGM stopped")

func play_sfx(sound_name: String, pitch_scale: float = 1.0):
	"""Play a sound effect"""
	if not sound_name in sfx_sounds:
		push_error("SFX sound not found: " + sound_name)
		return
	
	# Find available SFX player
	var player = _get_available_sfx_player()
	if not player:
		return  # All players busy
	
	# Load and play sound
	var path = sfx_sounds[sound_name]
	
	# Check if file exists (won't in this basic setup)
	# var stream = load(path)
	# if stream:
	#	player.stream = stream
	#	player.pitch_scale = pitch_scale
	#	player.play()
	
	print("[AudioManager] Playing SFX: " + sound_name)

func _get_available_sfx_player() -> AudioStreamPlayer:
	"""Get an available SFX player from the pool"""
	for player in sfx_players:
		if not player.playing:
			return player
	return sfx_players[0]  # Fallback to first player (will interrupt)

func set_bgm_volume(volume: float):
	"""Set BGM volume (0.0 to 1.0)"""
	bgm_volume = clamp(volume, 0.0, 1.0)
	bgm_player.volume_db = linear2db(bgm_volume)

func set_sfx_volume(volume: float):
	"""Set SFX volume (0.0 to 1.0)"""
	sfx_volume = clamp(volume, 0.0, 1.0)
	for player in sfx_players:
		player.volume_db = linear2db(sfx_volume)

func linear2db(linear: float) -> float:
	"""Convert linear volume to decibels"""
	return 20.0 * log(linear) / log(10.0) if linear > 0 else -80.0
