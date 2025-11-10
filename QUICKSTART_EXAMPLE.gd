# ==========================================
# QUICK START EXAMPLE
# Copy this code to test the game systems
# ==========================================

extends Node

# This script demonstrates how to use the core game systems.
# Attach this to any Node and run it to see the systems in action.

func _ready():
	print("\n========== QUICK START EXAMPLE ==========\n")
	
	# Wait for singletons to initialize
	yield(get_tree(), "idle_frame")
	
	example_world_state()
	example_cultivation()
	example_abilities()
	example_simulation()
	example_save_load()
	
	print("\n========== EXAMPLE COMPLETE ==========\n")


# ==========================================
# EXAMPLE 1: World State & Causal System
# ==========================================

func example_world_state():
	print("\n--- Example 1: World State ---")
	
	# View initial state
	print("Initial karma: " + str(StoryStateManager.get_state("karma")))
	
	# Perform villainous action
	print("Performing villainous action...")
	StoryStateManager.modify_state("karma", -25)
	print("New karma: " + str(StoryStateManager.get_state("karma")))
	
	# Affect sect relationship
	print("Angering Talisman Sect...")
	StoryStateManager.modify_sect_influence("Talisman Sect", -30)
	print("Talisman Sect influence: " + str(StoryStateManager.get_sect_influence("Talisman Sect")))
	
	# Set a story flag
	StoryStateManager.set_flag("discovered_secret_cave", true)
	print("Secret cave discovered: " + str(StoryStateManager.get_flag("discovered_secret_cave")))
	
	# Trigger extreme karma for causal rule
	print("\nTriggering extreme negative karma...")
	StoryStateManager.modify_state("karma", -30)  # Total: -55, should trigger tribulation
	print("Check console for causal rule activation!")


# ==========================================
# EXAMPLE 2: Cultivation System
# ==========================================

func example_cultivation():
	print("\n--- Example 2: Cultivation System ---")
	
	# Check current realm
	print("Current realm: " + CultivationSystem.current_realm)
	
	# Add cultivation progress
	print("Cultivating...")
	CultivationSystem.add_cultivation_progress(50)
	print("Progress: %.1f / %.1f" % [
		CultivationSystem.cultivation_progress,
		CultivationSystem.cultivation_required
	])
	
	# Learn a sutra
	print("\nLearning Sutra of Crimson Blade...")
	CultivationSystem.learn_sutra("Sutra of the Crimson Blade")
	
	# Check stats
	print("Current strength: " + str(CultivationSystem.get_stat("strength")))
	
	# Add more progress to trigger breakthrough
	print("\nCultivating intensely...")
	CultivationSystem.add_cultivation_progress(60)
	
	if CultivationSystem.attempt_breakthrough():
		print("Breakthrough successful! New realm: " + CultivationSystem.current_realm)
	else:
		print("Breakthrough failed - need more progress or conditions not met")


# ==========================================
# EXAMPLE 3: Ability System
# ==========================================

func example_abilities():
	print("\n--- Example 3: Ability System ---")
	
	# Roll random abilities
	print("Rolling for abilities...")
	for i in range(5):
		var ability = AbilitySystem.roll_random_ability()
		if not ability.empty():
			print("  Roll %d: %s (%s rank)" % [i+1, ability["name"], ability["rank"]])
	
	# Unlock a specific ability
	print("\nUnlocking Naturally Supreme (Gold)...")
	AbilitySystem.unlock_ability("Naturally Supreme")
	
	# Check active abilities
	print("Unlocked abilities: " + str(AbilitySystem.get_unlocked_abilities()))
	
	# Check cultivation multiplier from abilities
	var multiplier = AbilitySystem.get_cultivation_multiplier()
	print("Cultivation bonus multiplier: %.2fx" % multiplier)


# ==========================================
# EXAMPLE 4: Simulation System
# ==========================================

func example_simulation():
	print("\n--- Example 4: Simulation System ---")
	
	print("Starting simulation (this will take a few seconds)...")
	
	# Connect to simulation signals
	SimulationManager.connect("simulation_event_occurred", self, "_on_sim_event")
	SimulationManager.connect("simulation_completed", self, "_on_sim_complete")
	
	# Start simulation
	SimulationManager.start_simulation()
	
	# Wait for simulation to complete
	yield(SimulationManager, "simulation_completed")
	
	print("Simulation finished!")


