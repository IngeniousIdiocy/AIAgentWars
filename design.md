# The Big 4: AI Agent Wars — Design (design.md)

Version: 0.3  
Status: Authoritative design and architecture spec for AIAgentWars

---

## 0. Vision

### 0.1 High Concept

**Title:** The Big 4: AI Agent Wars  

A 2D isometric, web‑playable strategy/action game built with **Godot 4** and **GDScript**, explicitly designed to be developed by **multiple AI coding agents in parallel**.

You pick one of the Big 4:

- **KPMG**
- **PwC**
- **EY**
- **Deloitte**

The remaining Big 4 factions are controlled by AI.

A fifth, neutral faction sits in the middle:

- **Accenture** — central “trash mob” zone of **finite neutral enemies** (“trash for cash”).  
  They do not compete to win, but killing them grants **bonus credits**.  
  Once they’re dead, they’re gone.

Each Big 4 faction:

- Has an **HQ** with **fixed tower slots** around it (no free‑form base building),
- Generates **income** over time,
- Can spend income on:
  - **Upgrading towers** (fixed positions only),
  - **Spawning Analyst drones** (cheap autonomous attackers),
  - **Deploying an Auditor hero** (expensive hero unit; one active per faction).

Player tension:

- **Offense** — push specific rival HQs with analysts + hero.
- **Defense** — tower upgrades and defensive analysts.
- **Greed** — divert to central Accenture zone to farm limited trash mobs for extra credits.

**Win condition:** your chosen Big 4 faction is the last HQ standing.  
**Lose condition:** your HQ is destroyed.

The codebase must be:

- Browser‑friendly (HTML5 / WebAssembly),
- AI‑friendly (clear module boundaries, contracts, tests),
- Structured for **concurrent multi‑agent development** with minimal merge conflicts.

---

## 1. Tech Stack & Project Layout

### 1.1 Tech

