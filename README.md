# 🗡️ Simulation of the Eternal Path - Villain Edition

**A dark-fantasy cultivation game with a causal narrative system**

Built in Godot Engine for twin-stick action combat combined with deep narrative choices.

---

## 📖 Overview

You awaken as a cultivator possessing the **Villain Simulator**, a mysterious artifact that reveals possible futures. Each simulation shows you how you might die—but also grants you the power to change fate.

**Key Features:**
- **Causal Narrative Engine**: Every choice permanently alters the world state
- **Cultivation Progression**: Advance through 7 realms from Mortal to True Immortal  
- **Villain Simulator**: Run procedural simulations to gain abilities and insights
- **Twin-Stick Combat**: Soul Knight-inspired 2D action gameplay
- **Ability System**: Roll for passive/active powers (White → Gold rarity)
- **Multiple Endings**: Ascension, Demonization, Eternal Loop, or Transcendence

---

## 🎮 Gameplay

### Core Loop
1. **Explore** the Daxia Empire, completing quests and fighting enemies
2. **Activate** the Villain Simulator (Press **T**)
3. **Watch** your simulated future unfold with rolled abilities
4. **Choose** 2 of 5 rewards to apply to your real self
5. **Cultivate** through realms using gained stats and sutras
6. **Face Consequences** of your karma and reputation choices

### Controls
- **WASD**: Movement
- **Mouse**: Aim direction
- **Left Click**: Attack/Cast talisman
- **Space**: Dodge roll
- **T**: Open Villain Simulator
- **I**: Open Inventory
- **ESC**: Pause/Close menus

---

## 🧠 Core Systems

### Causal World State
Everything is tracked in a single timeline:
- **Karma** (-100 to 100): Moral alignment affecting fate
- **Reputation** (-100 to 100): Social standing with sects
- **Destiny Thread** (0-100): Probability of fortunate encounters
- **Faith in System** (0-100): Your trust in the Simulator
- **Sect Influences**: Relationships with 5 major factions

### Cultivation Realms
Progress through power levels:
1. **Mortal** → 2. **Qi Condensation** → 3. **Foundation Establishment** → 4. **Core Formation** → 5. **Nascent Soul** → 6. **Saint Realm** → 7. **True Immortal**

Each breakthrough requires cultivation progress and may have special conditions (e.g., surviving Heavenly Tribulation).

### Ability Ranks
Rolled at simulation start:
- **White** (50%): Basic bonuses
- **Green** (25%): Uncommon effects  
- **Blue** (15%): Rare powers
- **Purple** (8%): Epic abilities
- **Gold** (2%): Legendary game-changers

### Sutra System
- **Heart Sutras**: Define cultivation path and efficiency
- **Combat Sutras**: Grant attack techniques
- **Movement Sutras**: Mobility skills
- **Utility Sutras**: Crafting and support

---

## 🏗️ Project Structure

```
/workspace/
├── project.godot           # Godot project configuration
├── scripts/
│   ├── systems/            # Core singleton systems
│   │   ├── StoryStateManager.gd     # Causal narrative engine
│   │   ├── CultivationSystem.gd     # Realm progression
│   │   ├── AbilitySystem.gd         # Ability rolling/management
│   │   ├── SimulationManager.gd     # Villain simulator logic
│   │   ├── SaveLoadSystem.gd        # Save/load persistence
│   │   └── AudioManager.gd          # Sound/music control
│   ├── player/
│   │   └── Player.gd       # Player controller
│   ├── ui/
│   │   ├── MainMenu.gd     # Title screen
│   │   ├── HUD.gd          # In-game UI
│   │   ├── SimulationMenu.gd  # Simulator interface
│   │   └── LogBook.gd      # Event history viewer
│   └── npc/                # NPC behaviors (to be added)
├── scenes/
│   ├── MainMenu.tscn       # Entry point scene
│   ├── WorldScene.tscn     # Main game world
│   └── Player.tscn         # Player character
├── assets/
│   ├── sprites/            # Pixel art (to be added)
│   ├── audio/              # Music and SFX (to be added)
│   └── fonts/              # UI fonts (to be added)
├── data/                   # JSON configuration files
├── GAME_DESIGN.md          # Detailed system documentation
└── README.md               # This file
```

---

## 🚀 Getting Started