func _on_sim_event(event_text: String):
	# This is called for each simulation event
	pass  # Already printed by SimulationManager


func _on_sim_complete(results: Dictionary):
	print("\nSimulation Results:")
	print("  Death cause: " + results["death_cause"])
	print("  Success rating: " + str(results["success_rating"]))
	print("  Insights gained: " + str(results["insights_gained"].size()))
	print("  Items found: " + str(results["items_found"].size()))
	
	# In a real game, you'd present reward choices here
	print("\nIn the actual game, you'd now choose 2 of 5 rewards!")


# ==========================================
# EXAMPLE 5: Save/Load System
# ==========================================

func example_save_load():
	print("\n--- Example 5: Save/Load System ---")
	
	# Save current state
	print("Saving game to slot 1...")
	SaveLoadSystem.save_game(1)
	
	# Get save info
	var save_info = SaveLoadSystem.get_save_info(1)
	print("Save info: " + str(save_info))
	
	# List all saves
	print("\nAll saves:")
	SaveLoadSystem.print_all_saves()
	
	print("\nTo load: SaveLoadSystem.load_game(1)")


# ==========================================
# BONUS: Demonstrating Causal Chain
# ==========================================

func example_causal_chain():
	"""
	This shows how actions create consequences that affect future events.
	Run this separately to see a complete causal chain.
	"""
	print("\n--- BONUS: Causal Chain Example ---")
	
	# Step 1: Destroy sacred artifact
	print("\n1. You destroy a sacred talisman...")
	StoryStateManager.modify_state("karma", -15)
	StoryStateManager.modify_sect_influence("Talisman Sect", -20)
	
	# Step 2: More hostile actions
	print("\n2. You continue attacking sect disciples...")
	StoryStateManager.modify_state("karma", -20)
	StoryStateManager.modify_sect_influence("Talisman Sect", -40)
	
	# Step 3: Sect becomes hostile
	var sect_influence = StoryStateManager.get_sect_influence("Talisman Sect")
	if sect_influence < -50:
		print("\n3. Talisman Sect declares you an enemy!")
		StoryStateManager.trigger_event("sect_declares_vendetta", {"sect": "Talisman Sect"})
	
	# Step 4: Extreme karma triggers tribulation
	print("\n4. Your accumulated sins attract Heavenly attention...")
	StoryStateManager.modify_state("karma", -30)
	# Causal rule should trigger Heavenly Tribulation
	
	# Step 5: Reputation consequences
	StoryStateManager.modify_state("reputation", -40)
	print("\n5. Your infamy spreads across the empire...")
	
	print("\n--- End of Causal Chain ---")
	print("In the game, NPCs would now react to your reputation!")
	print("Quests would change. New events would spawn.")
	print("The world remembers everything you've done.")


# ==========================================
# UTILITY: Reset Everything
# ==========================================

func reset_all_systems():
	"""Reset all systems to default state (for testing)"""
	print("\n--- Resetting All Systems ---")
	StoryStateManager.reset_world_state()
	print("Systems reset!")


# ==========================================
# HOW TO USE THIS SCRIPT
# ==========================================

"""
INSTRUCTIONS:

1. Create a new scene in Godot
2. Add a Node and attach this script
3. Run the scene (F6)
4. Watch the console output

OR:

1. Copy individual example functions to your own scripts
2. Call them when needed
3. Experiment with different values!

TIPS:

- Connect to signals to react to events:
  StoryStateManager.connect("event_triggered", self, "_on_event")

- Check world state before actions:
  if StoryStateManager.get_state("karma") < -50:
      # Do something

- Chain multiple modifications for bigger effects:
  StoryStateManager.modify_state("karma", -10)
  StoryStateManager.modify_sect_influence("Sect", -20)
  CultivationSystem.add_cultivation_progress(5)

- Save frequently during development:
  SaveLoadSystem.quick_save()

HAVE FUN! 🎮
"""
