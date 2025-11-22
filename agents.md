
```markdown
# agents.md — AI Coding Agents, Roles, and Coordination

Version: 0.3  
Status: Authoritative multi‑agent coordination spec for AIAgentWars

This document defines how multiple AI coding agents work on **AIAgentWars** concurrently without stepping on each other.

Every coding agent MUST read:

- `design.md`
- `agents.md`

before making changes.

---

## 1. Global Rules for All Agents

### 1.1 Read Before Writing

Before any modifications:

1. Read `design.md` completely.
2. Read `agents.md` completely.

If **code** and **docs** disagree, the docs are correct and the code must be updated.

### 1.2 Respect Ownership Boundaries

Each agent has a **domain** (directories and scripts) where it is allowed to write.

- Agents MAY read any file.
- Agents SHOULD only write in their domain(s).
- Agents MUST NOT modify files outside their domain except when:
  - Explicitly instructed, or
  - Performing agreed shared infra changes (e.g., via Tests & Docs Agent).

Ownership is defined in Section 3.

### 1.3 Contracts Are APIs

The following are treated as **public APIs**:

- Class names:

  - `GameManager`, `FactionState`, `FactionRegistry`, `UnitRegistry`,
  - `WorldController`, `FactionBase`, `NeutralZone`, `Lane`,
  - `Analyst`, `Auditor`, `NeutralMob`, `Projectile`, `Tower`, `HQ`,
  - `EconomySystem`, `FactionAIController`,
  - `HUDController`, `InputController`, `FactionSelectController`,
  - `FactionsConfig`, `BalanceConfig`.

- Public method signatures:

  - As described in `design.md` (e.g., `add_income`, `get_lane_path`, `process_ai`).

- Signals:

  - E.g., `GameManager.game_over`, `EconomySystem.credits_changed`, `FactionSelectController.faction_selected`.

- Global constants:

  - Faction IDs, arrays like `BIG4_IDS`, `NEUTRAL_IDS`.

Agents MUST NOT change public contracts lightly.

If a change is absolutely necessary:

1. Update `design.md` to reflect the new contract.
2. Update `agents.md` if ownership/usage changes.
3. Update all tests referencing the old contract.
4. Add a brief comment at the top of modified files summarizing the change.

### 1.4 Tests Are Mandatory

- Every non‑trivial feature or bugfix must be accompanied by tests.
- Tests live under:

  - `tests/unit/` for unit tests,
  - `tests/integration/` for integration tests.

- No agent should leave failing tests.

If an agent cannot complete a change without breaking tests:

- Prefer to **avoid** committing that change.
- At minimum, leave very explicit TODOs indicating which tests fail and why.

### 1.5 Small, Coherent Changes

Agents should:

- Implement small, coherent changesets:

  - One feature or subsystem at a time,
  - Or one clearly defined refactor,
  - Or test/documentation improvements.

- Leave the project in:

  - A loadable state in Godot,
  - A test‑passing (or clearly documented) state.

### 1.6 TODOs and Handoffs

If work is left incomplete:

- Add `# TODO` comments with:

  - The agent role name,
  - A short description of the remaining work.

Example:

