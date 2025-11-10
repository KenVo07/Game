# Development Guide

## 🛠️ Setting Up Development Environment

### Requirements
- Godot Engine 3.5 or later
- Git (for version control)
- A text editor (Godot's built-in editor is sufficient)

### First Time Setup
1. Clone the repository
2. Open `project.godot` in Godot
3. Let Godot import all assets (first time may take a moment)
4. Press F5 to run the game

## 📂 Project Architecture

### Singleton Systems (Autoload)
These are globally accessible throughout the game:

1. **StoryStateManager** - Manages world state and causal events
2. **SimulationManager** - Handles villain simulator logic
3. **CultivationSystem** - Tracks cultivation progress
4. **AbilitySystem** - Manages abilities and rolls
5. **AudioManager** - Handles music and sound effects

### Scene Structure
- `MainMenu.tscn` - Entry point
- `WorldScene.tscn` - Main gameplay scene
- `Player.tscn` - Player character with combat
- `UI.tscn` - Complete UI overlay (HUD, menus)
- `Projectile.tscn` - Player projectiles

### Script Organization
```
scripts/
  systems/     # Core game systems (singletons)
  ui/          # UI controllers
  entities/    # (Future) Entity behaviors
  utils/       # (Future) Helper functions
```

## 🎮 Adding New Content

### Adding a New Ability

1. Open `scripts/systems/AbilitySystem.gd`
2. Add to `ability_pool` dictionary:
```gdscript
"Blue": [
    # ... existing abilities
    {
        "name": "Your Ability Name",
        "description": "What it does",
        "effect": {
            "stat_name": value,
            "special_flag": true
        }
    }
]
```

### Adding a New Event

1. Open `data/events.json`
2. Add to `random_events` array:
```json
{
    "id": "unique_id",
    "name": "Event Name",
    "description": "What happens",
    "conditions": ["karma > 20"],
    "outcomes": [
        {
            "text": "Choice 1",
            "karma": 5,
            "rewards": {"spirit": 3}
        }
    ]
}
```

### Adding a New NPC

1. Open `data/npcs.json`
2. Add NPC definition
3. Create dialogue tree in `scripts/NPC.gd` or separate dialogue system
4. Place in world scene

### Adding a New Sutra

1. Open `data/sutras.json`
2. Add to `technique_sutras` or `heart_sutras`:
```json
{
    "name": "Sutra of ...",
    "description": "...",
    "techniques": ["Tech1", "Tech2"],
    "realm_requirement": "Core Formation"
}
```
3. Implement techniques in `scripts/Player.gd` if needed

## 🔧 Common Development Tasks

### Testing Specific Scenario
```gdscript
# In WorldScene.gd _ready():
StoryStateManager.world_state["karma"] = -50
CultivationSystem.realm_level = 5
# Test your scenario
```

### Debugging World State
```gdscript
# Print current world state
print(StoryStateManager.get_world_state())

# Check specific condition
print(StoryStateManager.query_state("karma > 20"))
```

### Force Simulation
```gdscript
# In any scene
SimulationManager.start_simulation()
```

### Grant Ability for Testing
```gdscript
# In Player script or console
var test_ability = {
    "name": "Test Ability",
    "rank": "Gold",
    "effect": {"all_stats": 50}
}
AbilitySystem.unlock_ability(test_ability, false)
```

## 🐛 Debugging

### Enable Debug Prints
Many systems have debug print statements. Uncomment them in:
- `SimulationManager.gd` - Simulation flow
- `StoryStateManager.gd` - Event triggers
- `CultivationSystem.gd` - Stat changes

### Common Issues

**Issue:** Player won't move
- Check if `Player.tscn` has CollisionShape2D
- Verify input actions in `project.godot`

**Issue:** Simulation menu doesn't open
- Check if `E` key is mapped to `open_simulation`
- Verify UI scene is loaded in WorldScene

**Issue:** Save/load fails
- Check console for file path errors
- Ensure `user://saves/` directory is created

**Issue:** Stats not updating
- Verify signals are connected
- Check if CultivationSystem is autoloaded

## 📊 Performance Optimization

### Current Limits
- Event history: 500 entries (circular buffer)
- Simulation log: 50 entries
- SFX players: 16 concurrent
- Save file size: ~50KB typical

### If Performance Issues
1. Reduce particle effects
2. Limit enemy count per room
3. Use object pooling for projectiles
4. Optimize tilemap collision shapes

## 🎨 Asset Creation Guidelines

### Sprites
- Size: 16x16 to 32x32 pixels for entities
- Format: PNG with transparency
- Palette: Dark purples, bronze, jade, ash tones
- Style: Pixel art, high contrast

### Audio
- Format: OGG for music, WAV for SFX
- Sample rate: 44.1kHz
- Bit depth: 16-bit
- Keep files under 5MB for BGM

### Naming Conventions
- Scenes: PascalCase (e.g., `MainMenu.tscn`)
- Scripts: PascalCase (e.g., `Player.gd`)
- Variables: snake_case (e.g., `current_health`)
- Constants: UPPER_SNAKE_CASE (e.g., `MAX_HEALTH`)

## 🧪 Testing Checklist

Before committing major changes:
- [ ] Game starts without errors
- [ ] Player can move and attack
- [ ] Simulation menu opens and runs
- [ ] Save/load works
- [ ] No console errors on startup
- [ ] New content doesn't break existing features

## 📝 Code Style

### GDScript Best Practices
```gdscript
# Good: Descriptive names
var current_health = 100

# Bad: Unclear abbreviations
var hp = 100

# Good: Type hints
func take_damage(amount: int) -> void:

# Good: Early returns
func can_attack() -> bool:
    if is_dead:
        return false
    if is_stunned:
        return false
    return true

# Good: Signals for decoupling
signal health_changed(new_health, max_health)
emit_signal("health_changed", current_health, max_health)
```

### Documentation
- Add docstrings to complex functions
- Comment non-obvious logic
- Use `# TODO:` for future work
- Use `# FIXME:` for known issues

## 🚀 Building for Release

### Export Settings
1. Project → Export
2. Add template for your platform
3. Configure settings:
   - Name: "Simulation of the Eternal Path"
   - Icon: `icon.png`
   - Enable "Embed PCK" for single executable

### Pre-Release Checklist
- [ ] All TODO items resolved or documented
- [ ] No debug prints in release build
- [ ] All assets properly attributed
- [ ] README and GAME_DESIGN.md up to date
- [ ] Version number updated
- [ ] Save system tested with migrations

## 🤝 Contributing Workflow

1. Create feature branch: `git checkout -b feature/your-feature`
2. Make changes and commit: `git commit -m "Add: feature description"`
3. Test thoroughly
4. Push and create pull request
5. Address review feedback

### Commit Message Format
```
Add: New feature
Fix: Bug description
Update: System improvement
Refactor: Code restructure
Docs: Documentation changes
```

## 📚 Useful Resources

- [Godot Documentation](https://docs.godotengine.org/)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)

---

**Happy Coding!** 🎮✨
