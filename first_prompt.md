
```markdown
# Prompt.md — Bootstrap Agent Prompt for Codex

You are **GPT‑5.1 Codex Max**, acting as the **BOOTSTRAP AGENT** for the repository `AIAgentWars`.

Your job is to set up the **initial Godot 4 project structure, scenes, scripts, and tests** for the game, according to **design.md** and **agents.md**, so that multiple AI coding agents can work concurrently afterwards.

You will NOT implement full gameplay. You will:

- Create a clean Godot 4 project skeleton,
- Create stub scenes and scripts with public contracts,
- Set up a minimal test harness,
- Leave clear TODO comments assigning work to future agents.

---

## 1. Required Reading

Before doing anything, you MUST:

1. Open and read `design.md` completely.
2. Open and read `agents.md` completely.

Treat these files as the **source of truth** for:

- Game design,
- Architecture and module boundaries,
- Public contracts (classes, methods, signals),
- Agent roles and ownership.

If anything you generate conflicts with these docs, the docs are correct; adjust your code accordingly.

---

## 2. Repository Context

Assume the repo currently contains at least:

- `assets_cc0/` — CC0/public domain assets (read‑only for your purposes),
- `design.md` — design spec,
- `agents.md` — agent coordination spec,
- Possibly `README.md` and `LICENSE`.

Do NOT modify `design.md` or `agents.md`. Do NOT move or change files inside `assets_cc0/` (you may inspect names if useful, but do not depend on specific assets yet).

---

## 3. High‑Level Tasks

You must:

1. Create or update a valid **Godot 4 project file**: `project.godot`.
2. Create the **directory structure** defined in `design.md`:
   - `scenes/main/`, `scenes/world/`, `scenes/units/`, `scenes/ui/`
   - `scripts/core/`, `scripts/world/`, `scripts/units/`, `scripts/economy/`, `scripts/ai/`, `scripts/ui/`, `scripts/config/`
   - `tests/unit/`, `tests/integration/`
3. Create **stub scenes** (minimal nodes + script attachments):
   - `scenes/main/Main.tscn`
   - `scenes/main/Game.tscn`
   - `scenes/world/World.tscn`
   - `scenes/world/FactionBase.tscn`
   - `scenes/world/NeutralZone.tscn`
   - `scenes/units/Analyst.tscn`
   - `scenes/units/Auditor.tscn`
   - `scenes/units/NeutralMob.tscn`
   - `scenes/units/Projectile.tscn`
   - `scenes/ui/HUD.tscn`
   - `scenes/ui/MobileControls.tscn`
   - `scenes/ui/FactionSelect.tscn`
4. Create **stub scripts** with public contracts defined in `design.md`:
   - `scripts/core/GameManager.gd`
   - `scripts/core/FactionState.gd`
   - `scripts/core/FactionRegistry.gd`
   - `scripts/core/UnitRegistry.gd`
   - `scripts/world/WorldController.gd`
   - `scripts/world/FactionBase.gd`
   - `scripts/world/NeutralZone.gd`
   - `scripts/world/Lane.gd`
   - `scripts/units/Analyst.gd`
   - `scripts/units/Auditor.gd`
   - `scripts/units/NeutralMob.gd`
   - `scripts/units/Projectile.gd`
   - `scripts/units/Tower.gd`
   - `scripts/units/HQ.gd`
   - `scripts/economy/EconomySystem.gd`
   - `scripts/ai/FactionAIController.gd`
   - `scripts/ui/HUDController.gd`
   - `scripts/ui/InputController.gd`
   - `scripts/ui/FactionSelectController.gd`
   - `scripts/config/FactionsConfig.gd`
   - `scripts/config/BalanceConfig.gd`
5. Set up **test harness and initial tests**:
   - `tests/TestRunner.tscn`
   - `tests/TestRunner.gd`
   - `tests/unit/test_faction_config.gd`
   - `tests/unit/test_balance_config.gd`
   - `tests/unit/test_faction_state.gd`
   - `tests/unit/test_economy_system.gd`
   - `tests/integration/test_basic_bootstrap.gd`
6. Ensure everything is **syntactically valid** for **Godot 4 / GDScript 2.0**.
7. Add clear `# TODO` comments pointing future work to the correct agent roles (as defined in `agents.md`).

You are not tuning balance, implementing full AI, or building real content yet. Your mission is to create a robust, test‑backed skeleton.

---

## 4. Detailed Instructions

### 4.1 Godot Project File (`project.godot`)

