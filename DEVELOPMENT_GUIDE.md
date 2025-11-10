# Development Guide - Simulation of the Eternal Path

## Project Structure

```
/workspace/
├── project.godot              # Godot project configuration
├── default_env.tres           # Default environment settings
├── scripts/
│   ├── singletons/           # Global singleton managers
│   │   ├── StoryStateManager.gd     # Causal narrative engine
│   │   ├── CultivationSystem.gd     # Realm and stats management
│   │   ├── AbilitySystem.gd         # Ability rolling and effects
│   │   ├── SimulationManager.gd     # Villain Simulator core
│   │   ├── AudioManager.gd          # Sound and music
│   │   └── SaveLoadSystem.gd        # Save/load persistence
│   ├── ui/                   # UI components
│   │   ├── HUD.gd           # In-game HUD
│   │   ├── SimulationMenu.gd # Simulation interface
│   │   └── LogBook.gd       # Simulation history viewer
│   ├── Player.gd            # Player controller
│   ├── Enemy.gd             # Enemy base class
│   ├── Projectile.gd        # Projectile behavior
│   ├── MainMenu.gd          # Main menu controller
│   └── CausalEventTriggers.gd # Example event system
└── scenes/
    ├── MainMenu.tscn        # Main menu scene
    ├── WorldScene.tscn      # Main game world
    ├── SimulationScene.tscn # Simulation UI
    └── Projectile.tscn      # Projectile prefab
```

## Core Systems

### 1. StoryStateManager (Causal Narrative Engine)

The heart of the game's narrative system. Tracks all world state variables and triggers causal events based on conditions.

**Key Variables:**
- `karma`: Moral alignment (-100 to +100)
- `reputation`: Social standing
- `sect_influence`: Relations with each sect
- `faith_in_system`: Trust in the Villain Simulator
- `realm_level`: Current cultivation realm
- `simulations_done`: Number of simulations run

**Usage:**
```gdscript
# Modify a state variable
StoryStateManager.modify_state("karma", -15)

# Set directly
StoryStateManager.set_state("heart_sutra", "Heart Sutra of Silent Chaos")

# Trigger custom event
StoryStateManager.trigger_event("custom_event_name")

# Apply complex action
StoryStateManager.apply_causal_action({
    "karma": -15,
    "sect_influence": {"Talisman Sect": -30},
    "enemies": "Elder Feng"
})
```

### 2. CultivationSystem

Manages player cultivation progression, realms, stats, and sutras.

**Realms:**
1. Mortal
2. Qi Condensation
3. Foundation Establishment
4. Core Formation
5. Nascent Soul
6. Saint
7. True Immortal

**Stats:**
- strength: Physical power
- spirit: Qi manipulation
- vitality: Health and defense
- agility: Speed and dodge

**Usage:**
```gdscript
# Modify stats
CultivationSystem.modify_stat("strength", 5)

# Learn sutras
CultivationSystem.learn_sutra("Phantom Step Technique", "movement")

# Attempt breakthrough
if CultivationSystem.can_breakthrough():
    CultivationSystem.breakthrough()
```

### 3. AbilitySystem

Handles random ability rolling and permanent ability acquisition.

**Ability Ranks:**
- White (50%): Common abilities
- Green (25%): Uncommon abilities
- Blue (15%): Rare abilities
- Purple (8%): Epic abilities
- Gold (2%): Legendary abilities

**Usage:**
```gdscript
# Roll a random ability
var ability = AbilitySystem.roll_ability()

# Accept the rolled ability
AbilitySystem.accept_rolled_ability()

# Check for specific ability
if AbilitySystem.has_ability("Naturally Supreme"):
    # Player has the ability
```

### 4. SimulationManager

The Villain Simulator - generates text-based simulations of possible futures.

**Simulation Flow:**
1. Roll random ability
2. Generate 3-5 events based on player state
3. Determine outcome (death or survival)
4. Present 5 reward choices
5. Player selects 2 rewards
6. Apply rewards to player

**Usage:**
```gdscript
# Start a simulation
var simulation = SimulationManager.start_simulation()

# Apply selected rewards (indices 0-4, select 2)
SimulationManager.apply_selected_rewards([0, 2])

# Get simulation history
var history = SimulationManager.get_simulation_history()
```

### 5. SaveLoadSystem

JSON-based save/load system with 5 save slots.

**Usage:**
```gdscript
# Save to slot
SaveLoadSystem.save_game(1)

# Load from slot
SaveLoadSystem.load_game(1)

# Quick save/load
SaveLoadSystem.quick_save()
SaveLoadSystem.quick_load()

# Get save info
var info = SaveLoadSystem.get_save_info(1)
```

## Causal Event System

The game uses a cause-and-effect narrative system where every action has consequences.

### Creating Causal Events

**Example 1: Simple state check**
```gdscript
# In StoryStateManager, add to causal_rules:
{
    "name": "Demonic Path Unlock",
    "condition": func(): return world_state["karma"] < -30,
    "effect": func(): trigger_event("demonic_path_unlock")
}
```

