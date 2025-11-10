# Simulation of the Eternal Path - Villain Edition
## Game Implementation Documentation

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Core Systems](#core-systems)
4. [Game Flow](#game-flow)
5. [Usage Guide](#usage-guide)
6. [Extending the Game](#extending-the-game)

---

## 🎮 Overview

**Simulation of the Eternal Path - Villain Edition** is a dark-fantasy cultivation game built in Godot, featuring:

- **Twin-stick combat** inspired by Soul Knight
- **Causal narrative system** with persistent consequences
- **Villain Simulator** that predicts possible futures
- **Cultivation progression** through realms and sutras
- **Reactive NPCs** that respond to player's karma and reputation
- **Procedural ability system** with ranked powers

---

## 🏗️ System Architecture

### Core Singleton Systems

All core systems are autoloaded singletons defined in `project.godot`:

1. **StoryStateManager** - Causal narrative engine
2. **CultivationSystem** - Realm progression and sutras
3. **AbilitySystem** - Ability rolls and passive/active powers
4. **SimulationManager** - Villain Simulator logic
5. **AudioManager** - Music and sound effects
6. **SaveLoadSystem** - Save/load game state

### Scene Hierarchy

```
/root
├── MainMenu (scenes/MainMenu.tscn)
└── WorldScene (scenes/WorldScene.tscn)
    ├── Environment (TileMap)
    ├── Player (KinematicBody2D)
    ├── NPCs (Node2D)
    ├── Enemies (Node2D)
    └── UI (CanvasLayer)
        ├── HUD
        ├── SimulationMenu
        └── LogBook
```

---

## ⚙️ Core Systems

### 1. Story State Manager (`StoryStateManager.gd`)

**Purpose:** Tracks world state variables that determine all future events.

**Key Variables:**
- `karma` (-100 to 100): Moral alignment
- `reputation` (-100 to 100): Social standing
- `destiny_thread` (0 to 100): Fate/coincidence factor
- `sect_influence` (dict): Relationship with each sect
- `faith_in_system` (0 to 100): Trust in Villain Simulator
- `realm_level` (1 to 7): Current cultivation realm

**Key Functions:**
```gdscript
# Modify world state
StoryStateManager.modify_state("karma", -10)

# Check sect influence
var influence = StoryStateManager.get_sect_influence("Talisman Sect")

# Trigger events
StoryStateManager.trigger_event("alliance_formed", {"faction": "Moon Pavilion"})

# Add items/insights
StoryStateManager.add_item("Cursed Amulet")
StoryStateManager.add_insight("The Moon Pavilion hides a dark secret")
```

**Causal Rules:**
The system automatically evaluates causal rules:
- Karma < -50 → Triggers heavenly tribulation
- Karma > 50 → Opens path to Heaven's Gate
- Sect influence > 70 + alliance → Unlocks forbidden locations

### 2. Cultivation System (`CultivationSystem.gd`)

**Purpose:** Manages cultivation realms, sutras, and player stats.

**Realms (in order):**
1. Mortal
2. Qi Condensation
3. Foundation Establishment
4. Core Formation
5. Nascent Soul
6. Saint
7. True Immortal

**Key Functions:**
```gdscript
# Check breakthrough possibility
if CultivationSystem.can_breakthrough():
    CultivationSystem.breakthrough()

# Learn sutras
CultivationSystem.load_heart_sutra("Heart Sutra of Veiled Hatred")
CultivationSystem.learn_technique_sutra("Talisman Strike Sutra")

# Modify stats
CultivationSystem.modify_stat("strength", 10)

# Cultivation
CultivationSystem.cultivate(delta)  # In _process
CultivationSystem.consume_qi(50)
```

**Sutra Types:**
- **Heart Sutras:** Define cultivation path (only one active)
- **Technique Sutras:** Grant combat abilities (multiple allowed)

### 3. Ability System (`AbilitySystem.gd`)

**Purpose:** Manages ability rolling and passive/active powers.

**Ability Ranks (Drop Rates):**
- White (50%): Basic bonuses
- Green (25%): Moderate bonuses
- Blue (15%): Strong effects
- Purple (8%): Rare powers
- Gold (2%): Legendary abilities

**Key Functions:**
```gdscript
# Roll ability
var ability = AbilitySystem.roll_ability()

# Unlock ability
AbilitySystem.unlock_ability(ability)

# Activate active ability
AbilitySystem.activate_ability("Demon Heart")

# Check for effects
if AbilitySystem.has_effect("qi_drain_on_kill"):
    # Handle effect
```

**Example Abilities:**
- **[White] Quick Learner:** +10% cultivation speed
- **[Blue] Echo of the Dead:** Absorb qi from kills
- **[Gold] Naturally Supreme:** +25% all stats, 2x cultivation speed

### 4. Simulation Manager (`SimulationManager.gd`)

**Purpose:** Core "Villain Simulator" system that generates narrative futures.

**Simulation Flow:**
1. Roll random ability
2. Load current player state
3. Generate events based on karma/stats
4. Determine death cause
5. Calculate rewards
6. Present 5 choices (player picks 2)

**Key Functions:**
```gdscript
# Start simulation
var simulation = SimulationManager.start_simulation()

# Get simulation history
var logs = SimulationManager.get_simulation_history(10)

# Reroll (if Fate Weaver ability)
if SimulationManager.can_reroll_simulation():
    SimulationManager.reroll_simulation()
```

**Reward Types:**
- Stats (strength, spirit, comprehension)
- Abilities (unlock rolled ability)
- Items (found during simulation)
- Sutras (new techniques)
- Insights (world secrets)
- Karma/Cultivation progress

### 5. Save/Load System (`SaveLoadSystem.gd`)

**Purpose:** Manages game saves and persistence.

**Key Functions:**
```gdscript
# New game
SaveLoadSystem.new_game()

# Save game
SaveLoadSystem.save_game(0)  # Slot 0
SaveLoadSystem.quick_save()
SaveLoadSystem.auto_save()

# Load game
SaveLoadSystem.load_game(0)

# Get save info
var saves = SaveLoadSystem.get_all_saves()
```

**Save Data Includes:**
- World state (karma, reputation, etc.)
- Cultivation progress
- Abilities and techniques
- Simulation history
- Event history
- Audio settings

---

## 🎯 Game Flow

### 1. Main Menu → New Game

```gdscript
SaveLoadSystem.new_game()
get_tree().change_scene("res://scenes/WorldScene.tscn")
```

### 2. Exploration & Combat

Player explores world using WASD movement:
- **WASD**: Move
- **Space**: Dodge roll
- **Mouse Click**: Attack/Shoot
- **T**: Open Simulation Menu
- **L**: Open Logbook

### 3. Running a Simulation

```gdscript
# Player presses T
SimulationManager.start_simulation()

# System generates narrative
# Player sees 5 reward options (A, B, C, D, E)
# Player selects 2
SimulationManager.select_rewards("A", "C")

# Rewards applied immediately
```

### 4. NPC Interactions

NPCs react dynamically:
```gdscript
# NPC checks player reputation
var reputation = StoryStateManager.get_state("reputation")
var karma = StoryStateManager.get_state("karma")

if karma < -30:
    behavior_state = "hostile"
elif reputation > 50:
    behavior_state = "friendly"
```

### 5. Cultivation & Breakthrough

```gdscript
# Gain cultivation progress
CultivationSystem.add_realm_progress(0.1)

# Check for breakthrough
if CultivationSystem.can_breakthrough():
    CultivationSystem.breakthrough()
    # New realm unlocked!
```

---

## 🎨 Usage Guide

### For Game Designers

**Adding New Sutras:**
```gdscript
# In CultivationSystem.gd -> initialize_sutra_database()
"Blood Moon Technique": {
    "type": "combat",
    "description": "Harness blood qi for devastating attacks",
    "unlocks": ["Blood Moon Strike", "Crimson Burst"],
    "karma_requirement": -40
}
```

**Adding New Death Causes:**
```gdscript
# In SimulationManager.gd -> death_causes array
death_causes.append("devoured by inner demons")
death_causes.append("betrayed by a close ally")
```

**Creating Causal Rules:**
```gdscript
# In StoryStateManager.gd -> evaluate_causal_rules()
if get_sect_influence("Shadow Demon Cult") > 80:
    if "Demonic Path" in world_state["secrets_revealed"]:
        unlocked_paths.append("Ancient Demon Realm")
```

### For Programmers

**Creating Custom NPCs:**
```gdscript
# Extend NPCBase.gd
extends "res://scripts/npc/NPCBase.gd"

func _ready():
    npc_name = "Elder Chen"
    sect_affiliation = "Talisman Sect"
    initial_disposition = 20
    ._ready()

func custom_behavior():
    # Add custom logic
    pass
```

**Adding New Abilities:**
```gdscript
# In AbilitySystem.gd -> ability_pool
"Purple": [
    {
        "name": "Time Dilation",
        "description": "Slow time for 5 seconds",
        "type": "active",
        "effects": {"time_scale": 0.3, "duration": 5.0}
    }
]
```

**Hooking into Events:**
```gdscript
# In any script
func _ready():
    StoryStateManager.connect("event_triggered", self, "_on_event")

func _on_event(event_name, event_data):
    if event_name == "heavenly_tribulation":
        # React to tribulation
        pass
```

---

## 🔧 Extending the Game

### Adding AI/LLM Integration

Replace the template-based narrative generation in `SimulationManager.gd`:

```gdscript
func generate_narrative_log(events, death_cause, ability):
    # Instead of template-based:
    # Call your AI API here
    var prompt = build_prompt(events, death_cause, ability)
    var ai_response = call_ai_api(prompt)
    return ai_response
```

### Creating Quest System

```gdscript
# New file: QuestManager.gd
extends Node

var active_quests = []
var completed_quests = []

func start_quest(quest_id):
    # Quest logic
    pass

func complete_quest(quest_id):
    # Give rewards based on karma/reputation
    pass
```

### Adding Combat Techniques

```gdscript
# In Player.gd
func use_technique(technique_name):
    match technique_name:
        "Talisman Strike":
            spawn_talisman_projectile()
        "Shadow Step":
            perform_shadow_teleport()
```

### Implementing Multiplayer Elements

The causal state system supports multiplayer:
```gdscript
# Share world state between players
func sync_world_state():
    rpc("receive_world_state", StoryStateManager.world_state)

remote func receive_world_state(state):
    StoryStateManager.world_state = state
```

---

## 📊 World State Variables Reference

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| `karma` | int | -100 to 100 | Moral alignment |
| `reputation` | int | -100 to 100 | Social standing |
| `destiny_thread` | int | 0 to 100 | Fate factor |
| `faith_in_system` | int | 0 to 100 | Trust in simulator |
| `realm_level` | int | 1 to 7 | Cultivation realm |
| `sect_influence` | dict | -100 to 100 | Per-sect influence |
| `simulations_done` | int | 0+ | Total simulations |

---

## 🎮 Controls Reference

| Action | Key | Description |
|--------|-----|-------------|
| Move | WASD | Character movement |
| Shoot | Mouse 1 | Attack/Cast |
| Dodge | Space | Dodge roll |
| Simulation | T | Open Villain Simulator |
| Logbook | L | View history/insights |
| Cancel | ESC | Close menus |

---

## 🏆 Endgame Conditions

The game tracks player progression toward multiple endings:

1. **Immortal Ascension** - Karma > 50, Heart Sutra stable
2. **Demonic Overlord** - Karma < -70, Faith in System high
3. **Eternal Loop** - Faith in System collapses (0)
4. **Devoured by Self** - Special event if simulation self rebels
5. **Abyssal Enlightenment** - Secret ending, merge both existences

---

## 🐛 Debugging

**Console Commands (in debug build):**
```gdscript
# Print current state
StoryStateManager.print_world_state()
CultivationSystem.print_cultivation_status()
AbilitySystem.print_abilities()
SaveLoadSystem.print_save_info()

# Test functions
SimulationManager.print_simulation_summary()
```

---

## 📝 Notes for Development

### Performance Considerations

- Event history grows over time - consider limiting to last 100 events
- Simulation logs should be capped (currently uncapped)
- NPC behavior updates every frame - consider optimizing

### Future Enhancements

1. **Visual Effects**: Add particle systems for abilities
2. **Sound Design**: Implement full audio system with spatial sound
3. **Procedural World**: Generate dungeons and locations
4. **Multiplayer**: Shared causal world state
5. **AI Narrative**: Replace templates with LLM integration
6. **Mobile Support**: Touch controls for twin-stick gameplay

---

## 📚 Additional Resources

- Godot Documentation: https://docs.godotengine.org
- GDScript Reference: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/
- Twin-stick Movement: See `Player.gd` for implementation
- Causal System: See `StoryStateManager.gd` for examples

---

**Version:** 1.0.0  
**Engine:** Godot 3.x  
**License:** See LICENSE file  
**Author:** Generated from Villain Simulator Blueprint

---