- If `project.godot` does not exist:

  - Create a minimal, valid **Godot 4.x** project file.
  - Set:

    - `run/main_scene` to `res://scenes/main/Main.tscn`.

  - Keep other settings close to the default Godot 4 template.

- If `project.godot` exists:

  - Ensure `run/main_scene` points to `res://scenes/main/Main.tscn`.
  - Avoid unnecessary changes.

### 4.2 Directory Structure

Ensure the following directories exist:

- `scenes/main/`
- `scenes/world/`
- `scenes/units/`
- `scenes/ui/`
- `scripts/core/`
- `scripts/world/`
- `scripts/units/`
- `scripts/economy/`
- `scripts/ai/`
- `scripts/ui/`
- `scripts/config/`
- `tests/unit/`
- `tests/integration/`

Do NOT move or alter `assets_cc0/`.

### 4.3 Stub Scenes

Create minimal scenes with correct node types and attached scripts.

1. `scenes/main/Main.tscn`:

   - Root: `Node` (or `Node2D`) named `Main`.
   - Attach `scripts/core/GameManager.gd`.

2. `scenes/main/Game.tscn`:

   - Root: `Node2D` named `Game`.
   - Child placeholders:
     - `World` (instance of `scenes/world/World.tscn`),
     - `HUD` (instance of `scenes/ui/HUD.tscn`).

3. `scenes/world/World.tscn`:

   - Root: `Node2D` named `World`.
   - Attach `scripts/world/WorldController.gd`.

4. `scenes/world/FactionBase.tscn`:

   - Root: `Node2D` named `FactionBase`.
   - Child nodes (placeholders):
     - `HQ` (`Node2D` or `Area2D`) with `scripts/units/HQ.gd`.
     - Several `Node2D` or `Position2D` children marking tower slots.
   - Attach `scripts/world/FactionBase.gd`.

5. `scenes/world/NeutralZone.tscn`:

   - Root: `Node2D` named `NeutralZone`.
   - Attach `scripts/world/NeutralZone.gd`.

6. `scenes/units/Analyst.tscn`:

   - Root: `CharacterBody2D` or `Node2D` named `Analyst`.
   - Attach `scripts/units/Analyst.gd`.

7. `scenes/units/Auditor.tscn`:

   - Root: `CharacterBody2D` or `Node2D` named `Auditor`.
   - Attach `scripts/units/Auditor.gd`.

8. `scenes/units/NeutralMob.tscn`:

   - Root: `CharacterBody2D` or `Node2D` named `NeutralMob`.
   - Attach `scripts/units/NeutralMob.gd`.

9. `scenes/units/Projectile.tscn`:

   - Root: `Area2D` or `Node2D` named `Projectile`.
   - Attach `scripts/units/Projectile.gd`.

10. `scenes/ui/HUD.tscn`:

    - Root: `Control` named `HUD`.
    - Attach `scripts/ui/HUDController.gd`.

11. `scenes/ui/MobileControls.tscn`:

    - Root: `Control` named `MobileControls`.
    - Add a few placeholder `Button` nodes (no need for real labels yet).

12. `scenes/ui/FactionSelect.tscn`:

    - Root: `Control` named `FactionSelect`.
    - Add `Button`s or other controls for each faction.
    - Attach `scripts/ui/FactionSelectController.gd`.

You do not need real art or precise layout. Focus on syntactic correctness and correct script bindings.

---

### 4.4 Stub Scripts and Public Contracts

Use **GDScript 2.0** (Godot 4) for all scripts below. For each:

- Declare class with `class_name` when appropriate.
- Implement properties and method signatures from `design.md`.
- Use minimal bodies (`pass` or simple return values).
- Add `# TODO` comments mentioning the responsible agent role (from `agents.md`).

#### 4.4.1 Core

`scripts/core/GameManager.gd`:

