# Simulation of the Eternal Path - Villain Edition

A dark-fantasy cultivation game combining twin-stick 2D combat with a text-based simulation system and causal narrative engine.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Engine](https://img.shields.io/badge/engine-Godot_3.x-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## 🎮 Game Overview

**Simulation of the Eternal Path** is a unique blend of:
- **Action Combat**: Twin-stick 2D combat inspired by Soul Knight
- **Narrative Depth**: Text-based "Villain Simulator" that generates possible futures
- **Causal World**: Every choice permanently affects the world state
- **Cultivation Progression**: Grow from mortal to immortal through 7 realms

### The Villain Simulator

A mysterious artifact that simulates your possible futures. Each simulation:
- Rolls a random ability (White → Gold rarity)
- Shows how you might die or succeed
- Reveals hidden insights about the world
- Offers rewards to strengthen your real self

But beware: the more you simulate, the more reality fractures...

## 🚀 Quick Start

### Prerequisites
- Godot Engine 3.5+ ([Download](https://godotengine.org/download))

### Installation
1. Clone this repository
2. Open Godot Engine
3. Click "Import" and select the `project.godot` file
4. Press F5 to run the game

### Controls
- **WASD**: Movement
- **Arrow Keys**: Aim/Shoot (twin-stick style)
- **Space**: Dodge/Dash
- **T**: Open Villain Simulator
- **ESC**: Pause Menu

## 📖 Key Features

### 🎲 Causal Narrative Engine
- No branching paths - one timeline that reacts to all choices
- NPCs remember your actions
- Consequences can emerge much later
- World permanently changes based on karma

### ⚔️ Cultivation System
7 realms of progression:
1. Mortal
2. Qi Condensation
3. Foundation Establishment
4. Core Formation
5. Nascent Soul
6. Saint
7. True Immortal

### 🎁 Ability System
Random abilities with 5 rarity tiers:
- **White (50%)**: Common abilities
- **Green (25%)**: Uncommon abilities
- **Blue (15%)**: Rare abilities
- **Purple (8%)**: Epic abilities
- **Gold (2%)**: Legendary abilities

### 📜 Multiple Endings
Your karma, realm, and choices determine your fate:
- Immortal Ascension
- Demonic Overlord
- Abyssal Enlightenment
- Eternal Loop
- Reality Collapse
- And more secret endings...

## 🏗️ Project Structure

```
/workspace/
├── project.godot              # Godot project configuration
├── scripts/
│   ├── singletons/           # Global game systems
│   │   ├── StoryStateManager.gd     # Causal narrative engine
│   │   ├── CultivationSystem.gd     # Realm progression
│   │   ├── AbilitySystem.gd         # Ability rolling
│   │   ├── SimulationManager.gd     # Villain Simulator
│   │   ├── AudioManager.gd          # Audio system
│   │   └── SaveLoadSystem.gd        # Save/load
│   ├── ui/                   # User interface
│   ├── Player.gd            # Player controller
│   ├── Enemy.gd             # Enemy AI
│   └── CausalEventTriggers.gd # Event system
├── scenes/                   # Godot scenes
│   ├── MainMenu.tscn
│   ├── WorldScene.tscn
│   ├── SimulationScene.tscn
│   └── Projectile.tscn
├── DEVELOPMENT_GUIDE.md     # Detailed development documentation
├── GAME_DESIGN_SUMMARY.md   # Game design philosophy
└── IMPLEMENTATION_NOTES.md  # Current implementation status
```

## 🎯 Core Systems

### StoryStateManager
Tracks global world state and triggers causal events:
```gdscript
# Modify karma
StoryStateManager.modify_state("karma", -15)

# Trigger event
StoryStateManager.trigger_event("sect_revenge_raid")

# Complex action
StoryStateManager.apply_causal_action({
    "karma": -15,
    "sect_influence": {"Talisman Sect": -30}
})
```

### CultivationSystem
Manages cultivation progression:
```gdscript
# Modify stats
CultivationSystem.modify_stat("strength", 5)

# Learn sutra
CultivationSystem.learn_sutra("Phantom Step", "movement")

# Attempt breakthrough
CultivationSystem.breakthrough()
```

### SimulationManager
The Villain Simulator:
```gdscript
# Start simulation
var sim = SimulationManager.start_simulation()

# Apply rewards
SimulationManager.apply_selected_rewards([0, 2])
```

## 📚 Documentation

- **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)**: Complete development documentation
- **[GAME_DESIGN_SUMMARY.md](GAME_DESIGN_SUMMARY.md)**: Game design philosophy and vision
- **[IMPLEMENTATION_NOTES.md](IMPLEMENTATION_NOTES.md)**: Current implementation status

## 🎨 Art & Audio

### Current Implementation
- Placeholder colored sprites (easy to replace)
- UI with dark fantasy theme
- Audio manager ready for sound integration

### Adding Your Own Assets
1. **Sprites**: Replace colored rectangles with pixel art
2. **Audio**: Add files to `audio/bgm/` and `audio/sfx/`
3. **UI**: Modify scene files in `scenes/`

## 🔧 Extending the Game

### Adding New Abilities
Edit `scripts/singletons/AbilitySystem.gd`:
```gdscript
var ability_pool = {
    "Gold": [
        {
            "name": "Your New Ability",
            "desc": "What it does"
        }
    ]
}
```

### Creating Causal Events
Edit `scripts/CausalEventTriggers.gd`:
```gdscript
func _on_world_state_changed(variable_name, old_value, new_value):
    match variable_name:
        "your_variable":
            _trigger_custom_event()
```

### Adding Simulation Events
Edit `scripts/singletons/SimulationManager.gd`:
```gdscript
var event_templates = [
    {
        "stage": "mid",
        "type": "combat",
        "text": "Your event text...",
        "outcomes": ["victory", "defeat", "escape"]
    }
]
```

## 🎮 Gameplay Tips

1. **Manage Karma**: Your moral choices unlock different paths
2. **Use Simulations Wisely**: They reveal secrets but cost faith
3. **Experiment with Abilities**: Different builds drastically change gameplay
4. **Track World State**: Pay attention to sect relations and reputation
5. **Read Simulation Logs**: They contain vital clues

## 🐛 Known Issues

- Placeholder art (colored rectangles)
- Audio files not included (paths ready)
- Limited enemy variety
- Single test area

These are intentional for the template/prototype phase.

## 🚧 Roadmap

### Phase 1 - Core Complete ✅
- [x] Core systems implementation
- [x] Basic combat and movement
- [x] Simulation generation
- [x] Causal narrative engine
- [x] Save/load system

### Phase 2 - Content
- [ ] More sutras and abilities
- [ ] NPC dialogue system
- [ ] Additional enemy types
- [ ] Multiple game areas
- [ ] Visual effects

### Phase 3 - Polish
- [ ] AI-driven narrative generation
- [ ] Balance tuning
- [ ] Full story campaign
- [ ] Achievement system
- [ ] Performance optimization

### Phase 4 - Extended
- [ ] New game+ modes
- [ ] Additional characters
- [ ] Multiplayer elements
- [ ] Community content tools

## 🤝 Contributing

Contributions are welcome! Areas needing work:
- Pixel art sprites
- Sound effects and music
- Additional abilities and sutras
- More simulation events
- Balance tuning
- Bug fixes

## 📜 License

This project is provided as-is under the MIT License. Feel free to use, modify, and distribute.

## 🙏 Acknowledgments

Inspired by:
- Chinese cultivation novels (xianxia/wuxia)
- Soul Knight (combat gameplay)
- 80 Days (narrative simulation)
- Disco Elysium (choice consequences)
- Nier: Automata (philosophical themes)

## 📞 Support

For questions or issues:
1. Check the [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)
2. Review the inline code documentation
3. Open an issue on the repository

---

*"If you could simulate your future selves, would you become who they were? And if you did, which one would be real?"*

**Made with Godot Engine**