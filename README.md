# Simulation of the Eternal Path – Villain Edition

## Section 1: Technical Blueprint

### 1. Game Overview
- Engine: Godot (2D)
- Art Style: Dark-fantasy pixel art
- Core Gameplay: Twin-stick combat and exploration (inspired by Soul Knight)
- Simulation Layer: Text-based “Villain Simulator” driven by AI or procedural event logic
- Progression: Cultivation through Sutras, Abilities, and Realms
- Narrative Engine: Causal world-state system (no parallel branches)

### 2. Core Modules
1. Player Controller (2D movement, combat)
2. Simulation System (text generation, AI logic)
3. Causal Narrative Manager (state tracking)
4. Cultivation System (stats, realms, sutras)
5. Ability Generator (pre-simulation roll logic)
6. World Map (open exploration)
7. NPC Behavior (reacts to reputation, karma)
8. Dialogue/Choice System (branching based on world state)

### 3. Godot Node Structure
```
/root
├── MainMenu
├── WorldScene
│   ├── Player (KinematicBody2D)
│   ├── NPCs (Node2D)
│   ├── Enemies (Node2D)
│   ├── Environment (TileMap)
│   ├── UI
│   ├── HUD (Control)
│   ├── LogBook (RichTextLabel)
│   ├── SimulationMenu (Control)
├── Systems
│   ├── SimulationManager (Singleton)
│   ├── StoryStateManager (Singleton)
│   ├── AbilitySystem (Singleton)
│   ├── AudioManager (Singleton)
```

### 4. Global Variables (Causal Story Engine)
```gdscript
var world_state = {
	"reputation": 0, # social standing among sects
	"karma": 0, # moral alignment, affects fate
	"destiny_thread": 0, # determines world coincidences
	"sect_influence": 0, # standing with each sect
	"faith_in_system": 0, # trust in the Villain Simulator
	"realm_level": 1, # cultivation progress
	"heart_sutra": "Default Sutra",
	"abilities": [], # list of unlocked passive/active powers
	"inventory": [],
	"insight_clues": [],
	"simulations_done": 0
}

if world_state["karma"] < -50:
	trigger_event("Heavenly Tribulation - Punishment Realm")

if world_state["sect_influence"] > 70 and "Talisman Sect" in alliances:
	unlock_path("Forbidden Archive")
```

### 5. Simulation Flow
```gdscript
func start_simulation():
	roll_ability_rank() # random ability from White → Gold
	load_current_stats_and_sutra()
	run_simulation_until_death()
	record_log_and_outcome()
	present_player_with_choices(["A", "B", "C", "D", "E"])
	apply_two_selected_rewards()
```

Simulation output example:
```json
{
	"death_cause": "overwhelmed by cursed qi",
	"new_stats": {"strength": +3, "spirit": +2},
	"new_items": ["Cursed Amulet"],
	"new_sutras": ["Sutra of Veiled Hatred"],
	"insights": ["The Amulet resonates near Moon Pavilion"],
	"rolled_ability": "Blue Rank - Mind Splitter"
}
```

### 6. Cultivation and Realm System
- Realms: Mortal → Qi Condensation → Foundation → Core Formation → Nascent Soul → Saint → True Immortal
- Heart Sutras define realm efficiency. Combat and Technique Sutras grant techniques.

```gdscript
class_name CultivationSystem

var current_realm = "Mortal"
var heart_sutra = "Heart Sutra of Silent Chaos"
var sutras = []
var abilities = []

func breakthrough():
	if can_breakthrough(current_realm):
		current_realm = get_next_realm(current_realm)
		world_state["realm_level"] += 1
```

### 7. Ability System
```gdscript
var ability_ranks = ["White", "Green", "Blue", "Purple", "Gold"]
var ability_pool = {
	"White": ["Quick Learner"],
	"Green": ["Spirit Resonance"],
	"Blue": ["Echo of the Dead"],
	"Purple": ["Talisman Whisperer"],
	"Gold": ["Naturally Supreme"]
}

func roll_ability_rank():
	var roll = randf()
	if roll < 0.5:
		return "White"
	elif roll < 0.75:
		return "Green"
	elif roll < 0.9:
		return "Blue"
	elif roll < 0.98:
		return "Purple"
	else:
		return "Gold"
```