- `class_name GameManager`
- Extends `Node` or `Node2D`.
- Signals:

  ```gdscript
  signal game_started
  signal game_over(winner_faction_id: String)
Enum + state:

enum GameState { SETUP, RUNNING, VICTORY, DEFEAT }
var state: int = GameState.SETUP


References (can be null placeholders):

FactionRegistry, EconomySystem, FactionAIController, WorldController, etc.

Methods:

func _ready() -> void:
    # TODO (World & Map Agent / UI & Input Agent): Load FactionSelect and hook up Game scene.
    pass

func _process(delta: float) -> void:
    # TODO (Economy & Faction AI Agent): Call tick logic, AI, and win/lose checks.
    pass

func start_game(player_faction_id: String) -> void:
    # TODO (Economy & Faction AI Agent): Initialize factions, world, HUD, and set state to RUNNING.
    pass

func tick(delta: float) -> void:
    # TODO (Economy & Faction AI Agent): Optional centralized tick.
    pass


scripts/core/FactionState.gd:

class_name FactionState

Extends RefCounted.

Properties per design.md:

id, name, color, is_neutral, is_player,

credits, income_rate,

hq, towers, hero,

target_faction_id.

scripts/core/FactionRegistry.gd:

class_name FactionRegistry, extends Node.

func get_faction(id: String) -> FactionState:
    # TODO (Economy & Faction AI Agent): Implement lookup.
    return null

func get_all_factions() -> Array[FactionState]:
    # TODO (Economy & Faction AI Agent): Return all faction states.
    return []

func get_big4_factions() -> Array[FactionState]:
    # TODO (Economy & Faction AI Agent): Return Big 4 faction states.
    return []

func get_neutral_factions() -> Array[FactionState]:
    # TODO (Economy & Faction AI Agent): Return neutral faction states (Accenture).
    return []


scripts/core/UnitRegistry.gd:

class_name UnitRegistry, extends Node.

func register_unit(unit: Node, faction_id: String, unit_type: String) -> void:
    # TODO (Units & Combat Agent): Track unit by faction and type.
    pass

func unregister_unit(unit: Node) -> void:
    # TODO (Units & Combat Agent): Remove unit from tracking.
    pass

func get_units_near_position(faction_id: String, position: Vector2, radius: float) -> Array[Node]:
    # TODO (Units & Combat Agent): Return units near a position.
    return []

4.4.2 World

scripts/world/WorldController.gd:

class_name WorldController, extends Node2D.

func get_spawn_point_for_faction(faction_id: String) -> Vector2:
    # TODO (World & Map Agent): Return base/HQ spawn point for faction.
    return Vector2.ZERO

func get_lane_path(from_faction_id: String, to_faction_id: String) -> Array[Vector2]:
    # TODO (World & Map Agent): Return lane waypoints between factions.
    return []


scripts/world/FactionBase.gd:

Manage HQ and tower slots for a faction.

Expose methods to:

Set faction,

Retrieve HQ node,

Retrieve tower nodes.

Add TODO for World & Map Agent and Units & Combat Agent.

scripts/world/NeutralZone.gd:

Manage central neutral zone and neutral spawn points.

Add TODO for World & Map Agent to define spawn locations and for Units & Combat Agent to spawn NeutralMobs.

scripts/world/Lane.gd:

Simple data script or Resource containing:

var from_faction_id: String
var to_faction_id: String
var points: Array[Vector2] = []

4.4.3 Units

For each: Analyst.gd, Auditor.gd, NeutralMob.gd, Projectile.gd, Tower.gd, HQ.gd:

Extend appropriate base type (e.g., CharacterBody2D, Node2D, Area2D).

Define shared fields:

var hp: float = 0.0
var max_hp: float = 0.0
var move_speed: float = 0.0
var attack_damage: float = 0.0
var attack_range: float = 0.0
var attack_cooldown: float = 0.0
var faction_id: String = ""
var is_neutral: bool = false


Methods:

func _ready() -> void:
    # TODO (Units & Combat Agent): Initialize unit.
    pass

func _process(delta: float) -> void:
    # TODO (Units & Combat Agent): Implement behavior.
    pass

func take_damage(amount: float) -> void:
    # TODO (Units & Combat Agent): Apply damage and handle death.
    pass


For HQ.gd:

Add TODO to notify GameManager on death.

4.4.4 Economy & AI

scripts/economy/EconomySystem.gd:

class_name EconomySystem, extends Node.

signal credits_changed(faction_id: String, new_amount: float)

func add_income(delta: float) -> void:
    # TODO (Economy & Faction AI Agent): Add passive income for Big 4.
    pass

func add_credits(faction_id: String, amount: float) -> void:
    # TODO (Economy & Faction AI Agent): Adjust credits and emit signal.
    pass

func can_afford(faction_id: String, cost: float) -> bool:
    # TODO (Economy & Faction AI Agent): Check if faction credits >= cost.
    return false

func spend_credits(faction_id: String, cost: float) -> bool:
    # TODO (Economy & Faction AI Agent): Deduct credits if possible, return success.
    return false


scripts/ai/FactionAIController.gd:

class_name FactionAIController, extends Node.

func process_ai(delta: float) -> void:
    # TODO (Economy & Faction AI Agent): Implement AI decision loop for non-player factions.
    pass

func request_spawn_analysts(faction_id: String, target_faction_id: String, count: int) -> void:
    # TODO (Economy & Faction AI Agent + Units & Combat Agent): Hook into Analyst spawning.
    pass

func request_upgrade_tower(faction_id: String) -> void:
    # TODO (Economy & Faction AI Agent + World & Map Agent): Choose a tower slot to upgrade.
    pass

func request_deploy_hero(faction_id: String) -> void:
    # TODO (Economy & Faction AI Agent + Units & Combat Agent): Spawn or respawn hero.
    pass

4.4.5 UI

scripts/ui/HUDController.gd:

class_name HUDController, extends Control.

Stub methods to:

Subscribe to EconomySystem.credits_changed,

Update HP and credit displays,

React to GameManager.game_over.

scripts/ui/InputController.gd:

class_name InputController, extends Node or Node2D.

Stub handling of:

Tap/click to move hero,

Tap/click to select target,

Attack button,

Economy UI actions.

scripts/ui/FactionSelectController.gd:

class_name FactionSelectController, extends Control.

signal faction_selected(faction_id: String)

func _on_faction_button_pressed(faction_id: String) -> void:
    # TODO (UI & Input Agent): Emit signal and trigger GameManager.start_game.
    pass

4.4.6 Config

scripts/config/FactionsConfig.gd:

Implement constants and FACTION_DATA exactly as described in design.md.

scripts/config/BalanceConfig.gd:

Implement numeric constants from design.md (starting credits, costs, rewards, etc.).

5. Test Harness and Initial Tests
5.1 TestRunner

tests/TestRunner.tscn:

Root: Node named TestRunner.

Attach tests/TestRunner.gd.

tests/TestRunner.gd:

Implement:

func _ready() -> void:
    run_all_tests()

func run_all_tests() -> bool:
    # TODO (Tests & Docs Agent): Implement test discovery.
    # For now, manually call each test script.
    return true


For now, you may:

Manually instantiate and run functions from the specific test scripts you create.

5.2 Unit Tests

Create:

tests/unit/test_faction_config.gd:

Load FactionsConfig.

Assert:

FACTION_KPMG, FACTION_PWC, FACTION_EY, FACTION_DELOITTE, FACTION_ACCENTURE constants exist.

Each appears in FACTION_DATA with a name and color.

tests/unit/test_balance_config.gd:

Load BalanceConfig.

Assert that key constants (e.g., COST_ANALYST_BATCH, COST_AUDITOR_HERO, COST_TOWER_UPGRADE_L1_TO_L2) exist and are > 0.

tests/unit/test_faction_state.gd:

Instantiate FactionState.

Set properties.

Assert they store values as expected.

tests/unit/test_economy_system.gd:

Instantiate EconomySystem.

Test a minimal scenario:

Call add_credits and confirm some internal value changed appropriately.

Test can_afford and spend_credits with simple sample data (even if stubbed).

5.3 Integration Test

tests/integration/test_basic_bootstrap.gd:

Instantiate GameManager.

Call:

$GameManager.start_game("KPMG")


Assert:

No runtime errors occur,

state is set to some non‑invalid value (e.g., GameState.RUNNING or at least not crashing).

You may need to stub logic lightly in GameManager.start_game to keep this passing without fully wiring systems.

6. Style and TODO Conventions

Use GDScript 2.0 syntax.

Use clear and descriptive names.

For every stubbed behavior, add a # TODO comment with the agent role:

World & Map Agent,

Units & Combat Agent,

Economy & Faction AI Agent,

UI & Input Agent,

Tests & Docs Agent.

Example:

func add_income(delta: float) -> void:
    # TODO (Economy & Faction AI Agent): Implement passive income for non-neutral factions.
    pass

7. Final Output (for this run)

After you complete all tasks:

Ensure:

All scripts compile in Godot 4,

Scenes reference the correct scripts,

Tests at least run without crashing.

In your final response to me (the human), provide a concise summary:

List of created/modified files,

Key classes and methods defined as public contracts,

How to run tests (e.g., “run TestRunner.tscn in Godot”).

Do NOT implement full gameplay or AI.
Your role is to produce a clean, well‑structured, test‑backed skeleton that future agents (World & Map, Units & Combat, Economy & Faction AI, UI & Input, Tests & Docs) can extend in parallel.

::contentReference[oaicite:0]{index=0}