### Prerequisites
- **Godot Engine 3.5+** ([Download](https://godotengine.org/download))

### Installation
1. Clone or download this repository
2. Open Godot Engine
3. Click "Import" and select the `project.godot` file
4. Click "Import & Edit"
5. Press **F5** to run the game

### First Run
1. The game starts at the Main Menu
2. Click "New Game" to begin
3. You'll spawn in the WorldScene
4. Press **T** to try your first simulation
5. Explore and experiment with the causal system!

---

## 🛠️ Development Status

### ✅ Implemented
- ✓ Core singleton systems (6/6)
- ✓ Causal narrative engine with event rules
- ✓ Cultivation progression system
- ✓ Ability rolling and management
- ✓ Simulation flow with reward choices
- ✓ Save/load system (JSON)
- ✓ Player controller (twin-stick)
- ✓ UI components (HUD, SimulationMenu, LogBook)
- ✓ Basic scene structure

### 🔨 In Progress
- ⏳ Enemy AI and combat
- ⏳ NPC dialogue system
- ⏳ Quest framework
- ⏳ Visual assets (pixel art)
- ⏳ Audio implementation

### 📋 Planned
- ⬜ 5 major sect storylines
- ⬜ 10+ unique sutras per category
- ⬜ 50+ simulation event templates
- ⬜ Boss encounters with unique mechanics
- ⬜ Multiple ending sequences
- ⬜ LLM integration for dynamic text generation
- ⬜ Procedural dungeon generation

---

## 🎨 Art & Audio

### Art Style
- **Theme**: Dark fantasy with jade, bronze, and ash color palette
- **Style**: Pixel art (32x32 base tile size)
- **Atmosphere**: Decaying temples, spectral forests, golden imperial towers

### Audio Direction
- **Music**: Low strings, ritual drums, ambient chants
- **SFX**: Talisman bursts, sword echoes, qi resonance
- **Simulation**: Distorted whispers, mechanical hums, quill-on-scroll

**Note**: Asset directories are prepared but placeholder-free. Add your assets to `/assets/` subdirectories.

---

## 📚 Documentation

- **[GAME_DESIGN.md](GAME_DESIGN.md)**: Full system reference and design philosophy
- **Inline Comments**: All scripts are thoroughly documented
- **Signal Architecture**: Systems communicate via Godot signals

---

## 🧪 Testing & Debug

### Debug Features
- **F11**: Toggle fullscreen
- **PageUp/PageDown**: Heal/Damage player (debug builds only)
- **Console Commands** (in code):
  - `StoryStateManager.print_world_state()`
  - `CultivationSystem.force_breakthrough()`
  - `AbilitySystem.unlock_random_ability()`
  - `SaveLoadSystem.print_all_saves()`

### Testing Causal Rules
```gdscript
# In debug console or test script:
StoryStateManager.modify_state("karma", -60)  # Should trigger Heavenly Tribulation
StoryStateManager.modify_state("reputation", 80)  # Should trigger Legendary Hero status
```

---

## 🤝 Contributing

This is a solo project currently, but suggestions are welcome!

**Areas for contribution:**
- Pixel art assets (characters, environments, effects)
- Music composition (dark fantasy ambient/combat)
- Additional simulation event templates
- Sutra and ability design
- Balancing and playtesting

---

## 📜 License

This project is provided as-is for educational and entertainment purposes.

**Attribution appreciated but not required.**

---

## 🌟 Inspiration

- **Gameplay**: Soul Knight (twin-stick), Slay the Spire (reward choices)
- **Setting**: Chinese Xianxia novels (cultivation fantasy)
- **Narrative**: Zero Escape series (causality), Nier Automata (existential themes)

---

## 💬 Contact & Support

For questions or feedback:
- Open an issue on GitHub
- Check `GAME_DESIGN.md` for detailed system documentation
- Review inline code comments for implementation details

---

## 🗡️ May Your Path Be Eternal

*"The Simulator shows you your death... but only you can choose how to live."*

Embark on your journey through the Daxia Empire. Cultivate power, face tribulations, and decide whether to ascend as a hero or descend as a villain.

The choice—and its consequences—are yours.

---

**Version**: 1.0.0 Alpha  
**Engine**: Godot 3.x  
**Last Updated**: 2025-11-10
