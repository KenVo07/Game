# Simulation of the Eternal Path - Villain Edition
## Complete Game Design Document

### Table of Contents
1. [Overview](#overview)
2. [Core Systems](#core-systems)
3. [Gameplay Loop](#gameplay-loop)
4. [Technical Architecture](#technical-architecture)
5. [Content Structure](#content-structure)
6. [Development Roadmap](#development-roadmap)

---

## Overview

**Genre:** Dark-fantasy cultivation roguelite with twin-stick combat  
**Engine:** Godot 3.x (2D)  
**Art Style:** Pixel art with dark, atmospheric tones  
**Core Hook:** The "Villain Simulator" system that lets players preview possible futures

### Unique Selling Points
- **Causal Narrative Engine:** Every choice permanently affects the world state
- **Simulation System:** AI-generated narrative simulations that predict player's future
- **Cultivation Progression:** Deep character advancement through realms and sutras
- **Moral Ambiguity:** No clear good/evil, only consequences

---

## Core Systems

### 1. Story State Manager (`StoryStateManager.gd`)
Tracks all world variables that influence narrative branching:

```gdscript
world_state = {
    "reputation": 0,        # Social standing
    "karma": 0,             # Moral alignment
    "destiny_thread": 0,    # Fate influence
    "sect_influence": {},   # Relationship with factions
    "faith_in_system": 100, # Trust in Villain Simulator
    "realm_level": 1,       # Cultivation progress
    # ... more variables
}
```

**Key Features:**
- Event history tracking
- Causal rule engine
- Condition querying for dialogue/events
- Save/load integration

### 2. Cultivation System (`CultivationSystem.gd`)
Manages character progression through realms:

**Realms:**
1. Mortal
2. Qi Condensation
3. Foundation Establishment
4. Core Formation
5. Nascent Soul
6. Saint
7. True Immortal

**Stats:**
- Strength (physical damage)
- Spirit (qi manipulation)
- Qi Capacity/Current (resource pool)
- Vitality (health)
- Comprehension (cultivation speed)
- Luck (loot/encounters)

**Heart Sutras:** Define cultivation path and efficiency
**Technique Sutras:** Grant combat abilities

### 3. Ability System (`AbilitySystem.gd`)
Manages randomly rolled abilities before each simulation:

**Ability Ranks:**
- White (50%) - Common
- Green (25%) - Uncommon
- Blue (15%) - Rare
- Purple (8%) - Epic
- Gold (2%) - Legendary

**Example Abilities:**
- **Gold: Naturally Supreme** - 3x cultivation speed, +50 all stats
- **Purple: Talisman Whisperer** - 50% qi cost, 2x damage for talismans
- **Blue: Mind Splitter** - Parallel thinking, +20 comprehension

### 4. Simulation Manager (`SimulationManager.gd`)
The core "Villain Simulator" feature:

**Flow:**
1. Roll random ability rank
2. Generate narrative events based on world state
3. Simulate until death
4. Present 5 choices (A-E) of rewards
5. Player selects 2 rewards
6. Apply rewards and update world state

**Narrative Generation:**
- Procedural event chains
- Context-aware death causes
- Karma-influenced outcomes
- Loot/sutra rewards

### 5. Player Controller (`Player.gd`)
Twin-stick combat mechanics inspired by Soul Knight:

**Controls:**
- WASD - Movement
- Mouse - Aim direction
- Left Click - Shoot
- Space - Dash
- 1/2 - Abilities
- E - Interact
- Tab - Open Simulation Menu

**Combat Features:**
- Projectile attacks
- Dash with invulnerability (with ability)
- Qi-based abilities
- Technique system from sutras

---

## Gameplay Loop

### Macro Loop
1. **Explore** the world (Daxia Empire)
2. **Combat** enemies and gain cultivation experience
3. **Interact** with NPCs (influenced by karma/reputation)
4. **Run Simulations** to preview futures and gain rewards
5. **Make Choices** that alter world state
6. **Breakthrough** to new realms
7. **Repeat** with increasing stakes and complexity

### Simulation Loop
1. Press E to open Simulation Menu
2. Click "Run Simulation"
3. Read narrative log of simulated life
4. Review 5 possible rewards
5. Select 2 rewards to keep
6. Return to exploration
7. Faith in System decreases each use

### Consequence System
- Negative karma → Heavenly tribulations, sect raids
- Positive karma → Divine blessings, ally support
- Low faith → Simulator becomes unreliable, ending path
- High sect influence → Access to secret areas
- Alliances/Enemies → Change NPC behavior

---

## Technical Architecture

### Node Structure
```
/root
├── MainMenu (scene)
├── WorldScene (scene)
│   ├── Player (KinematicBody2D)
│   ├── NPCs (Node2D container)
│   ├── Enemies (Node2D container)
│   ├── Environment (TileMap)
│   └── UI (CanvasLayer)
│       ├── HUD
│       ├── SimulationMenu
│       └── LogBook
└── Singletons (autoload)
    ├── StoryStateManager
    ├── SimulationManager
    ├── CultivationSystem
    ├── AbilitySystem
    └── AudioManager
```

### Data Files
- `data/sutras.json` - Heart and technique sutras
- `data/events.json` - Random and story events
- `data/npcs.json` - NPC definitions and dialogue
- `data/items.json` - (TODO) Item definitions

### Save System (`SaveLoadSystem.gd`)
- JSON-based save files
- 10 save slots + auto-save + quick-save
- Saves all singleton states
- Player position and inventory
- Complete event history

---

## Content Structure

### World Map (Planned)
1. **Daxia Capital** - Starting city, multiple districts
   - Market District
   - Talisman Quarter
   - Imperial Palace
   - Slums

2. **Moon Pavilion** - Mysterious sect location
   - Hidden portal to celestial realm
   - Moon Sage NPC

3. **Forbidden Mountains** - Demonic territory
   - Blood Demon Sect base
   - Dangerous cultivation resources

4. **Ancient Ruins** - Exploration zones
   - Puzzles and secrets
   - Lost cultivation techniques

5. **Celestial Realm** - Endgame area
   - Ascension path
   - True Immortal challenges

### Faction System
- **Talisman Sect:** Neutral, teaches talisman arts
- **Blood Demon Sect:** Evil, demonic cultivation
- **Moon Pavilion:** Mysterious, space/time manipulation
- **Imperial Guard:** Lawful, protects empire
- **Hidden Masters:** Neutral, supreme dao seekers

### Ending Paths
1. **Immortal Ascension** - High karma, high realm
2. **Demonic Overlord** - Low karma, high faith
3. **Eternal Loop** - Faith collapses, trapped in simulations
4. **Devoured by Self** - Simulation self becomes real
5. **Abyssal Enlightenment** - Transcend reality itself

---

## Development Roadmap

### Phase 1: Core Systems ✅ (COMPLETED)
- [x] Project setup
- [x] All singleton systems
- [x] Player controller with basic combat
- [x] UI framework (HUD, SimulationMenu, LogBook)
- [x] Save/load system
- [x] NPC and Enemy base classes

### Phase 2: Content (TODO)
- [ ] Create tile maps for Daxia Capital
- [ ] Implement 10+ enemy types
- [ ] Add 20+ NPCs with dialogue
- [ ] Create 50+ random events
- [ ] Design 5 major story events
- [ ] Implement all sutras and abilities

### Phase 3: Polish (TODO)
- [ ] Art assets (pixel art sprites)
- [ ] Sound effects and music
- [ ] Particle effects for abilities
- [ ] Animation polish
- [ ] UI/UX improvements
- [ ] Balance tuning

### Phase 4: Advanced Features (TODO)
- [ ] AI narrative generation integration
- [ ] Procedural dungeon generation
- [ ] Multiplayer co-op (stretch goal)
- [ ] Mod support (stretch goal)

---

## AI Integration Notes

The `SimulationManager` is designed to integrate with AI for narrative generation:

**Current:** Procedural template-based generation
**Planned:** LLM integration for dynamic narratives

**AI Prompt Structure:**
```
Context: {world_state variables}
Character: Realm {realm}, Karma {karma}, Ability {ability}
Task: Generate a cultivation simulation ending in death
Style: Dark-fantasy, third-person, concise
Output: 3-7 events + death cause + rewards
```

**Integration Points:**
- `_run_simulation()` function
- Event description generation
- Death cause generation
- NPC dialogue generation

---

## Technical Notes

### Performance Considerations
- Event history limited to 500 entries
- Simulation log limited to 50 entries
- SFX player pool (16 concurrent sounds)
- Efficient JSON save/load

### Godot-Specific
- Uses GDScript signals for decoupling
- Autoload singletons for global state
- Scene-based UI management
- KinematicBody2D for player/enemies

### Extensibility
- JSON-based content (easy to add events/NPCs/sutras)
- Modular dialogue system
- Pluggable AI narrative generator
- Save system supports version migration

---

## Credits

**Design:** Based on cultivation novel tropes + roguelite mechanics
**Inspiration:** Soul Knight (combat), Hades (roguelite), Chinese xianxia novels
**Engine:** Godot 3.x

---

*This is a living document. Update as development progresses.*