```gdscript
# TODO (Units & Combat Agent): Implement lane-following behavior for Analysts using WorldController.
This is the handoff mechanism between agents.

1.7 Refactors and Renames

Refactors (renaming classes/files, restructuring directories) are disruptive.

Do NOT mix large refactors into feature work.

Refactors should be separate tasks, preferably by the Tests & Docs Agent (or a dedicated refactor run).

Refactors must:

Update code,

Update tests,

Update design.md and agents.md if needed.

2. Phases and Concurrency Model

We use two phases:

Bootstrap Phase — single Bootstrap Agent sets up scaffolding.

Feature Phase — multiple agents run concurrently on separate domains.

2.1 Bootstrap Phase

Bootstrap Agent:

Runs exactly once (or after an intentional reset).

Uses Prompt.md as its instructions.

Responsibilities:

Create base Godot 4 project (project.godot).

Create directory structure:

scenes/..., scripts/..., tests/....

Create stub scenes:

Main.tscn, Game.tscn, World.tscn,

FactionBase.tscn, NeutralZone.tscn,

Analyst.tscn, Auditor.tscn, NeutralMob.tscn, Projectile.tscn,

HUD.tscn, MobileControls.tscn, FactionSelect.tscn.

Create stub scripts with public contracts:

All scripts listed in design.md (core/world/units/economy/ai/ui/config).

Create test harness and basic tests:

TestRunner.tscn, TestRunner.gd,

test_faction_config.gd, test_balance_config.gd, test_faction_state.gd, test_economy_system.gd,

test_basic_bootstrap.gd.

Non‑responsibilities:

NO full gameplay logic,

NO deep AI,

NO balancing.

After Bootstrap Phase:

Project should load in Godot,

Scenes and scripts exist and compile,

Basic tests run without crashing.

2.2 Feature Phase

After bootstrap, we allow up to four concurrent feature agents:

World & Map Agent

Units & Combat Agent

Economy & Faction AI Agent

UI & Input Agent

Plus one Tests & Docs Agent that runs periodically (not concurrent with heavy refactors).

Recommended loop:

Run Bootstrap Agent once with Prompt.md.

Run up to four feature agents in parallel on their domains.

Run Tests & Docs Agent to fix tests and sync docs.

Repeat 2–3 as needed.

Running more than four feature agents at once is not recommended.

3. Agent Roles and Domains
3.1 World & Map Agent

Domain:

scenes/world/

scripts/world/

Responsibilities:

Implement map layout, bases, NeutralZone, and lanes.

Specific tasks:

World.tscn / WorldController.gd:

Manage map TileMaps (ground, roads, buildings).

Instantiate and position:

Four FactionBase instances (Big 4),

One NeutralZone instance (Accenture).

Implement:

func get_spawn_point_for_faction(faction_id: String) -> Vector2
func get_lane_path(from_faction_id: String, to_faction_id: String) -> Array[Vector2]


Store lane definitions via Lane resources or nodes.

FactionBase.tscn / FactionBase.gd:

Represent base:

HQ child with HQ.gd script,

Tower slot nodes/markers.

Expose base’s HQ and tower slots for other systems.

Link base to a FactionState.

NeutralZone.tscn / NeutralZone.gd:

Represent the central Accenture zone.

Provide spawn points for NeutralMobs.

Provide API for initial neutral spawn.

Lane.gd:

Data structure for lanes:

var from_faction_id: String
var to_faction_id: String
var points: Array[Vector2]


Must NOT:

Implement unit combat logic.

Implement AI decisions or economy rules.

Implement UI or direct input handling.

3.2 Units & Combat Agent

Domain:

scenes/units/

scripts/units/

Main logic in scripts/core/UnitRegistry.gd

Responsibilities:

Implement unit behavior (Analysts, Auditors, NeutralMobs, Towers, HQs, Projectiles).

Implement movement, targeting, attack, damage, and death.

Specific tasks:

Shared patterns:

Define standard fields (hp, max_hp, attack_damage, etc.).

Implement take_damage and die behavior.

Analyst.gd / Analyst.tscn:

Move along lanes from WorldController.

State machine:

Moving along lane,

Attacking when enemies in range.

On death:

Notify EconomySystem and UnitRegistry.

Auditor.gd / Auditor.tscn:

Hero logic:

Player hero: respond to InputController commands.

AI heroes: follow high‑level commands (attack/defend).

Attack logic for ranged combat.

NeutralMob.gd / NeutralMob.tscn:

Idle/patrol in NeutralZone.

Aggro on non‑neutral units/HQs in radius.

On death:

Notify EconomySystem to award Accenture kill bonus.

Tower.gd:

Auto‑target nearest enemy in range.

Fire Projectiles at rate determined by level.

HQ.gd:

HP, damage handling.

On 0 HP:

Notify GameManager of faction elimination.

Projectile.gd / Projectile.tscn:

Move in direction or toward target.

Apply damage on collision and despawn.

UnitRegistry.gd:

Track live units by faction and type.

Implement:

func register_unit(unit: Node, faction_id: String, unit_type: String) -> void
func unregister_unit(unit: Node) -> void
func get_units_near_position(faction_id: String, position: Vector2, radius: float) -> Array[Node]


Must NOT:

Decide when to spawn units or upgrade towers (Economy & Faction AI domain).

Handle UI or input.

3.3 Economy & Faction AI Agent

Domain:

scripts/economy/

scripts/ai/

scripts/config/

May modify scripts/core/FactionState.gd and scripts/core/FactionRegistry.gd as needed.

Responsibilities:

Implement credits, income, and rewards.

Implement AI logic for non‑player Big 4 factions.

Maintain faction/balance configuration.

Specific tasks:

EconomySystem.gd:

Implement:

signal credits_changed(faction_id: String, new_amount: float)

func add_income(delta: float) -> void
func add_credits(faction_id: String, amount: float) -> void
func can_afford(faction_id: String, cost: float) -> bool
func spend_credits(faction_id: String, cost: float) -> bool


Use FactionRegistry to track credits and income.

FactionsConfig.gd:

Implement faction IDs and FACTION_DATA (Big 4 + Accenture).

Provide arrays BIG4_IDS and NEUTRAL_IDS.

BalanceConfig.gd:

Implement starting credits, income rates, costs, kill rewards, Accenture bonuses, hero cooldowns.

FactionState.gd / FactionRegistry.gd:

Build and maintain runtime faction states from config.

Respect APIs in design.md.

FactionAIController.gd:

Implement:

func process_ai(delta: float) -> void
func request_spawn_analysts(faction_id: String, target_faction_id: String, count: int) -> void
func request_upgrade_tower(faction_id: String) -> void
func request_deploy_hero(faction_id: String) -> void


For each non‑player Big 4 faction:

Choose target_faction_id,

Decide when to spawn analysts, upgrade towers, deploy hero.

Must NOT:

Implement low‑level unit behavior (movement/combat).

Implement UI or direct input mapping.

3.4 UI & Input Agent

Domain:

scenes/ui/

scripts/ui/

scripts/core/InputController.gd

May modify GameManager.gd for wiring.

Responsibilities:

Implement all user interface.

Map input to gameplay commands.

Specific tasks:

HUD.tscn / HUDController.gd:

Show:

Hero HP,

Player HQ HP,

Player credits,

Enemy HQ statuses,

Optional Accenture mob count.

Subscribe to signals:

EconomySystem.credits_changed,

HQ HP updates,

GameManager.game_over.

MobileControls.tscn:

Buttons:

Attack,

Spawn Analysts,

Deploy/Respawn Hero,

Upgrade Tower,

Target Faction selection (or open a target menu).

FactionSelect.tscn / FactionSelectController.gd:

UI to choose KPMG/PwC/EY/Deloitte.

On selection:

Emit faction_selected(faction_id),

Call GameManager.start_game.

InputController.gd:

Translate input (touch/mouse/keyboard) into:

Hero movement commands,

Target selection,

Attack commands,

Economy actions (via EconomySystem).

Must NOT:

Implement economic rules.

Implement AI logic.

Implement detailed combat logic.

3.5 Tests & Docs Agent

Domain:

tests/

design.md

agents.md

README.md

Optional future CHANGELOG.md

Responsibilities:

Ensure tests exist, run, and pass.

Keep documentation in sync with reality.

Perform controlled refactors.

Specific tasks:

Testing:

Add/maintain unit tests for new logic.

Add integration tests for key flows.

Enhance TestRunner.gd to discover and run tests automatically.

After feature agents run, execute tests and fix failing ones.

Documentation:

Update design.md when contracts/gameplay change.

Update agents.md when roles or domains change.

Keep README.md up to date with setup/usage instructions.

Optionally maintain CHANGELOG.md.

Refactors:

Coordinate any renames/moves of core classes/files.

Ensure code, tests, and docs all reflect the new structure.

Must NOT:

Introduce major new gameplay features.

Change contracts without updating docs and tests.

4. Workflow and Concurrency
4.1 Recommended Workflow

Bootstrap:

Run Bootstrap Agent once using Prompt.md.

Commit resulting structure.

Feature Phase (Concurrent):

Run up to four feature agents in parallel:

World & Map Agent,

Units & Combat Agent,

Economy & Faction AI Agent,

UI & Input Agent.

Each agent:

Stays within domain,

Adds tests for its features.

Validation Phase:

Run Tests & Docs Agent:

Run all tests,

Fix failures,

Reconcile any minor inconsistencies,

Update design.md / agents.md if contracts changed.

Repeat Feature/Validation phases until the game is feature‑complete.

4.2 Maximum Concurrent Agents

After Bootstrap:

Safely run up to four feature agents concurrently:

World & Map Agent

Units & Combat Agent

Economy & Faction AI Agent

UI & Input Agent

Then:

Run one Tests & Docs Agent to consolidate, validate, and document.

Running more than four feature agents at the same time is not recommended.

5. Summary

design.md defines what we’re building and the architecture.

agents.md defines who does what and how they coordinate.

Prompt.md defines the Bootstrap Agent prompt that sets up the skeleton.

All coding agents must:

Read design.md and agents.md,

Stay inside their domain,

Respect contracts as APIs,

Maintain tests,

Update docs when contracts or behavior change.

This is the foundation for multi‑agent, AI‑driven development of The Big 4: AI Agent Wars.