**Example 2: Complex event chain**
```gdscript
# 1. Player action
StoryStateManager.apply_causal_action({
    "karma": -15,
    "destroyed_artifacts": "Sacred Talisman"
})

# 2. CausalEventTriggers reacts
func _check_artifact_destruction(artifact):
    if artifact == "Sacred Talisman":
        _trigger_elder_feng_warning()

# 3. Delayed consequence
yield(get_tree().create_timer(10.0), "timeout")
if still_hostile:
    StoryStateManager.trigger_event("sect_revenge_raid")
```

### Event Examples

See `scripts/CausalEventTriggers.gd` for complete examples including:
- Artifact destruction consequences
- NPC interaction chains
- Karma threshold unlocks
- Multi-stage quest chains

## Adding New Content

### New Abilities

Add to `AbilitySystem.gd`:
```gdscript
var ability_pool = {
    "Purple": [
        {
            "name": "New Ability Name",
            "desc": "Description of what it does"
        }
    ]
}

# Add effect in _apply_ability_effect():
"New Ability Name":
    CultivationSystem.modify_stat("spirit", 20)
```

### New Sutras

```gdscript
CultivationSystem.learn_sutra("New Sutra Name", "combat")

# Types: "combat", "technique", "movement", "heart"
```

### New Simulation Events

Add to `SimulationManager.gd`:
```gdscript
var event_templates = [
    {
        "stage": "mid",  # early/mid/late
        "type": "exploration",
        "text": "You discover a hidden cave...",
        "outcomes": ["success", "failure", "neutral"]
    }
]
```

### New Causal Rules

Add to `CausalEventTriggers.gd`:
```gdscript
func _on_world_state_changed(variable_name, old_value, new_value):
    match variable_name:
        "your_custom_variable":
            _handle_custom_event()
```

## Player Controls

- **WASD**: Movement
- **Arrow Keys**: Aim/Shoot (twin-stick)
- **Space**: Dodge/Dash
- **T**: Open Villain Simulator
- **ESC**: Pause menu
- **E**: Interact with NPCs/objects

## Extending the Game

### Adding NPCs

Create a new script extending `Node2D` or `KinematicBody2D`:
```gdscript
extends Node2D

var dialogue = []
var karma_requirement = 0

func interact():
    # Check karma/reputation
    if StoryStateManager.get_state("karma") >= karma_requirement:
        show_dialogue(dialogue)
```

### Adding Enemies

Extend the `Enemy.gd` base class:
```gdscript
extends "res://scripts/Enemy.gd"

func _ready():
    health = 100
    damage = 20
    move_speed = 150
    # Custom behavior here
```

### Adding New UI

1. Create scene file (.tscn)
2. Create controller script (.gd)
3. Connect to relevant singletons
4. Use signals for communication

## Audio Setup

To add audio:
1. Place audio files in `audio/bgm/` or `audio/sfx/`
2. Update paths in `AudioManager.gd`
3. Use `AudioManager.play_bgm("track_name")` or `AudioManager.play_sfx("sound_name")`

## Testing Features

### Test Simulation
```gdscript
# In game, press T to open simulator
# Or programmatically:
SimulationManager.start_simulation()
```

### Test Causal Events
```gdscript
# Force karma change
StoryStateManager.modify_state("karma", -60)

# Trigger specific event
StoryStateManager.trigger_event("heavenly_tribulation")
```

### Test Abilities
```gdscript
# Force gold ability roll
var gold_ability = AbilitySystem.ability_pool["Gold"][0]
AbilitySystem.current_rolled_ability = {
    "name": gold_ability["name"],
    "rank": "Gold",
    "desc": gold_ability["desc"]
}
AbilitySystem.accept_rolled_ability()
```

## Performance Considerations

- Simulations are text-based and lightweight
- Causal checks run only on state changes
- Save/load uses JSON (consider compression for large histories)
- Pool projectiles if shooting frequently

## Future Enhancements

Suggested features to add:
1. **AI Integration**: Use LLM for dynamic simulation text generation
2. **More Realms**: Extend beyond True Immortal
3. **Faction System**: Complex relations between multiple sects
4. **Equipment**: Weapons, armor, artifacts
5. **Companions**: Recruit NPCs as followers
6. **Dungeons**: Procedurally generated challenge areas
7. **PvP Arena**: Test against other cultivators
8. **World Events**: Time-based global events
9. **Achievement System**: Track player accomplishments
10. **Multiple Endings**: Based on final karma/realm/choices

## Debugging

Enable debug output:
```gdscript
# Each singleton prints initialization and state changes
# Check console for [SystemName] prefixed messages
```

Common issues:
- **Simulation not appearing**: Check T key binding in project settings
- **Stats not updating**: Verify CultivationSystem connections
- **Events not triggering**: Check causal_rules conditions in StoryStateManager

## Architecture Philosophy

The game follows these principles:
1. **Causal, not branching**: One timeline that reacts to all choices
2. **Singleton systems**: Global managers for core functionality
3. **Event-driven**: Signals connect systems loosely
4. **State-first**: World state determines all outcomes
5. **Data-driven**: JSON/Dictionary configuration over hardcoding

## Contributing

When adding new features:
1. Follow existing naming conventions
2. Add print statements for debugging
3. Connect to appropriate signals
4. Update this guide with new systems
5. Test save/load compatibility

## License

This project template is free to use and modify.
