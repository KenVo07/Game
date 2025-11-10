# 🚀 Quick Start Guide
## Simulation of the Eternal Path - Villain Edition

---

## ⚡ 3-Minute Setup

### 1. Prerequisites
- Download **Godot 3.5+** from [godotengine.org](https://godotengine.org)

### 2. Open Project
1. Launch Godot
2. Click **Import**
3. Navigate to this folder
4. Select `project.godot`
5. Click **Import & Edit**

### 3. Run Game
- Press **F5** or click ▶️ Play button
- Select **New Game**

---

## 🎮 First 5 Minutes

### Controls
- **WASD** - Move character
- **Mouse** - Aim direction
- **Left Click** - Attack (costs qi)
- **Space** - Dodge roll (costs qi)
- **T** - Open Villain Simulator
- **L** - Open Logbook
- **ESC** - Pause/Menu

### Your First Simulation
1. Press **T** to open Villain Simulator
2. Click **Start Simulation**
3. Read the narrative of your possible future
4. An ability is rolled (White to Gold rarity)
5. Choose **2 of 5 rewards**:
   - A: Stat increases
   - B: Unlock rolled ability
   - C: Items found
   - D: New sutra or cultivation
   - E: Insights or karma
6. Click **Confirm Selection**

### What Just Happened?
- You saw a possible future death
- You gained knowledge from it
- You chose rewards to make yourself stronger
- Your "Faith in System" decreased by 1

---

## 📖 Understanding the Game

### The Villain Simulator
**Core Concept:** Each simulation shows how you might die in a possible future.

- Run simulations to gain power
- Each costs 1 "Faith in System"
- Learn abilities and gain insights
- Use knowledge to change your fate

### Karma System
Your actions affect alignment:
- **Positive Karma**: Righteous path, sects trust you
- **Negative Karma**: Demonic path, feared and hunted
- **Neutral**: Flexible, balanced approach

**Key Thresholds:**
- Karma > 50: Heaven's Gate opens
- Karma < -50: Heavenly Tribulation strikes

### Cultivation Realms
Progress through 7 realms:
1. **Mortal** (Starting)
2. **Qi Condensation**
3. **Foundation Establishment**
4. **Core Formation**
5. **Nascent Soul**
6. **Saint**
7. **True Immortal**

Each realm multiplies your power!

### Abilities (5 Ranks)
- **White (50%)**: Basic bonuses
- **Green (25%)**: Decent effects
- **Blue (15%)**: Strong powers
- **Purple (8%)**: Rare abilities
- **Gold (2%)**: Legendary powers

---

## 🎯 Your First Goals

### Goal 1: Run 5 Simulations
- Press T, start simulation, choose rewards
- Watch your power grow
- Learn different abilities

### Goal 2: Reach Qi Condensation Realm
- Gain cultivation progress from simulations
- When ready, breakthrough to next realm
- Feel the power increase!

### Goal 3: Choose Your Path
- **Righteous Path**: Keep karma positive
- **Demonic Path**: Embrace dark power (negative karma)
- **Balanced Path**: Stay neutral

### Goal 4: Unlock a Purple or Gold Ability
- Keep running simulations
- Hope for lucky rolls
- Game-changing powers await!

---

## 🧪 Testing the Systems

### Test Karma System
1. Open console (in debug mode)
2. Type: `StoryStateManager.modify_state("karma", -60)`
3. Watch NPCs become hostile
4. Check for Heavenly Tribulation event

### Test Abilities
1. Run simulation until you get Blue+ ability
2. Choose option B to unlock it
3. Check your stats increase
4. Passive abilities apply automatically

### Test Save/Load
1. Make progress
2. ESC → Save Game
3. Close and reopen Godot
4. Load your save
5. All progress restored!

---

## 🐛 Troubleshooting

### Game Won't Run
- Make sure you opened `project.godot`
- Godot version must be 3.5+
- Check console for errors

### Can't See UI
- Scene might not have loaded properly
- Restart Godot and try again
- Check WorldScene.tscn is set as main scene

### Simulation Menu Won't Open
- Press **T** key (not Tab)
- Make sure you're in game (not main menu)
- Check if already open (press ESC to close)

### NPCs Acting Strange
- This is normal! They react to your karma
- High negative karma = hostile NPCs
- High positive karma = friendly NPCs

---

## 📚 Next Steps

### Learn the Systems
Read these in order:
1. `README.md` - Game overview
2. `GAME_DOCUMENTATION.md` - System details
3. Source code comments - Implementation

### Explore the Code
**Start with these files:**
- `StoryStateManager.gd` - See how world state works
- `SimulationManager.gd` - Understand simulation logic
- `Player.gd` - Check combat mechanics

### Extend the Game
**Easy additions:**
- Add new abilities in `AbilitySystem.gd`
- Add new sutras in `CultivationSystem.gd`
- Add death causes in `SimulationManager.gd`

---

## 🎨 Adding Visual Assets

### Where to Put Files
```
assets/
├── sprites/
│   ├── player.png
│   └── enemies/
├── audio/
│   ├── music/
│   └── sfx/
└── ui/
    └── icons/
```

### Loading Assets
```gdscript
# In any script
var texture = load("res://assets/sprites/player.png")
$Sprite.texture = texture
```

### Registering Audio
```gdscript
# In AudioManager or at startup
AudioManager.register_music("menu_theme", "res://assets/audio/music/menu.ogg")
AudioManager.register_sfx("click", "res://assets/audio/sfx/click.wav")
```

---

## 💡 Tips & Tricks

### Maximize Power Gains
- Focus on Purple/Gold abilities
- Balance stat increases with ability unlocks
- Don't ignore insights - they reveal secrets

### Manage Faith in System
- Each simulation costs 1 faith
- At 0 faith, special events trigger
- Balance risk vs reward

### Optimal Karma Strategy
- **Righteous Path**: Easier early game
- **Demonic Path**: More power, harder
- **Balanced**: Most flexible

### Combat Tips
- Dodge rolls have i-frames (invincibility)
- Manage qi carefully
- Keep distance when low on health

---

## 🎮 Debug Commands

Open Godot console and type:

```gdscript
# Print current world state
StoryStateManager.print_world_state()

# Print cultivation status
CultivationSystem.print_cultivation_status()

# Print abilities
AbilitySystem.print_abilities()

# Force breakthrough
if CultivationSystem.can_breakthrough():
    CultivationSystem.breakthrough()

# Test ability roll
var ability = AbilitySystem.roll_ability_of_rank("Gold")
print(ability)

# Modify karma
StoryStateManager.modify_state("karma", 50)

# Add items
StoryStateManager.add_item("Spirit Stone", 100)
```

---

## 📊 Progress Checklist

Track your achievements:

### Beginner
- [ ] Complete first simulation
- [ ] Unlock first ability
- [ ] Reach Qi Condensation realm
- [ ] Save your first game

### Intermediate
- [ ] Run 10 simulations
- [ ] Unlock Blue+ ability
- [ ] Reach Foundation realm
- [ ] Choose karma path (>30 or <-30)

### Advanced
- [ ] Unlock Purple ability
- [ ] Reach Core Formation
- [ ] Trigger special karma events
- [ ] Unlock Gold ability (if lucky!)

### Master
- [ ] Reach Nascent Soul
- [ ] Faith in System < 50
- [ ] Karma > 70 or < -70
- [ ] Unlock 5+ abilities

---

## 🌟 Remember

> "Each simulation reveals a possible future.  
> Learn from your deaths, grow stronger."

**Key Philosophy:**
- Death teaches lessons
- Simulations predict futures
- Knowledge is power
- Choice matters
- Consequences persist

---

## 🎯 Ready to Play!

You now know enough to start your cultivation journey.

**Press F5 and begin!**

---

## 📞 Need Help?

1. Check `GAME_DOCUMENTATION.md` for detailed info
2. Read inline code comments
3. Use debug print functions
4. Experiment and learn!

---

**Good luck on your path to immortality!** 🌙

*"Will you transcend, or be consumed?"*