### 8. Causal Narrative Ruleset
- Event: Player destroys a sect altar  
  Effect: `karma -= 20`, `sect_influence -= 30`, then `trigger_npc_event("SectRevengeRaid")`
- Event: Player saves a disciple  
  Effect: `karma += 10`, `add_follower("DiscipleName")`
- Future event checks:
  - If `world_state["karma"] < -50`: `spawn_demon_encounter()`
  - Elif `world_state["karma"] > 50`: `open_path_to_heaven_gate()`

### 9. Save/Load System
- Each save slot stores player stats, Sutras, abilities, world variables, simulation logs, story progress markers.
- Format: JSON (`user://saves/save_1.json`).

### 10. AI Integration (MiniAI / LLM)
- Generates narrative logs from simulation results.
- Predicts future outcomes based on causal state data.
- Dynamically writes NPC dialogue that reflects past events.
- Keeps tone consistent with dark-fantasy atmosphere.

Example prompt:
```
Prompt: "Simulate protagonist with stats X, karma Y, facing Event Z in Daxia Empire.
Output: short third-person narrative log, ending with death cause."
```

## Section 2: Narrative Design Format

### 1. World Setting
The world is the Daxia Empire, where immortal sects, ancient families, and hidden cultivators vie for supremacy. Heavenly laws govern karma and fate, yet the appearance of a mysterious artifact—the Villain Simulator—threatens this cosmic balance. The player awakens as a cultivator of unknown origin, inheriting the Villain Simulator. With each death, the System runs a simulation of possible futures, letting the player learn — but never without consequence.

### 2. Themes and Tone
- Dark-fantasy: moral ambiguity, tragic enlightenment, power corrupts.
- Psychological tension: simulated selves grow fearful and rebel.
- Philosophical depth: immortality vs. identity, fate vs. free will.
- Player emotion: shock, awe, curiosity, regret.

### 3. Player Experience
- Gameplay: real-time 2D combat (Soul Knight style), dodging, talisman casting, sutra-based techniques.
- Exploration: temples, cursed lands, immortal towers, and demonic realms.
- Decision-making: every moral, tactical, or dialogue choice updates world state variables.
- No true ending — only states of transcendence, corruption, or annihilation.

### 4. Key Systems Summary
- Heart Sutra: defines cultivation path and realm progression speed.
- Sutra (Technique): grants abilities like movement or attack combos.
- Ability (Gift): passive power rolled randomly before simulations.
- Villain Simulator: reveals possible deaths or victories.
- Karma and Destiny: govern what kinds of endings or entities appear later.

### 5. Example Causal Chain
1. Player destroys a sacred talisman → Karma -15, Sect influence -10.  
2. NPC elder warns player → If ignored, triggers `SectRaid` event.  
3. If `SectRaid` happens and the player dies → Simulation records “Sect’s Vengeance.”  
4. Player reads log, learns elder’s weakness.  
5. Player allies with rival sect → New simulation shows alternate path “Rise of the Heretic.”  
6. Consequence: world permanently divided — Daxia Empire weakened.

### 6. Endgame States
- Immortal Ascension: karma > 50 and `heart_sutra` stable.
- Demonic Overlord: karma < -70, `faith_in_system` high.
- Eternal Loop: `faith_in_system` collapses completely.
- Devoured by Self: simulation self replaces the real one.
- Abyssal Enlightenment: merge both existences, transcend reality.

### 7. Art Direction
- Environments: decaying temples, spectral forests, golden towers of the Empire.
- Color palette: muted purples, bronze, jade, and ash.
- Lighting: torch-flicker, spirit-glow, fog overlays.
- UI: scroll-like textures, blood-red runes for System messages.

### 8. Sound Design
- BGM: low strings, ritual drums, ambient chants.
- Combat SFX: talisman bursts, sutra resonance, metallic echoes.
- Simulation: distorted whispers, mechanical hums, quill-on-scroll writing effects.

### 9. Development Notes
- Start small: one city (Daxia Capital), one dungeon, two sects.
- Implement core causal system before expanding narrative.
- Integrate MiniAI for simulation logs and world reactions.
- Use JSON data for world state; extend via GDScript dictionary updates.

---

End of document.