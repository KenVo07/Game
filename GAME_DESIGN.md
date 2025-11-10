# Simulation of the Eternal Path - Villain Edition
## Godot Game Implementation - Design Reference

This document provides a quick reference for the game's systems and design philosophy.

---

## Core Philosophy

**Causal Narrative Engine**: Every decision modifies the world state in a single timeline. There are no parallel branches—only consequences that ripple forward through time.

**Villain Simulator**: The player possesses a mysterious artifact that can simulate possible futures. Each simulation grants insights, abilities, and knowledge, but using it comes with psychological costs.

**Cultivation Progression**: Inspired by Chinese xianxia, the player advances through cultivation realms by gathering qi, learning sutras, and surviving tribulations.

---

## System Architecture

### 1. StoryStateManager (Singleton)
- **Purpose**: Central hub for all narrative state
- **Key Variables**:
  - `karma`: Moral alignment (-100 to 100)
  - `reputation`: Social standing (-100 to 100)
  - `destiny_thread`: Fate intervention chance (0-100)
  - `faith_in_system`: Trust in the Villain Simulator (0-100)
  - `sect_influences`: Relationship with each faction
  
- **Causal Rules**: Automatically triggers events when thresholds are met
  - Karma < -50 → Heavenly Tribulation
  - Reputation > 70 → Legendary status unlocked
  - Faith < 20 → System Rebellion event

### 2. CultivationSystem (Singleton)
- **Purpose**: Handle player power progression
- **Realms**: Mortal → Qi Condensation → Foundation → Core → Nascent Soul → Saint → True Immortal
- **Heart Sutras**: Define cultivation path (efficiency multiplier)
- **Technique Sutras**: Grant combat abilities
- **Breakthrough Conditions**: Some realms require specific karma or events

### 3. AbilitySystem (Singleton)
- **Purpose**: Manage passive and active abilities
- **Ability Ranks**: White (50%) → Green (25%) → Blue (15%) → Purple (8%) → Gold (2%)
- **Pre-Simulation Roll**: Each simulation starts by rolling a random ability
- **Notable Abilities**:
  - Mind Splitter (Blue): Control simulation while playing
  - Naturally Supreme (Gold): Double all stat gains
  - Eternal Regression (Gold): Death immunity with memory retention

### 4. SimulationManager (Singleton)
- **Purpose**: Run procedural "villain simulator" sequences
- **Flow**:
  1. Roll ability rank and specific ability
  2. Generate 5-12 narrative events based on world state
  3. Conclude with death cause
  4. Present 5 reward choices (player picks 2)
- **Event Weighting**: Events are more likely if they match current karma/reputation
- **Reward Types**: Stats, items, insights, abilities, cultivation progress

### 5. SaveLoadSystem (Singleton)
- **Purpose**: Persistence across sessions
- **Format**: JSON saved to `user://saves/`
- **Features**: 10 save slots, auto-save, metadata preview

### 6. AudioManager (Singleton)
- **Purpose**: Music and sound effect control
- **Audio Buses**: Master, Music, SFX, Ambient
- **Context Music**: Automatically switches based on game state

---

## Player Controller

**Movement**: Twin-stick style (WASD for movement, mouse for aiming)
**Combat**: Click to attack (projectile/talisman casting)
**Dodge**: Space bar for invincibility roll
**Stats**: Derived from CultivationSystem
- Vitality → Max Health
- Spirit → Qi Capacity
- Strength → Damage
- Agility → Move Speed

---

## UI Components

### HUD
- Health/Qi bars
- Realm and cultivation progress
- Karma and reputation display
- Notifications for events

### Simulation Menu (Press T)
- View simulation log in real-time
- See rolled ability and success rating
- Select 2 of 5 rewards

### Log Book
- Event History: All world state changes
- Insights: Discovered clues and secrets
- Quests: Active objectives

---

## Causal Event Examples