- Engine: **Godot 4.x**
- Language: **GDScript** (no C#, must work with Web export)
- Rendering: **2D isometric**
- Targets:
  - Primary: **HTML5 / WebAssembly** (desktop + mobile browsers)
  - Secondary: desktop (Windows / macOS / Linux) if trivial

### 1.2 Repository Layout (Target)

All paths are relative to repo root:

```text
AIAgentWars/
  assets_cc0/              # CC0/public domain assets (read‑only by code)
  scenes/
    main/
      Main.tscn            # Entry scene, holds GameManager
      Game.tscn            # In‑game scene: World + HUD/UI
    world/
      World.tscn           # Map composition, bases, neutral zone
      FactionBase.tscn     # Generic base: HQ + tower slots
      NeutralZone.tscn     # Central Accenture zone with neutral spawns
    units/
      Analyst.tscn
      Auditor.tscn
      NeutralMob.tscn
      Projectile.tscn
    ui/
      HUD.tscn
      MobileControls.tscn
      FactionSelect.tscn
  scripts/
    core/
      GameManager.gd
      FactionState.gd
      FactionRegistry.gd
      UnitRegistry.gd
    world/
      WorldController.gd
      FactionBase.gd
      NeutralZone.gd
      Lane.gd
    units/
      Analyst.gd
      Auditor.gd
      NeutralMob.gd
      Projectile.gd
      Tower.gd
      HQ.gd
    economy/
      EconomySystem.gd
    ai/
      FactionAIController.gd
    ui/
      HUDController.gd
      InputController.gd
      FactionSelectController.gd
    config/
      FactionsConfig.gd
      BalanceConfig.gd
  tests/
    TestRunner.tscn
    TestRunner.gd
    unit/
      test_faction_config.gd
      test_balance_config.gd
      test_faction_state.gd
      test_economy_system.gd
    integration/
      test_basic_bootstrap.gd
      test_game_flow_minimal.gd
  design.md
  agents.md
  Prompt.md
  project.godot
  README.md
  LICENSE

assets_cc0/:
	•	Contains CC0/public‑domain art assets.
	•	Must be treated as read‑only by scripts.
	•	Safe to keep in a public GitHub repo.

2. Gameplay Design

2.1 Factions

Big 4 Factions (Player‑Selectable)
	•	KPMG
	•	PwC
	•	EY
	•	Deloitte

Each Big 4 faction has:
	•	An HQ (high‑HP building).
	•	A fixed number of tower slots around the HQ:
	•	Towers can be upgraded only; cannot be moved, sold, or added.
	•	An economy:
	•	credits (current bank),
	•	income_rate (credits per second),
	•	kill rewards,
	•	target_faction_id (which other Big 4 they’re focusing).
	•	Units:
	•	Analyst drones (cheap, autonomous combat units),
	•	Auditor hero (expensive, powerful hero; 1 active at a time).

Neutral Faction
	•	Accenture — central neutral faction.

Representation:
	•	Central NeutralZone on the map.
	•	A fixed pool of NeutralMob trash mobs:
	•	Spawned once at game start.
	•	Attack any nearby non‑neutral units/HQs.
	•	Grant bonus credits when killed.
	•	Do not respawn; finite resource.

Accenture cannot win or lose. They are shared hazard and economic opportunity.

2.2 Objectives
	•	Win: Your chosen Big 4 faction is the last HQ standing.
	•	Lose: Your HQ’s HP reaches 0.

Later variants (time/score modes) are possible but out of scope for v1.

2.3 Player Loop

One run:
	1.	Player selects a Big 4 faction on the FactionSelect screen.
	2.	Game spawns four Big 4 bases (HQ + towers) and central Accenture NeutralZone with NeutralMobs.
	3.	Each Big 4 faction gains passive income over time.
	4.	Player:
	•	Controls their Auditor hero:
	•	Tap/click to move hero.
	•	Tap/click enemy to set target.
	•	Attack button to fire.
	•	Spends credits on:
	•	Analyst batches,
	•	Hero deployment/respawn,
	•	Tower upgrades.
	•	Chooses a target Big 4 faction; new analysts push along lanes toward that HQ.
	•	Decides when to divert hero and analysts to central Accenture zone to kill NeutralMobs for bonus credits.
	5.	AI‑controlled Big 4 factions:
	•	Choose targets,
	•	Spend credits on analysts, towers, heroes,
	•	Use simple heuristics.
	6.	HQ destruction eliminates that faction.
	7.	Game ends when:
	•	Player HQ dies → DEFEAT,
	•	All other Big 4 HQs die → VICTORY.

3. World & Map Design
3.1 Layout

Single isometric map (v1):

Four Big 4 bases, approximately in corners:

NW, NE, SE, SW.

Central NeutralZone:

Accenture “campus” visuals,

NeutralMob spawn points.

3.2 Lanes

Movement is lane‑based:

Pre‑defined lanes connect:

Big 4 HQ ↔ NeutralZone,

Big 4 HQ ↔ other Big 4 HQs (direct or via center).

Represented as:

Lane resources or data:

from_faction_id: String,

to_faction_id: String,

points: Array[Vector2] world coordinates.

WorldController provides:

func get_spawn_point_for_faction(faction_id: String) -> Vector2
func get_lane_path(from_faction_id: String, to_faction_id: String) -> Array[Vector2]


Analysts follow lane paths. Auditors may also use lanes as their default movement paths, with some flexibility.

3.3 Bases & Towers

FactionBase.tscn:

Root: Node2D named FactionBase.

Child nodes:

HQ (HQ.gd) — static building with HP.

Tower slot markers (e.g., Node2D children or Position2Ds).

Responsibilities:

Attach to a specific faction (faction_id),

Provide access to its HQ and towers to other systems.

Towers (Tower.gd):

Static structure in tower slots.

Level 1–3 upgrades:

Higher damage,

Higher range,

Possibly higher fire rate.

They auto‑target enemies and fire Projectile instances.

3.4 Neutral Zone

NeutralZone.tscn:

Root: Node2D named NeutralZone.

Contains:

Spawn points for NeutralMobs,

Visual representation of Accenture’s presence.

At game start:

A fixed number of NeutralMob units spawn.

No respawns after death.

4. Units & Combat
4.1 Shared Unit Properties

All combat units (Analyst, Auditor, NeutralMob) share:

hp: float

max_hp: float

move_speed: float

attack_damage: float

attack_range: float

attack_cooldown: float

faction_id: String

is_neutral: bool

Each unit script must at least implement:

func _ready() -> void
func _process(delta: float) -> void
func take_damage(amount: float) -> void


Common pattern:

take_damage reduces hp, calls die() on <= 0.

die() notifies relevant systems (EconomySystem, GameManager, UnitRegistry) and frees the node.

4.2 Analyst Drones

Role:

Cheap, expendable attackers.

Behavior:

Spawn at owning faction HQ using spawn point from WorldController.

At spawn, set:

faction_id,

target_faction_id,

Current lane path via get_lane_path(faction_id, target_faction_id).

Movement:

Follow lane waypoints to target HQ.

Path interruption if enemies appear nearby.

Combat:

If enemy (unit/tower/HQ) in range:

Stop or adjust movement,

Attack target until:

Target dies or leaves range.

Death:

Notify EconomySystem of killer faction and reward.

Notify UnitRegistry to unregister.

No direct per‑unit control; only spawn and target assignment.

4.3 Auditor Heroes

Role:

High‑impact hero units, one active per faction.

Player hero:

Controlled by InputController (touch/mouse/keyboard).

Behavior:

Move to tapped/clicked positions (lane‑aware pathfinding).

Attack when Attack button pressed.

AI heroes:

Controlled by FactionAIController:

Move toward target HQ,

Respond to threats near own HQ when necessary.

Combat:

Ranged attack.

Higher HP, damage, and range than Analysts.

Possible stretch goals (later): secondary ability or AoE.

Death:

Triggers respawn cooldown and cost (COST_AUDITOR_HERO, AUDITOR_RESPAWN_COOLDOWN).

Only one hero per faction at a time.

4.4 Neutral Mobs (Accenture)

Role:

Central neutral enemies; limited and valuable to kill.

Behavior:

Spawn in NeutralZone at game start.

Idle or patrol within NeutralZone.

Aggro on any non‑neutral unit/HQ entering detection radius.

Attack nearest non‑neutral in range.

On death:

Award killer faction KILL_REWARD_ACCENTURE_MOB.

Do not respawn; finite pool.

4.5 Towers & Projectiles

Towers (Tower.gd):

Owned by faction_id.

Have level, damage, range, fire rate.

Logic:

Periodically find nearest enemy unit within range.

Fire Projectile at target if cooldown ready.

Projectiles (Projectile.gd):

Root: Area2D or Node2D.

Behavior:

Move at constant speed in a direction.

On collision with enemy:

Call take_damage on hit unit/HQ,

Despawn.

HQ (HQ.gd):

HP container for base.

On hp <= 0:

Notify GameManager of HQ destruction and faction elimination.

5. Economy & Faction State
5.1 FactionsConfig

scripts/config/FactionsConfig.gd defines faction IDs and metadata:

const FACTION_KPMG      = "KPMG"
const FACTION_PWC       = "PWC"
const FACTION_EY        = "EY"
const FACTION_DELOITTE  = "DELOITTE"
const FACTION_ACCENTURE = "ACCENTURE"  # neutral

const BIG4_IDS = [FACTION_KPMG, FACTION_PWC, FACTION_EY, FACTION_DELOITTE]
const NEUTRAL_IDS = [FACTION_ACCENTURE]

var FACTION_DATA := {
    FACTION_KPMG: {
        "name": "KPMG",
        "color": Color(0.0, 0.3, 0.7),
        "is_neutral": false,
    },
    FACTION_PWC: {
        "name": "PwC",
        "color": Color(0.9, 0.4, 0.1),
        "is_neutral": false,
    },
    FACTION_EY: {
        "name": "EY",
        "color": Color(0.9, 0.8, 0.1),
        "is_neutral": false,
    },
    FACTION_DELOITTE: {
        "name": "Deloitte",
        "color": Color(0.1, 0.7, 0.3),
        "is_neutral": false,
    },
    FACTION_ACCENTURE: {
        "name": "Accenture",
        "color": Color(0.7, 0.2, 0.7),
        "is_neutral": true,
    },
}

5.2 BalanceConfig

scripts/config/BalanceConfig.gd holds tunable numbers:

const STARTING_CREDITS := 100.0
const PASSIVE_INCOME_PER_SECOND := 5.0

const COST_ANALYST_BATCH := 10.0
const ANALYSTS_PER_BATCH := 3

const COST_AUDITOR_HERO := 50.0
const AUDITOR_RESPAWN_COOLDOWN := 10.0

const COST_TOWER_UPGRADE_L1_TO_L2 := 20.0
const COST_TOWER_UPGRADE_L2_TO_L3 := 40.0

const KILL_REWARD_UNIT := 2.0
const KILL_REWARD_TOWER := 10.0
const KILL_REWARD_HQ := 50.0
const KILL_REWARD_ACCENTURE_MOB := 8.0


Values are initial guesses; can be tuned later with tests and play.

5.3 FactionState & FactionRegistry

FactionState.gd:

class_name FactionState
extends RefCounted

var id: String
var name: String
var color: Color
var is_neutral: bool
var is_player: bool = false

var credits: float = 0.0
var income_rate: float = 0.0
var hq: Node = null
var towers: Array = []
var hero: Node = null
var target_faction_id: String = ""


FactionRegistry.gd:

Creates and manages all FactionState instances.

Public methods:

class_name FactionRegistry
extends Node

func get_faction(id: String) -> FactionState:
    pass

func get_all_factions() -> Array[FactionState]:
    return []

func get_big4_factions() -> Array[FactionState]:
    return []

func get_neutral_factions() -> Array[FactionState]:
    return []


Implementation is provided by the Economy & Faction AI Agent.

5.4 EconomySystem

EconomySystem.gd manages credits:

class_name EconomySystem
extends Node

signal credits_changed(faction_id: String, new_amount: float)

func add_income(delta: float) -> void:
    pass

func add_credits(faction_id: String, amount: float) -> void:
    pass

func can_afford(faction_id: String, cost: float) -> bool:
    return false

func spend_credits(faction_id: String, cost: float) -> bool:
    return false


Responsibilities:

Add passive income each tick (Big 4 only).

Add credits on kills (units, towers, HQs, Accenture mobs).

Handle spend logic (can_afford, spend_credits).

Emit credits_changed for UI updates.

6. Faction AI (Non‑Player Big 4)

FactionAIController.gd controls non‑player Big 4 factions.

6.1 Target Selection

Heuristics:

Prefer to target the player faction if:

Player recently damaged this HQ, or

Player is strongest (HQ HP, credits, remaining HQs).

Otherwise:

Target the strongest remaining non‑neutral Big 4.

Accenture is not chosen as main target_faction_id, but neutral mobs can be attacked opportunistically near lanes or HQs.

6.2 Spending Decisions

On fixed intervals (e.g., every 1–3 seconds):

Evaluate:

HQ HP ratio,

Number of enemy units near HQ,

Current credits,

Hero availability / alive status,

Tower levels and counts.

Decision order (example):

If HQ under heavy threat and hero not active and credits ≥ hero cost:

Deploy hero.

Else if HQ HP is low or many enemies near base and any tower below max level and credits ≥ upgrade cost:

Upgrade lowest‑level tower.

Else if credits ≥ analyst batch cost:

Spawn analysts toward target_faction_id.

Occasionally (future extension) and if base is safe and Accenture mobs remain:

Use hero to farm a few Accenture mobs.

Interaction with world:

func request_spawn_analysts(faction_id: String, target_faction_id: String, count: int) -> void
func request_upgrade_tower(faction_id: String) -> void
func request_deploy_hero(faction_id: String) -> void


Implementation is shared between Economy & Faction AI Agent and World & Units agents via these request APIs.

7. Player Controls & UI
7.1 Input Model

Mobile (primary):

Tap ground:

Move hero to tapped position (using lane‑aware pathfinding if possible).

Tap enemy:

Set hero’s current target.

Attack button:

Fire at current target if in range, otherwise at nearest enemy in range.

Buttons:

Spawn Analysts,

Deploy/Respawn Auditor,

Upgrade Tower,

Change target faction (open panel or cycle).

Desktop (secondary):

Mouse click as tap.

Optional keys:

WASD or arrow keys for movement,

Space or left mouse to attack,

Number keys / hotkeys for spend actions.

7.2 UI Scenes

HUD.tscn / HUDController.gd:

Displays:

Player HQ HP,

Hero HP,

Player credits,

Simple indicators for enemy HQ health,

Optional counter of remaining Accenture mobs.

MobileControls.tscn:

Contains on‑screen buttons for:

Attack,

Spawn Analysts,

Deploy/Respawn Hero,

Upgrade Tower,

Target Faction.

FactionSelect.tscn / FactionSelectController.gd:

Allows choosing:

KPMG, PwC, EY, Deloitte.

Emits faction_selected(faction_id) and calls GameManager.start_game.

InputController.gd:

Converts raw input (touch, mouse, keys) into:

Move commands for hero,

Target selection,

Attack requests,

Economy UI actions (e.g., calling EconomySystem to spend credits).

8. Core Runtime Flow

Game starts with Main.tscn:

Root node has GameManager script.

GameManager._ready():

Loads/instantiates FactionSelect.tscn.

Waits for player to choose faction.

On faction selection:

GameManager.start_game(player_faction_id):

Initializes FactionRegistry from FactionsConfig.

Marks chosen faction as player (is_player = true).

Instantiates World.tscn; places FactionBase instances for each Big 4 faction and NeutralZone.

Spawns initial NeutralMobs in NeutralZone (finite).

Instantiates HUD.tscn and hooks to EconomySystem and GameManager.

Instantiates EconomySystem, FactionAIController, UnitRegistry, etc.

Sets game state to RUNNING.

Each frame (_process(delta)):

GameManager:

Calls EconomySystem.add_income(delta),

Calls FactionAIController.process_ai(delta) for AI factions,

Lets unit scripts handle movement/combat via their own _process methods,

Checks HQ HPs to see if any faction is eliminated,

Triggers game_over when conditions met.

On unit/HQ deaths:

Unit/HQ script notifies GameManager and EconomySystem.

EconomySystem uses BalanceConfig to award credits.

If HQ destroyed:

Remove that faction from active Big 4 list.

If player HQ destroyed → defeat.

If all enemy HQs destroyed → victory.

On game over:

GameManager emits game_over(winner_faction_id).

HUD displays end state (basic v1: simple win/lose message).

9. Testing & Quality
9.1 Test Infrastructure

tests/TestRunner.tscn:

Simple scene with root node and TestRunner.gd.

TestRunner.gd:

On _ready():

Call run_all_tests().

run_all_tests():

For now: can directly call specific test scripts.

Later: Tests & Docs Agent implements discovery of tests in tests/unit and tests/integration.

9.2 Initial Tests

Unit tests:

tests/unit/test_faction_config.gd:

Asserts presence of Big 4 + Accenture IDs in FactionsConfig.

Asserts each has name and color, and is_neutral flag.

tests/unit/test_balance_config.gd:

Asserts main constants exist and are > 0.

tests/unit/test_faction_state.gd:

Instantiates FactionState, sets fields, validates stored values.

tests/unit/test_economy_system.gd:

Instantiates EconomySystem.

Tests add_credits, can_afford, spend_credits with simple values.

Integration tests:

tests/integration/test_basic_bootstrap.gd:

Instantiates GameManager.

Calls start_game with a valid faction ID.

Asserts no crash and sensible state (e.g., state not invalid).

tests/integration/test_game_flow_minimal.gd:

Simulates a few frames with simplified logic:

Income increases credits.

No runtime errors.

9.3 Testing Rules

Any new public API or significant behavior change must be covered by tests.

Public contract changes must update tests and docs in the same change.

All tests must pass before merging.

10. Multi‑Agent Development

A companion document, agents.md, defines:

Agent roles and domains,

Ownership of directories,

Number of concurrent agents and their responsibilities.

All coding agents must read design.md and agents.md before editing code.

This file is the canonical design and architecture spec for AIAgentWars.
