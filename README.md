# 🌙 Simulation of the Eternal Path - Villain Edition

A dark-fantasy cultivation game with causal narrative system and AI-powered villain simulator.

![Version](https://img.shields.io/badge/version-1.0.0-purple)
![Engine](https://img.shields.io/badge/engine-Godot%203.x-blue)
![Genre](https://img.shields.io/badge/genre-Action%20RPG-red)

---

## 📖 Overview

**Simulation of the Eternal Path - Villain Edition** is a 2D action RPG built in Godot that combines:

- **Twin-stick combat** inspired by Soul Knight
- **Causal narrative system** where every choice has persistent consequences
- **Villain Simulator** that predicts possible futures through death
- **Cultivation progression** through 7 realms of power
- **Reactive world** that responds to your karma and reputation
- **Procedural abilities** with 5 rarity tiers (White → Gold)

### 🎮 Core Gameplay Loop

1. **Explore** dark-fantasy world filled with sects, cultivators, and ancient secrets
2. **Fight** using twin-stick combat with qi-powered abilities
3. **Simulate** possible futures to see how you might die
4. **Choose** rewards from simulation outcomes (pick 2 of 5)
5. **Progress** through cultivation realms using acquired knowledge
6. **React** to world changes based on your karma and actions

---

## ✨ Key Features

### 🔮 Villain Simulator
- Run simulations that show your possible futures
- Each simulation rolls a random ability (White to Gold rarity)
- Learn from your deaths to grow stronger
- Choose 2 rewards from 5 options: stats, abilities, items, sutras, insights

### ⚔️ Combat System
- **Twin-stick movement**: WASD to move, mouse to aim and shoot
- **Dodge mechanics**: Space to roll with i-frames
- **Qi abilities**: Consume qi for powerful techniques
- **Cultivation-based stats**: Strength, spirit, and qi scale with realm

### 🧘 Cultivation System
- **7 Realms**: Mortal → Qi Condensation → Foundation → Core → Nascent Soul → Saint → True Immortal
- **Heart Sutras**: Define your cultivation path (demonic, righteous, or neutral)
- **Technique Sutras**: Grant combat abilities and movement skills
- **Breakthrough**: Advance realms when requirements are met

### 📜 Causal Narrative Engine
- **Single timeline**: No parallel branches - all choices persist
- **Karma system**: Actions affect moral alignment (-100 to +100)
- **Reputation**: Social standing with sects and factions
- **Sect influence**: Build or destroy relationships with powerful organizations
- **Faith in system**: Trust in the Villain Simulator affects its reliability

### 🎭 Reactive NPCs
- NPCs remember your actions and reputation
- Behavior changes based on karma (hostile, neutral, friendly)
- Sect members react to your standing with their faction
- Dynamic dialogue based on world state

### 💾 Save System
- 10 save slots + auto-save
- Persistent world state across all systems
- Full simulation and event history
- Resume from any saved point

---

## 🚀 Getting Started

### Prerequisites
- **Godot 3.5+** (download from [godotengine.org](https://godotengine.org))

### Installation

1. Clone this repository:
```bash
git clone <repository-url>
cd workspace
```

2. Open Godot and import the project:
   - Click "Import"
   - Navigate to the workspace folder
   - Select `project.godot`

3. Run the game:
   - Press F5 or click the Play button

### First Run

1. Start from **Main Menu**
2. Click **New Game** to begin
3. Press **T** to open the Villain Simulator
4. Run your first simulation to gain abilities
5. Explore the world and make choices

---

## 🎮 Controls

| Action | Key | Description |
|--------|-----|-------------|
| **Move** | WASD | Character movement |
| **Aim** | Mouse | Direction to shoot |
| **Attack** | Left Click | Fire projectile (costs qi) |
| **Dodge** | Space | Dodge roll (costs qi) |
| **Simulation** | T | Open Villain Simulator |
| **Logbook** | L | View history and insights |
| **Pause** | ESC | Pause/Resume game |

---

## 📂 Project Structure

```
workspace/
├── project.godot           # Godot project configuration
├── default_env.tres        # Environment settings
├── scenes/                 # Scene files
│   ├── MainMenu.tscn      # Main menu
│   └── WorldScene.tscn    # Main game scene
├── scripts/
│   ├── systems/           # Core singleton systems
│   │   ├── StoryStateManager.gd    # Causal narrative engine
│   │   ├── CultivationSystem.gd    # Realm progression
│   │   ├── AbilitySystem.gd        # Ability rolls and effects
│   │   ├── SimulationManager.gd    # Villain Simulator
│   │   ├── AudioManager.gd         # Audio control
│   │   └── SaveLoadSystem.gd       # Save/load
│   ├── player/            # Player scripts
│   │   └── Player.gd      # Player controller
│   ├── npc/               # NPC scripts
│   │   └── NPCBase.gd     # Base NPC behavior
│   └── ui/                # UI scripts
│       ├── HUD.gd         # Heads-up display
│       ├── SimulationMenu.gd  # Simulation interface
│       ├── LogBook.gd     # History viewer
│       └── MainMenu.gd    # Main menu
├── assets/                # Game assets (to be added)
├── README.md              # This file
└── GAME_DOCUMENTATION.md  # Detailed documentation
```

---

## 📚 Documentation

- **[Complete Game Documentation](GAME_DOCUMENTATION.md)** - Detailed system reference
- **[Blueprint](README.md)** - Original game design document

### Key Systems

1. **[Story State Manager](scripts/systems/StoryStateManager.gd)** - Tracks all world variables
2. **[Cultivation System](scripts/systems/CultivationSystem.gd)** - Realm progression and sutras
3. **[Ability System](scripts/systems/AbilitySystem.gd)** - Ability rolls and management
4. **[Simulation Manager](scripts/systems/SimulationManager.gd)** - Core simulation logic
5. **[Save/Load System](scripts/systems/SaveLoadSystem.gd)** - Game persistence

---

## 🎨 Game Mechanics

### Ability Ranks & Drop Rates

| Rank | Color | Drop Rate | Power Level |
|------|-------|-----------|-------------|
| White | ⚪ | 50% | Basic bonuses |
| Green | 🟢 | 25% | Moderate effects |
| Blue | 🔵 | 15% | Strong powers |
| Purple | 🟣 | 8% | Rare abilities |
| Gold | 🟡 | 2% | Legendary |

### Example Abilities

- **[White] Quick Learner**: +10% cultivation speed
- **[Green] Spirit Resonance**: +15% spirit stat
- **[Blue] Echo of the Dead**: Absorb qi from kills
- **[Purple] Talisman Whisperer**: Reveal ancient secrets
- **[Gold] Naturally Supreme**: +25% all stats, 2x cultivation

### Karma Thresholds

| Karma | Alignment | Effects |
|-------|-----------|---------|
| > 70 | Immortal Path | Heaven's blessing, righteous allies |
| 30 to 70 | Righteous | Good reputation, sect acceptance |
| -30 to 30 | Neutral | Balanced world response |
| -70 to -30 | Dark Path | Demonic attention, fear |
| < -70 | Demonic | Heavenly tribulation, outcast |

---

## 🔧 Development

### Adding New Content

**New Sutras:**
```gdscript
# In CultivationSystem.gd
"My New Sutra": {
    "type": "combat",
    "description": "Your description here",
    "unlocks": ["Technique1", "Technique2"]
}
```

**New Abilities:**
```gdscript
# In AbilitySystem.gd
"Purple": [
    {
        "name": "Your Ability",
        "description": "What it does",
        "type": "passive",
        "effects": {"stat_name": value}
    }
]
```

**New Causal Rules:**
```gdscript
# In StoryStateManager.gd -> evaluate_causal_rules()
if world_state["karma"] < -80:
    unlocked_paths.append("Demon Realm")
```

### Extending the System

The game is designed to be extensible:

1. **AI Integration**: Replace template narratives with LLM calls
2. **Procedural Worlds**: Add dungeon generation
3. **Quest System**: Build on NPC dialogue system
4. **Multiplayer**: Shared causal world state
5. **Mobile**: Adapt twin-stick controls for touch

See [GAME_DOCUMENTATION.md](GAME_DOCUMENTATION.md) for detailed guides.

---

## 🎯 Roadmap

### Version 1.0 (Current)
- ✅ Core systems implemented
- ✅ Simulation mechanics
- ✅ Causal narrative engine
- ✅ Basic UI
- ✅ Save/load system

### Version 1.1 (Planned)
- [ ] Visual effects for abilities
- [ ] Combat animations
- [ ] Sound effects and music
- [ ] More NPCs and dialogue
- [ ] Quest system

### Version 1.2 (Future)
- [ ] Procedural dungeons
- [ ] Boss encounters
- [ ] AI-generated narratives
- [ ] Expanded cultivation tree
- [ ] Multiplayer support

---

## 🐛 Known Issues

- Placeholder graphics (sprites not implemented)
- Audio files not included (system ready)
- Limited NPC variety (base system implemented)
- Template-based narratives (AI integration pending)

---

## 🤝 Contributing

This is a blueprint implementation. To contribute:

1. Fork the repository
2. Create your feature branch
3. Implement your changes
4. Test thoroughly
5. Submit a pull request

---

## 📜 License

This project is provided as a game blueprint/template. Feel free to use and modify for your own projects.

---

## 🙏 Acknowledgments

- Inspired by cultivation novels and roguelike games
- Twin-stick combat inspired by Soul Knight
- Narrative system inspired by causal storytelling
- Built with Godot Engine

---

## 📞 Support

For questions or issues:
- Check [GAME_DOCUMENTATION.md](GAME_DOCUMENTATION.md) for detailed help
- Review inline code comments in system scripts
- Test systems using debug print functions

---

## 🌟 Key Highlights

> "Each simulation reveals a possible future. Learn from your deaths, grow stronger."

- **No save scumming**: Simulations cost faith in the system
- **Permanent consequences**: All choices persist in single timeline
- **Emergent narratives**: World reacts to your karma and reputation
- **Power progression**: From mortal to true immortal
- **Dark-fantasy atmosphere**: Moral ambiguity and tragic enlightenment

---

**Start your path to immortality... or damnation. The choice is yours.**

🌙 *"In the end, will you transcend the cycle, or be devoured by it?"*