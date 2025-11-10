# Simulation of the Eternal Path - Villain Edition

A dark-fantasy cultivation roguelite game built in Godot with twin-stick combat and a unique "Villain Simulator" narrative system.

## 🎮 Game Overview

You awaken as a cultivator in the **Daxia Empire**, wielding a mysterious artifact called the **Villain Simulator**. This cursed device shows you possible futures—but each simulation costs faith, and every choice reshapes reality permanently.

**Key Features:**
- 🌀 **Causal Narrative System** - Every decision permanently alters the world state
- 🔮 **Villain Simulator** - Preview multiple futures and extract rewards
- ⚔️ **Twin-Stick Combat** - Fast-paced action inspired by Soul Knight
- 📈 **Cultivation Progression** - Advance through 7 realms from Mortal to True Immortal
- 🎲 **Procedural Abilities** - Roll random powers before each simulation
- 🎭 **Moral Consequences** - Karma and reputation affect everything

## 🚀 Quick Start

### Prerequisites
- Godot Engine 3.5+ (GLES2 renderer)
- No additional dependencies required

### Installation
1. Clone this repository
2. Open `project.godot` in Godot Engine
3. Press F5 to run the game

### Controls
- **WASD** - Movement
- **Mouse** - Aim
- **Left Click** - Shoot
- **Space** - Dash
- **1/2** - Use Abilities
- **E** - Interact / Open Simulation Menu
- **Tab** - Open Log Book
- **ESC** - Pause Menu

## 📁 Project Structure

```
/workspace/
├── project.godot           # Main project file
├── scenes/                 # Scene files (.tscn)
│   ├── MainMenu.tscn
│   ├── WorldScene.tscn
│   ├── Player.tscn
│   ├── UI.tscn
│   └── Projectile.tscn
├── scripts/                # GDScript files
│   ├── systems/           # Core singleton systems
│   │   ├── StoryStateManager.gd
│   │   ├── SimulationManager.gd
│   │   ├── CultivationSystem.gd
│   │   ├── AbilitySystem.gd
│   │   └── AudioManager.gd
│   ├── ui/                # UI controllers
│   │   ├── HUD.gd
│   │   ├── SimulationMenu.gd
│   │   ├── LogBook.gd
│   │   └── MainMenu.gd
│   ├── Player.gd
│   ├── NPC.gd
│   ├── Enemy.gd
│   ├── Projectile.gd
│   ├── WorldScene.gd
│   └── SaveLoadSystem.gd
├── data/                  # JSON data files
│   ├── sutras.json       # Cultivation techniques
│   ├── events.json       # World events
│   └── npcs.json         # NPC definitions
├── audio/                 # (TODO) Sound assets
├── sprites/               # (TODO) Visual assets
├── README.md
└── GAME_DESIGN.md        # Detailed design document
```

## 🎯 Core Systems

### 1. Story State Manager
Tracks the causal world state:
- **Reputation** - Standing among sects
- **Karma** - Moral alignment (-100 to +100)
- **Destiny Thread** - Fate influence
- **Sect Influence** - Relationships with factions
- **Faith in System** - Trust in the Villain Simulator

### 2. Cultivation System
Progress through 7 realms:
1. Mortal → 2. Qi Condensation → 3. Foundation Establishment → 4. Core Formation → 5. Nascent Soul → 6. Saint → 7. True Immortal

Learn **Heart Sutras** (cultivation paths) and **Technique Sutras** (combat abilities).

### 3. Ability System
Before each simulation, roll a random ability:
- **White** (50%) - Common
- **Green** (25%) - Uncommon
- **Blue** (15%) - Rare
- **Purple** (8%) - Epic
- **Gold** (2%) - Legendary

### 4. Simulation Manager
The "Villain Simulator" flow:
1. Roll random ability
2. Generate narrative events
3. Simulate until death
4. Present 5 reward choices
5. Select 2 to keep
6. Apply rewards to real character

