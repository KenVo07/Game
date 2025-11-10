# 🛠️ Extending the Game - Developer Guide

This guide shows you how to add new content to **Simulation of the Eternal Path - Villain Edition**.

---

## 📚 Table of Contents

1. [Adding New Sutras](#adding-new-sutras)
2. [Creating New Abilities](#creating-new-abilities)
3. [Adding Simulation Events](#adding-simulation-events)
4. [Creating Causal Rules](#creating-causal-rules)
5. [Implementing NPCs](#implementing-npcs)
6. [Adding Sects](#adding-sects)
7. [Creating Quests](#creating-quests)
8. [Custom Endings](#custom-endings)

---

## 1. Adding New Sutras

Sutras are cultivation techniques that grant stats and abilities.

### Location
`scripts/systems/CultivationSystem.gd` → `sutra_database` dictionary

### Template

```gdscript
"Sutra of [Name]": {
    "type": "heart" | "combat" | "movement" | "utility",
    "description": "Your description here",
    "efficiency": 1.0,  # For heart sutras (cultivation speed multiplier)
    "stat_bonus": {
        "strength": 5,
        "agility": 3,
        "spirit": 2,
        "vitality": 1,
        "qi_capacity": 50
    },
    "abilities": ["Ability Name 1", "Ability Name 2"],  # Optional
    "special": "Special effect description"  # Optional
}
```

### Example: Adding a Fire Sutra

```gdscript
# In CultivationSystem.gd, add to sutra_database:

"Sutra of Infernal Rebirth": {
    "type": "combat",
    "description": "Harness the flames of rebirth to burn enemies and regenerate.",
    "stat_bonus": {
        "strength": 8,
        "spirit": 5,
        "qi_capacity": 30
    },
    "abilities": ["Phoenix Strike", "Flame Regeneration"],
    "special": "Restore 5% health on kill"
}
```

### Granting Sutras

```gdscript
# In game code or simulation reward:
CultivationSystem.learn_sutra("Sutra of Infernal Rebirth")
```

---

## 2. Creating New Abilities

Abilities are passive or active powers rolled during simulations.

### Location
`scripts/systems/AbilitySystem.gd` → `ability_database` dictionary

### Template

```gdscript
"Ability Name": {
    "rank": "White" | "Green" | "Blue" | "Purple" | "Gold",
    "type": "passive" | "active",
    "description": "What the ability does",
    "effect": {
        "key": "value"  # Effect parameters
    },
    "cooldown": 60.0  # Only for active abilities (in seconds)
}
```

### Example: Blue Rank Active Ability

```gdscript
# Add to ability_database in AbilitySystem.gd:

"Time Reversal": {
    "rank": "Blue",
    "type": "active",
    "description": "Revert the last 5 world state changes.",
    "effect": {"history_reversal": 5},
    "cooldown": 120.0
}
```

### Implementing Active Ability Logic

```gdscript
# In AbilitySystem.gd → _execute_ability_effect():

match ability_name:
    "Time Reversal":
        var history = StoryStateManager.get_event_history(5)
        for event in history:
            # Reverse the change
            var delta = event["old_value"] - event["new_value"]
            StoryStateManager.modify_state(event["variable"], delta)
```

---

## 3. Adding Simulation Events

Events are the narrative building blocks of simulations.

### Location
`scripts/systems/SimulationManager.gd` → `_initialize_event_templates()`

### Template

```gdscript
{
    "text_variants": [
        "Text option 1",
        "Text option 2",
        "Text option 3"
    ],
    "type": "neutral" | "righteous" | "villainous" | "combat" | "discovery",
    "karma_change": 0,      # Optional
    "reputation_change": 0, # Optional
    "stat_change": {},      # Optional
    "insight": "text",      # Optional
    "item": "item_name",    # Optional
    "karma_weight": 0.0,    # How likely if karma is negative/positive
    "reputation_weight": 0.0
}
```

### Example: Demonic Encounter

```gdscript
# Add to event_templates array:

{
    "text_variants": [
        "A demon offers forbidden knowledge in exchange for your soul.",
        "You encounter a demonic cultivator practicing blood rituals.",
        "Whispers from the abyss tempt you with dark power."
    ],
    "type": "villainous",
    "karma_change": -15,
    "stat_change": {"spirit": 5, "strength": 3},
    "insight": "Demonic cultivation grants power, but at what cost?",
    "karma_weight": -1.0  # More likely if karma is already negative
}
```

---

## 4. Creating Causal Rules

Causal rules automatically trigger events when conditions are met.

### Location
`scripts/systems/StoryStateManager.gd` → `_initialize_causal_rules()`

### Template

```gdscript
{
    "name": "Rule Name",
    "condition": func(): return [boolean expression],
    "trigger_once": true | false,
    "cooldown": 10,  # Optional (in simulation counts)
    "last_triggered": -999,
    "effect": func(): [effect code]
}
```

### Example: Sect Master Appears

```gdscript
# Add to causal_rules array:

{
    "name": "Sect Master Intervention",
    "condition": func():
        var sect_influence = get_sect_influence("Talisman Sect")
        var simulations = world_state["simulations_done"]
        return sect_influence < -80 and simulations > 10,
    "trigger_once": false,
    "cooldown": 15,
    "last_triggered": -999,
    "effect": func():
        trigger_event("sect_master_challenge")
        modify_state("reputation", 20)  # You're becoming notorious
}
```

### Handling the Triggered Event

```gdscript
# In StoryStateManager._apply_event_consequences():

match event_name:
    "sect_master_challenge":
        set_flag("sect_master_hunting_you", true)
        emit_signal("consequence_applied", {
            "type": "boss_encounter",
            "message": "The Sect Master himself hunts you now!"
        })
```

---

## 5. Implementing NPCs

NPCs use the BaseNPC class and can be customized.

### Creating a Specific NPC

```gdscript
# Create new file: scripts/npc/TalismanMerchant.gd

extends BaseNPC

func _ready():
    npc_name = "Elder Feng"
    npc_title = "Talisman Merchant"
    affiliated_sect = "Talisman Sect"
    
    dialogue_lines = [
        "Ah, a customer! I have rare talismans for sale.",
        "My wares are of the highest quality.",
        "Beware of fakes sold by street vendors!"
    ]
    
    ._ready()  # Call parent


func interact(player):
    # Custom interaction
    if StoryStateManager.get_state("karma") < -30:
        dialogue_lines = [
            "I've heard rumors about you...",
            "Your reputation precedes you, dark one.",
            "I won't sell to someone like you!"
        ]
        can_talk = true
    
    .interact(player)  # Call parent
```

### Adding to Scene

```gdscript
# In WorldScene or via Godot editor:
var merchant = preload("res://scripts/npc/TalismanMerchant.gd").new()
merchant.position = Vector2(500, 300)
$NPCs.add_child(merchant)
```

---

## 6. Adding Sects

Sects are factions with their own relationships and storylines.

### Registering a Sect

```gdscript
# In StoryStateManager._initialize_default_sects():

var sects = [
    "Talisman Sect",
    "Sword Saint Pavilion",
    "Moon Shadow Clan",
    "Demonic Blood Cult",
    "Heavenly Star Alliance",
    "Azure Dragon Palace",  # NEW SECT
]
```

### Sect-Specific Events

```gdscript
# Create custom event for your sect:

func _check_sect_events(sect_name: String, influence: int):
    # Call parent for default behavior
    ._check_sect_events(sect_name, influence)
    
    # Custom events
    if sect_name == "Azure Dragon Palace":
        if influence >= 90:
            trigger_event("azure_dragon_heir_invitation")
        elif influence <= -90:
            trigger_event("azure_dragon_extermination_order")
```

---

## 7. Creating Quests

Quests are tracked in the world state and displayed in the LogBook.

### Adding a Quest

```gdscript
# From anywhere in the game:

var quest = {
    "id": "find_ancient_relic",
    "title": "The Lost Talisman",
    "description": "Elder Feng seeks an ancient talisman lost in the Cursed Forest.",
    "progress": 0,
    "goal": 1,
    "rewards": {
        "karma": 15,
        "items": ["Rare Talisman Blueprint"]
    }
}

var active_quests = StoryStateManager.get_state("active_quests")
active_quests.append(quest)
StoryStateManager.modify_state("active_quests", active_quests, true)
```

### Updating Quest Progress

```gdscript
# When player finds the item:

var quests = StoryStateManager.get_state("active_quests")
for quest in quests:
    if quest["id"] == "find_ancient_relic":
        quest["progress"] += 1
        
        if quest["progress"] >= quest["goal"]:
            _complete_quest(quest)
            break

StoryStateManager.modify_state("active_quests", quests, true)
```

### Completing Quests

```gdscript
func _complete_quest(quest: Dictionary):
    # Apply rewards
    for key in quest["rewards"].keys():
        match key:
            "karma":
                StoryStateManager.modify_state("karma", quest["rewards"]["karma"])
            "items":
                for item in quest["rewards"]["items"]:
                    StoryStateManager.modify_state("inventory", item)
    
    # Remove from active quests
    var quests = StoryStateManager.get_state("active_quests")
    quests.erase(quest)
    StoryStateManager.modify_state("active_quests", quests, true)
    
    print("Quest completed: " + quest["title"])
```

---

## 8. Custom Endings

Endings are triggered by world state conditions.

### Defining an Ending Condition

```gdscript
# Create new file: scripts/systems/EndingManager.gd

extends Node

func check_for_endings():
    """Check if any ending conditions are met"""
    
    var karma = StoryStateManager.get_state("karma")
    var realm = CultivationSystem.current_realm
    var faith = StoryStateManager.get_state("faith_in_system")
    var simulations = StoryStateManager.get_state("simulations_done")
    
    # Immortal Ascension
    if karma > 50 and realm == "True Immortal":
        trigger_ending("immortal_ascension")
    
    # Demonic Overlord
    elif karma < -70 and faith > 70:
        trigger_ending("demonic_overlord")
    
    # Eternal Loop
    elif faith < 10 and simulations > 50:
        trigger_ending("eternal_loop")
    
    # Devoured by Simulation
    elif StoryStateManager.get_flag("system_has_rebelled") and simulations > 30:
        trigger_ending("devoured_by_self")
    
    # Abyssal Enlightenment
    elif abs(karma) < 5 and realm == "True Immortal" and simulations > 40:
        trigger_ending("abyssal_enlightenment")


func trigger_ending(ending_name: String):
    """Load ending scene"""
    print("ENDING: " + ending_name)
    get_tree().change_scene("res://scenes/endings/" + ending_name + ".tscn")
```

### Calling Ending Check

```gdscript
# In Player.gd after major events or in SimulationManager:

if EndingManager.check_for_endings():
    return  # Ending triggered, stop normal flow
```

---

## 🎯 Quick Reference

### Modifying World State
```gdscript
StoryStateManager.modify_state("karma", -20)
StoryStateManager.modify_sect_influence("Talisman Sect", 15)
StoryStateManager.set_flag("found_secret_cave", true)
```

### Granting Rewards
```gdscript
CultivationSystem.learn_sutra("Sutra of X")
CultivationSystem.add_cultivation_progress(50)
AbilitySystem.unlock_ability("Naturally Supreme")
```

### Triggering Events
```gdscript
StoryStateManager.trigger_event("custom_event_name", {"context": "data"})
```

### Playing Audio
```gdscript
AudioManager.play_music("combat")
AudioManager.play_sfx("cultivation_breakthrough")
```

---

## 💡 Best Practices

1. **Always test causal rules**: Use debug console to force world states
2. **Balance karma changes**: Major events should be ±10-20, minor ±5
3. **Weight simulation events**: Match tone to karma (negative karma → more villainous events)
4. **Name conventions**: Use snake_case for IDs, Title Case for display names
5. **Save compatibility**: When adding new world_state keys, provide defaults

---

## 🐛 Debugging Tips

```gdscript
# Print current world state
StoryStateManager.print_world_state()

# Force cultivation breakthrough
CultivationSystem.force_breakthrough()

# Unlock random ability
AbilitySystem.unlock_random_ability()

# View all saves
SaveLoadSystem.print_all_saves()

# Test specific causal rule
StoryStateManager.modify_state("karma", -100)  # Should trigger tribulation
```

---

## 📖 Further Reading

- **[GAME_DESIGN.md](GAME_DESIGN.md)**: Full system architecture
- **[README.md](README.md)**: Project overview and setup
- **Inline Documentation**: All scripts have detailed comments

---

**Happy developing! May your code be as eternal as the path itself.** 🗡️✨