```gdscript
# Example 1: Destroying a sect altar
modify_state("karma", -20)
modify_sect_influence("Talisman Sect", -30)
trigger_event("sect_revenge_raid")

# Example 2: Saving a disciple
modify_state("karma", 10)
modify_state("reputation", 5)
add_follower("DiscipleName")

# Example 3: Using simulation 20+ times
# Automatically triggers "simulation_addiction" event
# Reduces faith_in_system by -30
```

---

## Data-Driven Design

### Sutras (in CultivationSystem.gd)
```gdscript
"Heart Sutra of Silent Chaos": {
    "type": "heart",
    "efficiency": 1.0,
    "stat_bonus": {"strength": 2, "spirit": 3},
    "special": "Gain progress from negative karma"
}
```

### Abilities (in AbilitySystem.gd)
```gdscript
"Naturally Supreme": {
    "rank": "Gold",
    "type": "passive",
    "description": "Double all stat gains",
    "effect": {"stat_multiplier": 2.0}
}
```

### Events (in SimulationManager.gd)
```gdscript
{
    "text": "You plunder a sect's treasury",
    "karma_change": -8,
    "stat_change": {"strength": 1, "spirit": 1}
}
```

---

## Extending the Game

### Adding New Sutras
1. Add entry to `CultivationSystem.sutra_database`
2. Specify type (heart/combat/movement/utility)
3. Define stat bonuses and abilities
4. Optionally add special effects

### Adding New Abilities
1. Add entry to `AbilitySystem.ability_database`
2. Set rank (White/Green/Blue/Purple/Gold)
3. Define passive or active type
4. Implement effect logic in `_execute_ability_effect()`

### Adding New Causal Rules
1. Add rule to `StoryStateManager._initialize_causal_rules()`
2. Define condition function
3. Define effect function
4. Set trigger_once flag and cooldown

### Adding Simulation Events
1. Add template to `SimulationManager._initialize_event_templates()`
2. Provide text variants
3. Set karma/reputation weights for contextual triggering
4. Define effects (stat changes, insights, items)

---

## Development Roadmap

### Phase 1: Core Systems ✓
- [x] Causal narrative engine
- [x] Cultivation progression
- [x] Ability system
- [x] Simulation flow
- [x] Save/load

### Phase 2: Content Expansion
- [ ] 10+ sutras per category
- [ ] 50+ simulation events
- [ ] 5 major sects with storylines
- [ ] Boss encounters
- [ ] Multiple endings

### Phase 3: Polish
- [ ] Pixel art assets
- [ ] Atmospheric audio
- [ ] Particle effects
- [ ] Tutorial system
- [ ] Achievements

### Phase 4: Advanced Features
- [ ] AI-generated simulation text (LLM integration)
- [ ] Procedural dungeon generation
- [ ] Multiplayer simulation sharing
- [ ] Mod support

---

## Technical Notes

### Godot Version
Built for **Godot 3.x**. Main scene: `res://scenes/MainMenu.tscn`

### Performance
- Event history capped at 100 entries
- SFX player pool of 8 concurrent sounds
- Auto-save every 5 minutes

### Architecture Principles
1. **Single Responsibility**: Each singleton handles one domain
2. **Signal-Driven**: Systems communicate via signals, not direct calls
3. **Data Separation**: Game data in dictionaries, logic in functions
4. **Save Everything**: All systems expose `get_save_data()` and `load_save_data()`

---

## Credits & Inspiration

- **Genre**: Roguelike + Cultivation + Narrative Sim
- **Inspired By**: Soul Knight (gameplay), Slay the Spire (reward system), Chinese Xianxia novels (setting)
- **Art Style**: Dark-fantasy pixel art with jade, bronze, and ash tones

---

## Quick Start Guide

1. Open project in Godot 3.x
2. Run project (F5) - starts at MainMenu
3. Click "New Game" to enter WorldScene
4. Press **T** to open Villain Simulator
5. Press **WASD** to move, **Mouse** to aim, **Click** to attack
6. Press **Space** to dodge

Enjoy your journey on the Eternal Path! 🗡️✨