### 5. Causal Narrative Engine
Events trigger based on world state:
```gdscript
if karma < -50:
    trigger_event("Heavenly Tribulation")

if sect_influence["Talisman Sect"] > 70 and has_alliance("Talisman Sect"):
    unlock_location("Forbidden Archive")
```

## 🎨 Art Direction

**Style:** Dark-fantasy pixel art  
**Palette:** Muted purples, bronze, jade, ash  
**Lighting:** Torch flicker, spirit glow, fog overlays  
**UI:** Scroll-like textures, blood-red runes for System messages

## 🔊 Sound Design

**BGM:** Low strings, ritual drums, ambient chants  
**Combat SFX:** Talisman bursts, sutra resonance, metallic echoes  
**Simulation:** Distorted whispers, mechanical hums, quill-on-scroll writing

## 📖 Story & Themes

The **Daxia Empire** is ruled by immortal sects and ancient families. You inherit a mysterious **Villain Simulator** that lets you preview possible futures—but each use erodes your sense of self.

**Themes:**
- ⚖️ Moral ambiguity - No clear good/evil
- 🧠 Identity crisis - Are you or the simulation real?
- 🌌 Fate vs. Free Will - Can you escape destiny?
- 💀 Power's corruption - Strength demands sacrifice

**Possible Endings:**
1. **Immortal Ascension** - Achieve enlightenment
2. **Demonic Overlord** - Rule through fear
3. **Eternal Loop** - Trapped in simulations forever
4. **Devoured by Self** - Simulation replaces reality
5. **Abyssal Enlightenment** - Transcend existence itself

## 🛠️ Development Status

### ✅ Completed (Phase 1)
- Core singleton systems (Story State, Cultivation, Abilities, Simulation)
- Player controller with twin-stick combat
- UI framework (HUD, Simulation Menu, Log Book)
- Save/load system (JSON-based, 10 slots)
- NPC and Enemy base classes
- Data structure for sutras, events, NPCs

### 🚧 In Progress (Phase 2)
- World map and tileset creation
- Enemy variety and AI
- NPC dialogue trees
- Event implementation
- Art asset creation
- Sound effects and music

### 📋 TODO (Phase 3+)
- Particle effects for abilities
- Animation polish
- Balance tuning
- AI narrative generation integration
- Procedural dungeon generation
- Steam achievements (if released)

## 🎮 Gameplay Tips

1. **Manage Faith in System** - Each simulation costs faith. If it hits 0, you're trapped forever.
2. **Balance Karma** - Too negative triggers tribulations, too positive may make you weak to demons.
3. **Choose Abilities Wisely** - Gold abilities are rare, but even White abilities stack over time.
4. **Explore Thoroughly** - Insights from simulations reveal hidden secrets in the world.
5. **Sect Politics Matter** - Alliances open new paths, enemies close them forever.

## 🤝 Contributing

This is currently a solo project, but feedback is welcome! 

### How to Contribute
1. Open issues for bugs or suggestions
2. Fork and submit pull requests
3. Share ideas in Discussions

### Code Style
- Follow GDScript style guide
- Comment complex logic
- Use signals for decoupling
- Keep systems modular

## 📝 License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

**Inspired by:**
- Soul Knight (twin-stick combat)
- Hades (roguelite progression)
- Chinese Xianxia novels (cultivation systems)
- Roguelites with meta-progression

**Built with:**
- Godot Engine 3.x
- Love for dark-fantasy and moral ambiguity

---

## 📚 Additional Resources

- **Full Design Document:** See `GAME_DESIGN.md`
- **System Documentation:** Each script has inline documentation
- **Data Format:** Check `data/` folder for JSON schemas

---

**Status:** Early Alpha Development  
**Platform:** PC (Linux/Windows/Mac via Godot export)  
**Genre:** Roguelite, Action, Cultivation  
**Developer:** Solo Project  

*May the heavens guide your path... or damn it forever.* 🌙⚔️
